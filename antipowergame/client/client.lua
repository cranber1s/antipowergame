local cfg = Config.Settings

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cfg.WaitTime)
        local veh = GetVehiclePedIsIn(PlayerPedId())

        if veh ~= 0 then
            local vehclass = GetVehicleClass(veh)

            if isInArray(cfg.VehClass.Offroad, vehclass) then
                Citizen.Wait(4500) -- Wait longer for off-road vehicles
            else
                handleVehicleGrip(veh, vehclass)
            end
        else
            Citizen.Wait(1200) -- No vehicle, wait longer
        end
    end
end)

function handleVehicleGrip(veh, vehclass)
    local material_id = GetVehicleWheelSurfaceMaterial(veh, 1)
    
    if isInArray(cfg.Materials.OffRoad, material_id) then
        SetVehicleReduceGrip(veh, false) -- On road
        SetVehicleBurnout(veh, 0)
        Citizen.Wait(350)
    else
        supercarsStop(veh, vehclass)
        adjustGripBasedOnRotation(veh)
    end
end

function adjustGripBasedOnRotation(veh)
    local wheel_type = GetVehicleWheelType(veh)
    local rot = GetEntityRotation(veh, 5)
    local offroadY = cfg.Settings.OffroadRotationY
    local normalY = cfg.Settings.NormalRotationY
    local offroadYl = cfg.Settings.OffroadRotationYl
    local normalYl = cfg.Settings.NormalRotationYl

    if (wheel_type == 4 and (rot.y >= offroadY or rot.x >= offroadY) or 
        (rot.y < offroadYl or rot.x < offroadYl)) then
        SetVehicleReduceGrip(veh, true)
    else
        SetVehicleReduceGrip(veh, false)
    end
end

function supercarsStop(veh, vehclass)
    if isInArray(cfg.VehClass.SuperCars, vehclass) then
        handleSuperCarBurnout(veh)
    elseif not isInArray({2, 8, 19, 9}, vehclass) then
        handleOtherVehicles(veh)
    end
end

function handleSuperCarBurnout(veh)
    local ratas = getWheelMaterials(veh)
    
    if areAllWheelsValid(ratas) then
        SetVehicleBurnout(veh, 1)
        local speed = GetEntitySpeed(veh) * 3.6
        
        if speed > cfg.Settings.SpeedThresholdSuperCar then
            adjustEngineHealth(veh, cfg.Settings.EngineHealthDecreaseSuperCar)
        end
    else
        SetVehicleBurnout(veh, 0)
    end
end

function handleOtherVehicles(veh)
    local ratas = getWheelMaterials(veh)
    
    if not IsEntityInAir(veh) and areAllWheelsValid(ratas) then
        local speed = GetEntitySpeed(veh) * 3.6
        
        if speed > cfg.Settings.SpeedThresholdOther then
            adjustEngineHealth(veh, cfg.Settings.EngineHealthDecreaseOther)
        end
    end
end

function adjustEngineHealth(veh, decrease)
    local health = GetVehicleEngineHealth(veh) - decrease
    if health > 265 then
        SetVehicleEngineHealth(veh, health)
    end
end

function getWheelMaterials(veh)
    local materials = {}
    for i = 0, 5 do
        table.insert(materials, GetVehicleWheelSurfaceMaterial(veh, i))
    end
    return materials
end

function areAllWheelsValid(ratas)
    for _, wheel in pairs(ratas) do
        if not isInArray(cfg.Materials.ValidMaterials, wheel) then
            return false
        end
    end
    return true
end

function isInArray(array, value)
    for _, v in pairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cfg.Settings.AirCheckWaitTime)
        local veh = GetVehiclePedIsIn(PlayerPedId())
        
        if veh ~= 0 then
            getWheelMaterials(veh) -- Ensure we gather wheel materials periodically
        end
    end
end)
