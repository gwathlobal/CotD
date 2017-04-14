CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

Apr 15, 2017 v1.1.0

- Added stealth to the game! Remaining in shadows will render you invisible to your enemies while moving through illuminated terrain (and moving in general) will expose you.  
- To counter stealth, Citizens of the City carry lanterns and Angels radiate light (note that Demons do not have a portable light source). Moreover, stationary light sources were added to the houses and some streets.
- Outdoor lighting depends on the time of day - at midnight you will need to rely on lamps, while at day time the sun will not let anybody hide outside buildings.
- Time of day now changes dynamically as the time passes. 
- Added scenario options regarding the starting time of the day - you may start at night, at noon, in the morning or in the evening.
- Added hearing to the game! Characters' actions will generate sounds that others can hear and learn the general direction to the sound's origin. Most creatures will try to investigate what or who produced the sound if they have no other pressing matters.
- Added the Thief to the game.
- Added Death from Above ability to the Thief. This allows the Thief to jump onto an enemy from an upper Z level and make a devastating blow.
- Added Climbing ability to the Thief. It allows the Thief to go up and down along the Z level when clinging to walls.
- Added trees spanning across several Z levels.
- Added inventories to characters. You are now able to pick up, carry and drop items.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.