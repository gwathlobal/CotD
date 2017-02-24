CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

Feb 24, 2017 v1.0.7

- Momentum added! When you have the Momentum ability, that means that you gain speed when moving in a direction and are able to cover several tiles within one turn but you can not drastically change your direction when at high speed (unlike normal movement when you can make all kind of turns and backpedal at any time). If you bump into an obstacle, your speed drops to zero. If you bump into another unit, your speed drops to zero but you will try to push this unit (similar to the Charge ability).
- Horses are added to the game. They are allied with all non-demon factions and have momentum. Horses can be found in the stables.
- Fiends added to the game. They are demonic beasts who will attack everybody (even demons). They also have momentum.
- Horseback riding added! Military units are able to use horses as mounts. When riding a mount, your mount moves independently of your actions, you can only give directions to it. This means that once you've gained speed, the mount will be moving in the chosen direction on its own, while you can shoot the enemies as you pass them by. Mounts may also be used as meatshields as enemies have 50% chance to hit your mount instead of you.
- All demons are able to mount fiends.
- Added scouts to the military. They are armed with rifles, are able to reveal a single enemy and start riding a horse.
- You may now start as a scout. Scouts gain no followers but compensate that with their unsurpassed speed.
- Added stables to the buildings of the city.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.