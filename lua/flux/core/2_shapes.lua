local Gradient = {}
Flux.Gradient = Gradient

function Gradient.Down(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientUp)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Up(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientDown)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Right(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientLeft)
    surface.DrawTexturedRect(x, y, w, h)
end

function Gradient.Left(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientRight)
    surface.DrawTexturedRect(x, y, w, h)
end

local Shapes = {}
Flux.Shapes = Shapes

Flux.Shapes.Rectangle = surface.DrawRect
Flux.Shapes.Border = surface.DrawOutlinedRect
function Flux.Shapes.Frame(x, y, w, h, BackgroundColor, OutlineColor, Blur, AlphaMultiplier)
    BackgroundColor = BackgroundColor or Flux.Colors.Background
    OutlineColor = OutlineColor or Flux.Colors.Outline
    AlphaMultiplier = AlphaMultiplier or 1
    if Blur then Flux.Blur.Section(x, y, w, h, nil, nil, 255 * AlphaMultiplier) end
    
    surface.SetDrawColor(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, AlphaMultiplier and BackgroundColor.a * AlphaMultiplier or BackgroundColor.a)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h, 180 * AlphaMultiplier)

    local OutlineAlpha = AlphaMultiplier and OutlineColor.a * AlphaMultiplier or OutlineColor.a
    surface.SetDrawColor(OutlineColor.r, OutlineColor.g, OutlineColor.b, OutlineAlpha)
    Flux.Shapes.Border(x, y, w, h, 2)
    surface.SetDrawColor(OutlineColor.r - 15, OutlineColor.g - 15, OutlineColor.b - 15, OutlineAlpha)
    Flux.Shapes.Border(x + 2, y + 2, w - 4, h - 4, 2)
    
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.Shade(x, y, w, h, alpha)
    surface.SetDrawColor(0, 0, 0, alpha or 180)
    surface.SetMaterial(Flux.Materials.GradientDown)
    surface.DrawTexturedRect(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientUp)
    surface.DrawTexturedRect(x, y, w, h/6)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.ShadedRect(x, y, w, h, followDrawAlpha)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h, followDrawAlpha and Flux.DrawColor.a or nil)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.Scrollbar(scrollbar)
    scrollbar:SetWide(10)
    function scrollbar:Paint() end
    function scrollbar.btnUp:Paint(w, h)
		surface.SetMaterial(Flux.Materials.ScrollbarUp)
        local DrawColor = self:IsHovered() and 255 or 200
		surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
		surface.DrawTexturedRect(0, 0, w, h)
	end
    function scrollbar.btnDown:Paint(w, h)
		surface.SetMaterial(Flux.Materials.ScrollbarDown)
        local DrawColor = self:IsHovered() and 255 or 200
		surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
		surface.DrawTexturedRect(0, 0, w, h)
	end
    function scrollbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 200)
        Flux.Shapes.Rectangle(1, 1, w-2, h-2)
		surface.SetDrawColor(64, 64, 64, 200)
		Shapes.ShadedRect(2, 2, w - 4, h - 4)
	end

end

-- gmod wiki lmfao
function Flux.Shapes.Circle(x, y, radius, segments)
    local cir = {}

    draw.NoTexture()
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, segments do
		local a = math.rad( ( i / segments ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end