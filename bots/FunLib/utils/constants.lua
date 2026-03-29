--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____dota = require("bots.ts_libs.dota.index")
local Barracks = ____dota.Barracks
local BotScriptEnums = ____dota.BotScriptEnums
local Lane = ____dota.Lane
local Team = ____dota.Team
local Tower = ____dota.Tower
local ____heroes = require("bots.ts_libs.dota.heroes")
local HeroName = ____heroes.HeroName
____exports.DebugMode = false
____exports.ScriptID = 3246316298
____exports.RadiantFountainTpPoint = Vector(-7172, -6652, 384)
____exports.DireFountainTpPoint = Vector(6982, 6422, 392)
____exports.RadiantRoshanLoc = Vector(-2984, 2349, 1092)
____exports.DireRoshanLoc = Vector(2980, -2816, 1107)
____exports.BarrackList = {
    Barracks.TopMelee,
    Barracks.TopRanged,
    Barracks.MidMelee,
    Barracks.MidRanged,
    Barracks.BotMelee,
    Barracks.BotRanged
}
____exports.WisdomRunes = {
    [Team.Radiant] = Vector(-8126, -320, 256),
    [Team.Dire] = Vector(8319, 266, 256)
}
____exports.BuggyHeroesDueToValveTooLazy = {
    [HeroName.Muerta] = true,
    [HeroName.Marci] = true,
    [HeroName.LoneDruidBear] = true,
    [HeroName.PrimalBeast] = true,
    [HeroName.DarkWillow] = true,
    [HeroName.ElderTitan] = true,
    [HeroName.Hoodwink] = true,
    [HeroName.IO] = true,
    [HeroName.Kez] = true
}
____exports.HighGroundTowers = {
    Tower.Top3,
    Tower.Mid3,
    Tower.Bot3,
    Tower.Base1,
    Tower.Base2
}
____exports.FirstTierTowers = {Tower.Top1, Tower.Mid1, Tower.Bot1}
____exports.SecondTierTowers = {Tower.Top2, Tower.Mid2, Tower.Bot2}
____exports.AllTowers = {
    Tower.Top1,
    Tower.Mid1,
    Tower.Bot1,
    Tower.Top2,
    Tower.Mid2,
    Tower.Bot2,
    Tower.Top3,
    Tower.Mid3,
    Tower.Bot3,
    Tower.Base1,
    Tower.Base2
}
____exports.NonTier1Towers = {
    Tower.Top2,
    Tower.Mid2,
    Tower.Bot2,
    Tower.Top3,
    Tower.Mid3,
    Tower.Bot3,
    Tower.Base1,
    Tower.Base2
}
____exports.CachedVarsCleanTime = 5
--- Some specific heroes with hugh potential AOE damages.
-- Map each "special AOE hero" to its threat conditions.
____exports.SpecialAOEHeroesDetails = {
    [HeroName.Axe] = {minLevel = 4, requiredItems = {}, requiredModifiers = {}},
    [HeroName.Enigma] = {minLevel = 6, requiredItems = {}, requiredModifiers = {}},
    [HeroName.Earthshaker] = {minLevel = 6, requiredItems = {"item_blink"}, requiredModifiers = {}},
    [HeroName.Invoker] = {minLevel = 9, requiredItems = {}, requiredModifiers = {}},
    [HeroName.SandKing] = {minLevel = 6, requiredItems = {"item_blink"}, requiredModifiers = {}},
    [HeroName.TrollWarlord] = {minLevel = 6, requiredItems = {"item_bfury"}, requiredModifiers = {"modifier_troll_warlord_battle_trance"}}
}
--- A mapping from hero name to an array of important spell(s)
-- that have long cooldowns and can drastically change a team fight.
____exports.ImportantSpells = {
    [HeroName.Alchemist] = {"alchemist_chemical_rage"},
    [HeroName.Axe] = {"axe_culling_blade"},
    [HeroName.Bristleback] = {"bristleback_bristleback"},
    [HeroName.Centaur] = {"centaur_stampede"},
    [HeroName.ChaosKnight] = {"chaos_knight_phantasm"},
    [HeroName.Dawnbreaker] = {"dawnbreaker_solar_guardian"},
    [HeroName.Doom] = {"doom_bringer_doom"},
    [HeroName.DragonKnight] = {"dragon_knight_elder_dragon_form"},
    [HeroName.EarthSpirit] = {"earth_spirit_magnetize"},
    [HeroName.Earthshaker] = {"earthshaker_echo_slam"},
    [HeroName.ElderTitan] = {"elder_titan_earth_splitter"},
    [HeroName.Kunkka] = {"kunkka_ghostship"},
    [HeroName.LegionCommander] = {"legion_commander_duel"},
    [HeroName.Lifestealer] = {"life_stealer_rage"},
    [HeroName.Mars] = {"mars_arena_of_blood"},
    [HeroName.NightStalker] = {"night_stalker_darkness"},
    [HeroName.Omniknight] = {"omniknight_guardian_angel"},
    [HeroName.PrimalBeast] = {"primal_beast_pulverize"},
    [HeroName.Sven] = {"sven_gods_strength"},
    [HeroName.Tidehunter] = {"tidehunter_ravage"},
    [HeroName.TreantProtector] = {"treant_overgrowth"},
    [HeroName.Undying] = {"undying_tombstone", "undying_flesh_golem"},
    [HeroName.WraithKing] = {"skeleton_king_reincarnation"},
    [HeroName.Antimage] = {"antimage_mana_void"},
    [HeroName.Bloodseeker] = {"bloodseeker_rupture"},
    [HeroName.Clinkz] = {"clinkz_burning_barrage"},
    [HeroName.FacelessVoid] = {"faceless_void_chronosphere"},
    [HeroName.Gyrocopter] = {"gyrocopter_flak_cannon"},
    [HeroName.Hoodwink] = {"hoodwink_sharpshooter"},
    [HeroName.Juggernaut] = {"juggernaut_omni_slash"},
    [HeroName.Luna] = {"luna_eclipse"},
    [HeroName.Medusa] = {"medusa_stone_gaze"},
    [HeroName.MonkeyKing] = {"monkey_king_wukongs_command"},
    [HeroName.NagaSiren] = {"naga_siren_song_of_the_siren"},
    [HeroName.Razor] = {"razor_static_link"},
    [HeroName.ShadowFiend] = {"nevermore_requiem"},
    [HeroName.Slark] = {"slark_shadow_dance"},
    [HeroName.Spectre] = {"spectre_shadow_step", "spectre_haunt"},
    [HeroName.Terrorblade] = {"terrorblade_metamorphosis", "terrorblade_sunder"},
    [HeroName.TrollWarlord] = {"troll_warlord_battle_trance"},
    [HeroName.Ursa] = {"ursa_enrage"},
    [HeroName.Viper] = {"viper_viper_strike"},
    [HeroName.Weaver] = {"weaver_time_lapse"},
    [HeroName.AncientApparition] = {"ancient_apparition_ice_blast"},
    [HeroName.CrystalMaiden] = {"crystal_maiden_freezing_field"},
    [HeroName.DeathProphet] = {"death_prophet_exorcism"},
    [HeroName.Disruptor] = {"disruptor_static_storm"},
    [HeroName.Grimstroke] = {"grimstroke_dark_portrait", "grimstroke_soul_chain"},
    [HeroName.Jakiro] = {"jakiro_macropyre"},
    [HeroName.Lich] = {"lich_chain_frost"},
    [HeroName.Lina] = {"lina_laguna_blade"},
    [HeroName.Lion] = {"lion_finger_of_death"},
    [HeroName.Muerta] = {"muerta_pierce_the_veil"},
    [HeroName.Necrophos] = {"necrolyte_ghost_shroud", "necrolyte_reapers_scythe"},
    [HeroName.Oracle] = {"oracle_false_promise"},
    [HeroName.OutworldDestroyer] = {"obsidian_destroyer_sanity_eclipse"},
    [HeroName.Puck] = {"puck_dream_coil"},
    [HeroName.Pugna] = {"pugna_life_drain"},
    [HeroName.QueenOfPain] = {"queenofpain_sonic_wave"},
    [HeroName.Ringmaster] = {"ringmaster_wheel"},
    [HeroName.ShadowDeamon] = {"shadow_demon_disruption", "shadow_demon_demonic_cleanse", "shadow_demon_demonic_purge"},
    [HeroName.ShadowShaman] = {"shadow_shaman_mass_serpent_ward"},
    [HeroName.Silencer] = {"silencer_global_silence"},
    [HeroName.SkywrathMage] = {"skywrath_mage_mystic_flare"},
    [HeroName.Warlock] = {"warlock_fatal_bonds", "warlock_golem"},
    [HeroName.WitchDoctor] = {"witch_doctor_voodoo_switcheroo", "witch_doctor_death_ward"},
    [HeroName.Zeus] = {"zuus_thundergods_wrath"},
    [HeroName.Abaddon] = {"abaddon_borrowed_time"},
    [HeroName.Bane] = {"bane_fiends_grip"},
    [HeroName.Batrider] = {"batrider_flaming_lasso"},
    [HeroName.Beastmaster] = {"beastmaster_primal_roar"},
    [HeroName.Brewmaster] = {"brewmaster_primal_split"},
    [HeroName.Broodmother] = {"broodmother_insatiable_hunger"},
    [HeroName.Chen] = {"chen_hand_of_god"},
    [HeroName.DarkSeer] = {"dark_seer_wall_of_replica"},
    [HeroName.DarkWillow] = {"dark_willow_terrorize"},
    [HeroName.Enigma] = {"enigma_black_hole"},
    [HeroName.Lycan] = {"lycan_shapeshift"},
    [HeroName.Magnus] = {"magnataur_reverse_polarity"},
    [HeroName.Marci] = {"marci_unleash"},
    [HeroName.Pangolier] = {"pangolier_gyroshell"},
    [HeroName.Phoenix] = {"phoenix_supernova"},
    [HeroName.SandKing] = {"sandking_epicenter"},
    [HeroName.Snapfire] = {"snapfire_mortimer_kisses"},
    [HeroName.VengefulSpirit] = {"vengefulspirit_nether_swap"},
    [HeroName.Venomancer] = {"venomancer_noxious_plague"},
    [HeroName.Windrunner] = {"windrunner_focusfire"},
    [HeroName.WinterWyvern] = {"winter_wyvern_cold_embrace", "winter_wyvern_winters_curse"}
}
____exports.ImportantItems = {"item_black_king_bar", "item_refresher"}
____exports.GameStates = {defendPings = nil, recentDefendTime = -200, cachedVars = nil, twinGates = {}}
____exports.LoneDruid = {}
____exports.FrameProcessTime = 0.06
____exports.EstimatedEnemyRoles = {npc_dota_hero_any = {lane = Lane.Mid, role = 2}}
____exports.BARRACKS = {
    Barracks.TopMelee,
    Barracks.TopRanged,
    Barracks.MidMelee,
    Barracks.MidRanged,
    Barracks.BotMelee,
    Barracks.BotRanged
}
____exports.LEVEL_3_TOWERS = {Tower.Top3, Tower.Mid3, Tower.Bot3}
____exports.specialOffensiveHeroes = {HeroName.ArcWarden, HeroName.Phoenix, HeroName.Terrorblade}
____exports.meaningfulActivities = {
    ACTIVITY_RUN,
    ACTIVITY_ATTACK,
    ACTIVITY_ATTACK2,
    ACTIVITY_ATTACK_EVENT,
    ACTIVITY_CAST_ABILITY_1,
    ACTIVITY_CAST_ABILITY_2,
    ACTIVITY_CAST_ABILITY_3,
    ACTIVITY_CAST_ABILITY_4,
    ACTIVITY_CAST_ABILITY_5,
    ACTIVITY_CAST_ABILITY_6,
    ACTIVITY_CHANNEL_ABILITY_1,
    ACTIVITY_CHANNEL_ABILITY_2,
    ACTIVITY_CHANNEL_ABILITY_3,
    ACTIVITY_CHANNEL_ABILITY_4,
    ACTIVITY_CHANNEL_ABILITY_5,
    ACTIVITY_CHANNEL_ABILITY_6
}
return ____exports
