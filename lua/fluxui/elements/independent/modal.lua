function FluxUI.Elements.Modal(Title, Content)
    local Modal = vgui.Create("DFrame")
    Modal:SetTitle("")
    Modal:ShowCloseButton(false)
    Modal:SetSize(FluxUI.ScrW, FluxUI.ScrH)
    Modal:Center()
    Modal:MakePopup()
    Modal:SetDraggable(false)
    Modal.Title = istable(Title) and Title or {Title}
    Modal.Content = istable(Content) and Content or {Content}
    function Modal:SetTitle(...) self.Title = {...} self:InvalidateLayout() return self end
    function Modal:SetContent(...) self.Content = {...} self:InvalidateLayout() return self end
    function Modal:Paint(w, h)
        FluxUI.Blur.Panel(self)
        FluxUI.RGB(0, 0, 0, 200)
        FluxUI.Shapes.Rectangle(0, 0, w, h)
    end
    function Modal:GetTargetSize()
        surface.SetFont(FluxUI.Font(20, true))
        local TitleW, TitleH = FluxUI.Text.GetTextSize(unpack(Modal.Title))
        surface.SetFont(FluxUI.Font(20))
        local ContentW, ContentH = FluxUI.Text.GetTextSize(unpack(Modal.Content))
        return math.max(128, ContentW + 24, TitleW + 24 + 32), math.max(80, ContentH + TitleH + 50)
    end
    function Modal:Think()
        if not IsValid(self.Container) or not IsValid(self.Close) then self:Remove() return end
        self.Container:SetPos(self.Container:GetCenter())
        self.Close:SetPos(self.Container:GetWide() - self.Close:GetWide() - 8, 8)
    end
    -- Container ( actual message )
    local Container = vgui.Create("DPanel", Modal)
    Container:SetSize(Modal:GetTargetSize())
    Container:Center()

    Modal.Container = Container
    function Container:Paint(w, h)
        FluxUI.Blur.Panel(self)

        FluxUI.Shapes.Frame(0, 0, w, h, FluxUI.Colors.Frame.Background, FluxUI.Colors.Black, false)
        surface.SetFont(FluxUI.Font(20, true))
        FluxUI.RGB(255, 255, 255, 255)
        FluxUI.Text.Outline(FluxUI.Text.Left, 12, 10, 1, unpack(Modal.Title))
        surface.SetFont(FluxUI.Font(20))
        FluxUI.RGB(255, 255, 255, 255)
        FluxUI.Text.Outline(FluxUI.Text.Left, 12, 30, 1, unpack(Modal.Content))
    end
    function Container:GetCenter(w, h)
        return math.max(Modal:GetWide() / 2 - (w or Container:GetWide()) / 2, 0),
        math.max(Modal:GetTall() / 2 - (h or Container:GetTall()) / 2, 100)
    end

    -- Button list
    local ButtonList = vgui.Create("DPanel", Container)
    Container.Buttons = ButtonList
    ButtonList:Dock(BOTTOM)
    ButtonList:SetTall(26)
    ButtonList:DockMargin(8, 8, 8, 8)
    ButtonList.Paint = nil
    function Modal:AddButton(content, func, icon, col)
        local Button = FluxUI.Derma.Button(ButtonList, func, content):SetTextColor(col or FluxUI.Colors.White)
        if icon then Button:SetIcon(icon) end
        Button:Dock(RIGHT)
        Button:SetFont(FluxUI.Font(20))
        Button:DockMargin(4, 0, 0, 0)
        Button:SetAutoLayout(true)
    end

    Container:SetSize(0, 0)
    local W, H = Modal:GetTargetSize()
    Container:SizeTo(W, H, 0.5, 0, 0.3)
    Modal:SetAlpha(0)
    Modal:AlphaTo(255, 0.3, 0)
    Container:SetAlpha(0)
    Container:AlphaTo(255, 0.4, 0)

    -- Close button
    local Close = FluxUI.Elements.CloseButton(Container, Modal)
    Modal.Close = Close

    table.insert(FluxUI.ActiveElements, Modal)
    return Modal, Container
end