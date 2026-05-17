local Elements = Flux.Elements

function Elements.Modal(Title, Content)
    -- Modal ( black part )
    local Modal = vgui.Create("DFrame")
    Modal:SetTitle("")
    Modal:ShowCloseButton(false)
    Modal:SetSize(Flux.ScrW, Flux.ScrH)
    Modal:Center()
    Modal:MakePopup()
    Modal:SetDraggable(false)
    Modal.Title = istable(Title) and Title or {Title}
    Modal.Content = istable(Content) and Content or {Content}
    function Modal:SetTitle(...) self.Title = {...} self:InvalidateLayout() return self end
    function Modal:SetContent(...) self.Content = {...} self:InvalidateLayout() return self end
    function Modal:Paint(w, h)
        Flux.Blur.Panel(self)
        Flux.RGB(0, 0, 0, 200)
        Flux.Shapes.Rectangle(0, 0, w, h)
    end
    function Modal:GetTargetSize()
        surface.SetFont(Flux.Font(18, true))
        local TitleW, TitleH = Flux.Text.GetTextSize(unpack(Modal.Title))
        surface.SetFont(Flux.Font(16))
        local ContentW, ContentH = Flux.Text.GetTextSize(unpack(Modal.Content))
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
        -- Blur
        Flux.Blur.Panel(self)

        -- Draw the frame ontop, so the border covers the logo
        Flux.Shapes.Frame(0, 0, w, h, Flux.Colors.Background, Flux.Colors.Black, false)
        surface.SetFont(Flux.Font(18, true))
        Flux.RGB(255, 255, 255, 255)
        Flux.Text.Outline(Flux.Text.Left, 12, 10, 1, unpack(Modal.Title))
        surface.SetFont(Flux.Font(16))
        Flux.RGB(255, 255, 255, 255)
        Flux.Text.Outline(Flux.Text.Left, 12, 30, 1, unpack(Modal.Content))
    end
    function Container:GetCenter(w, h)
        return math.max(Modal:GetWide()/2 - (w or Container:GetWide())/2, 0),
        math.max(Modal:GetTall()/2 - (h or Container:GetTall())/2, 100)
    end

    -- Button list
    local ButtonList = vgui.Create("DPanel", Container)
    Container.Buttons = ButtonList
    ButtonList:Dock(BOTTOM)
    ButtonList:SetTall(26)
    ButtonList:DockMargin(8, 8, 8, 8)
    ButtonList.Paint = nil
    function Modal:AddButton(content, func, icon, col)
        local Button = Flux.Derma.Button(ButtonList, func, content):SetTextColor(col or Flux.Colors.White)
        if icon then Button:SetIcon(icon) end
        Button:Dock(RIGHT)
        Button:SetFont(Flux.Font(16))
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
    local Close = Flux.Elements.CloseButton(Container, Modal)
    Modal.Close = Close
    return Modal, Container
end