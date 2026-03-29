// utils/constants.ts - Auto-generated sub-module

import { Barracks, BotScriptEnums, Lane, Team, Tower } from "bots/ts_libs/dota";
import { GameState } from "bots/ts_libs/bots";
import { HeroName } from "bots/ts_libs/dota/heroes";


export const DebugMode = false;




export const ScriptID = 3246316298;




export const RadiantFountainTpPoint = Vector(-7172, -6652, 384);


export const DireFountainTpPoint = Vector(6982, 6422, 392);


export const RadiantRoshanLoc = Vector(-2984, 2349, 1092);


export const DireRoshanLoc = Vector(2980, -2816, 1107);


export const BarrackList: Barracks[] = [Barracks.TopMelee, Barracks.TopRanged, Barracks.MidMelee, Barracks.MidRanged, Barracks.BotMelee, Barracks.BotRanged];


export const WisdomRunes = {
    [Team.Radiant]: Vector(-8126, -320, 256),
    [Team.Dire]: Vector(8319, 266, 256),
};




// Bugged heroes, see: https://www.reddit.com/r/DotA2/comments/1ezxpav
export const BuggyHeroesDueToValveTooLazy = {
    [HeroName.Muerta]: true,
    [HeroName.Marci]: true,
    [HeroName.LoneDruidBear]: true,
    [HeroName.PrimalBeast]: true,
    [HeroName.DarkWillow]: true,
    [HeroName.ElderTitan]: true,
    [HeroName.Hoodwink]: true,
    [HeroName.IO]: true,
    [HeroName.Kez]: true,
};




export const HighGroundTowers = [Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];




export const FirstTierTowers = [Tower.Top1, Tower.Mid1, Tower.Bot1];




export const SecondTierTowers = [Tower.Top2, Tower.Mid2, Tower.Bot2];




export const AllTowers = [Tower.Top1, Tower.Mid1, Tower.Bot1, Tower.Top2, Tower.Mid2, Tower.Bot2, Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];




export const NonTier1Towers = [Tower.Top2, Tower.Mid2, Tower.Bot2, Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];




export const CachedVarsCleanTime = 5;




/**
 * Data structure describing "special AOE" threats
 * and what conditions must be met before we consider them dangerous.
 */
export interface AOEHeroThreat {
    // Minimum level the hero must be at to be considered dangerous
    minLevel: number;

    // Items the hero must have to be considered dangerous (e.g. item_bfury, item_blink, etc.)
    requiredItems: string[];

    // Modifiers the hero must have active
    // (e.g. "modifier_troll_warlord_battle_trance")
    requiredModifiers: string[];
}




/**
 * Some specific heroes with hugh potential AOE damages.
 * Map each "special AOE hero" to its threat conditions.
 */
export const SpecialAOEHeroesDetails: Record<string, AOEHeroThreat> = {
    [HeroName.Axe]: {
        minLevel: 4,
        requiredItems: [], //["item_blink"],
        requiredModifiers: [], // e.g. no special modifier needed to be a threat
    },
    [HeroName.Enigma]: {
        minLevel: 6,
        requiredItems: [], //["item_blink"],
        // or maybe no item needed if you consider black hole a threat at all times
        requiredModifiers: [
            // Some teams prefer checking if Enigma has the black hole ability off cooldown,
            // but for simplicity, let's assume we just check if he's Enigma + blink?
        ],
    },
    [HeroName.Earthshaker]: {
        minLevel: 6,
        requiredItems: ["item_blink"],
        requiredModifiers: [], // Echo Slam threat
    },
    [HeroName.Invoker]: {
        minLevel: 9, // maybe require some levels for big combo
        requiredItems: [],
        requiredModifiers: [],
    },
    [HeroName.SandKing]: {
        minLevel: 6,
        requiredItems: ["item_blink"],
        requiredModifiers: [], // Epi center is the threat
    },
    [HeroName.TrollWarlord]: {
        minLevel: 6,
        requiredItems: ["item_bfury"],
        requiredModifiers: ["modifier_troll_warlord_battle_trance"],
    },
    // more to add ...
};




/**
 * A mapping from hero name to an array of important spell(s)
 * that have long cooldowns and can drastically change a team fight.
 */
export const ImportantSpells: Record<string, string[]> = {
    // Strength
    [HeroName.Alchemist]: ["alchemist_chemical_rage"],
    [HeroName.Axe]: ["axe_culling_blade"],
    [HeroName.Bristleback]: ["bristleback_bristleback"],
    [HeroName.Centaur]: ["centaur_stampede"],
    [HeroName.ChaosKnight]: ["chaos_knight_phantasm"],
    [HeroName.Dawnbreaker]: ["dawnbreaker_solar_guardian"],
    [HeroName.Doom]: ["doom_bringer_doom"],
    [HeroName.DragonKnight]: ["dragon_knight_elder_dragon_form"],
    [HeroName.EarthSpirit]: ["earth_spirit_magnetize"],
    [HeroName.Earthshaker]: ["earthshaker_echo_slam"],
    [HeroName.ElderTitan]: ["elder_titan_earth_splitter"],
    // huskar missing from list – add as needed
    [HeroName.Kunkka]: ["kunkka_ghostship"],
    [HeroName.LegionCommander]: ["legion_commander_duel"],
    [HeroName.Lifestealer]: ["life_stealer_rage"],
    [HeroName.Mars]: ["mars_arena_of_blood"],
    [HeroName.NightStalker]: ["night_stalker_darkness"],
    [HeroName.Omniknight]: ["omniknight_guardian_angel"],
    [HeroName.PrimalBeast]: ["primal_beast_pulverize"],
    // pudge, slardar, spirit_breaker missing
    [HeroName.Sven]: ["sven_gods_strength"],
    [HeroName.Tidehunter]: ["tidehunter_ravage"],
    // timbersaw, tiny missing
    [HeroName.TreantProtector]: ["treant_overgrowth"],
    // tusk missing
    [HeroName.Undying]: ["undying_tombstone", "undying_flesh_golem"],
    // Wraith King's internal name was once skeleton_king. Keep as needed:
    [HeroName.WraithKing]: ["skeleton_king_reincarnation"],

    // Agility
    [HeroName.Antimage]: ["antimage_mana_void"],
    // arc_warden missing
    [HeroName.Bloodseeker]: ["bloodseeker_rupture"],
    // bounty_hunter missing
    [HeroName.Clinkz]: ["clinkz_burning_barrage"],
    // drow_ranger, ember_spirit missing
    [HeroName.FacelessVoid]: ["faceless_void_chronosphere"],
    [HeroName.Gyrocopter]: ["gyrocopter_flak_cannon"],
    [HeroName.Hoodwink]: ["hoodwink_sharpshooter"],
    [HeroName.Juggernaut]: ["juggernaut_omni_slash"],
    // keeling? Possibly a custom or incomplete
    [HeroName.Luna]: ["luna_eclipse"],
    [HeroName.Medusa]: ["medusa_stone_gaze"],
    // meepo missing
    [HeroName.MonkeyKing]: ["monkey_king_wukongs_command"],
    // morphling missing
    [HeroName.NagaSiren]: ["naga_siren_song_of_the_siren"],
    // phantom_assassin, phantom_lancer missing
    [HeroName.Razor]: ["razor_static_link"],
    // riki missing
    [HeroName.ShadowFiend]: ["nevermore_requiem"],
    [HeroName.Slark]: ["slark_shadow_dance"],
    // sniper missing
    [HeroName.Spectre]: ["spectre_shadow_step", "spectre_haunt"],
    // templar_assassin missing
    [HeroName.Terrorblade]: ["terrorblade_metamorphosis", "terrorblade_sunder"],
    [HeroName.TrollWarlord]: ["troll_warlord_battle_trance"],
    [HeroName.Ursa]: ["ursa_enrage"],
    [HeroName.Viper]: ["viper_viper_strike"],
    [HeroName.Weaver]: ["weaver_time_lapse"],

    // Intelligence
    [HeroName.AncientApparition]: ["ancient_apparition_ice_blast"],
    [HeroName.CrystalMaiden]: ["crystal_maiden_freezing_field"],
    [HeroName.DeathProphet]: ["death_prophet_exorcism"],
    [HeroName.Disruptor]: ["disruptor_static_storm"],
    // enchantress missing
    [HeroName.Grimstroke]: ["grimstroke_dark_portrait", "grimstroke_soul_chain"],
    [HeroName.Jakiro]: ["jakiro_macropyre"],
    // keeper_of_the_light, leshrac missing
    [HeroName.Lich]: ["lich_chain_frost"],
    [HeroName.Lina]: ["lina_laguna_blade"],
    [HeroName.Lion]: ["lion_finger_of_death"],
    [HeroName.Muerta]: ["muerta_pierce_the_veil"],
    // furion (nature's prophet) missing
    [HeroName.Necrophos]: ["necrolyte_ghost_shroud", "necrolyte_reapers_scythe"],
    [HeroName.Oracle]: ["oracle_false_promise"],
    [HeroName.OutworldDestroyer]: ["obsidian_destroyer_sanity_eclipse"],
    [HeroName.Puck]: ["puck_dream_coil"],
    [HeroName.Pugna]: ["pugna_life_drain"],
    [HeroName.QueenOfPain]: ["queenofpain_sonic_wave"],
    [HeroName.Ringmaster]: ["ringmaster_wheel"], // likely custom hero
    // rubick missing
    [HeroName.ShadowDeamon]: ["shadow_demon_disruption", "shadow_demon_demonic_cleanse", "shadow_demon_demonic_purge"],
    [HeroName.ShadowShaman]: ["shadow_shaman_mass_serpent_ward"],
    [HeroName.Silencer]: ["silencer_global_silence"],
    [HeroName.SkywrathMage]: ["skywrath_mage_mystic_flare"],
    // storm_spirit, tinker missing
    [HeroName.Warlock]: ["warlock_fatal_bonds", "warlock_golem"],
    [HeroName.WitchDoctor]: ["witch_doctor_voodoo_switcheroo", "witch_doctor_death_ward"],
    [HeroName.Zeus]: ["zuus_thundergods_wrath"],

    // Universal
    [HeroName.Abaddon]: ["abaddon_borrowed_time"],
    [HeroName.Bane]: ["bane_fiends_grip"],
    [HeroName.Batrider]: ["batrider_flaming_lasso"],
    [HeroName.Beastmaster]: ["beastmaster_primal_roar"],
    [HeroName.Brewmaster]: ["brewmaster_primal_split"],
    [HeroName.Broodmother]: ["broodmother_insatiable_hunger"],
    [HeroName.Chen]: ["chen_hand_of_god"],
    // clockwerk missing
    [HeroName.DarkSeer]: ["dark_seer_wall_of_replica"],
    [HeroName.DarkWillow]: ["dark_willow_terrorize"],
    // dazzle missing
    [HeroName.Enigma]: ["enigma_black_hole"],
    // invoker, io, lone_druid missing
    [HeroName.Lycan]: ["lycan_shapeshift"],
    [HeroName.Magnus]: ["magnataur_reverse_polarity"],
    [HeroName.Marci]: ["marci_unleash"],
    // mirana, nyx_assassin missing
    [HeroName.Pangolier]: ["pangolier_gyroshell"],
    [HeroName.Phoenix]: ["phoenix_supernova"],
    [HeroName.SandKing]: ["sandking_epicenter"],
    [HeroName.Snapfire]: ["snapfire_mortimer_kisses"],
    // techies missing
    [HeroName.VengefulSpirit]: ["vengefulspirit_nether_swap"],
    [HeroName.Venomancer]: ["venomancer_noxious_plague"],
    // visage, void_spirit missing
    [HeroName.Windrunner]: ["windrunner_focusfire"],
    [HeroName.WinterWyvern]: ["winter_wyvern_cold_embrace", "winter_wyvern_winters_curse"],
};




export const ImportantItems: string[] = ["item_black_king_bar", "item_refresher"];




// Some gaming state keepers to keep a record of different states to avoid recomupte or anything.
export const GameStates: GameState = {
    defendPings: null,
    recentDefendTime: -200,
    cachedVars: null,
    twinGates: [],
};


export const LoneDruid = {} as { [key: number]: any };


export const FrameProcessTime = 0.06;




export const EstimatedEnemyRoles = {
    // sample role entry
    npc_dota_hero_any: {
        lane: Lane.Mid,
        role: 2,
    },
} as { [key: string]: any };




export const BARRACKS = [Barracks.TopMelee, Barracks.TopRanged, Barracks.MidMelee, Barracks.MidRanged, Barracks.BotMelee, Barracks.BotRanged];


export const LEVEL_3_TOWERS = [Tower.Top3, Tower.Mid3, Tower.Bot3];



export const specialOffensiveHeroes = [HeroName.ArcWarden, HeroName.Phoenix, HeroName.Terrorblade];



// Check for meaningful animation activities
export const meaningfulActivities = [
    BotScriptEnums.ACTIVITY_RUN, // Bot is running/moving
    BotScriptEnums.ACTIVITY_ATTACK, // Bot is attacking
    BotScriptEnums.ACTIVITY_ATTACK2, // Bot is performing secondary attack
    BotScriptEnums.ACTIVITY_ATTACK_EVENT, // Bot is in attack event
    BotScriptEnums.ACTIVITY_CAST_ABILITY_1, // Bot is casting ability 1
    BotScriptEnums.ACTIVITY_CAST_ABILITY_2, // Bot is casting ability 2
    BotScriptEnums.ACTIVITY_CAST_ABILITY_3, // Bot is casting ability 3
    BotScriptEnums.ACTIVITY_CAST_ABILITY_4, // Bot is casting ability 4
    BotScriptEnums.ACTIVITY_CAST_ABILITY_5, // Bot is casting ability 5
    BotScriptEnums.ACTIVITY_CAST_ABILITY_6, // Bot is casting ability 6
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_1, // Bot is channeling ability 1
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_2, // Bot is channeling ability 2
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_3, // Bot is channeling ability 3
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_4, // Bot is channeling ability 4
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_5, // Bot is channeling ability 5
    BotScriptEnums.ACTIVITY_CHANNEL_ABILITY_6, // Bot is channeling ability 6
];


