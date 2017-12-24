CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

December 24, 2017 v1.2.5

- Introduced a new playable character - the Lost soul. It is a very fragile (1 HP) non-corporeal being that can possess humans and dead bodies. Unlike demons, its possession ability is improved - it gains all the abilities of the victims and uses their HP instead of its own. When the victim dies, it just leaves the body ready to jump into another target in range.
- When in ghost form the Lost soul can turn completely invisible and escape any dangerous situation, as well as pass through walls and floors.
- The aim of the Lost soul is to find the Book of Rituals stored in the library and use it on the sacrificial circle on the lowest floor of the satanists' lair. 
- Added a second tier of defensive mutations for the Eater of the dead. These are thick carapace (even more passive damage resistance), acidic tips (extended spines start to deal acid damage) and jump (gain an ability to jump similar to the thief).
- Added a second tier of offensive mutations for the Eater of the dead. These are piercing needles (constricted target have reduced dodge), increased acid strength (acid spit also reduces flesh and acid resistances) and increased cerebellum (corrosive bile always lands to the destination target).
- Added survival mutations to the Eater of the dead like hooks & sucker cups (lets you climb walls) and facade readjustment (lets you disguise yourself as a human).
- Spawning mutations are rearranged for the Eater of the dead. The ovipositor is now the prerequisite for all spawning mutations. Then you can branch into locusts or scarabs. Parasites are now dependent on the ovipositor as well. All spawning is no longer immediate - first, you need to lay eggs and wait before they grow.
- The Eater of the dead can gain an ability to spawn seeker larvae. These small creatures are harmless but eat corpses and transfer their power to you.
- The Eater of the dead can gain an ability to spawn spore colonies. These are immobile creatures that spit acid at their enemies in sight.
- Fixed the bug when you could throw the parasite through solid objects.
- Added a card that could polymorph enemies into trees. Trees are immobile and do negligible damage but have superior defenses.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.