local Fonts = {Registered = {}}
FluxUI.Fonts = Fonts

local FontBold = {Windows = "Lexend Bold", Linux = "lexend-bold.ttf"}
local FontRegular = {Windows = "Lexend", Linux = "lexend-regular.ttf"}

function Fonts.InternalName(size, bold, italicized) return "FluxUI_" .. tostring(size) .. (bold and ":bold" or "") .. (italicized and ":ital" or "") end
function Fonts.Name(...)
    local FontName = Fonts.InternalName(...)
    return Fonts.Registered[FontName] and FontName or Fonts.Create(...)
end
FluxUI.Font = Fonts.Name
function Fonts.Create(size, bold, italicized)
    local FontName = Fonts.InternalName(size, bold, italicized)
    Fonts.Registered[FontName] = true
    surface.CreateFont(FontName, {
        font = FluxUI.IsLinux and (bold and FontBold.Linux or FontRegular.Linux) or (bold and FontBold.Windows or FontRegular.Windows),
        size = size,
        bold = bold and 1500 or 600,
        antialias = true,
        italic = italic or false
    })
    return FontName
end

-- note: lookupid 1 is default and thats just like the basic name, 4 is what you want for "full names" e.g. Lexend Bold, Lexend Regular, 1 would just return family name like Lexend
function Fonts.ReadFont(path, pathType, lookupid)
    local fontFile = file.Open(path, "rb", pathType or "GAME")
    if not fontFile then return false, "No file exists" end
    fontFile:Seek(4)
    local tbls = bit.rshift(bit.bswap(fontFile:ReadUShort()), 16)
    fontFile:Seek(12)

    local nameoffset
    for _ = 1, tbls do
        local tag = fontFile:Read(4)
        fontFile:ReadULong()
        local offset = bit.rshift(bit.bswap(fontFile:ReadULong()), 32)
        fontFile:ReadULong()
        if tag ~= "name" then continue end
        nameoffset = offset
    end
    if not nameoffset then return false, "Couldn't find the font name" end
    fontFile:Seek(nameoffset)
    fontFile:ReadUShort()
    local count, offset = bit.rshift(bit.bswap(fontFile:ReadUShort()), 16), bit.rshift(bit.bswap(fontFile:ReadUShort()), 16)
    local ret
    for _ = 1, count do
        local pid = bit.rshift(bit.bswap(fontFile:ReadUShort()), 16)
        fontFile:ReadUShort()
        fontFile:ReadUShort()
        local id, len, rOffset = bit.rshift(bit.bswap(fontFile:ReadUShort()), 16), bit.rshift(bit.bswap(fontFile:ReadUShort()), 16), bit.rshift(bit.bswap(fontFile:ReadUShort()), 16)
        if id ~= (lookupid or 1) then continue end
        ret = {plat = pid, len = len, offset = rOffset}
        break
    end
    if not ret then return false, "Not found by lookupid " .. tostring(lookupid) .. " (no name id located)" end
    fontFile:Seek(nameoffset + offset + ret.offset)
    local raw = fontFile:Read(ret.len)
    fontFile:Close()
    if ret.plat == 3 or ret.plat == 0 then local nm = string.gsub(raw, "%z", "") return nm end -- stupid and dumb. iirc this breaks on certain fonts?
    return raw
end

function Fonts.FindByName(name, fontType, exact, lookupid)
    local found
    local fonts, _ = file.Find("resource/fonts/*.ttf", "GAME")
    for k, v in pairs(fonts) do
        local fontName = Fonts.ReadFont("resource/fonts/" .. v, nil, lookupid)
        if (exact and fontName == name) or (not exact and string.lower(fontName) == string.lower(name)) then
            if fontType and not string.find(string.lower(v), string.lower(fontType)) then continue end
            found = {name = fontName, fileName = v, path = "resource/fonts/" .. v}
            break
        end
    end
    return found
end

function Fonts.GetPlatformFriendlyFont(byName, byFile, fontType, exact)
    if byName then
        local found = Fonts.FindByName(byName, fontType, exact, 4)
        return found and (jit.os == "Linux" and found.fileName or found.name)
    elseif byFile then
        if jit.os == "Linux" then return byFile end
        return Fonts.ReadFont("resource/fonts/" .. byFile, 4)
    end
end