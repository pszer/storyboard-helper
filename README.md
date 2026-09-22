# storyboard-helper

**storyboard-helper** is a DSL compiler that lets you write **.osb** format osu! storyboards in **Lua**.

It aims to make animating and scripting storyboards easier in three ways:

1. Relative, combinable transformations.
2. Metaprogramming support.
3. Automatic optimisation.

In the .osb format all the transformation commands work in absolutes, you can tell a sprite to
move from one specific screen co-ordinate to another, but you can't tell it to move 50 pixels
to the right from where it currently is, same with scales, rotations and colour. Normally when scripting
the transformation states of objects have to be manually kept track of.
**storyboard-helper** allows for relative versions of all the transformations, moving
a sprite 50 pixels to the right becomes a single command that will automatically resolve state upon
evaluation:

`{'MoveRel', 'linear', {'00:01:000', '00:02:000'}, {0,0}, {50, 0}}`

Relative commands have no limit to how they can overlap in time, and in cases of non-linear easings
their final motion will be resolved and keyframed to create the correct visual effect without additional
steps.

With relative commands, there are option for more abstract ways of scripting storyboards.
Custom, compounded and potentially recursive commands can be created in the manner of functional programming,
or defined by the user where they will integrate with the rest of the compiler and can be used with any
other parts/commands of the program such as the *keyframer*.

## Optimisation and documentation WIP
