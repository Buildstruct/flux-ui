local Elements = Flux.Elements

function Elements.DropdownPanel(button, callback, belowButton)
    local Dropdown = vgui.Create("DPanel")
    Dropdown.DistanceToClose = 175
    Dropdown.Paint = nil
    Dropdown.Flux = true
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
        if (input.IsMouseDown(MOUSE_FIRST) or input.IsMouseDown(MOUSE_RIGHT)) and (MouseX < StartX or MouseX > EndX or MouseY < StartY or MouseY > EndY) then
            self:Remove()
        end
    end
    function Dropdown:GetTargetSize()
        local Width = 15
        local Height = 10

        for k, v in pairs(self.Container:GetChildren()) do
            local TextWidth = v.TextW or 0
            Width = math.max(TextWidth + 30 + (v.Icon and (v:GetTall()-12 + 8) or 0), v:GetWide(), Width)
            Height = Height + v:GetTall() + 2
        end

        return math.Clamp(Width, 125, 250), math.max(Height, 15)
    end 
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
        Flux.Color(Flux.Colors.DropdownOutline)
        Flux.Shapes.Border(0, ZeroY, w, h, 2)
        Flux.Color(Flux.Colors.DropdownOutline, 200)
        Flux.Shapes.Border(2, 2 + ZeroY, w-4, h-4, 2)
    end
    function Container:PerformLayout() Dropdown:SetSize(Dropdown:GetTargetSize()) end
    function Container:OnChildAdded(child)
        if not IsValid(child) then return end 
        if child.DoLayout then child.DoLayout = false end
        child:SetWide(self:GetWide())
        child:Dock(TOP)
        child:DockMargin(0,0,0,2)
    end
    function Dropdown:Add(child)
        if not IsValid(child) then return end 
        if child.DoLayout then child.DoLayout = false end
        child:SetParent(self.Container)
        child:SetWide(self:GetWide())
        child:Dock(TOP)
        child:DockMargin(0,0,0,2)
    end
    function Dropdown:OnChildAdded(child)
        if not IsValid(child) then return end 
        self:Add(child)
    end

    -- Boundries
    Dropdown:SetSize(Dropdown:GetTargetSize())
    if belowButton and IsValid(button) then
        local ButtonX, ButtonY = button:LocalToScreen(0, button:GetTall())
        Dropdown:SetPos(math.Clamp(ButtonX, 0, ScrW() - Dropdown:GetWide()), math.Clamp(ButtonY, 0, ScrH() - Dropdown:GetTall()))
    else
        Dropdown:SetPos(math.Clamp(gui.MouseX(), 0, ScrW() - Dropdown:GetWide()), math.Clamp(gui.MouseY(), 0, ScrH() - Dropdown:GetTall()))
    end

    if callback and isfunction(callback) then callback(Dropdown, Container) end
    return Dropdown
end

function Elements.DropdownMenu(Button)
    return Elements.DropdownPanel(Button, callback, Button ~= nil)
end