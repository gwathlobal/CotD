CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

March 29, 2018 v1.3.0

- The concept of missions was introduced. The previous scenario where the demons wanted to kill all angels in the city became the 'Demonic attack' mission.
- A new mission was added - Demonic raid. The demons opened the portals in order to gather flesh from the city. Their goal for this mission is to kill citizens, pick up their corpses and throw them into portals, while the military and the angels want to stop and destroy demons.
- If you die, this is no longer the end of the world. The battle will go on until one of the sides wins. You might even get resurrected by your allies and continue fighting as if nothing happened.
- You can no longer win the game by ascending beyond Angel or Archdemon/Shadow Devil.
- As a Scout, you can no longer lose the game by getting possessed. Though you will lose the control over your character until you get purged (or the end of the mission).
- You will now be able to customize the factions you want to see in a scenario.
- AI will bump into friendly mobs much less often and will try to navigate around them to get to its target.
- Added a journal where you can see objectives for the current mission and your relations with other factions. The journal is displayed using the 'j' button.
- Defending military will be stationed inside the city.
- Possessable creatures will try to get away from you if you are the one that can possess them.
- Characters with ranged weapons will try to step out of melee combat.
- Ghosts can now sense the direction to the sacrificial circle and the Book of Rituals.
- Abilities on cooldown will be displayed in the status string.
- The game over screen now also shows the comparative statistics between the character who earned the title and the player.

CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.