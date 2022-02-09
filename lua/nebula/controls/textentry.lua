local TEXT = {}
AccessorFunc(TEXT, "m_bBackground", "TextColor")
function TEXT:Init()
    self:SetTall(36)
    self:SetTextColor(Color(235, 235, 235))
    self.textentry = vgui.Create("DTextEntry", self)
    self.textentry:Dock(FILL)
    self.textentry:SetFont(NebulaUI:Font(18))
    self.textentry:DockMargin(0, 0, 0, 0)
    self.textentry:SetContentAlignment(4)
    self.textentry:SetUpdateOnType(true)

    self.textentry.OnEnter = function(s, val)
        self:OnEnter(val)
    end
    self.textentry.OnValueChange = function(s, txt)
        self:OnValueChange(txt)
    end

    self.placeholder = ""

    self.textentry.Paint = function(s, w, h)
        if (s:GetText() ~= "") then
            s:DrawTextEntryText(self:GetTextColor() or Color(200, 200, 200), Color(200, 200, 200), color_white)
        else
            draw.SimpleText(self.placeholder or "", NebulaUI:Font(18), 2, h / 2, Color(255, 255, 255, 50), 0, 1)
        end
    end

end

function TEXT:OnEnter()
end

function TEXT:SetNumeric(b)
    self.textentry:SetNumeric(b)
end

function TEXT:OnValueChange(txt)
end

function TEXT:SetUpdateOnType(b)
    self.textentry:SetUpdateOnType(b)
end

function TEXT:SetPlaceholder(txt)
    self.placeholder = txt
end

TEXT.SetPlaceholderText = TEXT.SetPlaceholder

function TEXT:SetMultiline(b)
    self.textentry:SetMultiline(b)
end

function TEXT:SetText(txt)
    self.textentry:SetText(txt)
end

function TEXT:GetText()
    return self.textentry:GetText()
end

function TEXT:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, self.textentry:IsEditing() and 25 or 5))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))
end

vgui.Register("nebula.textentry", TEXT)
