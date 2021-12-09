file.CreateDir("nebula")
file.CreateDir("nebula/imgur")

local PANEL = {}
PANEL.HasImage = false

function PANEL:Init()
end

function PANEL:SetImage(url)
    local imgurID = ""

    if (string.StartWith(url, "https")) then
        for k = #url, 1, -1 do
            if (url[k] == "/") then
                imgurID = string.sub(url, k + 1)
                break
            end
        end

        for k = 1, #imgurID do
            if (imgurID[k] == ".") then
                imgurID = string.sub(imgurID, 1, k - 1)
                break
            end
        end
    else
        imgurID = url
    end

    if (file.Exists("nebula/imgur/" .. imgurID .. ".png", "DATA")) then
        self.Material = Material("../data/nebula/imgur/" .. imgurID .. ".png")
        self.HasImage = true
        return
    end

    http.Fetch("https://i.imgur.com/" .. imgurID .. ".png", function(body)
        file.Write("nebula/imgur/" .. imgurID .. ".png", body)
        self.Material = Material("../data/nebula/imgur/" .. imgurID .. ".png")
        self.HasImage = true
    end)
end

function PANEL:Paint(w, h)
    if (!self.HasImage) then return end
    surface.SetDrawColor(self:GetColor())
    surface.SetMaterial(self.Material)
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("NebulaUI.Imgur", PANEL, "DPanel")

function NebulaUI:Imgur(url)
    local imgur = vgui.Create("NebulaUI.Imgur")
    imgur:SetImage(url)
    return imgur
end

concommand.Add("nebula_clear_imgur", function()
    local files, dirs = file.Find("nebula/imgur/*", "DATA")

    for k, v in pairs(files) do
        file.Delete("nebula/imgur/" .. v)
    end
end)