local dermaImage = Material("nebularp/ui/palette")

NebulaUI.Derma = {}

NebulaUI.Derma.Button = GWEN.CreateTextureBorder(0, 0, 32, 32, 16, 16, 16, 16, dermaImage)
NebulaUI.Derma.ButtonHover = GWEN.CreateTextureBorder(32, 0, 32, 32, 16, 16, 16, 16, dermaImage)

NebulaUI.Derma.Checkbox = GWEN.CreateTextureNormal(64, 0, 16, 16, dermaImage)
NebulaUI.Derma.CheckboxOn = GWEN.CreateTextureNormal(64 + 16, 0, 16, 16, dermaImage)

NebulaUI.Derma.TextEntry = GWEN.CreateTextureBorder(96, 0, 32, 32, 16, 16, 16, 16, dermaImage)
NebulaUI.Derma.TextEntryOn = GWEN.CreateTextureBorder(96 + 32, 0, 32, 32, 16, 16, 16, 16, dermaImage)

local invImage = Material("nebularp/ui/inventory_icons")
NebulaUI.Derma.Inventory = {}
for k = 0, 7 do
    table.insert(NebulaUI.Derma.Inventory, GWEN.CreateTextureNormal(k * 32, 0, 32, 32, invImage))
end

local f4Image = Material("nebularp/ui/navicons")
NebulaUI.Derma.F4 = {}
for k = 0, 7 do
    table.insert(NebulaUI.Derma.F4, GWEN.CreateTextureNormal(k * 32, 0, 32, 32, f4Image))
end