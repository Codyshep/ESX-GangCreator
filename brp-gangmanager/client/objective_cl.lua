local flagstatus = {}

for _, gangs in ipairs(config.gangs) do
    local x, y, z = gangs.obj_coords
    local object = nil
    while not DoesEntityExist(object) do
        object = CreateObject('m23_1_prop_m31_crate_narc', x, y, z, true)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        print(object)
        Citizen.Wait(1000)
    end
end

for _, gangs in ipairs(config.gangs) do 
    flagstatus[gangs.label] = {
        stolen = false
    }
    exports.ox_target:addBoxZone({
        coords = gangs.obj_coords,
        size = vec3(3,3,3),
        options = {
            {
                label = 'Steal Flag',
                distance = 4,
                onSelect = function()
                    TriggerServerEvent('brp:stealGangFlag', gangs)
                end
            }
        }
    })
end