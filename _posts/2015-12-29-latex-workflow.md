---
layout: post
title: Microsoft Word Will Probably Never Die
categories: ["latex", "bash"]
tags: ["latex", "bash"]

---

![XKCD](http://imgs.xkcd.com/comics/file_extensions.png)

When it came time to write college essays, I decided to write them all in LaTeX. Is LaTeX a bit overkill for something that normal people would use Microsoft Word for? Yeah probably. But 

 - I wanted to learn LaTeX anyways
 - My editor configuration is so much better than the un-customizable Microsoft Word
 - I can easily version-control my essays with git since `.tex` files aren't rich-text like `.docx` files

So I continued on my merry way and happily wrote my essays in LaTeX, created a git repository, used [Sublime Text's LaTeXTools](https://github.com/SublimeText/LaTeXTools) for the build system, etc. But the issue arose when I tried to send my essays to my family to look over. My sister wasn't a fan of the pdf format I had sent her, but she humored me. My parents, on the other hand, refused to look at anything other than Microsoft Word files. If I wanted to continue to use LaTex, I had to find a way to convert the files to word before sending them to my family. 

##Pandoc

The obvious answer was [Pandoc](http://pandoc.org/). It is terrific and easily handled the task of converting `.tex` to `.docx`. And best of all, it is written in Haskell! But it is still a command line utility, so I needed a way to set it up to automatically make the conversion when needed. I could have created a [gulp task](http://gulpjs.com/) that watched the files for changes and made the conversion. But there was no point in converting every time I saved because I would work on the file for a while before I was ready to send it to my family. At most, I would need a converted word file every time I made a change significant enough to commit to git ([commit early and often, kids!](http://www.databasically.com/2011/03/14/git-commit-early-commit-often/)). So ideally, the converting would be bundled with the action of adding a file, commiting it, and pushing to my Github remote (which is unfortunately still a private repository). 

##The Bash Script

The most elegant solution I could think of was to just create a bash alias for that action. 

The first step was a wrapper function that would take as many files as needed and convert them all to word format, saving the resulting file in a folder that can be added to the `.gitignore`. The feature of converting an arbitrary number of files at a time is unnecessary, but doesn't hurt. 

```bash
latToDoc(){
    #Usage: `latToDoc FILE_NAME`                                                                                                        
    mkdir -p word_format #In case the folder doesn't exist yet                                                                          
    for arg in "$@"
    do
        echo "Converting $arg"
        pandoc -f latex -t docx $arg.tex -o word_format/$arg.docx
        open word_format
        echo "Converted $arg"
    done
}
```

Then, I needed a quick function that would convert the file, add it, commit it with the provided commit message, and push it to the remote. 

```bash                                                                                                                                       
pushAndConvert(){                                                                                                                       
    #Usage: `pushAndConvert FILE_NAME "COMMIT_MESSAGE"`                                                                                 
                                                                                                                                        
    latToDoc $1                                                                                                                         
                                                                                                                                        
    git add $1.tex $1.pdf                                                                                                               
    echo "Added $1.tex and $1.pdf"                                                                                                      
                                                                                                                                        
    git commit -m "$2"                                                                                                                  
    echo "Committed with message: $2"                                                                                                   
                                                                                                                                        
    git push origin master                                                                                                              
    echo "Pushed to master"                                                                                                             
}
```

Now all I do is `pushAndConvert accept_me_please "Doubled bribery offer"`. Simple enough, right?
