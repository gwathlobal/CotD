CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

Mar 25, 2017 v1.0.9

- The 3rd dimension was added to the map! Buildings now have several floors, mobs can go up and down the slopes.
- Gravity added! You can step off the ledges and fall down. You can drop one Z level without any consequences but any distance greater than that and you will take increasing falling damage.
- Mobs will now recognize the gravity and will short-cut off the ledges if they see they won't take any damage without finding the nearest slope down.
- Added mansions to the building types.
- Removed support of small tiles.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.