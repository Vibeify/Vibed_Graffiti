-- Server-side code for Graffiti System

-- Load config
local GraffitiTags = {}
local TagCount = 0

-- Server events
RegisterNetEvent('graffiti:saveTag')
AddEventHandler('graffiti:saveTag', function(data)
    local src = source
    local Player = GetPlayer(src) -- Get player (depends on framework)
    
    -- Check if player has spray can item
    if not HasItem(src, Config.SprayCanItem) then
        TriggerClientEvent('graffiti:notify', src, "You need a spray can to tag!", "error")
        return
    end
    
    -- Add the new tag
    TagCount = TagCount + 1
    local tagId = TagCount
    
    -- Store the tag data
    GraffitiTags[tagId] = {
        id = tagId,
        coords = data.coords,
        rotation = data.rotation,
        scale = data.scale,
        design = data.design,
        color = data.color,
        text = data.text,
        gang = data.gang,
        author = GetPlayerName(src),
        timestamp = os.time(),
        lifetime = Config.GraffitiLifetime * 3600 -- Convert hours to seconds
    }
    
    -- Remove spray can (optional)
    -- RemoveItem(src, Config.SprayCanItem, 1)
    
    -- Sync with all clients
    TriggerClientEvent('graffiti:syncTags', -1, GraffitiTags)
    
    -- Notify success
    TriggerClientEvent('graffiti:notify', src, "Tag sprayed successfully!", "success")
    
    -- Check if this is in gang territory and handle turf claiming
    CheckGangTurf(data.coords, data.gang)
end)

-- Function to check if tag is in gang territory
function CheckGangTurf(coords, gang)
    if gang == "" then return end
    
    -- Check if tag is in claimed territory
    for turfGang, turfData in pairs(Config.GangTurf) do
        for _, area in ipairs(turfData.areas) do
            if coords.x >= area.x1 and coords.x <= area.x2 and
               coords.y >= area.y1 and coords.y <= area.y2 then
                
                -- This territory belongs to someone
                if turfGang ~= gang then
                    -- Territory being contested!
                    TriggerClientEvent('graffiti:gangWar', -1, {
                        location = coords,
                        attacker = gang,
                        defender = turfGang
                    })
                end
                
                return
            end
        end
    end
end

-- Cleanup old tags periodically
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        local currentTime = os.time()
        local tagsRemoved = false
        
        for id, tag in pairs(GraffitiTags) do
            if (currentTime - tag.timestamp) > tag.lifetime then
                GraffitiTags[id] = nil
                tagsRemoved = true
            end
        end
        
        if tagsRemoved then
            TriggerClientEvent('graffiti:syncTags', -1, GraffitiTags)
        end
    end
end)

-- Sync tags with new clients
RegisterNetEvent('graffiti:syncRequest')
AddEventHandler('graffiti:syncRequest', function()
    local src = source
    TriggerClientEvent('graffiti:syncTags', src, GraffitiTags)
end)

-- Check if player has spray can
RegisterNetEvent('graffiti:checkItem')
AddEventHandler('graffiti:checkItem', function(item)
    local src = source
    if not HasItem(src, item) then
        TriggerClientEvent('graffiti:notify', src, "You need a spray can to tag!", "error")
    end
end)