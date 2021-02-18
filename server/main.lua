ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("fizzfau-gangsell:sell")
AddEventHandler("fizzfau-gangsell:sell", function(item, label, count, price, ped)
    local player = ESX.GetPlayerFromId(source)
    local itemcount = player.getQuantity(item)
    if itemcount >= count then
        player.removeInventoryItem(item, count)
        TriggerClientEvent("fizzfau-gangsell:clear", source, ped)
        text = "You sold " .. count .. " pieces " ..label.. " and earned " .. count*price.. "$!"
        TriggerClientEvent("notification", source, text)
        player.addMoney(count*price)
    end

end)

ESX.RegisterServerCallback("fizzfau-gangsell:itemcheck", function(source, cb, item, label, ped, count)
    local player = ESX.GetPlayerFromId(source)
    local itemcount = player.getQuantity(item)
    if itemcount > count then
       cb(true)
    else
        text = "You dont have enough "..label.. " and that makes him mad!"
        TriggerClientEvent("fizzfau-gangsell:fightped", source, ped)
        TriggerClientEvent("notification", source, text)
        cb(false)
    end
end)

RegisterServerEvent("fizzfau-gangsell:pedanim")
AddEventHandler("fizzfau-gangsell:pedanim", function(ped, item, label, k, price)
    TriggerClientEvent("fizzfau-gangsell:pedanim", -1, ped, item, label, k, price)
end)

RegisterServerEvent("fizzfau-gangsell:create")
AddEventHandler("fizzfau-gangsell:create", function(ped, item, label, k, price)
    TriggerClientEvent("fizzfau-gangsell:create", -1)
end)