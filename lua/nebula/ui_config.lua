-- SCOREBOARD CONFIG

NebulaUI.UserGroupTags = {
  ["superadmin"] = "Owner",
  ["management"] = "Management",
  ["senioradmin"] = "Senior Admin",
  ["admin"] = "Admin",
  ["mod"] = "Moderator",
  ["trialstaff"] = "Trial Staff"
}

NebulaUI.UserGroupColorGroups = {
  ["superadmin"] = "rainbow",
  ["management"] = { "flash", "2", Color(182, 32, 37) }, -- #b62025
  ["senioradmin"] = { "flash", "2", Color(202, 90, 90) }, -- #ca5a5a
  ["admin"] = Color(255, 153, 101), -- #ff9965
  ["mod"] = Color(154, 255, 238), -- #9affee
  ["trialstaff"] = Color(170, 255, 170) -- #aaffaa
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