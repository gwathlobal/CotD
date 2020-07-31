CITY OF THE DAMNED

City of the Damned is a simple fast-paced coffee-break roguelike inspired by a 7DRL entry "City of the Condemned" by Tapio (http://www.roguebasin.com/index.php?title=City_of_the_Condemned). 
It is written in Common Lisp using SDL.

LATEST RELEASE

August 1, 2020 v2.0.0

- Added campaigns as a whole new mode for the game. A city map is generated for the campaign where the missions take place. Each side of the conflict (angels, demons, and the military) have their own goals in the campaign. Each campaign day the player shall be presented with several available missions. The player can take one and play it as a usual game scenario. Or the player can choose to pass the day without taking a mission. Either way, all missions where the did no actively participate will be resolved automatically and the mission outcome will directly affect the campaign map.
- Added saving and loading of campaigns and standalone scenarios.
- A new type of mission added: Satanist elimination. The military tries to eradicate the satanists' lair and kill all satanists in the district.
- A new type of mission added: Celestial sabotage. The mission takes place in a hell dimension where the angels try to destroy dimensional engines that give demons the ability to open portals to Earth
- A new type of mission added: Military sabotage. The mission takes place in a hell dimension where the military tries to destroy stockpiles of raw flesh that the demons have stolen from Earth
- A new type of level map: hell jungle. Similar to the corrupted districts (the ground is covered with creep and demonic outgrowth is here and there) except it is even more otherworldly and sinister.
- The player shall now see what is happening on the upper or lower Z level whenever something interesting is nearby.
- Added a new terrain tile to the corrupted districts - glowshrooms. Glowshrooms emit faint light and illuminate everything around them.
- Message log can be now quickly skimmed using Shift+Up/Down.
- Added craters from artillery fire to abandoned and corrupted districts. 
- Added a new terrain tile to the corrupted districts and hell maps - glowing creep. If somebody steps on this tile, it will give irradiation to this character.
- Added an ability to purge demonic runes to angels. Purging runes provides 4 power to the angel.
- The following abilities:
     mount a horse, fiend, or Gargantaur, 
     merge trinity mimics 
     decipher runes
  will now show up only when the corresponding target is next to you to avoid confusion.
- Malseraph's Puppet irradiation strength will now depend on his favor with Malseraph.
- Malseraph's Puppet gets an ability to draw breath and exhale irradiation around them on the next turn.
- Made an option to hide messages that are visible through Angel's 'Singlemind' ability.
- Restructured the main menu: moved all quick scenario options into a submenu.
- Highscores shall be reset in the new version.
- Fixed the bug when merged angels did not merge their power values.
- Fixed the bug when slowed characters did not have their speed returned to normal.



CURRENT CHANGELOG

See the [CHANGELOG.txt](https://github.com/gwathlobal/CotD/blob/master/CHANGELOG.txt) file for the changes in the upcoming version.

DOWNLOADS

Head to the [Releases](https://github.com/gwathlobal/CotD/releases) directory and grab the latest binary for your platform.

COMPILING

Refer to [COMPILE-DEPENDECIES.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILE-DEPENDECIES.txt) for the Common Lisp library dependencies.

Refer to [COMPILING.txt](https://github.com/gwathlobal/CotD/blob/master/COMPILING.txt) to learn how to set up Common Lisp and compile the game for Windows.