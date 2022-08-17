-- SCOREBOARD CONFIG

NebulaUI.UserGroupTags = {
    ["superadmin"] = { "Owner", nil, "rainbow", },
    ["management"] = { "Management", Color(182, 32, 37), "flash", }, -- #b62025
    ["senioradmin"] = { "Senior Admin", Color(202, 90, 90), "flash", }, -- #ca5a5a
    ["admin"] = { "Admin", Color(255, 153, 101), }, -- #ff9965
    ["mod"] = { "Moderator", Color(154, 255, 238), },-- #9affee
    ["trialstaff"] = { "Trial Staff", Color(170, 255, 170), }, -- #aaffaa
}

NebulaUI.RankTags = {
    ["cosmic"] = { "COSMIC", Color(255, 0, 94), "flash", }, -- #ff005e
}

NebulaUI.BrandingConfig = {
    [1] = {
        Name = "Discord",
        Link = "https://discord.nebularoleplay.com",
    },
    [2] = {
        Name = "Steam",
        Link = "https://steamcommunity.com/groups/nebularoleplayofficial",
    },
    [3] = {
        Name = "Website",
        Link = "https://nebularoleplay.com",
    }
}

-- SPAWNMENU CONFIG
NebulaUI.ProhibitedCategories = {
    ["Admin"] = true,
    ["Posing"] = true,
    ["Props Tool"] = true,
    ["Falco Prop Protection"] = true,
    ["Zeros Trashman"] = true,
    ["Robotboy655"] = true,
    ["TFA SWEP Base Settings"] = true,
    ["pVault"] = true,
}

NebulaUI.ProhibitedTools = {
    ["gmod_tool rope"] = true,
    ["gmod_tool ballsocket"] = true,
    ["gmod_tool elastic"] = true,
    ["gmod_tool hydraulic"] = true,
    ["gmod_tool motor"] = true,
    ["gmod_tool mus"] = true,
    ["gmod_tool pulley"] = true,
    ["gmod_tool slider"] = true,
    ["gmod_tool winch"] = true,
    ["gmod_tool balloon"] = true,
    ["gmod_tool dynamite"] = true,
    ["gmod_tool emitter"] = true,
    ["gmod_tool hoverball"] = true,
    ["gmod_tool lamp"] = true,
    ["gmod_tool light"] = true,
    ["gmod_tool thruster"] = true,
    ["gmod_tool wheel"] = true,
    ["gmod_tool physprop"] = true,
    ["gmod_tool duplicator"] = true,
    ["gmod_tool axis"] = true,
    ["gmod_tool muscle"] = true,
    ["gmod_tool timedspawner"] = true,
    ["gmod_tool paint"] = true,
    ["gmod_tool trails"] = true,
}

NebulaUI.SpawnmenuAdmin = {
    ["superadmin"] = true,
    ["management"] = true,
}