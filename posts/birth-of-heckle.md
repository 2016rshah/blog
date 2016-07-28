% BlaTeX → Heckle
% Rushi Shah
% 26 July 2016

#BlaTeX -> Heckle

So I've been making a static site generator in Haskell to handle my own blog and hopefully help some other kindred souls as well, yeah? And it started out as a static site generator for LaTeX blog posts, and it was called BlaTeX. (Clever, right?). Well I decided the other day to bite the bullet and add support to Markdown. I know, I know, I sold out, etc. etc. But the fact of the matter is that some people like LaTeX and some people like Markdown, and some people probably like both so there's no reason to discriminate. 

Plus, it wasn't even that difficult to go ahead and add in that support, and I'm going to walk you through some of the fancy changes it took to support both elegantly. 

##Algebraic Data Types

Posts are gonna be LaTeX OR Markdown. In other words

```haskell
data Post = LaTeX {...} | Markdown {...}
```

But regardless of whether the post is LaTeX or Markdown, it should still have some consistent behavior (all posts should have titles, and dates, for example). So in order to do so, in the record syntax for both, just include the same record name and type for both:

```haskell
data Post 
	= LaTeX {
		filename :: String
		, title :: String
		, date :: DateTime
	}
	| Markdown {
		filename :: String
		, title :: String
		, date :: DateTime
	}
```

Then, given a Post, regardless of whether its LaTeX or Markdown, you can call title and get a string for that post. 

Both Post constructors include the abstract syntax trees (ASTs) for their respective files. Different parsers were used for the different posts: [HaTeX](https://github.com/Daniel-Diaz/HaTeX) for LaTeX and [Pandoc](http://pandoc.org/) for Markdown (more on this later). So perhaps we could also go ahead and add a record for the syntax tree in both options, right? Well not exactly. The thing is, the different libraries returned the AST in different types. You can't include the same record attribute in different constructors with different types (which kind of makes sense, if you think about it). Thus the records need to be named differently to remind you in the type system that they aren't the same thing and can't necessarily be used in the same way. I ended up with the following definition for the ADT for Posts:

```haskell
data Post 
  = LaTeX {
  fileName :: String
  , postTitle :: String
  , postDate :: DateTime
  , syntaxTree :: LaTeX
    }
  | MD {
  fileName :: String
  , postTitle :: String
  , postDate :: DateTime
  , pd :: Pandoc
    }
    deriving (Eq, Show)
```

(Later on, I removed HaTeX as a dependency and just used Pandoc to parse both LaTeX and Markdown. At that point, I was able to replace `syntaxTree :: LaTeX` with `pd :: Pandoc`.)

##Type Annotations and Pattern Matching
Based on this definition for the ADT, we can do some nice stuff with the type annotations and pattern matching. The type annotation doesn't need to concern itself with whether it is LaTeX or Markdown, as long as the function implementation is complete for both constructors. For example, the `postToHtml` function has the annotation `postToHtml :: Post -> Html`, which would tell someone looking through documentation everything they need to know. Then the implementation can just do what it needs to do based on what kind of post is pattern matched. 

```haskell
postToHtml :: Post -> Html
postToHtml p@(MD _ _ _ _) = li ! class_ "blog-post" $ do
        a ! class_ "post-link" ! href (stringValue ("posts/"++fileName p++".html")) $ toHtml (postTitle p)
        H.div ! class_ "post-date" $ toHtml ((displayDate . postDate) p)
postToHtml p@(LaTeX _ _ _ _) = li ! class_ "blog-post" $ do
        a ! class_ "post-link" ! href (stringValue ("posts/"++fileName p++".pdf")) $ toHtml (postTitle p)
        H.div ! class_ "post-date" $ toHtml ((displayDate . postDate) p)
```

##DRY - Don't Repeat Yourself

You might notice, though, that both of the patterns have a lot in common. In fact, they only have one disparity: the file extension that is used based on whether its a Markdown post or a LaTeX post. So there must be a way to avoid repeating ourselves so much, right? Yep, with our definition of the ADT as it stands, we can leverage the matching records like `filename p` and `postTitle p`:

```haskell
postToHtml :: Post -> Html
postToHtml p = li ! class_ "blog-post" $ do
        a ! class_ "post-link" ! href (stringValue ("posts/"++fileName p++ext)) $ toHtml (postTitle p)
        H.div ! class_ "post-date" $ toHtml ((displayDate . postDate) p)
        where
          ext = case p of
            (MD _ _ _ _) -> ".html"
            (LaTeX _ _ _ _) -> ".pdf"
```

The only part that changes based on the constructor is the file extension, which can be addressed with a quick case statement.

##Pandoc as a Markdown Parser

So originally, I was using [HaTeX](https://github.com/Daniel-Diaz/HaTeX) for parsing LaTeX. But when I added support for Markdown, I needed a Markdown parser to extract meta-data from the markdown posts. Thus, I added Pandoc as a dependency and was able to use that. 

The way that Pandoc works is it can read in a ton of file types, and convert them to native Pandoc representations as an abstract syntax tree. Then it can convert that native representation into a bunch of output file types. So I was able to pass in the markdown file, and then query the native pandoc document for information like the post title, etc. 

For example, given a Pandoc document (pd), you can find the DateTime object: `date = (getMeta docDate pd) >>= parseAbsoluteDate`

##Pandoc as a LaTeX Parser

As a result of using HaTeX for LaTeX and Pandoc for Markdown, I ended up with [the following code](https://github.com/2016rshah/heckle/blob/57cbdae11624654dbd6d97367932cb6bce691abf/Heckle.hs#L112) that I didn't like very much:

```haskell
createMDPost :: Show a => String -> Either a Pandoc -> Either String Post
createMDPost fn (Right pd) = 
  MD <$> pure fn <*> title <*> date <*> pure pd
  [...]

createLaTeXPost :: String -> Either ParseError LaTeX -> Either String Post
createLaTeXPost s (Right t) = 
  LaTeX <$> pure s <*> title <*> date <*> pure t
  [...]

fileToPost :: String -> IO (Either String Post)
fileToPost fn = 
  case splitOn "." fn of
    [fn, "pdf"] -> do

      latexFile <- fmap (parseLaTeXWith (ParserConf ["verbatim", "minted"]) . pack) (readFile ("posts/"++fn++".tex"))
      
      return (createLaTeXPost fn latexFile)
    [fn, "md"] -> do
      
      native <- fmap (readMarkdown def) (readFile ("posts/" ++ fn++".md"))
      
      return (createMDPost fn native)
    _ -> return (Left "Not a LaTeX or MD file")

```

It physically pained me to read my code and see how much of the same pattern was repeated, so I decided to port my LaTeX parsing over to Pandoc. That would allow me to have both constructors for the ADT mirror each other perfectly, and I would be able to parse the meta-information in the same exact way. 

##DRY - Don't Repeat Yourself

I ended up with the following code instead, which is significantly better:

```haskell
createPost :: Show a =>
     (String -> String -> DateTime -> Pandoc -> Post)
     -> String -> Either a Pandoc -> Either String Post
createPost _ _ (Left e) = Left (show e)
createPost t fn (Right pd) = 
  t <$> pure fn <*> title <*> date <*> pure pd
  [...]

fileToPost :: String -> IO (Either String Post)
fileToPost fn = 
  case splitOn "." fn of
    [fn, "pdf"] -> do
      latexFile <- fmap (readLaTeX def) (readFile ("posts/" ++ fn ++ ".tex"))
      return (createPost LaTeX fn latexFile)
    [fn, "md"] -> do
      native <- fmap (readMarkdown def) (readFile ("posts/" ++ fn ++".md"))
      return (createPost MD fn native)
    _ -> return (Left "Not a LaTeX or MD file")
```

I'm not happy with the type-signature for `createPost` because I think it could be a bit more specific. I knew the code would work but wasn't sure how to write the type signature so I had ghci derive a type signature for me and went from there. I just put in a comment explaining the type signature, but let me know if you have any suggestions. 

I was excited to remove an entire large dependency from my project, but I was sad I wouldn't be using [HaTeX](https://github.com/Daniel-Diaz/HaTeX) anymore because it is such a great package. I had even opened what had seemed like an impossible issue to fix, and the maintainers were able to solve it elegantly. HaTeX only really does one thing, but it does it extremely well. In comparison, Pandoc does a ton of things rather well, but not perfectly. I have a similarly minor issue with Pandoc's LaTeX parsing, but given that it has more than 400 open issues I don't want to distract the maintainers with this edge-case situation. 

<!-- #IO Logic -->

##The Birth of Heckle
Okay so let's talk about etymology for a moment. The original static site generator was for LaTeX, so it was aptly named BlaTeX. But after I added support for Markdown, it needed a new name. Since the original inspiration for the project was Jekyll, I toyed with various puns along the those lines, trying to integrate the H of Haskell somewhere in there. Hekyll was too boring, but it sounded like Heckle, which was the final name I alighted upon. Thus, Heckle was born. 

And I guess if you want to read into it a bit more, consider it this way. People heckle speakers they don't agree with. And blog posts are kind of like uncensored speeches in a way. So heckle could be something along those lines, I don't know. 

##Conclusion

There you have it, in the process of adding support for an entire new filetype I was blown away by the abstraction patterns of Haskell. The bulk of my logic for an entire static site compiler fits in [just about 100 lines of code](https://github.com/2016rshah/heckle/blob/87c074e5b0a1ba3f544909ffbd26576a8764183f/Heckle.hs#L33) thanks to the expressiveness of the language. There is still some stuff I want to work on to make Heckle even better, but hopefully the project is useful for an even larger audience now. 