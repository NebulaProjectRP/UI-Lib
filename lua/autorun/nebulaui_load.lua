MsgC(Color(255, 50, 255), "[UI] ", color_white, " Loading UI\n")
AddCSLuaFile("nebula/meta.lua")
if CLIENT then
    include("nebula/meta.lua")
end

for k, v in pairs(file.Find("nebula/controls/*.lua", "LUA")) do
    AddCSLuaFile("nebula/controls/" .. v)
    if CLIENT then
        include("nebula/controls/" .. v)
    end
end
MsgC(Color(255, 50, 255), "[UI] ", color_white, " Loaded successfuly\n")