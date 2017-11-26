CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

November 25, 2017 v1.2.4

- Added signal flares to Scouts. Signal flares prompt the artillery that the military has deployed outside the City to strike at the location of the flare. This strike deals significant iron and fire damage around the location where the strike lands.
- The Eater of the dead can now mutate and grow various organs that can help it in its quest to destroy the outsiders.
- For offensive mutations, the Eater of the dead can choose from clawed tentacles (an increased melee attack), acid spite (an additional ranged attack) or corrosive bile (a cooldown ability similar to an artillery strike).
- For defensive mutations, the Eater of the dead can choose from chitinous plating (a passive direct resistance increase), metabolic boost (an active ability that grants increased speed and dodging) or retracting spines (an active ability that gives increased percentage resistances and inflicts damage to melee attackers).
- For spawning mutation, the Eater of the dead has either spawning sacs or an ovipositor. The spawning sacs can spawn locusts which are rather weak creatures that can attack in melee but die off naturally after a number of turns. The ovipositor spawns scarabs which are living bombs that roll to the target and explode dealing acid damage to everybody around. You can further enhance your spawns by giving locusts an acid bite and making them tougher or making scarabs roll faster and spawning more of them.
- From the very start, to boost its combat prowess the Eater of the dead now has an adrenal gland. When the Eater attacks someone, the gland secrets adrenaline which makes all melee and ranged attacks faster.
- The Eater of the dead can create parasites that can be thrown onto enemies. A parasited character will always reveal its location to the Eater.
- The Eater of the dead can cure mutations that you do not find helpful.
- When the Eater of the dead devours corpses, it has a chance to get abilities depending on the type of the corpse.
- The Eater of the dead can no longer use primordial power.
- The Eater of the dead starts with 2 power that you can immediately use on mutations. 
- If an ability requires the player to select a target, the game will initially focus the applicable target (instead of always focusing hostile characters).
- Irradiation has a small chance to mutate you giving you a minor negative effect.
- Malseraph can sometimes cure malmutations of its followers.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.