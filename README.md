# storyboard-helper

**storyboard-helper** is a DSL compiler that lets you write **.osb** format osu! storyboards in **Lua**.

It aims to make animating and scripting storyboards easier in three ways:

1. Relative, combinable transformations.
2. Metaprogramming support.
3. Automatic optimisation.

In the .osb format all the transformation commands work in absolutes, you can tell a sprite to
move from one specific screen co-ordinate to another, but you can't tell it to move 50 pixels
to the right from where it currently is, same with scales, rotations and colour. When scripting
you have to manually track the transformation states of objects.
**storyboard-helper** has relative versions of each of the .osb transformations, so moving
a sprite 50 pixels from to the right becomes the command:

`{'MoveRel', 'linear', {'00:01:000', '00:02:000'}, {0,0}, {50, 50}}`

Relative commands have no limits to how they can overlap in time, and even with non-linear easings their
expected motion will be resolved and keyframed in the end.

With relative commands, there are option for more abstract and advanced ways of scripting animations.
Custom, compounded and potentially recursive commands can be created in a functional programming manner,
or defined by the user and added to the compiler, where they will integrate with the rest of the
compilation steps and can be used with any other parts/commands of the program such as the *keyframer*.

## Optimisation and documentation WIP
