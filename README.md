## We love bot games!

We love bot games! [*CRITICAL*] in order to play the script you need to create a Lobby and select "Local Host" as Server Location. To enable enhanced challenging mode, follow the steps on Workshop page to correctly install this script. The bots in game should have names with suffix ".OHA" when installed correctly.

Bot script in Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298

Thanks and kudos to all that contributed to make bot games fun and exciting.

#### The goal of this script is to: 
1. Share the most up to date functionalities that we've implemented/fixed to keep the bot games challenging, 
1. For players to have fun with chill by playing/practicing against the bots that can play ALL Dota2 heroes. 
1. Bots are meant to be for chill games, if you are looking for more competitive bots than the existing ones, please stop complaining and help us build it with constructive effort.

## Why it's enjoyable
0. Support 7.39
1. Support ALL 126 heroes! You will see bots playing Kez, Ringmaster, Invoker, Techies, Meepo, Lone Druid, Dark Willow, Hoodwink, io, Muerta, Primal Beast, etc. Just note that some of the newly added ones are not very strong and in progress to be further enhanced.
1. Bots are easily customizable . E.g. you can easily set ban / picks for bots, change their names, etc. 
   1. Check out the file in [Customize/general.lua](bots/Customize/general.lua).
   1. You can also customize bot's item purcashes, ability upgrades, etc - check out the sample file in [Customize/hero/viper.lua](bots/Customize/hero/viper.lua).
   1. Which Customize file you should change?
      1. Make sure to select Open Hyper AI as the script in custom lobby.
      1. If you have NOT installed the script via `quick-install-oha.bat`, simply update settings in <Steam\steamapps\workshop\content\570\3246316298\Customize>
      2. If you have installed the script via `quick-install-oha.bat`, update settings in <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize>
1. Dynamic difficulty. If you ever feel all existing bot scripts lack excitement. This script boosts bots with huge unfair advantages to make bot games a lot more challenging. You will need to enable the Fretbots mode for this feature. See instructions on section [How to install this script](#how-to-install-this-script) below.
1. Support almost ALL game modes: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/72
1. Improved code structure & general logic for decision making for ability casting, item usages, defending, roaming as well as farming.
1. Enhanced AI Chatbot. You can chat with bots in the game as if they were real and optimistic players. Integrated with ChatGPT. [Note: you need to enable Fretbot mode for this, check out How to Install section below.]
1. All supported heroes in this script can play any position roles. Heroes will go to any lane they are assigned. The laning or pos of the bot heroes will seem random in the game, but it's deterministic - check the Bot roles section below.
1. Fixed tons of bugs. Bugs that can cause bots to stay idle or cancel it's own channeling spells or stuck on weird states.

## How to install this script
1. This bot script can only work when you create `Custom Lobby`, and select `Local Host` as the `Server Location`, this is because there is an issue on Valve side that most of custom scripts can only work in `Local Host`.
2. This script has enhanced Fretbots mode that can boost bots with HUGE unfair advantage which makes the game much harder. You MUST `manually install` this script, please follow the instruction here to enable Fretbots mode: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/68, note this can also resolve other issues like enabling bots to use Neutral items.

## Bot roles, lanings and positioning
1. In local lobby, the positions of the bots are the same as the order of the slots: 1, 2, 3, 4, 5 from top to bottom in the lobby.
1. You can change bot ban/picks, and roles, etc easily and permanently. Check out the file in [Customize/general.lua](bots/Customize/general.lua)
   - Which Customize file you should change?
      1. Make sure to select Open Hyper AI as the script in custom lobby.
      1. If you have NOT installed the script via `quick-install-oha.bat`, simply update settings in <Steam\steamapps\workshop\content\570\3246316298\Customize>
      2. If you have installed the script via `quick-install-oha.bat`, update settings in <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize>
1. Pos1 and Pos5 bots go to safe lane. Pos3 and Pos4 bots go offlane. Pos2 bot goes to mid lane.

## Support multiple in-game commands
1. `!pos X` You can type: `!pos X` to swap the position with a bot. For example: `!pos 2` to swap role and lane with the bot that's going to mid.
1. `!pick XXX` During hero selection phase, you can type: `!pick XXX` to pick a hero. For example: `!pick puck` to pick puck as ally.
   1. You can type: `/all !pick XXX` to pick hero for enemy. For example: `/all !pick puck` to pick puck as enemy.
   1. For complex hero names or names that may apply to multiple heroes, please use the full internal code name. For example: `!pick npc_dota_hero_keeper_of_the_light` .
   1. You can find a list of hero's internal code names in here: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71
1. `!Xpos Y` Swap other players' positions without changing your position. For example you can use `!3pos 5` to tell the 3rd bot on the team to play pos 5.
1. `!ban XXX` You can type: `!ban XXX` to ban a hero so the bots won't pick that hero. For example: `!ban puck` to prevent any bots from picking puck.
1. `!sp XX` You can type `!sp en` or `!speak zh` to do localization - make bots talk in English, or other languages like: `!sp zh` for `Chinese`, `!sp ru` for `Russian`, `!sp ja` for `Japanese`, for now. 
   1. Note, if you use this localization command after the hero selection phase is started, this switch only works for your *ally* bots
      1. Enemy bots will use default language, so you better change the setting in [Customize/general.lua](bots/Customize/general.lua) . 
   1. For all ally & enemy bots, you should set `Customize.Localization` in [Customize/general.lua](bots/Customize/general.lua).
1. Batch commands. You can put pick/ban multiple heroes at once by putting the commands in 1 line, for example: `!pick sand king; !pick io; !ban zuus; !ban sniper` .

## Contribute to this script
1. Please feel very welcome to contribute to the Github repo any time you like. Just update the logic and create a pull request.
1. Note if you just changing the item purcahes, or ability upgrades, etc, these don't really need a pull request because everyone has their own favorites, just chekc out [Customize/hero/viper.lua](bots/Customize/hero/viper.lua)
1. Future development work for this script will be written in typescript as possible: [typescript/README](typescript/README.md).
1. The typescipt source code is as well work-in-progress, feel free to convert more lua files to ts, and add libs/modules as you feel necessary.
1. Project structure:
```
root: <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts>
│
└───bots: contains all lua files for the bot logic. This is the folder `3246316298` in Workshop.
│   │   hero_selection.lua
│   │   bot_generic.lua
│   │   ...
│   │
│   └───Funlib: contains the libraries/utils of this project
│   │   │   utils.lua
│   │   │   ...
│   │
│   └───Customize: contains the files for you to easily customzie the settings for bots in this project
│   │   │   general.lua: to customzie the settings for each bot teams
│   │   │   ...
│   │   │
│   │   └───hero: to easily customzie each of the bots in this project
│   │       │   viper.lua
│   │       │   ...
│   │
│   └───BotLib: contains the bot item purcahse, ability usage, etc logic for every bots.
│       │   hero_abaddon.lua
│       │   ...
│   
└───typescript: contains the scripts written in typescript (TS) to maintain this project in a more 
│   │           extendable way since TS supports types and can catch errors in compile time.
│   │
│   └───bots: the TS version of the script that's converted to LUA files into the `root/bots` folder.
│   │   │   ...
│   │
│   └───post-process: contains the scripts to do post-processing for the TS to LUA translation.
│   │   ...
│   
└───game: default setup from Value, including them here for custom mode setup.
│   │   botsinit.lua
│   │   ...
│   │
│   └───Customize: You can copy & paste the Customize folder from <root/bots> to <root/game> to avoid
│                  the custom settings getting replaced/overridden by workshop upgrades.
│   ...

```

## What's next
0. Ultimately, the bots play style is static/fixed with the current AI approach provided by Valve at the moment. We need ML or LLM enhanced AI bots! Just like the AIs we’ve seen from OpenAI Five.
1. Improvements to be done: https://github.com/forest0xia/dota2bot-OpenHyperAI/issues?q=is%3Aissue+is%3Aopen+%5BFeature+request%5D
1. Follow up on https://www.reddit.com/r/DotA2/comments/1ezxpav/a_note_to_valve_official_regarding_bot_scripts/
1. Better decision making on laning, pushing and ganking.
1. Support all game modes.
1. Code fixes for new Dota2 patches.
1. Better spell casting for certain heroes like Invoker, Rubick, Morph, etc.
1. Figure out how to better support the Bugged-Heroes: Dark Willow, Elder Titan, Hoodwink, io, Lone Druid, Marci, Muerta, Primal Beast. Note that they are buggy due to problems on the Valves side, not script developers.

## Support the script
1. Please feel very welcome to contribute to the Github repo.
2. If you'd like to buy me a coffee: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/74

## Useful resources:
- Posts shared by Ranked Matchmaking AI author: https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html
- Official Bot side script intro: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Lua (Bots side) APIs: https://docs.moddota.com/lua_bots/
- Ability metadata: https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt
- Lua APIs, modes, and enum values: https://moddota.com/api/#!/vscripts/dotaunitorder_t
- Bot modifier names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota2 data mining (details of items, abilities, heroes): https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json

## Credits to
This script is based on Valve's default bot script and many other people's work and their scripts. That being said, this is a partial override not completely take over bot script. It takes the advantages of some other existing bot scripts and aims to be a better off script than the existing ones. We hope the bot's decision making and team strategies are more effective and brings more joy to you.

- New Beginner AI (by dota2jmz@163.com). Awesome work to bring Valve default bots to next level.
- Tinkering ABout (by @ryndrb: https://github.com/ryndrb/dota2bot or https://steamcommunity.com/sharedfiles/filedetails/?id=3139791706).
- New beginner ai (by dota2jmz@163.com).
- Ranked Matchmaking AI (by adamqqq, https://github.com/adamqqqplay/dota2ai)
- fretbots (by fretmute, https://github.com/fretmute/fretbots)
- BOT Experiment (by Furiospuppy)
- ExtremePush (https://github.com/insraq/dota2bots)
- All other bot script authors/contributors that had made bot scripts interesting.
