local Translation = {}
FluxUI.Translation = Translation

function Translation.Scale(scale, w, h, x, y)
    if not scale then
        cam.PopModelMatrix()
		render.PopFilterMag()
		return render.PopFilterMin()
    end

    local state = surface.GetPanelPaintState()
    x = x or state.translate_x
    y = y or state.translate_y
    w = w or state.scissor_right - state.scissor_left or FluxUI.ScrW
    h = h or state.scissor_bottom - state.scissor_top or FluxUI.ScrH

    local matrix
    local memoryID = "scaleMatrix:" .. scale .. w .. h .. x .. y
    if not FluxUI.Memory.Exists(memoryID) then
        local center = Vector(x + (w / 2), y + (h / 2), 0)
        matrix = FluxUI.Memory.Push(memoryID, Matrix())[1]
        matrix:Translate(center)
        matrix:SetScale(Vector(scale, scale, scale))
        matrix:Translate(-center)
    else 
        matrix = FluxUI.Memory.Pull(memoryID)[1]
    end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	cam.PushModelMatrix(matrix, true)
end

function Translation.Rotation(angle, w, h, x, y)
    if not angle then
        cam.PopModelMatrix()
		render.PopFilterMag()
		return render.PopFilterMin()
    end

    local state = surface.GetPanelPaintState()
    x = x or state.translate_x
    y = y or state.translate_y
    w = w or state.scissor_right - state.scissor_left or FluxUI.ScrW
    h = h or state.scissor_bottom - state.scissor_top or FluxUI.ScrH

    local matrix
    local memoryID = "rotationMatrix:" .. angle .. w .. h .. x .. y
    if not FluxUI.Memory.Exists(memoryID) then
        local center = Vector(x + (w / 2), y + (h / 2), 0)
        matrix = FluxUI.Memory.Push(memoryID, Matrix())[1]
        matrix:Translate(center)
        matrix:SetAngles(Angle(0, angle, 0))
        matrix:Translate(-center)
    else 
        matrix = FluxUI.Memory.Pull(memoryID)[1]
    end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	cam.PushModelMatrix(matrix, true)
end