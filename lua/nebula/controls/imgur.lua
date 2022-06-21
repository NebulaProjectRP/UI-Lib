file.CreateDir("nebula")
file.CreateDir("nebula/imgur")

FIT_STRETCH = 1
FIT_COVER = 2
FIT_ASPECT_W = 3
FIT_ASPECT_H = 4

local PANEL = {}
PANEL.HasImage = false
AccessorFunc(PANEL, "m_iFitMode", "FitMode", FORCE_NUMBER)
AccessorFunc(PANEL, "m_tColor", "Color")

local debug = CreateConVar("nebula_debug_imgur", "0")

function PANEL:Init()
    self:SetColor(color_white)
    self:SetFitMode(FIT_STRETCH)
    self._offsetx = TEXT_ALIGN_CENTER
    self._offsety = TEXT_ALIGN_CENTER
    self._sizew = 1
    self._sizeh = 1
end

function PANEL:SetCropSize(w, h)
    self._sizew = w
    self._sizeh = h
end

function PANEL:SetContentAllignment(x, y)
    self._offsetx = x
    self._offsety = y
    self:SetFitMode(FIT_COVER)
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
        self.Material:SetInt("$vertexalpha", 1)
        if (debug:GetBool()) then
            MsgC(Color(135, 209, 38), "[IMGUR]", color_white, " loading image material...\n")
        end
        self.HasImage = true
        self.imgurID = imgurID
        self.wide, self.height = self.Material:Width(), self.Material:Height()
        self.proportion = self.wide / self.height
        self:SetCropSize(self.wide, self.height)
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
        self.Material:SetInt("$vertexalpha", 1)
        self.wide, self.height = self.Material:Width(), self.Material:Height()
        self.proportion = self.wide / self.height
        self:SetCropSize(self.wide, self.height)
        self.HasImage = true
        self.imgurID = imgurID
    end)
end

PANEL.SetURL = PANEL.SetImage

function PANEL:Paint(w, h)
    if (!self.HasImage) then return end
    surface.SetDrawColor(self:GetColor())
    surface.SetMaterial(self.Material)
    local fitMode = self:GetFitMode()
    if (fitMode == FIT_STRETCH) then
        surface.DrawTexturedRect(0, 0, w, h)
    elseif (fitMode == FIT_COVER) then
        local sx, sy = self._sizew, self._sizeh
        surface.DrawTexturedRectRotated(
            self._offsetx == TEXT_ALIGN_LEFT and w / 2 - sx / 2
            or self._offsetx == TEXT_ALIGN_RIGHT and w - sx / 2
            or w / 2, self._offsety == TEXT_ALIGN_TOP and h / 2 - sy / 2
            or self._offsety == TEXT_ALIGN_BOTTOM and h - sy / 2
            or h / 2, sx, sy, 0
        )
    elseif (fitMode == FIT_ASPECT_W) then
        local tall = w / self.proportion
        surface.DrawTexturedRectRotated(w / 2, h / 2, w, tall, 0)
    elseif (fitMode == FIT_ASPECT_H) then
        local wide = h / self.proportion
        surface.DrawTexturedRectRotated(w / 2, h / 2, wide, h, 0)
    else
        ErrorNoHalt("[IMGUR]", " Invalid fit mode!\n")
        self:Remove()
        return
    end
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