# De Miedo Character Controller.
Based on Q_Move, A Quake-like controller for Godot.* 

(*adapted and updated from Btan's original README)

# Important Notes:
  - This is for Godot 3.5, the project has been in development since before the release of 4.x. Unfortunately, it cannot be converted 1 to 1, due to the overhauls of the GDScript Node. If you are interested in this style controller for the latest version of Godot, you will be able to find it under Btan's original Repo. (link below)

  - This project is meant to provide Godot developers with a robust character controller that delivers the same level of responsiveness as Quake and Half-Life. It's primarily intended for use with game projects or to be modified, so it's not exactly a tutorial. Just wanted to caveat up front that learning from this won't be as straightforward as say, finding some lessons online. I've done my best to leave as many notes in the code as I can. :)

# Features
  - Various functions from Quake source code have been converted into GDScript, such as head-bob and camera movement rolling. 
  - Air control and acceleration modified from WiggleWizard's Quake3 Movement script (https://github.com/WiggleWizard/quake3-movement-unity3d).
  - Optional head-bob style converted from Admer456's "Better View Bobbing" tutorial (https://gamebanana.com/tuts/12972).
  - Proper step climbing, works with steps of varying sizes.
  - Trace singleton addon for collision shape casting (used for step detection).
  - Jump hang to allow more forgiving jumping precision off ledges.
  - Expandable Weapon Inventory with 3 different weapon types: Melee, Hitscan & Projectile.
  - Simple Health System, also works for enemies.
  - Simple Swimming system.
  - Other little things I am sure I am not remembering at the moment :P

# Known Issues
  - Sliding along a wall while moving into a step can sometimes stop the player. Can be somewhat offset with diagonal movement.
  - The trace functions are a little inefficient as multiple casting methods are required to retrieve collision information; a standard trace call will cast 3 shape queries for collision info.
  - The controller will slowly slide down non-steep slopes.
  - The player can fall infinitely if caught between two steep slopes.
  - The player can sometimes move up if pressed between two steep slopes when they should otherwise slide down. Since this was also present in Half-Life and Quake, it's been left it in for prosterity.


# License and Credits
Original Repo: https://github.com/Btan2/Q_Move

A generalised description on how the step function works can be found on Btan's website: https://thelowrooms.com/articledir/programming_stepclimbing.php

  - Textures used in this repo are from FREEDOOM (https://freedoom.github.io/)
  - Sounds are from LibreQuake (https://github.com/MissLavender-LQ/LibreQuake)
  - Weapon Models are by Kenney (https://www.kenney.nl/)

This project is under the GNU v3 license.
