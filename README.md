CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

September 15, 2017 v1.2.1

- Added Trinity mimics as a playable faction. Trinity mimics are three mind-linked angels - the Star singer, Star gazer, and Star mender. Each has a separate set of abilities and all of them can merge with each other. The player controls each mimic individually.
- Added Righteous fury ability to the Star singer. Righteous fury is a berserk-like ability that lets you attack harder and faster but at a cost of slowing you afterwards.
- Added Pain link ability to the Star signer. Pain link makes the target deal increased damage to the caster but decreased damage to everyone else.
- Added Heal other ability to the Star mender. This ability allows healing not only yourself but your allies as well.
- Added Soul reinforcement ability to the Star mender. Soul reinforcement prevents a fatal blow that would otherwise kill the target.
- Added Silence ability to the Star gazer. Silence prevents the target from casting.
- Added Confuse ability to the Star gazer. Confused targets sometimes move in a random direction instead of an intended action.
- Added Pandemonium Shades as a playable faction. Shadow creatures are unable to possess humans but get a number of shadow-related abilities. You start as a shadow imp.
- Added Umbral aura to shadow devils. This makes shadow devils be not light, but darkness sources.
- Added Extinguish light to shadow demons and shadow devils. This ranged ability will switch off a stationary light or cause an enemy to stop emitting light for short period.
- Added Shadow step to all shadow creatures. Shadow step is a short-range teleport that works only if the source and destination tiles are not lit.
- Added the Church as a playable faction. You start as a priest in a church and your aim is to destroy all demons.
- Added Smite to priests. Smite is a single target damage ability that gets better the more humans are around the caster.
- Added Slow to priests. Slow is a single target ability that causes the enemy to take more time when attempting any action.
- Added Prayer of wrath to the priests. This ability grants a fire-based melee attack to those who follow you.
- You can now wait a turn using [.], and pick items using [g] and [,].
- The game now logs your current title instead of your initial title into a high score entry.
- The player is now highlighted on the map.
- Dropping in water gives you a 'wet' effect, which means 25% of increased fire resistance.
- Added rainy weather. Being caught in the rain will make characters wet, extinguish fires and clear blood.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.