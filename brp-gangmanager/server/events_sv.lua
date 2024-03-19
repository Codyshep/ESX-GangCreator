ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('brp:getUserGangInfo')
AddEventHandler('brp:getUserGangInfo', function(id)
    local source = source
    local player = ESX.GetPlayerFromId(id)
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
end)

RegisterServerEvent('brp:setUserGang')
AddEventHandler('brp:setUserGang', function(id, gang, gangGrade)
    local player = ESX.GetPlayerFromId(id)
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
                        -- Update the player's gang and grade in the users table
                        local updateQuery = "UPDATE users SET gang = @gang, gang_grade = @gangGrade WHERE identifier = @identifier;"
                        local updateParams = {
                            ['@gang'] = gang,
                            ['@gangGrade'] = gangGrade,
                            ['@identifier'] = identifier
                        }

                        MySQL.Async.execute(updateQuery, updateParams, function(rowsChanged)
                            if rowsChanged > 0 then
                                TriggerClientEvent('brp:showNotification', id, "Gang information updated successfully", 1)
                                print(("Gang information updated for user with identifier %s"):format(identifier))
                            else
                                TriggerClientEvent('brp:showNotification', id, "Failed to update gang information", 3)
                                print(("Failed to update gang information for user with identifier %s"):format(identifier))
                            end
                        end)
                    else
                        TriggerClientEvent('brp:showNotification', id, "You do not have permission to set this grade", 2)
                        print(("User with identifier %s does not have permission to set their grade to %d"):format(identifier, gangGrade))
                    end
                else
                    TriggerClientEvent('brp:showNotification', id, "Failed to fetch user's gang grade", 3)
                    print(("Failed to fetch gang grade for user with identifier %s"):format(identifier))
                end
            end)
        else
            TriggerClientEvent('brp:showNotification', id, "Failed to fetch highest grade for the gang", 3)
            print(("Failed to fetch highest grade for gang %s"):format(gang))
        end
    end)
end)



RegisterCommand('setgang', function(source, args)
    TriggerEvent('brp:setUserGang', args[1], args[2], args[3])
end, 'group.admin')

RegisterCommand('getganginfo', function(source, args)
    TriggerEvent('brp:getUserGangInfo', args[1])
end, 'group.admin')