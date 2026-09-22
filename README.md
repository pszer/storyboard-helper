# storyboard-helper

**storyboard-helper** is a DSL compiler for writing **.osb** format osu! storyboards in **Lua**.

The goal is to make animating and scripting storyboards easier by supporting *relative transformations that combine additively/multiplicatively*, and programmatic composition/metaprogramming.

In the .osb format, transformation commands operate in absolute units.
A sprite can be told to move from one calculated screen coordinate to another, but it cannot be
told to move 50 pixels to the right from its current position.

Normally, when scripting, the transformation state of an object has to be manually tracked by
the user and used to calculate the desired motion. This becomes increasingly
time-consuming and error-prone when dealing with complex motion.

**storyboard-helper** provides relative versions of each transformations, so the previous example of
moving a sprite 50 pixels to the right becomes a single command that resolves to its final state when compiling:

`{"MoveRel", "linear", {"00:01:000", "00:02:000"}, {0, 0}, {50, 0}}`

Relative transformations can overlap in time without restriction, allowing for compounded transformations.
When several commands with non-linear easings are compounded, the resulting motion is automatically sampled
and keyframed to produce the correct visual effect without additional steps.

Relative commands also enable more abstract ways of scripting storyboards. Any composition of transformations
or commands can be turned into a new command, either through Lua functions and closures or through definitions
passed to the program. Custom commands fully integrate with the rest of the compiler and can be used within
other compound commands or tools such as the *keyframer*.

## Optimisation and documentation WIP
