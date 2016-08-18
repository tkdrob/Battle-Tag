*** ATTENTION. IF YOU ARE EXPERIENCING ANY PROBLEMS, YOU SHOULD DO A CLEAN INSTALL BEFORE COMING TO THE FORUMS FOR SUPPORT. IF YOU WANT TO USE THE EXTRA BEN10 AND RNC AVATARS, DOWNLOAD THEM FROM HERE: https://db.tt/3ELHwTD9. ENJOY!!!

Capture now displays the total number of flags a player has captured, the total remaining captures to win, and who has the flag. Players in a team that captures a flag will be notified with an announcement from their guns (requires updating your guns with new sound banks. Open UTMain.lua and change REG_FORCEREVISION to equal true). A UI option is now available to have a 2 team game display the teams side by side, useful for large games.

Some bug fixes. Rejoin is now available for all activities. 

Dual wield blasters are now here. Clicking the Dual button on the Players Management screen will pair guns on the same team with the same profile names. Keep in mind that the guns left displayed on the screen are the ones that must have a vest connected. Guns paired will still react to hits especially when friendly fire is enabled so players beware. The Martian Wolf can now have multiple wolves. Disarm bomb codes are now four digits with T-Bases 1-4 available. Overall roundloop optimizations have been done, KoTH being the most important one. You now have another option at your disposal to handle players who cheat by disconnecting their vests. The leaderboard will display those players who have vest connection issues. With a click on their profile icon, you can disable their ability to shoot even when their vest is connected. Clicking the button again will reenable their triggers. Currently excluded games: FreeFrag, Infection, LastoftheSpecies, Wild West Duel, Tag Then Shoot, and The Martian Wolf. You can switch this to automatic mode where the game master will disable the gun trigger if a player's vest is disconnected for more than 5 seconds. Team colors, another Ui option allows you to have the game assign teams based only on the team default set for each gun. (i.e. The Red team and the Yellow team can go against each other instead of having the yellow team appear as the red team.) More Ui settings are now available that allow you to display more players at a time. The last game that you selected will now be the first one displayed in the game selection menu. New game activity called Stalk the Lantern: Stalkers must try to scan the T-Base while the Defenders must stop them. There should be more Stalkers than Defenders with Stalkers having more ammo and less health points than the Defenders. In case you are having problems with loading the bytecode, you can now cancel the operation and try again. 

Made changes to the bytecodes for nearly all game modes. They are now more concise with another sound for assist that Ubisoft put in the gun sound banks but never used. When a player is down to only 3 bullets with no clips remaining, the gun will tell the player to reload. When a player has more lives remaining than the hud gauge will display (5), the gauge will now blink in the same way it does with infinite ammo. This overhaul of the bytecodes may have bugs so please test and leave feedback on the forum. Fixed a Wild West Duel bug that prevented users from continuing. Reworked the code for Random Person's team defaults mod which caused Wild West Duel to crash the game with more than two players connected. Added new animations for the T-Blasters, see the animations guide text file for a guide on how to make your own. My testing has shown that an error in flashing the new DANI binary does not brick a T-Blaster. The animations will just not display if something is not right. I of course must disclaim any and all responsibility for any damage this mod may cause to your T-Blasters. "Add New T-Blasters" is now "T-Blaster Options". Go to UTMain.lua and change REG_FORCEREVISION to true. You will need to do this should you decide to use these new animations. Added medium size buttons in place of large buttons to activity settings to allow space for more options. For certain games, two options have been added in the Advanced Settings window. With these options, you can set the time interval for when a random player will receive invulnerability for a short time. The duration is the same as the respawn time setting. This could make the game more fun and exciting for kids. Classic Capture has been updated. Games that use the flag icons such as Capture and Hostage Situation now use the Classic Capture flag icons. (WIP: You can now force revision for your guns without going into the Main.lua file. The option is under T-Blaster Options.)
Fixed issue where a timed out player's hud icon would not change.

I added a new feature for the player profile popup window. You can now set profile names for all guns on the same team. This is nifty if you, like me, do not have enough guns for all participants for an event and don't want to be wasting time inbetween matches. Select a player that's on the team you want to configure. Click the team button, enter the names you want using the save button, and click the confirm button to set the profile names. Currently, names saved this way are not stored on the guns. 
Fixed a bug where assistance for all game modes was not informing the player to scan their T-Base.
These is now an option in the main Activity Settings to set the countdown for Team and free-for-all style games. 
Added "Scan ammo pack" message when assistance is enabled for some game modes where it was absent. 
Swap feature option "On" renamed to "Both". The "Both" option does work. You need to click on the far left of the button. 
The beam power can now be configured on the Activity Settings page from the main game options instead of on the settings screen where you set activity specific options. 
The Bytecode Override setting has been moved to the Game Settings page. 
Option for number of rounds in Old Fashion Duel has been added.

Player slot grid options have been expanded. 
Added Medic and Munitions classes. 
Another class just added is the birthday (Superman) class. The player will have 100 life and unlimited ammo. 
Added option in the main Activity Settings to skip the manual launch popup. 
The game master will now play countdown audio when the game is manually launched. 

Added Random Person's team defaults mod to replace my method. Team defaults are no longer tied to profile icons. Made some fixes to prevent the screen from hanging while a gun is connecting and the Team Defaults button "Fill Teams" work properly again. Thanks for your hard work, whoever you are. lol
Added an option in Ui Settings to hide the player team ribbon that Random Person introduced. 
Problems with blasters still saying "Scan T-Base 1 or 2" when the player had reached his life limit should now be fixed. 
Added classes: Soldier, Sniper, Heavy, and Stealth. Click the More Settings button on the Settings Screen to configure. 
Added the Classic Capture game that Random Person posted. 
Added option to only enable swap for health packs, leaving ammo packs to be used freely.

Corrected King of the Hill game ending prematurely when respawn timer is enabled. 
Fixed player still seeing respawn timer countdown even when they used all their lives. 
For King of the Hill, a team for which all players have used all their lives will lose all team points. 

Corrected an issue with the rejoin feature in certain game modes. 
Fixed the leaderboard to allow for more players to be displayed onscreen in team based games. 
A player holding the flag that loses gun power should no longer halt the game. You need to reconnect the gun to allow players to grab the flag again. 

Some bug fixes.
Final Rankings screen now displays more players. 
Final ranking details no longer display players on the same team when friendly fire is disabled. Details are smushed together to allow for more items to display on screen. 
Player slot grid options have been expanded. 
Added check on the bytecodes to prevent health cycling issues.

Added a new option in Ui Settings allowing you to change the number of players to be displayed on the right hand side of the player management and setup screens. Choose between 9, 12, and 18. 

A new button has been added on the player management screen allowing you to cycle teams for all players with just one click. If you are like me, I hate having to keep track of where the different T-Bases are.
In Hostage Situation for example, we have one team play the Terrorists first round and the other team plays as them next. 
The slide animations can now be turned on and off from the main options menu. 
The player slot grid has been adjusted to fit 9 players on the player management and setup screens instead of 8. 
The Liquidator now has an option that ends the game after one Liquidator has been eliminated. 

Added a new game mode, Last of the Species. If anyone has a better name, share your thoughts on the forums. Its a simple version of the Martian Wolf where everyone starts out as wolf. Shooting a player no longer makes you a wolf. Geting shot makes you a wolf. The game ends when only player is a wolf, the loser. No scoring. If anyone wants to make pictograms this game, please do. 

Made a number of tweaks and fixes. Fixed, guns that rejoin games that did not receive the configdata created some undesirable effects. Remaining respawns can now be seen with the hud gauge on a gun's dashboard when the health icon is lit. Fixed any issue where the accept button in a number of game modes would not enable. 

Improved the gun reconnect test feature. No more issues should exist with players being on wrong teams. I added a third option that leaves a button on the leaderboard that allows you to toggle unlocking the proxy (UbiConnect). This allows you an alternative to the Auto setting. It provides a player with full health and ammo with a method of control which prevents players from just reconnecting as a means of healing. Simply click the button to allow for one gun to reconnect. 
Please note that if you intend to use this feature that you have the player stand next to the Ubiconnect. The guns may not always get the configdata the first time. Restart the gun and click Rejoin if you see a 0 on the hud. 

Set a variable interval for bytecode loading based on number of connected guns. Allows for faster loading especially for smaller games. 

Added Random Person's improvement of categorizing game modes on the Game Selection screen. Added support for 32 players with scrollbar fix. 

Handicaps are now set on a player basis through use of the player context menu on the players management screen. Added handicap setting for the lives option.

Added handicap capabilities in certain game modes for health, ammo, and clips.

Made some fixes to Capture for energy mode which was not working properly, added an offset for the game master audio that tells the players how many life/energy points a player had when the flag was captured. 

Added option in audio settings to make the Game Master less chatty. 

Fixed the batch file that removes the settings file so that it should now work on Windows XP.

Added another setting to Capture allowing you to set whether the winning team is decided based on total points (hits, kills, and flags captured) or just flags captured.

Added a setting to Capture allowing you specify the number of flags a team must capture as a condition to ending the game. 

(requested by Delano) Added an option to assign teams by profile icons. Red for Dragon, Blue for Shark, Yellow for Puma, Green for Bear, Silver for Panda, Purple for Bull.

Total menu window buttons have been increase from 4 to 5. 

Added a button to the players management screen allowing you to directly access the game options menu. This replaces the Add T-Blaster button. 

When "Unregister Guns" is disabled, timed out players' hud icon will go blank, letting you know who is having issues. 

Added the avatars posted on the Battle Taggers forum. Credit goes to Grimor. 

Going back to the Players Management screen when multiple guns have deregistered will no longer change any team settings for the remaining registered guns. 

You can now connect guns as soon as the UbiConnect finishes booting. 

Added feature that prevents a game from launching (not including Manual Launch Popup) when all guns from a team are disconnected, all but one player for non-team based games.

Added option "Prevent Launch" to prevent the game from launching if one gun is disconnected when you have "Unregister Guns" set to Off)
(This serves a purpose by allowing you to leave the pc with the manual launch blaster. If the gun stops prompting you to press the trigger, its because someone disconnected.)

Added a button to the Players Management screen allowing you to toggle unregistering guns that have timed out. 

Added option to disable blasters from deregistering. This allows you to preserve player numbers and teams so that multiple disconnected players do not wind up on the wrong teams when they reconnect out of order. 

v2.00

Added an option to enable test features. The current feature allows a player to reenter the game after a power lose to the gun. There are still a number of bugs so you may want to keep this off. 
(In a game with two teams, a player on the blue team reconnecting seems to have the correct team number. A red team player will instead only be able to hit other red team players. 
This is probably caused by the game sending the same team number to any player that reconnects. It's the only variable that varies between players. 
We would have to figure out how to associate the correct team number to the player reconnecting. You can find to code lines I had to add in the function "ULUsbProxy:ProcessMessage0x12(arg)". Any help from you would be great. 
I'm not sure about the results if you have more than 2 teams active. One bug I managed to fix was the reduction of the number of clips a reconnected player gets from reloading.)

Added option to have the game unregister a gun after 80 seconds of no connection during a game. 

Added option to have gun numbers only include numbers. You may not want to use this if you are playing with 20 or more players.

Added a button on manual launch popup to change gun used to start the game.

Added Last Team Standing audio for Silver and Purple teams.

Assist is now an application wide setting. All game modes have 2 bytecode files, one with assist and one without. 

Added a setting for King of the Hill requiring dead players to hide and avoid getting hit in order to respawn. When a dead player who is waiting to respawn gets hit, the respawn time resets. 

Fixed a small bug in King of the Hill. 

v1.91

Reverted a change I made to the Players Management and Setup screens. The scrollbar will now appear when more than 8 players are connected. 

v1.9

Audio files added for Silver and Purple teams and Disarm, Capture, Hostage Situation, and King of the Hill. Thanks to Tatecg for making the audio. 

King of the Hill Game: Tatecg tested this and encountered a delay in points accumulating for the team controlling the hill even when the Delay setting was set to Off. Rest assured, I have not encountered this problem. If you have the ability to customize your T-Bases, you will need to make T-Base 7 if you decide to play with 4-6 teams with respawning set to T-Base. The major/minor type is 56. Consult the playground screen before playing. 

Adjustments to the playground screen, disable displaying T-Bases for respawning when respawn mode is set to Auto.

Graphics updated for Hostage Situation and King of the Hill. Thanks goes to Tatecg for the original design.

Resolved an issue where the Access database included would not show certain stats in the reports when fields in the scores table are blank. 

v1.8

5-6 teams are now supported. However, the gun firmware does not recognize teams 5 and 6. The workaround is forcing Friendly Fire to be on. A custom pack option has been added. Enable this if you have custom T-Bases for teams silver and purple (credit goes to grimor for most of the targa images.) The base major/minor types are 54 and 55. 

Even if you don't have the Medkit pack and/or the custom pack, you can still play Team Frag, Pro Team Frag, and King of the Hill with extra teams. Every player will have to respawn automatically if you don't have sufficient T-Bases. 

Disarm game mode has been reworked to solve an issue with scanning bomb digits. T-Base 2 is now the enter key. 

I put a quick fix for the scroll bar on the game selection screen which was starting to look weird if additional game packages are to be added. 

v1.72

Hostage Mode can now be set to end the game immediately after the Commandos secure the hostage.

v1.71

Fixed UTActivity.State.FinalRankings.lua to work better with MS Access database I created. 

Fixed a scrollbar issue in the game selection screen. 

The Test folder has a modified ULUsb.lua file with just a small change. ULUsb.updateFrameRate = 12 instead of 4. It seems that this setting changes the number of times the computer communicates with the ubiconnect. I have observed things like increased gun connection speed, to more accurate score keeping. Use this file if you want and let me know if you experience any undesirable side effects. 

v1.7

Disarm Game Mode:

At least 2 Commandos are required to play.

The gamemaster will now push lines for hits, frags, respawns, reloads, heals, all that jazz. It will also push a line when a Commando scans a bomb digit. 

I noticed an issue with my previous version of Tatecg's Disarm game. If you selected multiple bomb digits as the same number, the bomb disarming would not work correctly. To fix this, I had to put a short 2 second timer that starts when a Commando scans a t-base. Before it reaches zero, trying to scan another base will create the "scan_bad" sound. When it reachs zero, it sets the bombdigitscanned variable to 0 so that when the Commando scans the same t-base in a row, the gamemaster will recognize this. 

Hostage Situation Game Mode:

I have now split the Capture Game Mode, into Capture (with two flags) and Hostage Situation. This mode is used very much like Capture except there is one flag (hostage). T-base 4 should be used when the defending team (Terrorists) is set to 1, t-base 3 if set to 2. When a Commando nabs the hostage (t-base) he/she does not need to scan it since there is no energy points used here. However, if you require that player to scan it when he/she gets it, the gun led will flash green. Upon returning to the base, the Commando scans the hostage base and then his base. To make it even more fun, you could use a real person as the hostage (holding the hostage base), something that I plan to do for my events. 

With a little experimenting, I discovered that the guns retain their bytecode instructions when off. This means that if you only play one game mode and all your guns have the game bytecode loaded onto them, you will not need to load it during your entire event. Because of this, I added another game setting which you can find in the options menu off of the main title screen called "Bytecode Override". Keep in mind that if you are an inexperienced user or you are not sure if all your guns have the bytecode loaded for your game, it is best that you leave this setting the way it is, "No." 

v1.65

The options to set the number of points a team and a player get for a frag is now part of the main application settings under "Game Settings". These settings will apply to all applicable game modes. Games such as J141 Solo Frag, Liquidator, and Disarm are not affected. My reason for doing this is to make the individual game mode settings pages less cluttered. 

v1.6

Slide amination added for Tag Then Shoot and Wild West Duel. 

Tag Then Shoot and Wild West Duel will no longer force the bytecode to reload under the right conditions. 

End Game Mode for Capture:

I created this option for use at events I organize. Selecting timer ends the game like normal. Selecting team will end the game either when the timer runs out or if everyone on a team is dead for 10 seconds plus the respawn time selected. We take a more realistic approach to our games, very limited ammo with a hostage situation. If a player dies he/she must lie down, a teammate must then help him/her to the base to respawn. This option allows the game to end when everyone on a team is clearly dead and unable to respawn. 

Fixed a device pinger issue. 

v1.5

Solo Frag: (credit goes to j141 for making the original version)

The game file names are now called SoloFrag to match the naming format of all the other games. A friend of mine that I will be installing the game for may not understand the j141 lol. So I changed it with no intent to discredit j141. If you still want it be called j141 Solo Frag, you can change it in the .nfo. 

I fixed the rules screen by adding extra description of the game and correcting the names for what the bullet, skull, and heart icons stand for. 

The gamemaster will no longer push a line on the leaderboard for every time a player regains a shield point. If a player uses a medkit when he/she has at least 2 missing shield points, then the gamemaster will push a line for it. 

Another pushline issue that I have fixed is when the game would say that the player is back in the game immediately after the player loses a life even if there is a respawn time. 

If a player had less than the maximum ammo when dead, the game would also push a line saying he/she reloaded. This has also been fixed. 

The gun hud will now briefly display the number if lives left upon lossing one. 

Some bytecode logic slimming for more conciseness without affecting functionality. 

Game modes that have the lives setting enabled now allow players to use the hud button to switch between health, ammo, and lives. If lives are set to infinite, the hud will only switch between health and ammo. 

Manual Launch by Default:

Launch setting has been removed for all games. The manual launch popup will show when you click Play. The manual launch popup now has a quit button and a play button (launches the game just like it does in auto mode). This allows you to make a last second decision on how to launch the game. 

Cancel button on game launch at countdown screen: (debugged as far as I can tell except for Tag Then Shoot. The game master will still countdown to one but everything else seems to work.)

This allows you to abort the countdown and return to the player setup screen. 

Escape key for popups:

You can now use the escape key to close the pairing, profile, and manual launch popups. 

Slide end animation disabled:

Allows for faster navigation. Slide begin is still enabled.

Protected Mode disabled:

This allows the leaderboard to display players that have lost connection as greyed out icons. If only one player is connected, a popup will show. A close button has been added to this popup to ignore it. The game will unregister the gun after 80 seconds which is slightly longer than the time that the gun gives you before shutting off. 

Gun Disconnect Sound:

The Windows 8 device disconnected sound with go off 10 seconds after the game losses connection with a gun. A sound setting has also been added for this effect in the options menu. If you want a different sound, just replace the GunDisconnected.wav file located in data/audio/ui with another .wav file with the same name. 

Gun Bytecode reloading skipped under certain conditions:

After the gun bytecode is loaded, if you go past the players management screen for any different game, change a gun related setting, a player's team, or adding a player will make the game reload the bytecode. If however, if you only change player profiles, remove any players, or change for instance the gameplay duration setting, the bytecode will not be reloaded because it does not need to be. To avoid issues, if you plan on playing J141 Solo Frag (Solo Frag), you must use the game package I provided.

Profile name length can now go to 11 characters:

You can lengthen this if you wish by going to UIEditBox.lua and changing the value of self.maxChars. The only issue I can see with this is the overlap with other ui elements.  

HUD Icons:

Both small and large hud icons will now reflect the exact same player number/letter on the gun huds. 

Capture Mode:

The time left setting will now apply to both capture modes and can also be turned off altogether.

Changed the REG_BUILD number from 1.1.354 to 1.1.360 just for fun. 

Probably some other things I forgot about but it all works for me. 

Enjoy all these nice tweaks. 

v1.1

Bytecode fix. 

Pictograms for Team Frag Pro, Disarm, and capture now have alpha channels for transparency. 