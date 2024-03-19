ESX = exports['es_extended']:getSharedObject()

lib.registerContext({
    id = 'gang_leadermenu',
    title = 'Gang Menu',
    options = {
        {
            title = "Set Rank",
            onSelect = function()
                local input = lib.inputDialog('Set Rank', {
                    {type = 'number', label = 'Player ID', description = 'ID of player you want to set!', icon = 'hashtag'},
                    {type = 'number', label = 'Rank', description = 'Rank that you want to set them!', icon = 'hashtag'},
                    {type = 'input', label = 'Gang Name', description = 'Your gang name!', required = true}
                }) 
                if input then
                    TriggerServerEvent('brp:setUserGang', input[1], input[3], input[2])
                end
            end
        },
        {
            title = "Get Player Data",
            onSelect = function()
                local input = lib.inputDialog('Check Player', {
                    {type = 'number', label = 'Player ID', description = 'ID of player you want to check!', icon = 'hashtag'}
                }) 
                if input then
                    TriggerServerEvent('brp:getUserGangInfo', input[1])
                end
            end
        },
        {
            title = "Fire Player",
            onSelect = function()
                local input = lib.inputDialog('Check Player', {
                    {type = 'number', label = 'Player ID', description = 'ID of player you want to fire!', icon = 'hashtag'}
                }) 
                if input then
                    TriggerServerEvent('brp:resetUserGang', input[1])
                end
            end
        }
    }
})

for _, gangs in ipairs(config.gangs) do
    --bossmenu_coords
    exports.ox_target:addBoxZone({
        coords = vec3(gangs.bossmenu_coords),
        size = vec3(3,3,3),
        options = {
            {
                label = 'Gang Menu',
                onSelect = function()
                    lib.showContext('gang_leadermenu')
                end
            }
        }
    })
end