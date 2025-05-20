-- Client-side code for Graffiti System

local sprayingTag = false
local localGraffitiTags = {}
local graffitiProps = {}

-- Receive tags from server
RegisterNetEvent('graffiti:syncTags')
AddEventHandler('graffiti:syncTags', function(tags)
    localGraffitiTags = tags
    RefreshGraffitiProps()
end)

-- Refresh 3D graffiti objects
function RefreshGraffitiProps()
    -- Remove existing props
    for _, prop in pairs(graffitiProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    
    graffitiProps = {}
    
    -- Create new props for each tag
    for id, tag in pairs(localGraffitiTags) do
        local model = GetHashKey("prop_sign_road_01a") -- Using a flat sign as base
        
        -- Request model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end
        
        -- Create object
        local prop = CreateObject(model, tag.coords.x, tag.coords.y, tag.coords.z, false, false, false)
        SetEntityAlpha(prop, 0, false) -- Make base invisible
        FreezeEntityPosition(prop, true)
        SetEntityRotation(prop, tag.rotation.x, tag.rotation.y, tag.rotation.z, 2, true)
        
        -- Add to tracking table
        graffitiProps[id] = prop
        
        -- Create the graffiti overlay
        local textureDict = "graffiti_textures"
        local textureName = Config.GraffitiDesigns[tag.design].texture
        
        -- Create a sprite attached to the prop
        local handle = CreateRuntimeTxd("graffiti_" .. id)
        local dui = CreateDui("nui://Vibed_Graffiti/html/graffiti.html?text=" .. tag.text .. "&color=" .. tag.color .. "&design=" .. tag.design, 512, 512)
        local duiHandle = GetDuiHandle(dui)
        CreateRuntimeTextureFromDuiHandle(handle, "graffiti_texture", duiHandle)

        -- Apply runtime texture to the overlay prop
        AddReplaceTexture("p_cs_poster_top_01", "prop_poster_01a", "graffiti_" .. id, "graffiti_texture")

        -- Apply texture to prop
        local posX, posY, posZ = table.unpack(GetEntityCoords(prop))
        local object = CreateObjectNoOffset(GetHashKey("p_cs_poster_top_01"), posX, posY, posZ, false, false, false)
        
        -- Scale the graffiti
        SetEntityScale(object, tag.scale, tag.scale, tag.scale)
        
        -- Set the same rotation as the base prop
        SetEntityRotation(object, tag.rotation.x, tag.rotation.y, tag.rotation.z, 2, true)
        
        -- Add to tracking
        graffitiProps[id .. "_overlay"] = object
    end
end

-- Command to spray a new tag
RegisterCommand('tag', function(source, args, rawCommand)
    if sprayingTag then return end
    
    -- Check if player has spray can (this would be done server-side)
    TriggerServerEvent('graffiti:checkItem', Config.SprayCanItem)
    
    -- Open tagging UI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openTagMenu",
        designs = Config.GraffitiDesigns
    })
end, false)

-- NUI Callback when player confirms tag
RegisterNUICallback('createTag', function(data, cb)
    SetNuiFocus(false, false)
    
    -- Find surface in front of player
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local hit, coords, surfaceNormal = GetSurfaceAhead(2.0)
    
    if hit then
        -- Calculate rotation based on surface normal
        local rotation = GetRotationFromSurfaceNormal(surfaceNormal)
        
        -- Start spraying
        sprayingTag = true
        
        -- Play animation
        PlaySprayAnimation()
        
        -- Show progress bar
        exports['progressbar']:Progress({
            name = "spraying_tag",
            duration = Config.SprayDuration,
            label = "Spraying...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(cancelled)
            -- Complete
            StopAnimTask(ped, Config.SprayAnim.dict, Config.SprayAnim.anim, 1.0)
            sprayingTag = false
            
            if not cancelled then
                -- Save tag to server
                TriggerServerEvent('graffiti:saveTag', {
                    coords = coords,
                    rotation = rotation,
                    scale = data.size or 1.0,
                    design = data.design,
                    color = data.color,
                    text = data.text,
                    gang = data.gang or ""
                })
            end
        end)
    else
        -- No suitable surface found
        TriggerEvent('graffiti:notify', "No suitable surface found. Get closer to a wall.", "error")
    end
    
    cb({})
end)

-- Helper function to get surface in front of player
function GetSurfaceAhead(distance)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Calculate forward vector based on heading
    local angle = heading * math.pi / 180.0
    local forwardX = -math.sin(angle)
    local forwardY = math.cos(angle)
    
    local startPoint = pos
    local endPoint = vector3(
        startPoint.x + forwardX * distance,
        startPoint.y + forwardY * distance,
        startPoint.z
    )
    
    -- Cast ray to find surface
    local ray = StartShapeTestRay(
        startPoint.x, startPoint.y, startPoint.z,
        endPoint.x, endPoint.y, endPoint.z,
        16, ped, 0
    )
    
    local _, hit, hitCoords, surfaceNormal, _ = GetShapeTestResult(ray)
    
    return hit, hitCoords, surfaceNormal
end

-- Convert surface normal to rotation
function GetRotationFromSurfaceNormal(normal)
    -- Convert normal vector to rotation
    local rotation = {}
    rotation.x = math.atan2(normal.z, math.sqrt(normal.x * normal.x + normal.y * normal.y)) * 180.0 / math.pi
    rotation.y = 0.0
    rotation.z = math.atan2(normal.x, normal.y) * 180.0 / math.pi
    
    return rotation
end

-- Play spraying animation
function PlaySprayAnimation()
    local ped = PlayerPedId()
    local animDict = Config.SprayAnim.dict
    local animName = Config.SprayAnim.anim
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
    
    -- Create spray can prop
    local propModel = GetHashKey("prop_cs_spray_can")
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Citizen.Wait(10)
    end
    
    local prop = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Play animation
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, Config.SprayAnim.flag, 0, false, false, false)
    
    -- Delete prop after animation
    Citizen.SetTimeout(Config.SprayDuration + 1000, function()
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end)
end

-- Notification system (you can replace with your server's notification system)
RegisterNetEvent('graffiti:notify')
AddEventHandler('graffiti:notify', function(message, type)
    -- Basic notification
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
    
    -- You can replace with something like:
    -- exports['mythic_notify']:DoHudText(type, message)
end)

-- Gang war notification
RegisterNetEvent('graffiti:gangWar')
AddEventHandler('graffiti:gangWar', function(data)
    TriggerEvent('graffiti:notify', "Gang war triggered! " .. data.attacker .. " is challenging " .. data.defender .. " turf!", "warning")
    
    -- Add blip to map
    local blip = AddBlipForCoord(data.location.x, data.location.y, data.location.z)
    SetBlipSprite(blip, 310)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.5)
    SetBlipAsShortRange(blip, false)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Gang War")
    EndTextCommandSetBlipName(blip)
    
    -- Remove blip after 5 minutes
    Citizen.SetTimeout(300000, function()
        RemoveBlip(blip)
    end)
end)

-- Display nearby tags when close to them
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        
        for id, tag in pairs(localGraffitiTags) do
            local tagPos = vector3(tag.coords.x, tag.coords.y, tag.coords.z)
            local dist = #(pos - tagPos)
            
            if dist < 20.0 then
                -- Display 3D text for close tags
                if dist < 5.0 then
                    DrawText3D(tagPos.x, tagPos.y, tagPos.z + 0.5, "~o~" .. tag.text .. "~w~ - " .. tag.author)
                    
                    -- If this is a gang tag, show gang name
                    if tag.gang ~= "" then
                        DrawText3D(tagPos.x, tagPos.y, tagPos.z + 0.35, "~r~Gang: ~w~" .. tag.gang)
                    end
                end
            end
        end
    end
end)

-- Draw 3D text function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Initialize
Citizen.CreateThread(function()
    -- Request animations
    RequestAnimDict(Config.SprayAnim.dict)
    
    -- Request server to sync tags
    TriggerServerEvent('graffiti:requestSync')
end)

-- Request sync from server
RegisterNetEvent('graffiti:requestSync')
AddEventHandler('graffiti:requestSync', function()
    TriggerServerEvent('graffiti:syncRequest')
end)