Config = {}

-- false: hide all three mansion map silhouettes for the entire session.
-- true:  show only an estate's component while the player is inside its ox_lib zone.
Config.oxlib = false

-- ox_lib is optional unless Config.oxlib is true.
Config.debugZones = false
Config.zoneRadius = 45.0

-- Delay the initial native calls until the HUD has initialized.
Config.applyDelay = 500

-- Restore Rockstar's default component state if this resource is stopped.
Config.restoreOnStop = true

Config.zones = {
    {
        name = 'Vinewood Estate',
        coords = vec3(543.852, 712.754, 201.0),
        component = 21
    },
    {
        name = 'Richman Estate',
        coords = vec3(-1630.434, 470.852, 128.0),
        component = 20
    },
    {
        name = 'Tongva Estate',
        coords = vec3(-2601.712, 1874.826, 166.0),
        component = 22
    }
}
