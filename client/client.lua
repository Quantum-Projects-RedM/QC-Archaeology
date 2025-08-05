local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedRocks = {}
local isBusy = false
lib.locale()
local zoneIds = {} -- Table to store zone IDs

local function AttachPropToHand()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local propHash = GetHashKey('p_brush01x')
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Citizen.Wait(100)
    end
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, true)
    if prop and DoesEntityExist(prop) then
        print("Prop created successfully.")
            AttachEntityToEntity(prop, playerPed, 306, 0, -0.05, 0.08, 21.0, 170.0, -24.0, true, true, false, true, 0, true)
            print("Prop attached to hand.")
        lib.progressBar({
            duration = Config.arcsiteTime ,
            label = 'Searching Bones...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                scenario = "MP_LOBBY_WORLD_HUMAN_CROUCH_INSPECT"
            },
        })
        ClearPedTasksImmediately(playerPed)
        FreezeEntityPosition(playerPed, false)
        SetEntityAsNoLongerNeeded(prop)
        DeleteEntity(prop)
    else
        print("Failed to create or attach the prop.")
    end
end

local function RemoveIpl(arcid)
    -- Find the IPL number associated with the arcid
    local iplToRemove = nil
    for _, site in pairs(Config.ArcSites) do
        if site.arcid == arcid then
            iplToRemove = site.IPL
            break
        end
    end

    if iplToRemove then
        -- Assuming you have a function to remove the IMAP
        RemoveImap(iplToRemove) -- Replace with the correct function if necessary
        print("Removed IMAP with IPL: " .. iplToRemove)
    else
        print("No IMAP found for arcid: " .. arcid)
    end
end

local function RequestIpl(arcid)
    local addImap = nil
    for _, site in pairs(Config.ArcSites) do
        if site.arcid == arcid then
            addImap = site.IPL
            break
        end
    end
    if addImap then
        RequestImap(addImap)
    else
        print("No IMAP found for arcid: " .. arcid)
    end
end

---------------------------------
-- mine blips
---------------------------------
CreateThread(function()
    for _,v in pairs(Config.ArchaeologyHubs) do
        if v.showblip == true then    
            local ArcBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(ArcBlip, joaat('blip_hire_camp_follower'), true)
            SetBlipScale(ArcBlip, 0.2)
            SetBlipName(ArcBlip, v.name)
        end
    end
end)

---------------------------------
-- mining nodes
---------------------------------

CreateThread(function()
    for _, v in pairs(Config.ArcSites) do
        local zoneId = exports.ox_target:addSphereZone({
            coords = v.coords,
            name = v.arcid,
            radius = 1.1, 
            drawSprite = Config.Debug,
            options = {
                {
                    type = 'client',
                    icon = 'fa-solid fa-magnifying-glass',
                    label = locale('cl_lang_1'),
                    onSelect = function()
                        TriggerEvent('qc-archaeology:client:discoverarc', v.arcid, v.arcid)
                    end
                }
            }
        })

        table.insert(zoneIds, zoneId) 
    end
end)

CreateThread(function()
    for _, site in pairs(Config.ArcAdvancedSites) do
        for _, jobPoint in pairs(site.jobarea) do
            local coords = jobPoint[1]
            local zoneId = exports.ox_target:addSphereZone({
                coords = coords,
                name = site.arcid,
                radius = 0.8,
                drawSprite = Config.Debug, 
                options = {
                    {
                        type = 'client',
                        icon = 'fa-solid fa-magnifying-glass',
                        label = locale('cl_lang_1'),
                        onSelect = function()
                            TriggerEvent('qc-archaeology:client:discoveradv', site.arcid, site.arcid)
                        end
                    }
                }
            })
            table.insert(zoneIds, zoneId)
        end
    end
end)
---------------------------------------------
-- mine rock
---------------------------------------------
---
RegisterNetEvent('qc-archaeology:client:removeIpl')
AddEventHandler('qc-archaeology:client:removeIpl', function(iplToRemove)
    RemoveImap(iplToRemove)
    print("Client removed IMAP with IPL: " .. iplToRemove)
end)


RegisterNetEvent('qc-archaeology:client:discoverarc', function(arcid, zoneId)
    local site = nil
    for _, s in ipairs(Config.ArcSites) do
        if s.arcid == arcid then
            site = s
            break
        end
    end

    if not site then
        lib.notify({ title = 'Error', description = 'Invalid archaeological site.', type = 'error', duration = 7000 })
        return
    end
    RSGCore.Functions.TriggerCallback('qc-archaeology:server:checkarc', function(exists)
        -- Check if the site has already been mined
        if exists == true then
            lib.notify({ title = 'Error', description = locale('cl_lang_2'), type = 'error', duration = 7000 })
            return
        end
        
        -- Check if the player has a pickaxe
        local hasItem = RSGCore.Functions.HasItem(Config.ArchaeologyBrush)
        if hasItem == false then
            lib.notify({ title = 'Error', description = locale('cl_lang_3'), type = 'error', duration = 7000 })
            return
        end
        
        -- Check if the player is already busy
        if isBusy == true then
            lib.notify({ title = 'Error', description = locale('cl_lang_4'), type = 'error', duration = 7000 })
            return
        end

        -- Start the mining process
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        isBusy = true
        AttachPropToHand()
        local chance = math.random(100)
        local foundFossil = chance <= site.chance
        local sawFossilImage = foundFossil
        local imagePath = foundFossil and 'img/minigame/fossils/' .. site.item .. '.png' or 'img/minigame/fossils/fossil_coral.png'

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'toggleUI',
            status = true,
            rockImageSrc = imagePath
        })

        -- Listen for the minigame result
        RegisterNUICallback('cleaningComplete', function(data, cb)
            -- Minigame succeeded
            SetNuiFocus(false, false)
            SendNUIMessage({
                type = 'toggleUI',
                status = false,
            })
            TriggerServerEvent('qc-archaeology:server:DiscArcSite', arcid)
            TriggerServerEvent('qc-archaeology:server:givereward', arcid, foundFossil, sawFossilImage) -- Pass `true` for success
            TriggerServerEvent('qc-archaeology:server:removeIpl', arcid) -- Remove IPL
            exports.ox_target:removeZone(zoneId) -- Remove the zone
            isBusy = false
            cb('ok')
        end)

        RegisterNUICallback('minigameFailed', function(data, cb)
            SetNuiFocus(false, false)
            SendNUIMessage({
                type = 'toggleUI',
                status = false,
            })
            --lib.notify({ title = 'Failed', description = 'You failed to clean the fossil.', type = 'error', duration = 5000 })
            isBusy = false
            cb('ok')
        end)
    end, arcid)
end)

RegisterNetEvent('qc-archaeology:client:discoveradv', function(arcid, zoneId)
    RSGCore.Functions.TriggerCallback('qc-archaeology:server:checkarc', function(exists)
        -- check if already mined
        if exists == true then
            lib.notify({ title = 'Error', description = locale('cl_lang_2'), type = 'error', duration = 7000 })
            return
        end
        local hasItem = RSGCore.Functions.HasItem(Config.ArchaeologyBrush)
        if hasItem == false then
            lib.notify({ title = 'Error', description = locale('cl_lang_3'), type = 'error', duration = 7000 })
            return
        end
        if isBusy == true then
            lib.notify({ title = 'Error', description = locale('cl_lang_4'), type = 'error', duration = 7000 })
            return
        end
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        if not IsPedMale(cache.ped) then
            -- female ped
            isBusy = true
            SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
            AttachPropToHand()
            TriggerServerEvent('qc-archaeology:server:DiscArcSite', arcid)
            TriggerServerEvent('qc-archaeology:server:giverewardadv', arcid)
            RemoveIpl(arcid)
            exports.ox_target:removeZone(zoneId)
            isBusy = false
        else
            -- male ped
            isBusy = true
            SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
            AttachPropToHand()
            TriggerServerEvent('qc-archaeology:server:DiscArcSite', arcid)
            TriggerServerEvent('qc-archaeology:server:giverewardadv', arcid)
            exports.ox_target:removeZone(zoneId)
            RemoveIpl(arcid)
            isBusy = false
        end
    end, arcid)
end)

RegisterNetEvent('qc-archaeology:client:OpenBook', function(bookName, pages)
    local ped = PlayerPedId()
    local ped_coords = GetEntityCoords(ped)
    SetNuiFocus(true, true)
    local defaultPages = {}
    local allPages = {}
    for _, page in ipairs(defaultPages) do
        table.insert(allPages, page)
    end
    for _, page in ipairs(pages) do
        table.insert(allPages, page)
    end
    SendNUIMessage({
        event = 'book',
        show = true,
        book = bookName,
        pages = allPages,
        size = Config.Book[bookName]["size"],
    })
    --print("Book opened: " .. bookName)
end)

-- Book pages are now handled server-side with persistent storage
-- No client-side page management needed

RegisterNUICallback('escape', function(data, cb)
    local ped = PlayerPedId()
    SetNuiFocus(false, false)
    SendNUIMessage({
        show = false,
    })
    SendNUIMessage({
        type = 'toggleUI',
        status = false,
    })
    isBusy = false
    cb('ok')
end)
---------------------------------------------
-- cleanup
---------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false,false)
    SendNUIMessage({
        show = false
    })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, site in pairs(Config.ArcSites) do
        RequestIpl(site.arcid)
    end
end)