local black_color = Color(0, 0, 0, 200)

concommand.Add('menu_admin', function()
    if not LocalPlayer():IsAdmin() then
        notification.AddLegacy("У вас нет прав администратора!", NOTIFY_ERROR, 5)
        return
    end

    local menu_admin = vgui.Create('DFrame')
    menu_admin:SetSize(500,500)
    menu_admin:Center()
    menu_admin:MakePopup()
    menu_admin:SetTitle('')
    menu_admin:SetDraggable(true)

    menu_admin.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, black_color)
        draw.SimpleText('Админ панель', 'HudDefault', 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    for _, ply in ipairs(player.GetAll()) do
        local btn_admin = vgui.Create('DButton', menu_admin) 
        btn_admin:SetTall(50)
        btn_admin:Dock(TOP)
        btn_admin:SetText(ply:Name())

        btn_admin.DoClick = function()
            menu_admin:Close()
            local menu_int = vgui.Create('DFrame')
            menu_int:SetSize(500, 500)
            menu_int:Center()
            menu_int:SetTitle('')
            menu_int:SetDraggable(false)
            menu_int:ShowCloseButton(false)
            menu_int:MakePopup()

            menu_int.Paint = function(self, w, h)
                draw.RoundedBox(2, 0, 0, w, h, black_color)
                draw.SimpleText('Взаимодействие с игроком', 'HudDefault', 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            local btnKick = vgui.Create('DButton', menu_int)
            btnKick:SetTall(50)
            btnKick:Dock(TOP)
            btnKick:SetText('Кикнуть игрока')
            btnKick.DoClick = function()
                net.Start('KickPlayer')
                    net.WriteString(ply:SteamID())
                net.SendToServer()
                menu_int:Close()
            end

            local btnBan = vgui.Create('DButton', menu_int)
            btnBan:SetTall(50)
            btnBan:Dock(TOP)
            btnBan:SetText('Забанить игрока')
            btnBan.DoClick = function()
                Derma_StringRequest(
                    "Бан игрока "..ply:Name(),
                    "Время бана (в минутах, 0=навсегда):",
                    "60",
                    function(minutes)
                        minutes = tonumber(minutes) or 60
                        Derma_StringRequest(
                            "Причина бана",
                            "Укажите причину:",
                            "Нарушение правил",
                            function(reason)
                                net.Start("BanPlayer")
                                    net.WriteString(ply:SteamID())
                                    net.WriteUInt(minutes, 32)
                                    net.WriteString(reason)
                                net.SendToServer()
                            end
                        )
                    end
                )
                menu_int:Close()
            end

            local btnSlay = vgui.Create('DButton', menu_int)
            btnSlay:SetTall(50)
            btnSlay:Dock(TOP)
            btnSlay:SetText('Убить игрока')
            btnSlay.DoClick = function()
                Derma_Query(
                    "Убить игрока "..ply:Name().."?",
                    "Подтверждение",
                    "Да",
                    function()
                        net.Start("SlayPlayer")
                            net.WriteString(ply:SteamID())
                        net.SendToServer()
                        menu_int:Close()
                    end,
                    "Нет",
                    function() end
                )
            end

            local btnTp = vgui.Create('DButton', menu_int)
            btnTp:SetTall(50)
            btnTp:Dock(TOP)
            btnTp:SetText('Телепортироваться')
            btnTp.DoClick = function()
                RunConsoleCommand("ulx", "bring", ply:SteamID())
                menu_int:Close()
            end

            local btnMute = vgui.Create('DButton', menu_int)
            btnMute:SetTall(50)
            btnMute:Dock(TOP)
            
            if ply:GetNWBool("AdminMuted", false) then
                btnMute:SetText('Размутить игрока')
                btnMute.DoClick = function()
                    Derma_Query(
                        "Размутить игрока "..ply:Name().."?",
                        "Подтверждение",
                        "Да", 
                        function()
                            net.Start("UnmutePlayer")
                                net.WriteString(ply:SteamID())
                            net.SendToServer()
                            menu_int:Close()
                            notification.AddLegacy("Игрок "..ply:Name().." размучен", NOTIFY_GENERIC, 5)
                        end,
                        "Нет", 
                        function() end
                    )
                end
            else
                btnMute:SetText('Заглушить игрока')
                btnMute.DoClick = function()
                    Derma_StringRequest(
                        "Мут игрока "..ply:Name(),
                        "Время мута (в минутах, 0=навсегда):",
                        "5",
                        function(minutes)
                            minutes = tonumber(minutes) or 5
                            Derma_StringRequest(
                                "Причина мута",
                                "Укажите причину:",
                                "Нарушение чата",
                                function(reason)
                                    net.Start("MutePlayer")
                                        net.WriteString(ply:SteamID())
                                        net.WriteUInt(minutes, 32)
                                        net.WriteString(reason)
                                    net.SendToServer()
                                end
                            )
                        end
                    )
                    menu_int:Close()
                end
            end
        end
    end
end)

hook.Add("PlayerStartVoice", "BlockMutedPlayers", function(ply)
    if ply:GetNWBool("AdminMuted", false) then
        return false
    end
end)

hook.Add("OnPlayerChat", "MutedPlayerChat", function(ply, text, bTeam, bDead)
    if ply:GetNWBool("AdminMuted", false) then
        chat.AddText(Color(255,50,50), "[ЗАМУЧЕН] ", color_white, ply:Nick()..": "..text)
        return true
    end
end)