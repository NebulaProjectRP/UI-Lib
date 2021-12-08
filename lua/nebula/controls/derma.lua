local dermaImage = Material("nebularp/ui/palette")

NebulaUI.Derma = {}

NebulaUI.Derma.Button = GWEN.CreateTextureBorder(0, 0, 32, 32, 16, 16, 16, 16, dermaImage)
NebulaUI.Derma.ButtonHover = GWEN.CreateTextureBorder(32, 0, 32, 32, 16, 16, 16, 16, dermaImage)

NebulaUI.Derma.Checkbox = GWEN.CreateTextureNormal(64, 0, 16, 16, dermaImage)
NebulaUI.Derma.CheckboxOn = GWEN.CreateTextureNormal(64 + 16, 0, 16, 16, dermaImage)

NebulaUI.Derma.TextEntry = GWEN.CreateTextureBorder(96, 0, 32, 32, 16, 16, 16, 16, dermaImage)
NebulaUI.Derma.TextEntryOn = GWEN.CreateTextureBorder(96 + 32, 0, 32, 32, 16, 16, 16, 16, dermaImage)