-- Configuration for Graffiti System
Config = {}

-- Gang territories configuration
Config.GangTurf = {
    -- Define gang territories by coordinates
    ["Ballas"] = {
        color = {148, 0, 211}, -- Purple
        areas = {
            {x1 = 0.0, y1 = 0.0, x2 = 200.0, y2 = 200.0}, -- Example area
        }
    },
    ["Families"] = {
        color = {0, 128, 0}, -- Green
        areas = {
            {x1 = 300.0, y1 = 0.0, x2 = 500.0, y2 = 200.0}, -- Example area
        }
    },
    ["Vagos"] = {
        color = {255, 255, 0}, -- Yellow
        areas = {
            {x1 = 600.0, y1 = 0.0, x2 = 800.0, y2 = 200.0}, -- Example area
        }
    }
}

-- Item and duration settings
Config.SprayCanItem = "spray_can" -- Item needed for spraying
Config.SprayDuration = 10000 -- How long it takes to spray in ms
Config.GraffitiMaxDistance = 2.0 -- Maximum distance to spray a wall
Config.GraffitiLifetime = 24 -- Hours before graffiti fades (server restart will clear)
Config.GraffitiSize = {min = 0.5, max = 2.0} -- Min and max size for graffiti

-- Spraying animations
Config.SprayAnim = {
    dict = "switch@franklin@lamar_tagging_wall",
    anim = "lamar_tagging_wall_loop_lamar",
    flag = 1
}

-- Available graffiti designs
Config.GraffitiDesigns = {
    ["tag1"] = {
        label = "Basic Tag",
        prop = "prop_cs_spray_can",
        texture = "graffiti_tag1"
    },
    ["tag2"] = {
        label = "Bubble Letters",
        prop = "prop_cs_spray_can",
        texture = "graffiti_tag2"
    },
    ["gang1"] = {
        label = "Gang Symbol",
        prop = "prop_cs_spray_can",
        texture = "graffiti_gang1"
    },
    ["crown"] = {
        label = "Crown",
        prop = "prop_cs_spray_can",
        texture = "graffiti_crown"
    }
}

-- Framework compatibility functions
-- These would need to be adapted to your server's framework (ESX, QBus, etc.)

-- Get player function
function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Check if player has item (QBCore)
function HasItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemData = Player.Functions.GetItemByName(item)
    return itemData and itemData.amount > 0
end

-- Remove item from player (QBCore)
function RemoveItem(source, item, count)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(item, count or 1)
end