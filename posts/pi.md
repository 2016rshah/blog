% Introducing a Neat Com-π-ler
% Rushi Shah
% 25 February 2017

#Introducing a Neat Com-π-ler
*Rushi Shah on 25 February 2017*

Right now I’m in a Computer Architecture class. It is a super cool class
and our most recent project was implementing a compiler that takes code
in a C like language (henceforth called the “pi” language) and generates
x86\_64 assembly code. Each individual spent two weeks implementing the
initial compiler that worked with basic things like while loops,
functions, if statements, local and global variables, etc.

Then (and this is the crazy part) we split up into groups of 10-12
people and had a week-long code sprint to make coolest compiler we
possibly could. My team was called Hot Pi and had twelve students on it
total including me. I was blown away with the amount we got done in a
week, and the project is now [open source](https://github.com/2016rshah/pi)!

![](../resources/pi/branches.png)

##Features

###Error Reporting

This was the part I personally worked on because I like the idea of
helpful compilers. The first thing I did was set up descriptive error
messages for every possible error that could be thrown (for example
`Cannot reference something that is not an identifier!`). I carried the
location in the source file for every element of the abstract syntax
tree through the compiler so I could present line numbers for each of
the errors the user gets.

I also paid special attention to some errors. For example I used
Levenshtein distances for unrecognized identifiers to fix possible typos
(did you mean `return` rather than `retun`). I also reconstructed
expressions for mismatched parentheses, mismatched square brackets, and
mismatched curly brackets and presented the inferred location of the
missing parenthesis/bracket.

To tie it all together I used color-coded output to display the error
messages in a easy-to-read and approachable way (including an error
message, possibly the offending expression, and line numbers).

###Everything else

This is the complete list of language features we supported by the end
of the week. This doesn’t include the things we had already finished
individually like while-loops and if-statements. With this subset we
made a pretty substantial compiler.

-   Error Reporting

-   Sound (playing the Super-Mario theme song in our demo was
    a crowd-pleaser)

-   Graphics

-   Structs

-   Scoped variables

-   Arrays

-   Pointers, Delays, and the Bell Keyword

-   For-loops

-   Types

-   Higher Order Functions

-   Comments and Random Numbers

-   User Defined Operators (Macros)

-   Switch Statements

##Workflow

We ended the week with a single file that was 2,862 lines of C code. In
retrospect we should have split that code up into multiple files, but
you live and you learn. And even though each one of us poured our blood,
sweat, and tears into that file, our git workflow was surprisingly
smooth.

We started by each creating an issue on Github with what we were
planning to implement. This allowed everybody in the group to keep track
of everybody else and make sure the same work wasn’t being done more
than once.

We each worked on our own feature branches, and never pushed to master
until we had resolved merge conflicts and all the tests passed. There
were definitely head-aches resolving the merge conflicts, but that part
of the process was just passed into the development process of a new
feature rather than an after-thought.

Other teams expressed their displeasure with the large team dynamic, but
things turned out alright for us somehow because we followed good git
practices. And boy did I get practice teaching beginners at git how to
resolve their own merge conflicts.

##Outcome

At the end of the week each team presented their compiler and all the
neat features they had. Our presentation went splendidly and since we
had at least one test for every feature we were able to run through the
main tests, their output, and show that they passed.

Thanks to our professor we were given permission to [publish the project on Github](https://github.com/2016rshah/pi). It displays who contributed
what and you can see this lovely branch history:

![](../resources/pi/branches.png)

Our team also had a ton of fun and composed this poem to express our feelings:

```
team hot pi more like team not high amirite
more like team thought die
but then team fought rye
and then team shot high
and then team dot... sigh
and then team not bye
cuz team hot pi
```

##Reflection

Overall this class has been very enjoyable. First of all it has
introduced me to the incredible world of low-level programming. I don’t
expect to spend much time in my life doing low-level stuff, but it is
very neat and I’m glad I at least have a foundation in it. Also, the
class has yet again impressed upon me how incredible the Turing Scholars
Honors Program is at the University of Texas at Austin. I am not only
impressed with the curriculum (which has been very informative and
enjoyable) but also consistently amazed at how innovative and
hard-working my peers are.