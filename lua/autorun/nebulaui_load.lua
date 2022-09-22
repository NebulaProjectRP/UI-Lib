MsgC(Color(255, 50, 255), "[UI] ", color_white, " Loading UI\n")

AddCSLuaFile("nebula/meta.lua")
AddCSLuaFile("nebula/ui_config.lua")

AddCSLuaFile("xeninui/libs/circles.lua")
AddCSLuaFile("xeninui/libs/wyvern.lua")
AddCSLuaFile("xeninui/libs/animations.lua")
AddCSLuaFile("xeninui/elements/popup.lua")
AddCSLuaFile("xeninui/elements/query.lua")
AddCSLuaFile("xeninui/elements/avatar.lua")
AddCSLuaFile("xeninui/elements/checkbox.lua")
AddCSLuaFile("xeninui/elements/slider.lua")
AddCSLuaFile("xeninui/elements/query_single_button.lua")

if CLIENT then
    include("nebula/meta.lua")
    include("nebula/ui_config.lua")
    include("xeninui/libs/circles.lua")
    include("xeninui/libs/wyvern.lua")
    include("xeninui/libs/animations.lua")
    include("xeninui/elements/popup.lua")
    include("xeninui/elements/query.lua")
    include("xeninui/elements/avatar.lua")
    include("xeninui/elements/slider.lua")
    include("xeninui/elements/checkbox.lua")
    include("xeninui/elements/query_single_button.lua")
end

for k, v in pairs(file.Find("nebula/controls/*.lua", "LUA")) do
    AddCSLuaFile("nebula/controls/" .. v)
    if CLIENT then
        include("nebula/controls/" .. v)
    end
end

MsgC(Color(255, 50, 255), "[UI] ", color_white, " Loaded successfuly\n")
hook.Run("XeninUI.Loaded")
