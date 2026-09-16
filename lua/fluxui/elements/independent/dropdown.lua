local Elements = Flux.Elements
local SubmenuMousePadding = 6

function Elements.DropdownPanel(button, callback, belowButton)
    local Dropdown = vgui.Create("DPanel")
    Dropdown.DistanceToClose = 175
    Dropdown.Paint = nil
    Dropdown.Flux = "Dropdown"
    Dropdown.TargetWidth = 15
    Dropdown.OpenX = gui.MouseX()
    Dropdown.OpenY = gui.MouseY()
    local ExpectButton = button ~= nil
    function Dropdown:Think()
        if not IsValid(Dropdown.Container) or (button and not IsValid(button)) then Dropdown:Remove() return end
        self.Lerp = math.Approach(self.Lerp or 0, self.Opened and 1 or 0, RealFrameTime() * 1.75)
        self.Container:SetY(-self:GetTall() * math.ease.InExpo(1-self.Lerp))
        self.Container:SetSize(self:GetSize())

        -- Button no longer exists
        if ExpectButton and (not IsValid(button) or not button:IsVisible()) then self:Remove() return end

        -- Move too far away
        local StartX, StartY = self:LocalToScreen(0, 0)
        local EndX, EndY = self:LocalToScreen(self:GetWide(), self:GetTall())
        local MouseX, MouseY = gui.MouseX(), gui.MouseY()
        local MouseOutOfBounds = (MouseX < StartX or MouseX > EndX or MouseY < StartY or MouseY > EndY)
        if self.FluxSubmenuKeepAlive and IsValid(self.FluxSubmenuKeepAlive) and self.FluxSubmenuKeepAlive.Opened then return end
        if (input.IsMouseDown(MOUSE_FIRST) or input.IsMouseDown(MOUSE_RIGHT)) and MouseOutOfBounds then
            self:Remove()
        end
    end
    function Dropdown:GetTargetSize()
        local Width = self.TargetWidth
        local Height = 10

        for k, v in pairs(self.Container:GetChildren()) do
            local TextWidth = v.TextW or 0
            Width = math.max(TextWidth + 30 + (v.Icon and (v:GetTall() - 12 + 8) or 0) + (v.IsSubmenu and 8 or 0), v:GetWide(), Width)
            Height = Height + v:GetTall() + 2
        end

        return math.Clamp(Width, 125, 375), math.max(Height, 15)
    end
    function Dropdown:SetWide(width)
        self.TargetWidth = width
        self:SetSize(self:GetTargetSize())
        return self
    end
    function Dropdown:SetFont(font) self.Font = font return self end
    function Dropdown:PerformLayout() self:SetSize(self:GetTargetSize()) self:PerformPosition() end
    function Dropdown:Open()
        self.Opened = true
        Dropdown:MakePopup()
        Dropdown:SetKeyboardInputEnabled(false)
    end
    function Dropdown:Close() self.Opened = false end

    -- Container
    local Container = vgui.Create("DPanel", Dropdown)
    Dropdown.Container = Container
    Container:DockPadding(6, 6, 6, 6)
    Container:SetSize(Dropdown:GetSize())
    function Container:Paint(w, h)
        local ZeroY = h * math.ease.InExpo(1-Dropdown.Lerp)
        Flux.Blur.Panel(self)
        Flux.Color(Flux.Colors.DropdownBackground)
        Flux.Shapes.ShadedRect(0, ZeroY, w, h)
    end
    function Container:PaintOver(w, h)
        local ZeroY = h * math.ease.InExpo(1-Dropdown.Lerp)
        Flux.Color(Flux.Colors.DropdownOutline)
        Flux.Shapes.Border(0, ZeroY, w, h, 2)
        Flux.Color(Flux.Colors.DropdownOutline, 200)
        Flux.Shapes.Border(2, 2 + ZeroY, w-4, h-4, 2)
    end
    function Container:PerformLayout() Dropdown:SetSize(Dropdown:GetTargetSize()) end
    function Container:OnChildAdded(child)
        if not IsValid(child) then return end
        Dropdown:Add(child)
    end
    function Dropdown:Add(child)
        if not IsValid(child) then return end
        child:SetParent(self.Container)
        child:SetWide(self:GetWide())
        child:Dock(TOP)
        child:DockMargin(0,0,0,2)

        -- because fuck it!
        timer.Simple(0, function()
            if not IsValid(child) or child:GetParent() ~= self.Container then return end
            if self.Font and child.SetFont then child:SetFont(self.Font) end
            if child.DoLayout then child.DoLayout = false end
            child:SetWide(self:GetWide())
            if child.Flux and child.Flux == "Button" then child:SetTall(child.TextH + 12) end
        end)
    end
    function Dropdown:OnChildAdded(child)
        if not IsValid(child) then return end
        self:Add(child)
    end

    -- Elements
    function Container:AddSpacer()
        local Frame = vgui.Create("DPanel", Container)
        Frame:SetTall(6)
        Frame:Dock(TOP)
        function Frame:Paint(w, h)
            Flux.Color(Flux.Colors.DropdownOutline)
            Flux.Shapes.ShadedRect(0,2,w,h-4)
        end
    end
    Dropdown.AddSpacer = Container.AddSpacer

    -- Set Dropdown Position
    function Dropdown:PerformPosition()
        -- Button
        if belowButton and IsValid(button) then
            local ButtonX, ButtonY = button:LocalToScreen(0, button:GetTall())
            local TargetX, TargetY = ButtonX, ButtonY
            TargetX = ((TargetX + self:GetWide()) > Flux.ScrW and (Flux.ScrW - self:GetWide())) or (TargetX < 0 and 0) or TargetX
            TargetY = ((TargetY + self:GetTall()) > Flux.ScrH and (Flux.ScrH - self:GetTall())) or (TargetY < 0 and 0) or TargetY
            return Dropdown:SetPos(TargetX, TargetY)
        end

        -- Normal (mouse)
        local TargetX, TargetY = self.OpenX, self.OpenY
        TargetX = ((TargetX + self:GetWide()) > Flux.ScrW and (Flux.ScrW - self:GetWide())) or (TargetX < 0 and 0) or TargetX
        TargetY = ((TargetY + self:GetTall()) > Flux.ScrH and (Flux.ScrH - self:GetTall())) or (TargetY < 0 and 0) or TargetY
        return Dropdown:SetPos(TargetX, TargetY)
    end

    -- Boundries
    local targetW, targetH = Dropdown:GetTargetSize()
    Dropdown:SetSize(targetW, targetH)
    Dropdown:PerformPosition()
    if callback and isfunction(callback) then callback(Dropdown, Container) end
    table.insert(Flux.ActiveElements, Dropdown)
    return Dropdown
end

function Elements.DropdownSubMenu(parent, callback, ...)
    local SubmenuButton = Flux.Derma.Button(parent, callback, ...)
    function SubmenuButton:Paint(w, h)
        Flux.Blur.Panel(self)
        Flux.Color(Flux.Utility.ConvertRainbow(self.Color))
        Flux.Shapes.Rectangle(0, 0, w, h)
        Flux.Color(Flux.Utility.ConvertRainbow(self.OutlineColor))
        Flux.Shapes.Border(0, 0, w, h, 2)

        local ButtonHovered = self:IsHovered()
        Flux.Shapes.Shade(0, 0, w, h, ButtonHovered and 240 or 165)

        -- SubMenu
        Flux.RGB(Flux.Utility.ConvertRainbow(self.OutlineColor), 200)
        Flux.Gradient.Left(w / 2, 0, w / 2, h)

        Flux.Color(Flux.Utility.ConvertRainbow(self.TextColor), ButtonHovered and 255 or 190)
        surface.SetFont(self.Font)
        local _, textHeight = Flux.Text.Center((w / 2) + (self.Icon and (h-12) / 2 + 3 or 0) - 2, (h / 2) - self.TextH / 2, unpack(self.Content))
        if self.Icon then
            surface.SetDrawColor(255, 255, 255, ButtonHovered and 245 or 190)
            surface.SetMaterial(self.Icon)

            local OnlyIcon = self.Content and self.Content[1] == "" and not self.Content[2]
            if OnlyIcon then
                surface.DrawTexturedRect(w / 2 - (h-12) / 2, h / 2 - (h-12) / 2 - 2, h - 12, h - 12)
            else
                surface.DrawTexturedRect(w / 2 - self.TextW / 2 - (h-12) / 2 - 3 - 2, h / 2 - (h-12) / 2, h - 12, h - 12)
            end
        end

        -- Submenu icon
        Flux.RGB(255, 255, 255)
        surface.SetFont(Flux.Font(11, true))
        Flux.Text.Outline(Flux.Text.Right, w - 5, h / 2 - textHeight / 2 + 1, 1, ">")
    end
    SubmenuButton.IsSubmenu = true
    SubmenuButton:SetCursor("arrow")
    SubmenuButton.FluxSubmenuFirstParent = parent and parent.FluxSubmenuFirstParent or parent

    function SubmenuButton:SetFont(value)
        self.Font = value
        self.Dropdown.Font = value
        return self
    end
    function SubmenuButton:Think(x, y)
        if not IsValid(parent) then return self:Remove() end
        if not IsValid(self.Dropdown) then return self:Remove() end
        --if self.Dropdown.Opened then self.Dropdown:SetPos(self:LocalToScreen(self:GetWide() + 4, 0)) end
        if not self:IsHovered() then
            return
        end
        parent.FluxSubmenuKeepAlive = self.Dropdown

        local X, Y = self:LocalToScreen(self:GetWide() + 4, 0)
        local W, H = self.Dropdown:GetTargetSize()
        self.Dropdown:SetPos(math.Clamp(X, 0, Flux.ScrW - W), math.Clamp(Y, 0, Flux.ScrH - H))
        self.Dropdown:Open()
    end
    function SubmenuButton:OnRemove()
        if IsValid(self) then self:Remove() end
        if IsValid(self.Dropdown) then self.Dropdown:Remove() end
        if IsValid(parent) and parent.Flux == "Dropdown" then parent:Remove() end
        if IsValid(self.FluxSubmenuFirstParent) then self.FluxSubmenuFirstParent:Remove() end
    end
    function SubmenuButton:Close()
        if IsValid(self) then self:Remove() end
        if IsValid(self.Dropdown) then self.Dropdown:Remove() end
        if IsValid(self.FluxSubmenuFirstParent) then self.FluxSubmenuFirstParent:Remove() end
    end
    function SubmenuButton:OnChildAdded(child)
        if not IsValid(child) then return end
        if not IsValid(self.Dropdown) then return end
        self.Dropdown:Add(child)
    end

    -- Submenu Dropdown
    local Dropdown = Elements.DropdownPanel(SubmenuButton, function() end, nil)
    SubmenuButton.Dropdown = Dropdown
    function Dropdown:PerformPosition() end
    function Dropdown:Think()
        if not IsValid(Dropdown.Container) or (button and (not IsValid(button) or not IsValid(button:GetParent()))) then Dropdown:Remove() return end
        self.Lerp = math.Approach(self.Lerp or 0, self.Opened and 1 or 0, RealFrameTime() * 3)
        self.Container:SetY(-self:GetTall() * math.ease.InExpo(1-self.Lerp))
        self.Container:SetSize(self:GetSize())

        -- Button no longer exists
        if ExpectButton and (not IsValid(button) or not button:IsVisible()) then self:Remove() return end
        if ExpectButton and (not IsValid(button:GetParent())) then self:Remove() return end

        -- Move too far away
        local StartX, StartY = self:LocalToScreen(0, 0)
        local EndX, EndY = self:LocalToScreen(self:GetWide(), self:GetTall())
        local MouseX, MouseY = gui.MouseX(), gui.MouseY()

        if SubmenuButton.FluxSubmenuKeepAlive and IsValid(SubmenuButton.FluxSubmenuKeepAlive) and SubmenuButton.FluxSubmenuKeepAlive.Opened then
            return
        end
        if not SubmenuButton:IsHovered() and (MouseX < StartX - SubmenuMousePadding or MouseX > EndX + SubmenuMousePadding or MouseY < StartY - SubmenuMousePadding or MouseY > EndY + SubmenuMousePadding) then
            self.Opened = false
        end
    end

    SubmenuButton.AddSpacer = Dropdown.AddSpacer
    return SubmenuButton
end
function Elements.DropdownMenu(Button)
    return Elements.DropdownPanel(Button, callback, Button ~= nil)
end