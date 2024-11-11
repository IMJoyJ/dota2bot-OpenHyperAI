local HeroPositionMap = {
    ['npc_dota_hero_abaddon'] = {5, 5, 30, 10, 50},      -- Positions 3,5; some 4,1,2
    ['npc_dota_hero_abyssal_underlord'] = {5, 10, 80, 5, 0}, -- Positions 3 primarily, some mid, safe
    ['npc_dota_hero_alchemist'] = {50, 30, 15, 5, 0},    -- Positions 1,2,3
    ['npc_dota_hero_ancient_apparition'] = {5, 5, 10, 30, 50}, -- Positions 5,4; some mid
    ['npc_dota_hero_antimage'] = {90, 5, 5, 0, 0},       -- Positions 1, occasional mid/offlane
    ['npc_dota_hero_arc_warden'] = {30, 60, 5, 5, 0},    -- Positions 2,1
    ['npc_dota_hero_axe'] = {15, 5, 75, 5, 0},            -- Positions 3, occasional jungle/support
    ['npc_dota_hero_bane'] = {0, 20, 10, 30, 40},         -- Positions 5,4
    ['npc_dota_hero_batrider'] = {5, 60, 30, 5, 0},      -- Positions 2,3
    ['npc_dota_hero_beastmaster'] = {5, 25, 65, 5, 0},    -- Positions 3, occasional mid
    ['npc_dota_hero_bloodseeker'] = {45, 30, 25, 0, 0},   -- Positions 1,2
    ['npc_dota_hero_bounty_hunter'] = {0, 45, 10, 50, 35},-- Positions 4,5, occasional offlane
    ['npc_dota_hero_brewmaster'] = {5, 5, 85, 5, 0},     -- Positions 3, occasional mid
    ['npc_dota_hero_bristleback'] = {30, 10, 60, 0, 0}, -- Versatile core roles
    ['npc_dota_hero_broodmother'] = {15, 60, 20, 5, 0},   -- Positions 2,3
    ['npc_dota_hero_centaur'] = {5, 5, 85, 5, 0},        -- Offlane, occasional support
    ['npc_dota_hero_chaos_knight'] = {65, 10, 25, 0, 0},  -- Positions 1,2
    ['npc_dota_hero_chen'] = {0, 5, 10, 20, 45},         -- Positions 5,4
    ['npc_dota_hero_clinkz'] = {40, 45, 5, 10, 0},       -- Positions 1,2
    ['npc_dota_hero_crystal_maiden'] = {0, 5, 10, 30, 55},-- Positions 5,4
    ['npc_dota_hero_dark_seer'] = {5, 5, 80, 10, 0},     -- Positions 3, occasional mid/support
    ['npc_dota_hero_dark_willow'] = {0, 5, 10, 30, 25},  -- Positions 4,5
    ['npc_dota_hero_dawnbreaker'] = {5, 10, 75, 10, 0},  -- Positions 3,2
    ['npc_dota_hero_dazzle'] = {0, 45, 10, 30, 55},       -- Positions 5,4
    ['npc_dota_hero_disruptor'] = {0, 5, 10, 30, 55},    -- Positions 5,4
    ['npc_dota_hero_death_prophet'] = {5, 60, 30, 5, 0}, -- Positions 2,3
    ['npc_dota_hero_doom_bringer'] = {5, 5, 85, 5, 0},   -- Positions 3, occasional mid
    ['npc_dota_hero_dragon_knight'] = {5, 70, 15, 10, 0},-- Positions 2,3, occasional carry
    ['npc_dota_hero_drow_ranger'] = {70, 25, 5, 0, 0},    -- Positions 1, occasional mid
    ['npc_dota_hero_earth_spirit'] = {0, 5, 10, 70, 15}, -- Positions 4,5
    ['npc_dota_hero_earthshaker'] = {0, 5, 10, 70, 15},  -- Positions 4,5
    ['npc_dota_hero_elder_titan'] = {0, 5, 10, 30, 15},  -- Positions 4,5
    ['npc_dota_hero_ember_spirit'] = {15, 70, 15, 0, 0},   -- Positions 2,1
    ['npc_dota_hero_enchantress'] = {0, 5, 10, 35, 50},  -- Positions 5,4, occasional offlane
    ['npc_dota_hero_enigma'] = {0, 5, 85, 10, 0},        -- Positions 3,4
    ['npc_dota_hero_faceless_void'] = {80, 0, 15, 5, 0},  -- Positions 1, occasional offlane
    ['npc_dota_hero_furion'] = {5, 5, 80, 10, 0},        -- Positions 3, occasional mid/support
    ['npc_dota_hero_grimstroke'] = {0, 5, 10, 35, 50},   -- Positions 5,4
    ['npc_dota_hero_gyrocopter'] = {60, 5, 5, 20, 10},   -- Positions 1, occasional support
    ['npc_dota_hero_hoodwink'] = {0, 5, 10, 20, 15},     -- Positions 4,5
    ['npc_dota_hero_huskar'] = {25, 50, 25, 0, 0},         -- Positions 2,1
    ['npc_dota_hero_invoker'] = {20, 50, 20, 10, 0},        -- Positions 2, occasional carry
    ['npc_dota_hero_jakiro'] = {0, 5, 10, 30, 55},       -- Positions 5,4
    ['npc_dota_hero_juggernaut'] = {80, 5, 15, 0, 0},     -- Positions 1, occasional mid
    ['npc_dota_hero_keeper_of_the_light'] = {0, 5, 10, 25, 30}, -- Positions 5,4
    ['npc_dota_hero_kunkka'] = {5, 85, 5, 5, 0},         -- Positions 2,3
    ['npc_dota_hero_legion_commander'] = {5, 25, 65, 5, 0},-- Positions 3, occasional mid
    ['npc_dota_hero_leshrac'] = {5, 65, 25, 5, 0},        -- Positions 2,3
    ['npc_dota_hero_lich'] = {0, 20, 10, 30, 40},         -- Positions 5,4
    ['npc_dota_hero_life_stealer'] = {60, 5, 35, 0, 0},   -- Positions 1, occasional offlane
    ['npc_dota_hero_lina'] = {25, 50, 5, 20, 0},           -- Positions 2,1
    ['npc_dota_hero_lion'] = {0, 15, 10, 30, 45},         -- Positions 5,4
    ['npc_dota_hero_lone_druid'] = {20, 25, 15, 0, 0},    -- Positions 1,2
    ['npc_dota_hero_luna'] = {70, 5, 15, 0, 0},           -- Positions 1, occasional mid
    ['npc_dota_hero_lycan'] = {45, 45, 45, 5, 0},          -- Positions 3, occasional mid
    ['npc_dota_hero_magnataur'] = {5, 5, 85, 5, 0},      -- Positions 3, occasional mid
    ['npc_dota_hero_marci'] = {0, 5, 20, 20, 15},        -- Positions 4,5
    ['npc_dota_hero_mars'] = {5, 45, 55, 5, 0},           -- Positions 3, occasional mid
    ['npc_dota_hero_medusa'] = {50, 45, 5, 0, 0},         -- Positions 1, occasional mid
    ['npc_dota_hero_meepo'] = {35, 60, 5, 0, 0},          -- Positions 2,1
    ['npc_dota_hero_mirana'] = {0, 5, 10, 65, 20},       -- Positions 4,5
    ['npc_dota_hero_morphling'] = {20, 15, 5, 0, 0},      -- Positions 1, occasional mid
    ['npc_dota_hero_monkey_king'] = {50, 25, 25, 0, 0},   -- Positions 1,2
    ['npc_dota_hero_naga_siren'] = {70, 5, 5, 0, 0},     -- Positions 1, occasional mid
    ['npc_dota_hero_necrolyte'] = {5, 60, 30, 5, 0},      -- Positions 2,3
    ['npc_dota_hero_nevermore'] = {15, 80, 5, 0, 0},      -- Positions 2, occasional carry
    ['npc_dota_hero_night_stalker'] = {5, 5, 85, 5, 0},  -- Positions 3, occasional mid
    ['npc_dota_hero_nyx_assassin'] = {0, 5, 10, 65, 20}, -- Positions 4,5
    ['npc_dota_hero_obsidian_destroyer'] = {5, 90, 5, 0, 0},-- Positions 2,1
    ['npc_dota_hero_ogre_magi'] = {30, 45, 10, 30, 45},    -- Positions 5,4
    ['npc_dota_hero_omniknight'] = {0, 5, 10, 30, 55},   -- Positions 5,4
    ['npc_dota_hero_oracle'] = {0, 15, 10, 30, 45},       -- Positions 5,4
    ['npc_dota_hero_pangolier'] = {5, 55, 35, 5, 0},      -- Positions 2,3
    ['npc_dota_hero_phantom_lancer'] = {90, 5, 5, 0, 0}, -- Positions 1, occasional mid
    ['npc_dota_hero_phantom_assassin'] = {90, 5, 5, 0, 0},-- Positions 1, occasional mid
    ['npc_dota_hero_phoenix'] = {0, 5, 10, 65, 20},      -- Positions 4,5
    ['npc_dota_hero_primal_beast'] = {5, 5, 25, 5, 0},   -- Positions 3, occasional mid
    ['npc_dota_hero_puck'] = {5, 70, 25, 0, 0},           -- Positions 2, occasional support
    ['npc_dota_hero_pudge'] = {5, 35, 50, 5, 5},          -- Positions 3,4,5
    ['npc_dota_hero_pugna'] = {0, 5, 10, 65, 20},        -- Positions 4,5
    ['npc_dota_hero_queenofpain'] = {15, 50, 25, 10, 0},    -- Positions 2, occasional carry
    ['npc_dota_hero_rattletrap'] = {5, 5, 85, 5, 0},     -- Positions 3,4
    ['npc_dota_hero_razor'] = {5, 85, 5, 5, 0},          -- Positions 2,3
    ['npc_dota_hero_riki'] = {55, 10, 10, 15, 10},         -- Positions 1,4,5, occasional mid
    ['npc_dota_hero_rubick'] = {0, 25, 10, 20, 45},       -- Positions 5,4, occasional mid
    ['npc_dota_hero_sand_king'] = {5, 25, 65, 5, 0},      -- Positions 3,4
    ['npc_dota_hero_shadow_demon'] = {0, 5, 10, 30, 55}, -- Positions 5,4
    ['npc_dota_hero_shadow_shaman'] = {0, 0, 0, 45, 55},-- Positions 5,4
    ['npc_dota_hero_shredder'] = {5, 25, 65, 5, 0},       -- Positions 3, occasional mid
    ['npc_dota_hero_silencer'] = {0, 25, 10, 30, 35},     -- Positions 5,4
    ['npc_dota_hero_skeleton_king'] = {50, 5, 45, 0, 0},  -- Positions 1, occasional mid
    ['npc_dota_hero_skywrath_mage'] = {0, 5, 10, 65, 20},-- Positions 4,5
    ['npc_dota_hero_slardar'] = {35, 5, 55, 5, 0},        -- Positions 3, occasional support
    ['npc_dota_hero_slark'] = {90, 5, 5, 0, 0},          -- Positions 1, occasional mid
    ['npc_dota_hero_snapfire'] = {0, 5, 10, 70, 15},     -- Positions 4,5
    ['npc_dota_hero_sniper'] = {70, 25, 5, 0, 0},        -- Positions 1,2
    ['npc_dota_hero_spectre'] = {70, 5, 5, 0, 0},        -- Positions 1, occasional mid
    ['npc_dota_hero_spirit_breaker'] = {0, 5, 10, 70, 15},-- Positions 4,5
    ['npc_dota_hero_storm_spirit'] = {25, 20, 5, 0, 0},   -- Positions 2, occasional carry
    ['npc_dota_hero_sven'] = {60, 5, 35, 0, 0},           -- Positions 1, occasional mid
    ['npc_dota_hero_techies'] = {0, 35, 10, 40, 15},      -- Positions 4,5
    ['npc_dota_hero_terrorblade'] = {90, 5, 5, 0, 0},    -- Positions 1, occasional mid
    ['npc_dota_hero_templar_assassin'] = {5, 90, 5, 0, 0},-- Positions 2, occasional carry
    ['npc_dota_hero_tidehunter'] = {25, 25, 45, 5, 0},     -- Positions 3, occasional support
    ['npc_dota_hero_tinker'] = {5, 40, 5, 30, 0},         -- Positions 2, occasional carry
    ['npc_dota_hero_tiny'] = {5, 25, 65, 5, 0},           -- Positions 3, occasional support
    ['npc_dota_hero_treant'] = {0, 5, 10, 30, 55},       -- Positions 5,4
    ['npc_dota_hero_troll_warlord'] = {90, 5, 5, 0, 0},  -- Positions 1, occasional mid
    ['npc_dota_hero_tusk'] = {0, 20, 25, 40, 15},         -- Positions 4,5
    ['npc_dota_hero_undying'] = {0, 5, 10, 30, 55},      -- Positions 5,4
    ['npc_dota_hero_ursa'] = {50, 25, 25, 0, 0},           -- Positions 1, occasional mid
    ['npc_dota_hero_vengefulspirit'] = {0, 5, 10, 30, 55},-- Positions 5,4
    ['npc_dota_hero_venomancer'] = {5, 5, 45, 25, 20},     -- Positions 3,4
    ['npc_dota_hero_viper'] = {35, 45, 35, 5, 0},          -- Positions 2,3
    ['npc_dota_hero_visage'] = {5, 25, 35, 5, 0},         -- Positions 3, occasional mid
    ['npc_dota_hero_void_spirit'] = {15, 30, 15, 0, 0},    -- Positions 2, occasional carry
    ['npc_dota_hero_warlock'] = {0, 5, 0, 40, 55},      -- Positions 5,4
    ['npc_dota_hero_weaver'] = {5, 5, 10, 65, 15},       -- Positions 4,5, occasional core
    ['npc_dota_hero_windrunner'] = {5, 45, 45, 5, 0},     -- Positions 3,2
    ['npc_dota_hero_winter_wyvern'] = {0, 5, 10, 30, 55},-- Positions 5,4
    ['npc_dota_hero_wisp'] = {0, 5, 10, 25, 20},         -- Positions 4,5
    ['npc_dota_hero_witch_doctor'] = {0, 5, 10, 30, 55}, -- Positions 5,4
    ['npc_dota_hero_zuus'] = {15, 60, 15, 10, 0},           -- Positions 2, occasional support
    ['npc_dota_hero_ringmaster'] = {5, 20, 5, 50, 20},   -- Positions 4,5, occasional core
    ['npc_dota_hero_muerta'] = {35, 5, 5, 15, 5},        -- Positions 1,3, occasional support
    ['npc_dota_hero_kez'] = {60, 35, 5, 0, 0},        -- Positions 1,2
}

return HeroPositionMap