for _, vendors in ipairs(config.vendors) do
    local blip = AddBlipForCoord(vector3(vendors.pedcoords.x, vendors.pedcoords.y, vendors.pedcoords.z))
    SetBlipSprite(blip, 164)
    SetBlipColour(blip, 67)
    SetBlipScale(blip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Flag Vendor') -- Replace with the desired blip name
    EndTextCommandSetBlipName(blip)
    print("Blip created for: " .. vendors.pedcoords.x, vendors.pedcoords.y, vendors.pedcoords.z)
end

for _, vendors in ipairs(config.vendors) do
    local x, y, z, h = vendors.pedcoords.x, vendors.pedcoords.y, vendors.pedcoords.z, vendors.pedcoords.h
    local ped = nil
    local pedcreated = false
    print("Ped created for: " .. vendors.pedcoords)
    lib.zones.box({
        coords = vec3(x, y, z),
        size = vec3(30, 35, 10),
        onEnter = function()
            if pedcreated == false then
                pedcreated = true
                local model = vendors.pedmodel
                if IsModelInCdimage(model) and IsModelValid(model) then
                    -- Load the model
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(10)
                    end
            
                    -- Create the ped 
                    ped = CreatePed(0, model, vendors.pedcoords, false, true)
                    SetEntityAlpha(ped, 0, false)
                    Wait(50)
                    SetEntityAlpha(ped, 255, false)
            
                    -- Configure the ped's behavior
                    SetPedFleeAttributes(ped, 2)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedCanRagdollFromPlayerImpact(ped, false)
                    SetPedDiesWhenInjured(ped, false)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetPedCanPlayAmbientAnims(ped, false)
                end
            end
        end,
        onExit = function()
            pedcreated = false
            DeleteEntity(ped)
        end
    })
end

lib.registerContext({
    id = 'flag_vendor',
    title = 'Flag Vendor',
    options = {
        {
            title = 'Sell Flags',
            icon = 'hand',
            onSelect = function()
                local input = lib.inputDialog('Vendor', {
                    {type = 'input', label = 'Flag Name', description = '[example: KAO]', required = true},
                    {type = 'number', label = 'Number of flags to sell', description = '[example: 3]', icon = 'hashtag'}
                })
                if input then
                    input[1] = string.lower(input[1])
                    print(input[1], input[2])
                    TriggerServerEvent('brp:vendorsell', input[1], input[2])
                end
            end
        }
    }
})


for _, vendors in ipairs(config.vendors) do
    exports.ox_target:addBoxZone({
        coords = vector3(vendors.pedcoords.x, vendors.pedcoords.y, vendors.pedcoords.z+1.2),
        size = vec3(3,3,3),
        options = {
            {
                label = 'Sell Gang Flags',
                distance = 5,
                onSelect = function()
                    lib.showContext('flag_vendor')
                end
            }
        }
    })
end