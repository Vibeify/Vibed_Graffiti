-- Uncomment one of the following lines depending on your framework:
-- QBCore = exports['qb-core']:GetCoreObject()
-- ESX = exports['es_extended']:getSharedObject()

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
    if QBCore then
        return QBCore.Functions.GetPlayer(source)
    elseif ESX then
        return ESX.GetPlayerFromId(source)
    else
        return nil
    end
end

-- Check if player has item
function HasItem(source, item)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        local itemData = Player and Player.Functions.GetItemByName(item)
        return itemData and itemData.amount > 0
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        local itemData = xPlayer and xPlayer.getInventoryItem(item)
        return itemData and itemData.count > 0
    else
        return false
    end
end

-- Remove item from player
function RemoveItem(source, item, count)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.RemoveItem(item, count or 1) end
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then xPlayer.removeInventoryItem(item, count or 1) end
    end
end