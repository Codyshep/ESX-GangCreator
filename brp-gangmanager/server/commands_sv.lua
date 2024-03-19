ESX = exports['es_extended']:getSharedObject()

RegisterCommand("clearprop", function(source, args)
    -- Check if the player has specified a radius
    if #args ~= 1 then
        TriggerClientEvent("chatMessage", source, "^1Usage: /clearprop [radius]")
        return
    end

    -- Parse the radius argument
    local radius = tonumber(args[1])
    if radius == nil or radius <= 0 then
        TriggerClientEvent("chatMessage", source, "^1Invalid radius. Please provide a positive number.")
        return
    end

    -- Get the player's position
    local src = source
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(src), true))

    -- Get all entities around the player
    local objects = GetGamePool("CObject")
    local propsToDelete = {}

    -- Iterate through the objects and find props within the radius
    for _, object in ipairs(objects) do
        local objCoords = GetEntityCoords(object)
        local distance = #(vector3(x, y, z) - objCoords)
        if distance <= radius then
            table.insert(propsToDelete, object)
        end
    end

    -- Delete the props
    for _, prop in ipairs(propsToDelete) do
        DeleteEntity(prop)
    end

    -- Inform the player
    TriggerClientEvent("chatMessage", source, "^2Cleared props within a radius of " .. radius .. " meters.")
end, 'group.admin')

RegisterCommand('setgang', function(source, args)
    TriggerEvent('brp:setUserGang', args[1], args[2], args[3])
end, 'group.admin')

RegisterCommand('getganginfo', function(source, args)
    TriggerEvent('brp:getUserGangInfo', args[1])
end, 'group.admin')