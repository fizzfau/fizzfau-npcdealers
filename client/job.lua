ESX = nil
npc = {}
pressed = false
local entities = 0
local fight = {}
Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        local clock = GetClockHours()
        if clock >= Config.LocalTimes[1] or clock < Config.LocalTimes[2] then
            TriggerServerEvent("fizzfau-gangsell:create")
        else
            for k,v in pairs(npc) do
                if DoesEntityExist(npc[k]) then
                    DeleteEntity(npc[k])
                    npc[k] = nil
                end
            end
        end
        Citizen.Wait(Config.WaitBetweenSells * 1000 * 1)
    end
end)

function CreatePeds()
    for k,v in pairs(Config.Locations) do
        if not DoesEntityExist(npc[k]) and entities < #Config.Locations then
            RequestModel(v.hash)
            while not HasModelLoaded(v.hash) do
                Citizen.Wait(1)
            end
            npc[k] = CreatePed(1, v.hash, v.coords.x, v.coords.y, v.coords.z - 0.98, v.h, false, true)
            entities = entities + 1
            pressed = false
            SetBlockingOfNonTemporaryEvents(npc[k], true) 
            SetPedDiesWhenInjured(npc[k], false)
            SetPedCanPlayAmbientAnims(npc[k], true)
            SetPedCanRagdollFromPlayerImpact(npc[k], false) 
            SetEntityInvincible(npc[k], true)	
            FreezeEntityPosition(npc[k], true) 
            TaskStartScenarioInPlace(npc[k], "WORLD_HUMAN_SMOKING", 0, true);
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local clock = GetClockHours()
        local wait = 1000
        if clock >= Config.LocalTimes[1] or clock < Config.LocalTimes[2] then
            for k,v in pairs(Config.Locations) do

                if npc[k] ~= nil and pressed == false then
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    local distance = #(coords - v.coords)
                    if distance < 5.0 then
                        wait = 0
                        text = v.text
                        if distance <= 2.0 then
                            text = "E - " ..v.text
                            if IsControlJustPressed(0, 46) then
                                -- local count = 0
                                local count = math.random(v.min, v.max)
                                ESX.TriggerServerCallback("fizzfau-gangsell:itemcheck", function(bool)
                                    if bool then
                                        TriggerServerEvent("fizzfau-gangsell:pedanim", ped, v.item, v.label, k, v.price)
                                        --Anim(ped, v.item, v.label, k, v.price)
                                        Citizen.Wait(500)
                                        playAnim(ped, "mp_common", "givetake1_a", 2500)
                                        Sell(v.item, v.label, v.price, k, count)
                                    end
                                end, v.item, v.label, k, count)
                            end
                        end
                        DrawText3Ds(v.coords.x, v.coords.y, v.coords.z, text)
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function Anim(ped, item, label, k, price)
    pressed = true
    FreezeEntityPosition(npc[k], false)
    TaskTurnPedToFaceEntity(npc[k], ped, 1.0)
    Citizen.Wait(500)
    playAnim(npc[k], "mp_common", "givetake1_a", 2500)
    Citizen.Wait(1500)
    ClearPedTasks(npc[k])
    TriggerEvent("fizzfau-gangsell:clear", k)
end

function Sell(item, label, price, k, count)
    TriggerServerEvent("fizzfau-gangsell:sell", item, label, count, price, k)
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	ClearDrawOrigin()
end

function playAnim(ped, animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

function stopAnim(ped, dictionary, anim)
	StopAnimTask(ped, dictionary, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
end

RegisterNetEvent("fizzfau-gangsell:fightped")
AddEventHandler("fizzfau-gangsell:fightped", function(k)
    local playerp = PlayerPedId()
    SetPedDiesWhenInjured(npc[k], true) 
    SetPedCanRagdollFromPlayerImpact(npc[k], true) 
    SetEntityInvincible(npc[k], false)
    FreezeEntityPosition(npc[k], false)
    Citizen.Wait(100)
    TaskCombatPed(npc[k], playerp, 0, 16)
    fight[k] = npc[k]
    npc[k] = nil
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            for k,v in pairs(fight) do
                if IsPedDeadOrDying(v, 1) then
                    Citizen.Wait(10000)
                    entities = entities - 1
                    DeleteEntity(v)
                    fight[k] = nil
                    break
                end
            end
        end
    end)
end)

RegisterNetEvent("fizzfau-gangsell:clear")
AddEventHandler("fizzfau-gangsell:clear", function(k)
    Citizen.Wait(1000)
    TaskWanderStandard(npc[k], 10.0, 10)
    local willbedeleted = npc[k]
    npc[k] = nil
    entities = entities - 1
    Citizen.Wait(30000)
    DeleteEntity(willbedeleted)
    willbedeleted = nil
end)

RegisterNetEvent("fizzfau-gangsell:create")
AddEventHandler("fizzfau-gangsell:create", function()
    CreatePeds()
end)

RegisterNetEvent("fizzfau-gangsell:pedanim")
AddEventHandler("fizzfau-gangsell:pedanim", function(ped, item, label, k, price, pressed)
    Anim(ped, item, label, k, price)
end)