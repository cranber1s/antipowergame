local cfg = Config
local damageScale = Config.VehicleDamage.DamageScale
local tireBurstTriggered = false
local smokeEffectTriggered = false

if not Config then
    print("Config not found. Please ensure the config.lua is loaded.")
    return
end
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
            
        if Config.EnableVehicleControl then
            if vehicle ~= 0 then
                local model = GetEntityModel(vehicle)
                local roll = GetEntityRoll(vehicle)
                    
                if (IsThisModelACar(model) and IsEntityInAir(vehicle)) or (roll < -75 or roll > 75) then
                    sleep = 0 
                    DisableControlAction(0, 59) 
                    DisableControlAction(0, 60)
                end
            end
        end

        Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cfg.WaitTime)
        local veh = GetVehiclePedIsIn(PlayerPedId())

        if veh ~= 0 and DoesEntityExist(veh) then
            local vehclass = GetVehicleClass(veh)

            if isInArray(cfg.VehClass.Offroad, vehclass) then
                Citizen.Wait(4500)
            else
                handleVehicleGrip(veh, vehclass)
            end
        else
            Citizen.Wait(1200)
        end
    end
end)

function handleVehicleGrip(veh, vehclass)
    if not DoesEntityExist(veh) then return end

    local material_id = GetVehicleWheelSurfaceMaterial(veh, 1)
    
    if material_id and isInArray(cfg.Materials.OffRoad, material_id) then
        SetVehicleReduceGrip(veh, false)
        SetVehicleBurnout(veh, 0)
        Citizen.Wait(350)
    else
        supercarsStop(veh, vehclass)
        adjustGripBasedOnRotation(veh)
    end
end

function adjustGripBasedOnRotation(veh)
    if not DoesEntityExist(veh) then return end

    local wheel_type = GetVehicleWheelType(veh)
    local rot = GetEntityRotation(veh, 5)
    local offroadY = cfg.OffroadRotationY
    local normalY = cfg.NormalRotationY
    local offroadYl = cfg.OffroadRotationYl
    local normalYl = cfg.NormalRotationYl

    if wheel_type == 4 and ((rot.y >= offroadY or rot.x >= offroadY) or (rot.y < offroadYl or rot.x < offroadYl)) then
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
    if not DoesEntityExist(veh) then return end 

    local ratas = getWheelMaterials(veh)
    
    if areAllWheelsValid(ratas) then
        SetVehicleBurnout(veh, 1)
        local speed = GetEntitySpeed(veh) * 3.6
        
        if speed > cfg.SpeedThresholdSuperCar then
            adjustEngineHealth(veh, cfg.EngineHealthDecreaseSuperCar)
        end
    else
        SetVehicleBurnout(veh, 0)
    end
end

function handleOtherVehicles(veh)
    if not DoesEntityExist(veh) then return end

    local ratas = getWheelMaterials(veh)
    
    if not IsEntityInAir(veh) and areAllWheelsValid(ratas) then
        local speed = GetEntitySpeed(veh) * 3.6
        
        if speed > cfg.SpeedThresholdOther then
            adjustEngineHealth(veh, cfg.EngineHealthDecreaseOther)
        end
    end
end

function adjustEngineHealth(veh, decrease)
    if not DoesEntityExist(veh) then return end 

    local health = GetVehicleEngineHealth(veh) - decrease
    if health > 265 then
        SetVehicleEngineHealth(veh, health)
    end
end

function getWheelMaterials(veh)
    local materials = {}
    if not DoesEntityExist(veh) then return materials end

    for i = 0, 5 do
        local material = GetVehicleWheelSurfaceMaterial(veh, i)
        if material then
            table.insert(materials, material)
        end
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
        Citizen.Wait(cfg.AirCheckWaitTime)
        local veh = GetVehiclePedIsIn(PlayerPedId())
        
        if veh ~= 0 and DoesEntityExist(veh) then
            getWheelMaterials(veh)
        end
    end
end)

local function getDamageThreshold(scale)
    return 1000 - (scale * 90)
end

local function canBurstTire(engineHealth)
    if not Config.VehicleDamage.EnableTireBurst then return false end
    local tireBurstThreshold = getDamageThreshold(damageScale)
    return engineHealth < tireBurstThreshold and math.random(1, 100) <= Config.VehicleDamage.BurstChance
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) and Config.VehicleDamage.Enable then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local damageThreshold = getDamageThreshold(damageScale)

            if engineHealth < damageThreshold and not smokeEffectTriggered then
                StartVehicleSmokeEffect(vehicle)
                SetVehicleEnginePerformance(vehicle)
                smokeEffectTriggered = true
            elseif engineHealth >= damageThreshold and smokeEffectTriggered then
                smokeEffectTriggered = false
            end

            if HasEntityCollidedWithAnything(vehicle) and not tireBurstTriggered then
                if canBurstTire(engineHealth) then
                    BurstVehicleTire(vehicle)
                    tireBurstTriggered = true
                end
            elseif not HasEntityCollidedWithAnything(vehicle) then
                tireBurstTriggered = false
            end
        end
    end
end)

function StartVehicleSmokeEffect(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleEngineHealth(vehicle, getDamageThreshold(damageScale) - 50)
end

function SetVehicleEnginePerformance(vehicle)
    local currentSpeed = GetEntitySpeed(vehicle)
    local reducedSpeed = currentSpeed * 0.75
    SetVehicleForwardSpeed(vehicle, reducedSpeed)
end

function BurstVehicleTire(vehicle)

    local tireIndex = math.random(0, 5)
    if tireIndex == 2 or tireIndex == 3 then
        tireIndex = 4 
    end

    SetVehicleTyreBurst(vehicle, tireIndex, true, 1000.0)
    print("Bursting tire:", tireIndex)
end
