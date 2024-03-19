--TriggerServerEvent('brp:getUserGangInfo', '1')
--TriggerServerEvent('brp:setUserGang', 1, 'kao', 1)

local notification = function(message, ntype)
    exports['notifications']:sendnotify(message, ntype, 6000)
end

RegisterNetEvent('brp:showNotification')
AddEventHandler('brp:showNotification', function(message, ntype)
    notification(message, ntype)
end)