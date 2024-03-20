ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('brp:getUserGangInfo')
AddEventHandler('brp:getUserGangInfo', function(id)
    local source = source
    local player = ESX.GetPlayerFromId(id)
    if player ~= nil then
        local identifier = player.identifier
        local query = "SELECT gang, gang_grade FROM users WHERE identifier = @identifier;"
        local params = {['@identifier'] = identifier}
    
        MySQL.Async.fetchAll(query, params, function(result)
            if result then
                if result[1] then
                    local gang = result[1].gang or "Unknown Gang"
                    local gangGrade = result[1].gang_grade or 0
                    local message = ("User  belongs to gang %s with grade %d"):format(gang, gangGrade)
                    TriggerClientEvent('brp:showNotification', source, message, 1)
                else
                    local errorMessage = ("not found or has no gang information")
                    TriggerClientEvent('brp:showNotification', source, errorMessage, 2)
                end
            else
                local errorMessage = "Error fetching user gang information"
                TriggerClientEvent('brp:showNotification', source, errorMessage, 3)
            end
        end)
    else
        TriggerClientEvent('brp:showNotification', source, 'Player Not Found', 2)
    end
end)

RegisterServerEvent('brp:setUserGang')
AddEventHandler('brp:setUserGang', function(id, gang, gangGrade)
    local source = source
    local user = ESX.GetPlayerFromId(source)
    local player = ESX.GetPlayerFromId(id)
    if player ~= nil then
        local identifier = player.identifier

        -- Fetch the highest grade for the player's gang from the gang_grades table
        local query = "SELECT grade FROM gang_grades WHERE gang_name = @gang ORDER BY grade DESC LIMIT 1;"
        local params = {['@gang'] = gang}
    
        MySQL.Async.fetchScalar(query, params, function(highestGrade)
            if highestGrade then
                -- Convert highestGrade to a number
                highestGrade = tonumber(highestGrade)
    
                -- Fetch the player's grade from the users table
                local userGradeQuery = "SELECT gang_grade FROM users WHERE identifier = @identifier;"
                local userGradeParams = {['@identifier'] = identifier}
    
                MySQL.Async.fetchScalar(userGradeQuery, userGradeParams, function(userGrade)
                    if userGrade then
                        -- Convert userGrade to a number
                        userGrade = tonumber(userGrade)
    
                        -- Check if the player's grade is the highest grade for their gang
                        if userGrade == highestGrade then
                            -- Check if the target gang is the same as the player's gang
                            local userGangQuery = "SELECT gang FROM users WHERE identifier = @identifier;"
                            local userGangParams = {['@identifier'] = identifier}
    
                            MySQL.Async.fetchScalar(userGangQuery, userGangParams, function(userGang)
                                if userGang == gang then
                                    -- Check if the requested grade is not higher than the highestGrade
                                    if tonumber(gangGrade) <= highestGrade then
                                        -- Update the player's gang and grade in the users table
                                        local updateQuery = "UPDATE users SET gang = @gang, gang_grade = @gangGrade WHERE identifier = @identifier;"
                                        local updateParams = {
                                            ['@gang'] = gang,
                                            ['@gangGrade'] = gangGrade,
                                            ['@identifier'] = identifier
                                        }
    
                                        MySQL.Async.execute(updateQuery, updateParams, function(rowsChanged)
                                            if rowsChanged > 0 then
                                                TriggerClientEvent('brp:showNotification', source, "Gang information updated successfully", 1)
                                                print(("Gang information updated for user with identifier %s"):format(identifier))
                                            else
                                                TriggerClientEvent('brp:showNotification', source, "Failed to update gang information", 3)
                                                print(("Failed to update gang information for user with identifier %s"):format(identifier))
                                            end
                                        end)
                                    else
                                        TriggerClientEvent('brp:showNotification', source, "You cannot set a grade higher than the highest grade for the gang", 2)
                                    end
                                else
                                    TriggerClientEvent('brp:showNotification', source, "You can only set players to your own gang", 2)
                                end
                            end)
                        else
                            TriggerClientEvent('brp:showNotification', source, "You do not have permission to set this grade", 2)
                            print(("User with identifier %s does not have permission to set their grade to %d"):format(identifier, gangGrade))
                        end
                    else
                        TriggerClientEvent('brp:showNotification', source, "Failed to fetch user's gang grade", 3)
                        print(("Failed to fetch gang grade for user with identifier %s"):format(identifier))
                    end
                end)
            else
                TriggerClientEvent('brp:showNotification', source, "Failed to fetch highest grade for the gang", 3)
                print(("Failed to fetch highest grade for gang %s"):format(gang))
            end
        end)
    else
        TriggerClientEvent('brp:showNotification', source, 'Player Not Found', 2)
    end
end)

RegisterServerEvent('brp:resetUserGang')
AddEventHandler('brp:resetUserGang', function(id)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(id)

    if player and targetPlayer then
        local identifier = player.identifier
        local targetIdentifier = targetPlayer.identifier

        -- Fetch the player's gang and grade from the users table
        local playerQuery = "SELECT gang, gang_grade FROM users WHERE identifier = @identifier;"
        local playerParams = {['@identifier'] = identifier}

        MySQL.Async.fetchAll(playerQuery, playerParams, function(playerResult)
            if playerResult and playerResult[1] then
                local playerGang = playerResult[1].gang
                local playerGrade = tonumber(playerResult[1].gang_grade)

                -- Fetch the target player's gang and grade from the users table
                local targetQuery = "SELECT gang, gang_grade FROM users WHERE identifier = @identifier;"
                local targetParams = {['@identifier'] = targetIdentifier}

                MySQL.Async.fetchAll(targetQuery, targetParams, function(targetResult)
                    if targetResult and targetResult[1] then
                        local targetGang = targetResult[1].gang
                        local targetGrade = tonumber(targetResult[1].gang_grade)

                        -- Fetch the highest grade for the player's gang from the gang_grades table
                        local highestGradeQuery = "SELECT grade FROM gang_grades WHERE gang_name = @gang ORDER BY grade DESC LIMIT 1;"
                        local highestGradeParams = {['@gang'] = playerGang}

                        MySQL.Async.fetchScalar(highestGradeQuery, highestGradeParams, function(highestGrade)
                            if highestGrade then
                                highestGrade = tonumber(highestGrade)

                                -- Check if the player is the highest grade in the same gang as the target player
                                if playerGrade == highestGrade and playerGang == targetGang then
                                    -- Update the target player's gang and grade in the users table
                                    local updateQuery = "UPDATE users SET gang = @gang, gang_grade = @gangGrade WHERE identifier = @identifier;"
                                    local updateParams = {
                                        ['@gang'] = 'none',
                                        ['@gangGrade'] = 0,
                                        ['@identifier'] = targetIdentifier
                                    }

                                    MySQL.Async.execute(updateQuery, updateParams, function(rowsChanged)
                                        if rowsChanged > 0 then
                                            print(("Gang information reset for user with identifier %s"):format(targetIdentifier))
                                            TriggerClientEvent('brp:showNotification', source, "Gang information reset successfully", 1)
                                        else
                                            print(("Failed to reset gang information for user with identifier %s"):format(targetIdentifier))
                                            TriggerClientEvent('brp:showNotification', source, "Failed to reset gang information", 3)
                                        end
                                    end)
                                else
                                    TriggerClientEvent('brp:showNotification', source, "You do not have permission to reset this player's gang information", 2)
                                end
                            else
                                print(("Failed to fetch highest grade for gang %s"):format(playerGang))
                                TriggerClientEvent('brp:showNotification', source, "Failed to fetch highest grade for the gang", 3)
                            end
                        end)
                    else
                        print(("Target player with identifier %s not found or has no gang information"):format(targetIdentifier))
                        TriggerClientEvent('brp:showNotification', source, "Target player not found or has no gang information", 3)
                    end
                end)
            else
                print(("Player with identifier %s not found or has no gang information"):format(identifier))
                TriggerClientEvent('brp:showNotification', source, "Player not found or has no gang information", 3)
            end
        end)
    else
        print(("Player or target player with ID %d not found"):format(source))
        TriggerClientEvent('brp:showNotification', source, "Player or target player not found", 3)
    end
end)

local flagstatus = {}

for _, gangs in ipairs(config.gangs) do 
    flagstatus[gangs.label] = {
        stolen = false,
        timer = 0
    }
end

local cooldown = function(gangname)
    while flagstatus[gangname].stolen == true and flagstatus[gangname].timer > 0 do 
        flagstatus[gangname].timer = flagstatus[gangname].timer - 1
        if flagstatus[gangname].timer <= 0 then
            flagstatus[gangname].stolen = false
            flagstatus[gangname].timer = 0
            TriggerClientEvent('chatMessage', -1, '^5[Gang Alert]^0', {255, 255, 255}, gangname..'\'s flag is ready') -- Send the chat message to all players
        end
        Citizen.Wait(1000)
    end
end

RegisterServerEvent('brp:stealGangFlag')
AddEventHandler('brp:stealGangFlag', function(gangs)
    local source = source
    local gangname = gangs.label
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Check if the player is valid and in a gang
    if xPlayer and xPlayer.identifier then
        local query = "SELECT gang FROM users WHERE identifier = @identifier"
        local params = {['@identifier'] = xPlayer.identifier}

        MySQL.Async.fetchScalar(query, params, function(gang)
            if gang and gang ~= 'none' then -- Player is in a gang
                if gang ~= gangname then
                    if flagstatus[gangname].stolen == false then
                        if xPlayer.addInventoryItem(gangname..'_flag', 1) then
                            flagstatus[gangname].stolen = true
                            flagstatus[gangname].timer = gangs.stealcooldown
                            print(json.encode(flagstatus))
                            TriggerClientEvent('brp:showNotification', source, "You have stolen the "..gangname.." flag", 1)
                            TriggerClientEvent('chatMessage', -1, '^5[Gang Alert]^0', {255, 255, 255}, gangname..'\'s flag has been stolen!')
                            cooldown(gangname)
                        end
                    else
                        TriggerClientEvent('brp:showNotification', source, "Flag is already stolen, please wait: "..flagstatus[gangname].timer.." seconds", 2)
                    end
                else
                    TriggerClientEvent('brp:showNotification', source, "You cant steal your own flag", 2)
                end
            else
                TriggerClientEvent('brp:showNotification', source, "You must be a member of a gang to steal this flag", 2)
            end
        end)
    else
        print("Player not found or invalid player data")
    end
end)


RegisterServerEvent('brp:vendorsell')
AddEventHandler('brp:vendorsell', function(flagname, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = tonumber(amount)
    local flag = flagname..'_flag'
    local flagcount = xPlayer.getInventoryItem(flag).count
    local payout = amount * 45000
    print(flagcount)
    if flagcount ~= 0 then
        if amount <= flagcount then
            if xPlayer.removeInventoryItem(flag, amount) then
                xPlayer.addMoney(payout)
                TriggerClientEvent('brp:showNotification', source, 'Thanks for the flag(s)!', 1)
            else
                TriggerClientEvent('brp:showNotification', source, 'Failed to remove item from inventory!', 2)
            end
        else
            TriggerClientEvent('brp:showNotification', source, 'You dont have the amount you are trying to sell!', 3)
        end
    else
        TriggerClientEvent('brp:showNotification', source, 'You dont have the flag you are trying to sell!', 3)
    end

end)