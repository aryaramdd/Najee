script_key = "hwsBcoLfPoKtFjRvnQRRdSskibPmRPdh"; 
getgenv().UserConfig = {
    ["FPS Cap"] = 7,
    ["Auto Buy Seed"] = true,
    ["Auto Plant Seed"] = true,
    ["Limit Plant Seed"] = {
        ["Carrot"] = 50, 
    },
    ["Limit Buy Seed"] = {
        -- Limited
        ["Rocket Pop"] = 2000,

        -- Common
        ["Carrot"] = 1,
        ["Strawberry"] = 1,
        ["Blueberry"] = 1,

        -- Uncommon
        ["Tulip"] = 1,
        ["Tomato"] = 1,
        ["Apple"] = 1,

        -- Rare
        ["Bamboo"] = 50,
        ["Corn"] = 1,
        ["Cactus"] = 1,
        ["Pineapple"] = 1000,

        -- Epic
        ["Mushroom"] = 100,
        ["Banana"] = 1,
        ["Grape"] = 1,
        ["Coconut"] = 1000,
        ["Mango"] = 1,

        -- Legendary
        ["Dragon Fruit"] = 1,
        ["Acorn"] = 1,
        ["Cherry"] = 1,
        ["Sunflower"] = 1,
        ["Fire Fern"] = 1,

        -- Mythic
        ["Venus Fly Trap"] = 1,
        ["Pomegranate"] = 1,
        ["Poison Apple"] = 1,
        ["Venom Spitter"] = 100,

        -- Super
        ["Moon Bloom"] = 100,
        ["Dragon's Breath"] = 100,
        ["Hypno Bloom"] = 100,
        ["Sun Bloom"] = 100,
        ["Star Fruit"] = 100,

        -- Secret
        ["Eclipse Bloom"] = 100,
    },
    ["Blacklist Shovel"] = {"Dragon's Breath", "Moon Bloom", "Hypno Bloom", "Ghost Pepper", "Venom Spitter", "Poison Apple", "Pomegranate", "Venus Fly Trap"},
    ["Shovel Plant Once"] = {},
    ["Favorite"] = {
        -- ["Horned Melon"] = {"Rainbow", "Gold"},
    },
    ["Harvest Mutation Only"] = {
        "Mushroom",
        -- "Bamboo",
        "Rocket Pop",
        --["Tomato"] = {"Rainbow", "Gold", "Bloodlit", "Electric", "Starstruck", "Frozen", "Aurora"},
        --"Apple",
    },
    ["Buy Pets"] = {
        -- Rare
        ["Deer"] = {Normal = 5},
    },
    ["Equip Pets"] = {
        {"Deer", 5, 1},
    },
    ["Expand Plot"] = true,
    ["Plot Expansions"] = 3,
    ["Unlock Pet Slots"] = 5,
    ["Auto Collect Seed Packs"] = true,
    ["Gears"] = {
        ["Buy Gear"] = {
            "Common Sprinkler",
            "Uncommon Sprinkler",
            "Rare Sprinkler",
            "Super Sprinkler",
            "Super Watering Can",
        },
        ["Gears To Use"] = {
            "Common Sprinkler",
            "Uncommon Sprinkler",
            "Rare Sprinkler",
        },
    },
        -- WH Pet
    ["Webhook Pet URL"] = "",
    ["Webhook Pet Name"] = {},
    ["Webhook Pet Rarity"] = {},
 	-- WH Seed
    ["Webhook Seed URL"] = "",
    ["Webhook Seed Name"] = {},
    	-- WH Gear
    ["Webhook Gear URL"] = "https://discord.com/api/webhooks/1515378532426191009/_KnBk1J45g4ugiAiaXh5SgDZUh1npDGPCwWoM3qrdqKKDCt6TYbC9u_JkkCN6dINDLbE",
    ["Webhook Gear Name"] = {"Super Sprinkler", "Super Watering Can"},
    ["Webhook Note"] = "Cukimai",
    ["Discord ID"] = "436761359129116672",
    ["Mail To Username"] = {"gudangarya"},
    ["Items To Mail"] = {
        ["Pet"] = {},
        ["Seed"] = {
            ["Rocket Pop"] = 10,
            ["Rainbow"] = 5,
            ["Gold"] = 10,
            ["Dragon's Breath"] = 1,
            ["Moon Bloom"] = 1,
            ["Hypno Bloom"] = 1,
            ["Venom Spitter"] = 1,
            ["Sun Bloom"] = 1,
            ["Star Fruit"] = 1,
            ["Eclipse Bloom"] = 100,
            ["Mega"] = 5,
        },
        ["Gear"] = {
            ["Trowel"] = 750,
            ["Super Watering Can"] = 2,
            ["Super Sprinkler"] = 2,
        },
    },
    ["Claim Mail"] = true,
    ["Auto Plant"] = true,
    ["Limit Auto Plant"] = 500,
    ["Blacklist Seed"] = {"Dragon's Breath", "Moon Bloom", "Hypno Bloom", "Mega", "Sun Bloom", "Star Fruit", "Eclipse Bloom", "Coconut", "Pineapple"}
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/979cba1a5b965fbc24d274454049b447.lua"))()