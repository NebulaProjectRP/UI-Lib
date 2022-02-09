file.CreateDir("nebula")
file.CreateDir("nebula/imgur")

local PANEL = {}
PANEL.HasImage = false

local debug = CreateConVar("nebula_debug_imgur", "0")

function PANEL:Init()
end

function PANEL:SetImage(url)
    local imgurID = ""

    if (debug:GetBool()) then
        MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " loading image from url ", Color(200, 200, 200), url, "\n")
    end
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

    if (debug:GetBool() and self.imgurID == imgurID) then
        MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " image ID it's already applied\n")
        return
    end

    MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " image ID is ", Color(200, 200, 200), imgurID, "\n")

    if (file.Exists("nebula/imgur/" .. imgurID .. ".png", "DATA")) then
        self.Material = Material("../data/nebula/imgur/" .. imgurID .. ".png")
        if (debug:GetBool()) then
            MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " loading image material...\n")
        end
        self.HasImage = true
        self.imgurID = imgurID
        return
    end

    if (debug:GetBool()) then
        MsgC(Color(135, 209, 38), "[IMGUR] ", color_white, " downloading image...\n")
    end
    
    http.Fetch("https://i.imgur.com/" .. imgurID .. ".png", function(body)
        file.Write("nebula/imgur/" .. imgurID .. ".png", body)
        if (debug:GetBool()) then
            MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " Image successully downloaded!\n")
        end
        self.Material = Material("../data/nebula/imgur/" .. imgurID .. ".png")
        self.HasImage = true
        self.imgurID = imgurID
    end)
end

PANEL.SetURL = PANEL.SetImage

function PANEL:Paint(w, h)
    if (!self.HasImage) then return end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(self.Material)
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("nebula.imgur", PANEL, "DPanel")

function NebulaUI:Imgur(url)
    local imgur = vgui.Create("nebula.imgur")
    imgur:SetImage(url)
    return imgur
end

concommand.Add("nebula_clear_imgur", function()
    local files, dirs = file.Find("nebula/imgur/*", "DATA")

    for k, v in pairs(files) do
        file.Delete("nebula/imgur/" .. v)
    end
end)