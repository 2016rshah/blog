% The Birth of Heckle
% Rushi Shah
% 26 July 2016

#The Birth of Heckle

So I've been making a static site generator in Haskell to handle my own blog and hopefully help some other kindred souls as well, yeah? And it started out as a static site generator for LaTeX blog posts, and it was called BlaTeX. (Clever, right?). Well I decided the other day to bite the bullet and add support to Markdown. I know, I know, I sold out, etc. etc. But the fact of the matter is that some people like LaTeX and some people like Markdown, and some people probably like both so there's no reason to discriminate. 

Plus, it wasn't even that difficult to go ahead and add in that support, and I'm going to walk you through some of the fancy changes it took to support both elegantly. 

#Algebraic Data Types

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

Both Post constructors include the abstract syntax trees (ASTs) for their respective files. Different parsers were used for the different posts: HaTeX for LaTeX and Pandoc for Markdown (more on this later). So perhaps we could also go ahead and add a record for the syntax tree in both options, right? Well not exactly. The thing is, the different libraries returned the AST in different types. You can't include the same record attribute in different constructors with different types (which kind of makes sense, if you think about it). Thus the records need to be named differently to remind you in the type system that they aren't the same thing and can't necessarily be used in the same way. I ended up with the following definition for the ADT for Posts:

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

#Type Annotations and Pattern Matching
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

#DRY - Don't Repeat Yourself

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

#Pandoc as a Markdown Parser

#IO Logic

#Etymology
Okay so let's talk about nomenclature for a moment. The original static site generator was for LaTeX, so it was aptly named BlaTeX. But after I added support for Markdown, it needed a new name. Since the original inspiration for the project was Jekyll, I toyed with various puns along the those lines, trying to integrate the H of Haskell somewhere in there. Hekyll was too boring, but it sounded like Heckle, which was the final name I alighted upon. Thus, Heckle was born. 

And I guess if you want to read into it a bit more, consider it this way. People heckle speakers they don't agree with. And blog posts are kind of like uncensored speeches in a way. So heckle could be something along those lines, I don't know. 

