local RSGCore = exports['rsg-core']:GetCoreObject()
local DiscArcSite = {}
lib.locale()

---------------------------------
-- searched Sites
---------------------------------
RegisterNetEvent('qc-archaeology:server:DiscArcSite', function(arcid)
    local exists = false
    for i = 1, #DiscArcSite do
        local rock = DiscArcSite[i]
        if rock == arcid then
            exists = true
            break
        end
    end
    if not exists then
        DiscArcSite[#DiscArcSite + 1] = arcid
    end
end)


RegisterServerEvent('qc-archaeology:server:removeIpl')
AddEventHandler('qc-archaeology:server:removeIpl', function(arcid)
    -- Find the IPL number associated with the arcid
    local iplToRemove = nil
    for _, site in pairs(Config.ArcSites) do
        if site.arcid == arcid then
            iplToRemove = site.IPL
            break
        end
    end

    if iplToRemove then
        -- Broadcast the removal to all clients
        TriggerClientEvent('qc-archaeology:client:removeIpl', -1, iplToRemove)
        print("Removed IMAP with IPL: " .. iplToRemove)
    else
        print("No IMAP found for arcid: " .. arcid)
    end
end)

---------------------------------
-- check sites
---------------------------------
RSGCore.Functions.CreateCallback('qc-archaeology:server:checkarc', function(source, cb, arcid)
    local exists = false
    for i = 1, #DiscArcSite do
        local rock = DiscArcSite[i]
        if rock == arcid then
            exists = true
            break
        end
    end
    cb(exists)
end)

RSGCore.Functions.CreateUseableItem(Config.ItemBook, function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    -- Query the database to get discovered sites
    local discoveredSites = MySQL.Sync.fetchAll("SELECT arcid FROM QC_Archaeology WHERE citizenid = @citizenid", {
        ['@citizenid'] = citizenid
    })
    
    local pagesToSend = {}
    -- Always include cover and intro pages
    table.insert(pagesToSend, { source = 'local', type = 'hard', pageName = '1' })
    table.insert(pagesToSend, { source = 'local', type = 'hard', pageName = '2' })
    table.insert(pagesToSend, { source = 'local', type = 'normal', pageName = '3' })
    
    -- Add pages for discovered sites
    for _, discovery in ipairs(discoveredSites) do
        for _, site in pairs(Config.ArcSites) do
            if site.arcid == discovery.arcid and site.givenpage and site.givenpage ~= '' then
                table.insert(pagesToSend, {
                    source = 'local',
                    type = 'normal',
                    pageName = site.givenpage
                })
            end
        end
    end

    -- Always include back cover
    table.insert(pagesToSend, { source = 'local', type = 'hard', pageName = '30' })

    TriggerClientEvent("qc-archaeology:client:OpenBook", source, "archeology_book", pagesToSend)
end)
---------------------------------
-- give reward item
---------------------------------

RegisterNetEvent('qc-archaeology:server:givereward', function(arcid, foundFossil, sawFossilImage)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    if not Player then return end

    local itemToGive = nil
    local givenPage = nil

    -- Find the site and its corresponding item
    for _, site in pairs(Config.ArcSites) do
        if site.arcid == arcid then
            itemToGive = site.item
            givenPage = site.givenpage
            print("DEBUG: Found site " .. arcid .. " with item: " .. (itemToGive or "nil") .. " and page: " .. (givenPage or "nil"))
            break
        end
    end

    if not itemToGive then
        print("No item found for arcid: " .. arcid)
        return
    end
    local hasDiscovered = MySQL.Sync.fetchScalar("SELECT COUNT(*) FROM QC_Archaeology WHERE citizenid = @citizenid AND arcid = @arcid", {
        ['@citizenid'] = citizenid,
        ['@arcid'] = arcid
    })
    if hasDiscovered == 0 and foundFossil then
        -- Add to archaeology discoveries
        MySQL.Async.execute("INSERT INTO QC_Archaeology (citizenid, arcid, time_found) VALUES (@citizenid, @arcid, @time_found)", {
            ['@citizenid'] = citizenid,
            ['@arcid'] = arcid,
            ['@time_found'] = os.date('%Y-%m-%d %H:%M:%S')
        })
        
        -- Page will be added to book automatically when they open it (based on discovered sites)
        if givenPage and givenPage ~= '' then
            TriggerClientEvent('ox_lib:notify', src, {title = 'New page added to your archaeology book! Page: ' .. givenPage, type = 'success', icon = 'fa-solid fa-book', iconAnimation = 'shake', duration = 5000 })
        end
        
        TriggerClientEvent('ox_lib:notify', src, {title = 'YOU DISCOVERED SOMETHING!', type = 'success', icon = 'fa-solid fa-magnifying-glass', iconAnimation = 'shake', duration = 7000 })
    end
    if sawFossilImage then
        Player.Functions.AddItem(itemToGive, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemToGive], 'add', 1)
        TriggerClientEvent('ox_lib:notify', src, {title = 'You found a fossil!', type = 'success', icon = 'fa-solid fa-magnifying-glass', duration = 5000 })
        -- Additional rare/common item reward logic
        local rewardchance = math.random(100)
        if rewardchance > (100 - Config.RareItemChance) then
            -- Rare item reward logic
            local randomRareItem = Config.RareRewardItems[math.random(#Config.RareRewardItems)]
            Player.Functions.AddItem(randomRareItem, 1)
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomRareItem], 'add', 1)
            TriggerEvent('rsg-log:server:CreateLog', 'mining', locale('sv_lang_1'), 'green', firstname..' '..lastname..' ('..citizenid..locale('sv_lang_2')..RSGCore.Shared.Items[randomRareItem].label)
        else
            -- Common item reward logic
            local randomCommonItem = Config.CommonRewardItems[math.random(#Config.CommonRewardItems)]
            Player.Functions.AddItem(randomCommonItem, 1)
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomCommonItem], 'add', 1)
            TriggerEvent('rsg-log:server:CreateLog', 'mining', locale('sv_lang_3'), 'green', firstname..' '..lastname..' ('..citizenid..locale('sv_lang_2')..RSGCore.Shared.Items[randomCommonItem].label)
        end
    else
        -- If no fossil was found, give a common item like fossil_coral
        Player.Functions.AddItem(Config.NoFossilItem, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.NoFossilItem], 'add', 1)
        TriggerClientEvent('ox_lib:notify', src, { title = 'You found some rocks!', type = 'info', icon = 'fa-solid fa-circle-exclamation', duration = 5000 })
    end
end)

RegisterNetEvent('qc-archaeology:server:giverewardadv', function(arcid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    if not Player then return end

    local itemToGive = nil
    for _, site in pairs(Config.ArcAdvancedSites) do
        if site.arcid == arcid then
            itemToGive = site.items
            break
        end
    end

    if not itemToGive then
        print("No item found for arcid: " .. arcid)
        return
    end

    local rewardchance = math.random(100)
    if rewardchance > (100 - Config.RareItemChance) then
        -- Rare item reward logic
        local randomRareItem = Config.RareRewardItems[math.random(#Config.RareRewardItems)]
        Player.Functions.AddItem(randomRareItem, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomRareItem], 'add', 1)
        TriggerEvent('rsg-log:server:CreateLog', 'mining', locale('sv_lang_1'), 'green', firstname..' '..lastname..' ('..citizenid..locale('sv_lang_2')..RSGCore.Shared.Items[randomRareItem].label)
    else
        -- Common item reward logic
        local randomCommonItem = Config.CommonRewardItems[math.random(#Config.CommonRewardItems)]
        Player.Functions.AddItem(randomCommonItem, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomCommonItem], 'add', 1)
        TriggerEvent('rsg-log:server:CreateLog', 'mining', locale('sv_lang_3'), 'green', firstname..' '..lastname..' ('..citizenid..locale('sv_lang_2')..RSGCore.Shared.Items[randomCommonItem].label)
    end
    Player.Functions.AddItem(itemToGive, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemToGive], 'add', 1)
end)
---------------------------------------------
-- site reset
---------------------------------------------
lib.cron.new(Config.arcsiteCronJob, function ()
    DiscArcSite = {}
    if Config.CronNotification then
        print(locale('sv_lang_4'))
    end
end)

---------------------------------------------
-- flush site table
---------------------------------------------
RegisterNetEvent('qc-archaeology:server:resetarcsites', function()
    DiscArcSite = {}
end)


