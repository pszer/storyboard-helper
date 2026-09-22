# storyboard-helper

**storyboard-helper** is a DSL compiler for writing **.osb** format osu! storyboards in **Lua**.

The goal is to make animating and scripting storyboards easier by supporting *relative transformations that combine additively/multiplicatively*, and metaprogramming*.

In the .osb format all transformation commands work in absolute units, a sprite can be told to
move from one calculated screen co-ordinate to another, but it can't be told to move 50 pixels to the right from it's current position.
Normally when scripting, the transformation state of an object has to be manually kept track of by the user and used in calculating
desired a motion, which is time consuming and error-prone if dealing with any sort of complex motion,

**storyboard-helper** allows for relative versions of all the transformations, the previous example of moving
a sprite 50 pixels to the right becomes a single command that will resolve to it's final state upon compilation:

`{'MoveRel', 'linear', {'00:01:000', '00:02:000'}, {0,0}, {50, 0}}`

Relative transformations have no limit to how they can overlap in time, allowing for compounded transformations.
In cases of several commands with non-linear easings being compounded, the final motion is automatically sampled
and keyframed to create the correct visual effect without additional steps.

With relative commands there are more abstract ways of scripting storyboards.
Any work that compounds several transformations/commands can be turned into a new command,
either by functions and closures, or through a definition passed to the compiler. Custom commands fully integrate themselves with the program
and can be used in any other compound commands and tools such as the *keyframer*.

## Optimisation and documentation WIP
