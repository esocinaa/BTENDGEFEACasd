local current_name = GetCurrentResourceName()

local resourceFile = LoadResourceFile(current_name, "auth.lua")
if not resourceFile then
    print("[photon-integrity] critical error please dont remove files from resource")
    return
end

local cfg = load(LoadResourceFile(current_name, "server/cfg.lua"))()

print("woow")

RegisterNetEvent("c2s:reportPedModel", function(clientPedModel)
    if not AUTHORIZED then
        return
    end

    local src = source
    local ped = GetPlayerPed(src)
    local serverPedModel = ped and ped ~= 0 and GetEntityModel(ped) or nil
    local fish_hash = 802685111

    if serverPedModel and clientPedModel then
        serverPedModel = tonumber(serverPedModel)
        clientPedModel = tonumber(clientPedModel)
        if serverPedModel == fish_hash then
            local playerName = GetPlayerName(src) or ("[" .. tostring(src) .. "]")
            print(("[photon] %s tried to crash"):format(playerName))
            exports[cfg.resource.fiveguard]:fg_BanPlayer(src, "Tried to crash - upx", true)
        end
    end
end)

local lastServerPedModels = {}

Citizen.CreateThread(function()
    while true do
        if AUTHORIZED then
            for _, src in ipairs(GetPlayers()) do
                local ped = GetPlayerPed(src)
                if ped and ped ~= 0 then
                    local serverPedModel = GetEntityModel(ped)
                    if lastServerPedModels[src] ~= serverPedModel then
                        lastServerPedModels[src] = serverPedModel
                        TriggerLatentClientEvent("s2c:requestPedModel", src)
                    end
                end
            end
        end
        Citizen.Wait(1500)
    end
end)
