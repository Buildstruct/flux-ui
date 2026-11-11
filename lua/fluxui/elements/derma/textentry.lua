function FluxUI.Derma.TextEntry(parent, onEnter)
    local FluxEntry = vgui.Create("DTextEntry", parent)
    FluxEntry.Color = FluxUI.Colors.Button.Background
    FluxEntry.OutlineColor = FluxUI.Colors.Button.Outline
    FluxEntry.TextColor = FluxUI.Colors.White
    FluxEntry.HighlightColor = FluxUI.Colors.Blue
    FluxEntry.Font = FluxUI.Font(14)
    FluxEntry.FontPlaceholder = FluxUI.Font(14)
    FluxEntry.PlaceholderText = "Type here"
    FluxEntry.ContentPadding = 14
    FluxEntry.CaretPos = 0
    FluxEntry.LastModified = 0
    FluxEntry.UpdateOnChange = false

    function FluxEntry:SetPlaceholderText(text) self.PlaceholderText = text return self end
    function FluxEntry:SetFont(text) self.PlaceholderText = text return self end
    function FluxEntry:SetContentPadding(value) self.ContentPadding = value return self end
    function FluxEntry:SetColor(value) self.Color = value return self end
    function FluxEntry:SetFont(value) self.Font = value return self end
    function FluxEntry:SetPlaceholderFont(value) self.FontPlaceholder = value return self end
    function FluxEntry:SetOutlineColor(value) self.OutlineColor = value return self end
    function FluxEntry:SetTextColor(value) self.TextColor = value return self end
    function FluxEntry:SetHighlightColor(value) self.HighlightColor = value return self end
    function FluxEntry:SetUpdateOnType(value) self.UpdateOnChange = value return self end

    function FluxEntry:PerformLayout()
        surface.SetFont(self.Font)
        local TextW, TextH = FluxUI.Text.GetTextSize(self:GetValue())
        if self.DoLayout or not self.Ready then
            self:SetWide(math.max(TextW + self.ContentPadding, 60))
        end
        self.TextH = TextH
        self.TextW = TextW
    end
    FluxEntry:PerformLayout()
    FluxEntry.Ready = true
    FluxEntry.GetAutoComplete = nil
    FluxEntry.GenerateExample = nil
    FluxEntry.GetCursorColor = nil
    FluxEntry.GetHighlightColor = nil

    function FluxEntry:OnKeyCodeTyped(code)
        self:OnKeyCode(code)
        if (code == KEY_ENTER and not self:IsMultiline() and self:GetEnterAllowed()) then
            self:FocusNext()
            self:OnEnter(self:GetText())
            if onEnter then onEnter(self:GetText()) end
            self.HistoryPos = 0
        end
    end

    function FluxEntry:OnTextChanged()
        self.HistoryPos = 0
        self.LastModified = SysTime()
        self.LineExploded = string.Explode("\n", self:GetText())
        if (self:GetUpdateOnType()) then
            self:UpdateConvarValue()
            self:OnValueChange(self:GetText())
        end
        self:OnChange(self:GetText())
        if self.UpdateOnChange and onEnter then onEnter(self:GetText()) end
    end

    function FluxEntry.CaretToRow(CurrentValue, Caret)
        local Row, Char = 0, 0
        for i = 1, Caret do
            Char = Char + 1
            if CurrentValue[i] ~= "\n" and CurrentValue ~= "\r" then continue end
            Row, Char = Row + 1, 0
        end
        return Row, Char
    end

    function FluxEntry:Paint(w, h)
        FluxUI.Blur.Panel(self)
        FluxUI.Color(FluxUI.Utility.ConvertRainbow(self.Color))
        FluxUI.Shapes.Rectangle(0, 0, w, h)

        local ButtonHovered = self:IsHovered()
        FluxUI.Shapes.Shade(0, 0, w, h, ButtonHovered and 240 or 165)

        surface.SetFont(self.Font)
        local CharacterSize, CharacterHeight = FluxUI.Text.Scale()
        local SelectedStart, SelectedEnd = self:GetSelectedTextRange()
        local TotalSelected = math.abs(SelectedEnd - SelectedStart)

        -- Get an accurate CaretX and CaretY
        local CaretPos = self:GetCaretPos()
        local CaretX, CaretY = 0, 0
        local CurrentValue = self:GetValue()
        for i = 1, #CurrentValue do
            if CaretPos < i then continue end
            CaretX = CaretX + 1
            if CurrentValue[i] == "\n" or CurrentValue[i] == "\r" then
                CaretY = CaretY + CharacterHeight
                CaretX = 0
            end
        end

        -- Animate the caret
        local CaretTruePos = CaretX * CharacterSize
        local Delta = CaretTruePos - self.CaretPos
        self.CaretPos = self.CaretPos + Delta * RealFrameTime() * 25

        -- Text
        if (string.Trim(CurrentValue, " ") == "") then
            surface.SetFont(self.FontPlaceholder)
            FluxUI.RGB(200, 200, 200)
            FluxUI.Text.Left(5, 5, FluxEntry.PlaceholderText)
        else
            FluxUI.Color(FluxUI.Utility.ConvertRainbow(self.TextColor))
            FluxUI.Text.Left(5, 5, self:GetValue())
        end

        -- Highlight and Caret
        if self:IsEditing() then
            if TotalSelected > 0 then
                local StartRow, StartCol = self.CaretToRow(CurrentValue, math.min(SelectedStart, SelectedEnd))
                local EndRow, EndCol = self.CaretToRow(CurrentValue, math.max(SelectedStart, SelectedEnd))
                FluxUI.Color(self.HighlightColor, 64)

                if StartRow ~= EndRow then
                    local LineLength = string.len(self.LineExploded[StartRow + 1] or "")
                    FluxUI.Shapes.Rectangle(5 + StartCol * CharacterSize, 5 + StartRow * CharacterHeight, math.max(0, LineLength - StartCol) * CharacterSize, CharacterHeight - 3)
                    for row = StartRow + 1, EndRow - 1 do
                        local LineLen = string.len(self.LineExploded[row + 1] or "")
                        FluxUI.Shapes.Rectangle(5, 5 + row * CharacterHeight, LineLen * CharacterSize, CharacterHeight - 3)
                    end
                    FluxUI.Shapes.Rectangle(5, 5 + EndRow * CharacterHeight, EndCol * CharacterSize, CharacterHeight - 3)
                else
                    FluxUI.Shapes.Rectangle(5 + StartCol * CharacterSize, 5 + StartRow * CharacterHeight, (EndCol - StartCol) * CharacterSize, CharacterHeight - 3)
                end
            end

            -- Caret
            local CursorBlink = math.abs(math.sin((0.5 + SysTime() - self.LastModified) * 3))
            local DeltaABS = math.abs(Delta)
            FluxUI.RGB(255, 255, 255, CursorBlink * 255)
            FluxUI.Shapes.Rectangle(5 + self.CaretPos - (DeltaABS / 2), 5 + CaretY, 1 + DeltaABS, CharacterHeight - 3)
        end

        -- Border bc we dont want text drawing over
        FluxUI.Color(FluxUI.Utility.ConvertRainbow(self.OutlineColor))
        FluxUI.Shapes.Border(0, 0, w, h, 3)
    end

    table.insert(FluxUI.ActiveElements, FluxEntry)
    return FluxEntry
end