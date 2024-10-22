Config = {}

Config.EnableVehicleControl = true  -- Set this to false to disable the vehicle control script (Avoids controlling the car in the air and when it is on the roof)

Config = {
    VehicleDamage = {
        Enable = true,              -- Set to 'true' to enable vehicle damage effects. Set to 'false' to disable all damage-related functionalities.
        DamageScale = 1,            -- Scale for damage effects, ranging from 1 (least damage) to 10 (most damage).This determines how severely the vehicle is affected by damage. Higher values will trigger effects sooner.
        EnableTireBurst = true,     -- Set to 'true' to enable the functionality of bursting tires upon collision. If set to 'false', tire bursting will not occur, regardless of collision.
        BurstChance = 20,           -- The probability (in percentage) of a tire bursting when a collision occurs. A value from 1 to 100, where higher values increase the likelihood of a tire burst after a collision is detected.
    },
}

Config.VehClass = {
    Offroad = {14, 15, 16, 21}, -- Vehicle classes considered as off-road vehicles
    SuperCars = {7}, -- Vehicle class for supercars
    TyreBurst = {0, 1, 2, 3, 4, 5}, -- Indices of tyres to burst when dropping
}

Config.Materials = {
    OffRoad = {4, 7, 1, 68, 13, 3}, -- Materials that signify off-road surfaces
    ValidMaterials = {48, 31, 32, 46, 19, 41, 23, 36, 35, 47, 43, 51, 18}, -- Valid wheel materials that can affect grip
}

Config.Settings = {
    OffroadRotationY = 30, -- Y-axis rotation threshold for off-road grip
    NormalRotationY = 20, -- Y-axis rotation threshold for normal grip
    OffroadRotationYl = -30, -- Lower threshold for off-road grip
    NormalRotationYl = -20, -- Lower threshold for normal grip
    SpeedThresholdSuperCar = 40, -- Speed in km/h for supercars to reduce engine health
    SpeedThresholdOther = 65, -- Speed in km/h for other vehicles to reduce engine health
    EngineHealthDecreaseSuperCar = 30, -- Amount to decrease engine health for supercars
    EngineHealthDecreaseOther = 5, -- Amount to decrease engine health for other vehicles
    WaitTime = 300, -- General wait time for the main thread in milliseconds
    SuperCarWaitTime = 75, -- Wait time for supercars to check conditions
    AirCheckWaitTime = 200, -- Wait time to check if the vehicle is in the air
}

-- Reference for vehicle properties: 
-- https://wiki.gtanet.work/index.php?title=Vehicle_Classes
-- https://wiki.gtanet.work/index.php?title=Vehicle_Wheel_Materials
