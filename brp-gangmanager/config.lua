config = {}

config.gangs = {
    {
        label = "KAO",
        flag_coords = vec3(1364.8881, -578.3230, 74.3802),
        bossmenu_coords = vec3(1341.2167, -597.3806, 74.6995),
        gangzone_size = 100,
        capturetime = 30 -- in seconds
    },
    {
        label = "OTF",
        flag_coords = vec3(1150.3079, -473.1122, 66.5488),
        bossmenu_coords = vec3(1106.1530, -485.2607, 65.4230),
        gangzone_size = 100,
        capturetime = 40 -- in seconds
    }
}

config.notifications = {
    enterzone = function(gangs)
        -- If you use another notification script make sure you use: gangs.label..'\'s | to mention the specific gangs name for the zone you are entering
        exports['notifications']:sendnotify('You have entered '..gangs.label..'\'s territory', 3, 5000)
    end,
    exitzone = function(gangs)
        exports['notifications']:sendnotify('You have exited '..gangs.label..'\'s territory', 3, 5000)
    end,
    flaggettingcapped = function(gangs)
        exports['notifications']:sendnotify(gangs.label..'\'s flag is already getting taken!', 2, 5000)
    end,
    flagtaken = function(gangs)
        exports['notifications']:sendnotify(gangs.label..'\'s flag has been captured!', 1, 8000)
    end
}

return config 