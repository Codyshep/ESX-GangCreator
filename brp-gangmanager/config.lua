config = {}

config.gangs = {
    {
        label = "kao",
        obj_coords = vec3(1345.2025, -600.0300, 73.7008),
        bossmenu_coords = vec3(1341.2167, -597.3806, 74.6995),
        gangzone_coords = vec3(1364.8881, -578.3230, 73.3802),
        color = 50,
        gangzone_size = 100,
        stealcooldown = 120 -- seconds
    },
    {
        label = "otf",
        obj_coords = vec3(1150.3079, -473.1122, 65.5488),
        bossmenu_coords = vec3(1106.1530, -485.2607, 65.4230),
        gangzone_coords = vec3(1150.9329, -473.0896, 66.5445),
        color = 45,
        gangzone_size = 100,
        stealcooldown = 120 -- seconds
    }
}

config.vendors = {
    {
        pedmodel = 'G_M_Y_StrPunk_02', -- https://forge.plebmasters.de/peds
        pedcoords = vector4(305.8061, -657.1238, 52.1440, 70)
    }
}

return config 