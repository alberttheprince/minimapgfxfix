local RESOURCE = GetCurrentResourceName()
local COMPONENT_IDS = { 20, 21, 22 }
local VALID_COMPONENT_IDS = { [20] = true, [21] = true, [22] = true }

local zones = {}
local occupiedZones = {}
local componentZoneCounts = {}
local baseStateApplied = false
local oxAttempted = false

local function setComponent(componentId, enabled)
    SetMinimapComponent(componentId, enabled, -1)
end

local function setComponents(enabled)
    for index = 1, #COMPONENT_IDS do
        setComponent(COMPONENT_IDS[index], enabled)
    end
end

local function loadOxZones()
    if oxAttempted or not baseStateApplied then return nil end
    if GetResourceState('ox_lib') ~= 'started' then return nil end

    oxAttempted = true

    local source = LoadResourceFile('ox_lib', 'init.lua')
    if not source then
        print(('^1[%s] Could not read ox_lib/init.lua; mansion map components remain hidden.^0'):format(RESOURCE))
        return nil
    end

    local chunk, compileError = load(source, '@@ox_lib/init.lua', 't', _ENV)
    if not chunk then
        print(('^1[%s] ox_lib compile error: %s; mansion map components remain hidden.^0')
            :format(RESOURCE, compileError))
        return nil
    end

    local loaded, zonesOrError = pcall(function()
        chunk()
        return _ENV.lib.zones
    end)

    if not loaded then
        print(('^1[%s] ox_lib load error: %s; mansion map components remain hidden.^0')
            :format(RESOURCE, zonesOrError))
        return nil
    end

    return zonesOrError
end

local function playerEnteredZone(zone)
    if occupiedZones[zone.id] then return end

    local componentId = zone.component
    occupiedZones[zone.id] = componentId
    componentZoneCounts[componentId] = (componentZoneCounts[componentId] or 0) + 1

    if componentZoneCounts[componentId] == 1 then
        setComponent(componentId, true)
    end
end

local function playerLeftZone(zone)
    local componentId = occupiedZones[zone.id]
    if not componentId then return end

    occupiedZones[zone.id] = nil
    componentZoneCounts[componentId] = math.max(0, (componentZoneCounts[componentId] or 1) - 1)

    if componentZoneCounts[componentId] == 0 then
        setComponent(componentId, false)
    end
end

local function createZones()
    local oxZones = loadOxZones()
    if not oxZones then return false end

    local defaultRadius = math.max(1.0, tonumber(Config.zoneRadius) or 45.0)

    for index = 1, #(Config.zones or {}) do
        local zoneConfig = Config.zones[index]
        local coords = zoneConfig.coords
        local componentId = tonumber(zoneConfig.component)

        if coords and tonumber(coords.x) and tonumber(coords.y) and tonumber(coords.z)
            and VALID_COMPONENT_IDS[componentId] then
            zones[#zones + 1] = oxZones.sphere({
                name = zoneConfig.name or ('mansion_%d'):format(index),
                coords = vec3(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)),
                radius = math.max(1.0, tonumber(zoneConfig.radius) or defaultRadius),
                component = componentId,
                debug = Config.debugZones == true,
                onEnter = playerEnteredZone,
                onExit = playerLeftZone
            })
        else
            print(('^1[%s] Ignoring invalid Config.zones entry %d.^0'):format(RESOURCE, index))
        end
    end

    print(('[%s] ox_lib mode active with %d mansion zones.'):format(RESOURCE, #zones))
    return true
end

if Config.oxlib == true then
    AddEventHandler('onClientResourceStart', function(resourceName)
        if resourceName == 'ox_lib' and baseStateApplied then
            createZones()
        end
    end)
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= RESOURCE then return end

    for index = 1, #zones do
        zones[index]:remove()
    end

    if Config.restoreOnStop ~= false then
        setComponents(true)
    end
end)

SetTimeout(math.max(0, tonumber(Config.applyDelay) or 500), function()
    setComponents(false)
    baseStateApplied = true

    if Config.oxlib == true then
        if not createZones() and GetResourceState('ox_lib') ~= 'started' then
            print(('^3[%s] Waiting for ox_lib to start; mansion map components remain hidden.^0'):format(RESOURCE))
        end
        return
    end

    print(('[%s] Mansion map components disabled. Zero-loop mode is active.'):format(RESOURCE))
end)
