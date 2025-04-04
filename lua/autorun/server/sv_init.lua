util.AddNetworkString('KickPlayer')
util.AddNetworkString('BanPlayer')
util.AddNetworkString('MutePlayer')
util.AddNetworkString('UnmutePlayer') 
util.AddNetworkString('SlayPlayer')

net.Receive('KickPlayer', function(len, ply)
    if not ply:IsAdmin() then return end
    local targetID = net.ReadString()
    game.KickID(targetID, "Кикнут администратором "..ply:Name())
end)

net.Receive('BanPlayer', function(len, ply)
    if not ply:IsAdmin() then return end
    
    local steamID = net.ReadString()
    local minutes = net.ReadUInt(32)
    local reason = net.ReadString()
    
    local target = player.GetBySteamID(steamID)
    if not IsValid(target) then return end

    if ULib and ulx then
        if minutes <= 0 then
            ulx.ban(ply, target, 0, reason)
        else
            ulx.ban(ply, target, minutes, reason)
        end
    else
        if minutes <= 0 then
            game.ConsoleCommand("banid 0 "..steamID.."\n")
        else
            game.ConsoleCommand("banid "..minutes.." "..steamID.."\n")
        end
        game.ConsoleCommand("kickid "..steamID.." "..reason.."\n")
        game.ConsoleCommand("writeid\n")
    end
    
    PrintMessage(HUD_PRINTTALK, "Игрок "..target:Nick().." забанен. Причина: "..reason)
end)

net.Receive('MutePlayer', function(len, ply)
    if not ply:IsAdmin() then return end
    
    local steamID = net.ReadString()
    local minutes = net.ReadUInt(32)
    local reason = net.ReadString()
    
    local target = player.GetBySteamID(steamID)
    if not IsValid(target) then return end

    timer.Remove("UnmutePlayer_"..steamID)

    if ULib and ulx then
        if minutes <= 0 then
            ulx.permamute(ply, target, reason)
        else
            ulx.mute(ply, target, minutes, reason)
        end
    else
        target:SetNWBool("AdminMuted", true)
        
        if minutes > 0 then
            timer.Create("UnmutePlayer_"..steamID, minutes * 60, 1, function()
                if IsValid(target) then
                    target:SetNWBool("AdminMuted", false)
                    PrintMessage(HUD_PRINTTALK, "Игрок "..target:Nick().." размучен")
                end
            end)
        end
    end
    
    PrintMessage(HUD_PRINTTALK, "Игрок "..target:Nick().." заглушен. Причина: "..reason)
end)

net.Receive('UnmutePlayer', function(len, ply)
    if not ply:IsAdmin() then return end
    
    local steamID = net.ReadString()
    local target = player.GetBySteamID(steamID)
    if not IsValid(target) then return end

    if ULib and ulx then
        ulx.unmute(ply, target)
    else
        target:SetNWBool("AdminMuted", false)
        timer.Remove("UnmutePlayer_"..steamID)
    end
    
    PrintMessage(HUD_PRINTTALK, "Игрок "..target:Nick().." размучен администратором "..ply:Name())
end)

net.Receive('SlayPlayer', function(len, ply)
    if not ply:IsAdmin() then return end
    
    local steamID = net.ReadString()
    local target = player.GetBySteamID(steamID)
    
    if not IsValid(target) then return end
    
    if ULib and ulx then
        ulx.slay(ply, target)
    else
        if target:Alive() then
            target:Kill()
            PrintMessage(HUD_PRINTTALK, "Игрок "..target:Nick().." был убит администратором "..ply:Name())
        end
    end
end)

function player.GetBySteamID(steamID)
    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamID then
            return v
        end
    end
    return nil
end