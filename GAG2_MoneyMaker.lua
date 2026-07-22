script_key="pGGQNqSpxDpWnhXSWMzIraybsePuTDuO";
getgenv().GAG2Config = {
    FPS_CAP = 5,
    ADD_FRIEND = false,
    AUTO_UPDATE_RESTART = true,
    COLLECT_FRUIT_DELAY = 20,

    -- Pet Config
    MAX_PET_EQUIP = 5,
    BUY_PET = {
        ["Deer"] = 4,
        ["Unicorn"] = 1,
    },
    EQUIP_PET = {
        {"Deer", 4, 1},
        {"Unicorn", 1, 2},
    },

    -- Planting Config (Legendary+ cuma ditanam kalo udah punya seednya, gak dibeli)
    PLANT_SEED = {
        ["Bamboo"] = 500,
        ["Mushroom"] = 400,
        ["Rainbow"] = 20,
        ["Gold"] = 20,
        ["Mega"] = 20,
        ["Dragon Fruit"] = 25,
        ["Fire Fern"] = 25,
        ["Acorn"] = 25,
        ["Cherry"] = 25,
        ["Sunflower"] = 25,
        ["Venus Fly Trap"] = 5,
        ["Pomegranate"] = 5,
        ["Poison Apple"] = 5,
    },

    -- Buying Config (HANYA Bamboo + Mushroom + mail items. Legendary+ MAHAL, gak dibeli!)
    BUY_SEED = {
        ["Bamboo"] = 9999,       -- 700/seed, profit
        ["Mushroom"] = 9999,     -- 15K/seed, profit kalo 1.5x
        -- Legendary+ GAK dibeli (Fire Fern 6M, Sunflower 5M, Pomegranate 12M dll)
        -- Rainbow/Gold/Mega cuma dari drop
        -- mail items (beli dikit buat dikirim)
        ["Venom Spitter"] = 5,
        ["Moon Bloom"] = 5,
        ["Hypno Bloom"] = 5,
        ["Dragon's Breath"] = 5,
    },
    BUY_AUCTION = {},
    BUY_CRATE = {
        ["Ladder Crate"] = 100,
        ["Roleplay Crate"] = 100,
    },
    BUY_GEAR_MIN_SHECKLE = 5000000,  -- 5M min biar gak beli kalo duit tipis
    BUY_GEAR = {
        ["Super Watering Can"] = 3,  -- 1M each, beli dikit aja
        ["Super Sprinkler"] = 5,
        ["Trowel"] = 750,
    },

    -- Sell Config (Mushroom WAJIB 1.5x biar profit)
    SELL_FRUIT_MULTIPLIER = { ["Mushroom"] = 1.5 },
    SELL_ALL_DAILY_DEAL = 50000000,
    SELL_ALL_DELAY = 20,

    -- Consumable Config
    USE_SPRINKLER = {},
    USE_WATERING_CAN = {},
    USE_WATERING_CAN_DELAY = 60,

    -- Misc Config
    COLLECT_PLANT_IF_MUTATED = {},
    FAVOURITE_FRUIT = {},
    FOCUS_COLLECT_DROPPED_SEED = true,
    EXPAND_PLOT = 4,

    -- Auto Mail (kirim ke alt)
    AUTO_MAIL = {
        ["gudangarya"] = {
            ["Moon Bloom"] = 1,
            ["Venom Spitter"] = 2,	
            ["Dragon's Breath"] = 1,
            ["Super Sprinkler"] = 2,
            ["Super Watering Can"] = 3,
            ["Ladder Crate"] = 100,
            ["Hypno Bloom"] = 1,
            ["Trowel"] = 750,
            ["Roleplay Crate"] = 100,
        },
    },
    AUTO_MAIL_DELAY = 60,
    COLLECT_MAIL = true,

    -- Webhook
    WEBHOOK_PET_NAME = {},
    WEBHOOK_PET_RARITY = { "Mythic", "Super", "Secret" },
    WEBHOOK_URL = "",
    DISCORD_ID = "",
    WEBHOOK_NOTE = "",
    SHOW_PUBLIC_DISCORD_ID = true,
    SHOW_WEBHOOK_USERNAME = true,
    SHOW_WEBHOOK_JOBID = true,
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/54f804e5a64896fdfd438fb42d226f04.lua"))()
