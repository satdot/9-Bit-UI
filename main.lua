--[[
    9-bit UI
    Visual: green pixel gradient (PressStart2P, UIGradient, UIStroke)
    API: millionware-style (Section:Checkbox / Slider / Combo / Keybind / ColorPicker / ...)
    Repo: https://github.com/satdot/9-Bit-UI
]]

local Icons = {
    crosshairs = "rbxassetid://96677288280405", ghost = "rbxassetid://95400397758754", mouse = "rbxassetid://74350468513068",
    user = "rbxassetid://97066657594742", pallet = "rbxassetid://83365140694071", hammer = "rbxassetid://118512898552101",
    code = "rbxassetid://100793810819046", save = "rbxassetid://136566823798983", feather = "rbxassetid://130188814728078",
    crown = "rbxassetid://73317911385704", dagger = "rbxassetid://133081986539088", baby = "rbxassetid://127135446273067",
    ad = "rbxassetid://134916447199398", axe_battle = "rbxassetid://91285868461583",
}

local cloneref = (typeof(cloneref) == "function" and cloneref) or function(o) return o end
local HttpService      = cloneref(game:GetService("HttpService"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players          = cloneref(game:GetService("Players"))
local Lighting         = cloneref(game:GetService("Lighting"))
local RunService       = cloneref(game:GetService("RunService"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local LP               = Players.LocalPlayer

local PIXEL_FONT = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local LOGO_ICON  = "rbxassetid://121387754739937"

local Library = {}
Library.__index = Library
Library.Flags = {}
Library.Registry = {}
Library.Connections = {}
Library.ThemeListeners = {}
Library.Icons = Icons
Library.ConfigItems = {}
Library.ConfigIgnore = {}
Library.ToggleKey = Enum.KeyCode.J

Library.Themes = {
    ["9-bit"] = {
        BG = Color3.fromRGB(20, 24, 20), Panel = Color3.fromRGB(28, 32, 28), Player = Color3.fromRGB(24, 28, 24),
        Button = Color3.fromRGB(48, 60, 50), Element = Color3.fromRGB(42, 48, 42), ElementHover = Color3.fromRGB(58, 70, 60),
        ElementActive = Color3.fromRGB(78, 92, 80), Stroke = Color3.fromRGB(143, 239, 157), Accent = Color3.fromRGB(130, 240, 148),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(190, 220, 195),
        GradientA = Color3.fromRGB(130, 240, 148), GradientB = Color3.fromRGB(78, 144, 88),
    },
    Blue = {
        BG = Color3.fromRGB(0, 50, 149), Panel = Color3.fromRGB(4, 51, 111), Player = Color3.fromRGB(5, 68, 144),
        Button = Color3.fromRGB(4, 48, 105), Element = Color3.fromRGB(6, 80, 155), ElementHover = Color3.fromRGB(10, 105, 185),
        ElementActive = Color3.fromRGB(20, 130, 210), Stroke = Color3.fromRGB(0, 39, 114), Accent = Color3.fromRGB(120, 195, 255),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(180, 205, 235),
        GradientA = Color3.fromRGB(4, 42, 87), GradientB = Color3.fromRGB(255, 255, 255),
    },
    Red = {
        BG = Color3.fromRGB(150, 0, 20), Panel = Color3.fromRGB(111, 4, 20), Player = Color3.fromRGB(144, 5, 30),
        Button = Color3.fromRGB(105, 4, 20), Element = Color3.fromRGB(155, 6, 40), ElementHover = Color3.fromRGB(185, 10, 60),
        ElementActive = Color3.fromRGB(210, 20, 80), Stroke = Color3.fromRGB(114, 0, 20), Accent = Color3.fromRGB(255, 120, 120),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(235, 180, 180),
        GradientA = Color3.fromRGB(87, 4, 20), GradientB = Color3.fromRGB(255, 255, 255),
    },
    Green = {
        BG = Color3.fromRGB(0, 100, 50), Panel = Color3.fromRGB(4, 80, 40), Player = Color3.fromRGB(5, 120, 60),
        Button = Color3.fromRGB(4, 70, 30), Element = Color3.fromRGB(6, 130, 70), ElementHover = Color3.fromRGB(10, 160, 90),
        ElementActive = Color3.fromRGB(20, 190, 110), Stroke = Color3.fromRGB(0, 70, 30), Accent = Color3.fromRGB(120, 255, 160),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(180, 235, 200),
        GradientA = Color3.fromRGB(4, 70, 30), GradientB = Color3.fromRGB(255, 255, 255),
    },
    Dark = {
        BG = Color3.fromRGB(15, 15, 20), Panel = Color3.fromRGB(25, 25, 30), Player = Color3.fromRGB(35, 35, 40),
        Button = Color3.fromRGB(45, 45, 50), Element = Color3.fromRGB(55, 55, 65), ElementHover = Color3.fromRGB(70, 70, 80),
        ElementActive = Color3.fromRGB(90, 90, 100), Stroke = Color3.fromRGB(50, 50, 60), Accent = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(150, 150, 160),
        GradientA = Color3.fromRGB(30, 30, 35), GradientB = Color3.fromRGB(80, 80, 90),
    },
}

Library.Theme = {}
for k, v in pairs(Library.Themes["9-bit"]) do Library.Theme[k] = v end

function Library:SetTheme(name)
    if not self.Themes[name] then return end
    for k, v in pairs(self.Themes[name]) do self.Theme[k] = v end
    for _, l in ipairs(self.ThemeListeners) do pcall(l, self.Theme) end
end

function Library:SetAccent(color)
    if typeof(color) ~= "Color3" then return end
    local t = self.Themes["9-bit"]
    t.Accent = color
    t.GradientA = color
    t.GradientB = Color3.new(color.R * 0.55, color.G * 0.55, color.B * 0.55)
    t.Stroke   = Color3.new(math.min(1, color.R + 0.05), math.min(1, color.G + 0.05), math.min(1, color.B + 0.05))
    if self.Theme.Accent == Library.Theme.Accent then
        for k, v in pairs(t) do Library.Theme[k] = v end
        for _, l in ipairs(self.ThemeListeners) do pcall(l, self.Theme) end
    end
end

--=== Utilities ===
local function New(class, props, children)
    local o = Instance.new(class)
    local fontValue = props and props.Font
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Font" and k ~= "FontFace" then
            pcall(function() o[k] = v end)
        end
    end
    if fontValue ~= nil then
        if typeof(fontValue) == "Font" then
            local ok = pcall(function() o.FontFace = fontValue end)
            if not ok then pcall(function() o.Font = Enum.Font.GothamBold end) end
        else pcall(function() o.Font = fontValue end) end
    end
    if props and props.FontFace ~= nil then pcall(function() o.FontFace = props.FontFace end) end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r) return New("UICorner", { CornerRadius = UDim.new(0, r or 2) }) end
local function Stroke(color, trans, thick)
    local s = New("UIStroke", { Color = color or Library.Theme.Stroke, Transparency = trans or 0, Thickness = thick or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    table.insert(Library.ThemeListeners, function(t) s.Color = t.Stroke end)
    return s
end
local function Gradient(rot)
    local g = New("UIGradient", { Rotation = rot or 106 })
    local function u(t) g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, t.GradientA), ColorSequenceKeypoint.new(1, t.GradientB) }) end
    u(Library.Theme)
    table.insert(Library.ThemeListeners, u)
    return g
end
local function Tween(o, t, p)
    if not o then return end
    local ok, tw = pcall(TweenService.Create, TweenService, o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
    if ok and tw then tw:Play() return tw end
end
local function Label(props)
    props = props or {}
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextSize = props.TextSize or 12
    props.TextColor3 = props.TextColor3 or Library.Theme.Text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return New("TextLabel", props)
end
local function GetParentGui()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local ok2, c = pcall(function() return CoreGui end)
    if ok2 and c then
        local test = pcall(function() local f = Instance.new("Folder"); f.Parent = c; f:Destroy() end)
        if test then return c end
    end
    return LP:WaitForChild("PlayerGui")
end
local function Connect(sig, fn)
    local c = sig:Connect(fn); table.insert(Library.Connections, c); return c
end
local function RegisterFlag(flag, setter) if flag then Library.Registry[flag] = setter end end
local function SafeExec()
    local n = "Unknown"
    pcall(function() if type(identifyexecutor) == "function" then n = identifyexecutor() end end)
    return n
end
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos, dragConn
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dragStart
                    TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                    }):Play()
                end
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragConn then dragConn:Disconnect(); dragConn = nil end
        end
    end)
end

--=== Notify ===
local notifyGui
function Library:Notify(o)
    if type(o) == "string" then o = { Title = "Notice", Text = o } end
    if not notifyGui or not notifyGui.Parent then
        notifyGui = New("ScreenGui", { Name = "9BitNotify", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui })
    end
    local wrap = New("Frame", { Size = UDim2.fromOffset(240, 56), BackgroundTransparency = 1, Parent = notifyGui })
    local f = New("Frame", { Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 20, 0, 0), BackgroundColor3 = Library.Theme.Panel, Parent = wrap }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    local color = Library.Theme.Accent
    if o.Type == "Success" then color = Color3.fromRGB(80, 220, 140)
    elseif o.Type == "Warning" then color = Color3.fromRGB(255, 200, 80)
    elseif o.Type == "Error" then color = Color3.fromRGB(255, 88, 108) end
    New("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = color, Parent = f }, { Corner(2) })
    Label({ Text = o.Title or "Notice", Font = PIXEL_FONT, TextSize = 10, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -20, 0, 14), Parent = f })
    Label({ Text = o.Text or "", Font = PIXEL_FONT, TextSize = 8, TextColor3 = Library.Theme.TextDim, Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -20, 0, 22), TextWrapped = true, Parent = f })
    Tween(f, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(o.Duration or 4, function()
        local tw = Tween(f, 0.25, { Position = UDim2.new(1, 20, 0, 0) })
        if tw then tw.Completed:Connect(function() wrap:Destroy() end) else wrap:Destroy() end
    end)
end

--=== Binder (Keybind) ===
local BIND_MODES = { "Always On", "On Hotkey", "Toggle" }
local AllBinders = {}
local function MakeBinder(parent, default, onChange, defaultMode, onMode, onActive)
    local b = { key = default, isActive = (defaultMode or "Always On") == "Always On", mode = defaultMode or "Always On", listening = false }
    local btn = New("TextButton", {
        Size = UDim2.fromOffset(54, 22), BackgroundColor3 = Library.Theme.Element, BorderSizePixel = 0,
        Text = default and default.Name or "NONE", Font = PIXEL_FONT, TextSize = 8, TextColor3 = Library.Theme.Text,
        AutoButtonColor = false, Parent = parent,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local modeBtn = New("TextButton", {
        Size = UDim2.fromOffset(20, 22), BackgroundColor3 = Library.Theme.Element, BorderSizePixel = 0,
        Text = (b.mode):sub(1, 1), Font = PIXEL_FONT, TextSize = 8, TextColor3 = Library.Theme.Accent,
        AutoButtonColor = false, Parent = parent,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    table.insert(Library.ThemeListeners, function(t)
        btn.BackgroundColor3 = t.Element; modeBtn.BackgroundColor3 = t.Element
        btn.TextColor3 = t.Text; modeBtn.TextColor3 = t.Accent
    end)
    b.btn, b.modeBtn = btn, modeBtn
    table.insert(AllBinders, b)

    function b:setActive(a, silent)
        a = a and true or false
        if self.isActive == a then return end
        self.isActive = a
        if not silent and onActive then onActive(a) end
    end
    function b:setMode(m, silent)
        for _, v in ipairs(BIND_MODES) do
            if v == m then
                self.mode = m
                modeBtn.Text = m:sub(1, 1)
                self:setActive(m == "Always On", silent)
                if not silent and onMode then onMode(m, self.isActive) end
                return
            end
        end
    end
    function b:set(k, silent)
        self.key = k
        self.listening = false
        btn.Text = k and k.Name or "NONE"
        if not silent and onChange then onChange(k) end
    end
    btn.MouseButton1Click:Connect(function()
        b.listening = true; btn.Text = "..."; btn.TextColor3 = Library.Theme.Accent
    end)
    modeBtn.MouseButton1Click:Connect(function()
        local i = 1
        for j, v in ipairs(BIND_MODES) do if v == b.mode then i = j break end end
        b:setMode(BIND_MODES[(i % #BIND_MODES) + 1])
        Library:Notify({ Title = "Mode", Text = b.mode, Type = "Success", Duration = 1.5 })
    end)
    return b
end

Connect(UserInputService.InputBegan, function(i, gp)
    for _, b in ipairs(AllBinders) do
        if b.listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                if i.KeyCode ~= Enum.KeyCode.Escape then
                    b:set(i.KeyCode)
                else b:set(nil) end
                return
            elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 then
                b:set(i.UserInputType)
                return
            end
        end
    end
    if not gp then
        for _, b in ipairs(AllBinders) do
            if b.key and typeof(b.key) == "EnumItem" then
                local match = (b.key.EnumType == Enum.KeyCode and i.KeyCode == b.key)
                           or (b.key.EnumType == Enum.UserInputType and i.UserInputType == b.key)
                if match then
                    if b.mode == "On Hotkey" then b:setActive(true)
                    elseif b.mode == "Toggle" then b:setActive(not b.isActive) end
                end
            end
        end
    end
end)
Connect(UserInputService.InputEnded, function(i)
    for _, b in ipairs(AllBinders) do
        if b.mode == "On Hotkey" and b.key and typeof(b.key) == "EnumItem" then
            local match = (b.key.EnumType == Enum.KeyCode and i.KeyCode == b.key)
                       or (b.key.EnumType == Enum.UserInputType and i.UserInputType == b.key)
            if match then b:setActive(false) end
        end
    end
end)

--=== Color Button ===
local function MakeColorButton(parent, initial, alpha, onChange)
    local h, s, v = (initial or Color3.new(1,1,1)):ToHSV()
    local a = alpha or 1
    local btn = New("TextButton", {
        Size = UDim2.fromOffset(20, 20), BackgroundColor3 = Color3.fromHSV(h, s, v),
        BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = parent,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    local picker, popup
    local function fire()
        local c = Color3.fromHSV(h, s, v)
        btn.BackgroundColor3 = c
        if onChange then onChange(c, a) end
    end
    local function buildPicker()
        if popup then popup:Destroy() end
        local ap = btn.AbsolutePosition
        popup = New("Frame", {
            Size = UDim2.fromOffset(180, 200), Position = UDim2.fromOffset(math.max(8, ap.X - 160), ap.Y + 24),
            BackgroundColor3 = Library.Theme.Panel, BorderSizePixel = 0, ZIndex = 500,
            Parent = btn:FindFirstAncestorOfClass("ScreenGui") or GetParentGui(),
        }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
        local sv = New("ImageButton", {
            Size = UDim2.fromOffset(164, 130), Position = UDim2.fromOffset(8, 8),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, Text = "",
            AutoButtonColor = false, Image = "", ZIndex = 501, Parent = popup,
        }, { Corner(2) })
        New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1,1,1), Parent = sv, ZIndex = 502 },
            { Corner(2), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
        New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), Parent = sv, ZIndex = 503 },
            { Corner(2), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
        local svKnob = New("Frame", {
            Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(s, 1 - v), BackgroundTransparency = 1,
            ZIndex = 504, Parent = sv,
        }, { Corner(9), Stroke(Color3.new(1,1,1), 0, 2) })
        local hue = New("ImageButton", {
            Size = UDim2.fromOffset(164, 10), Position = UDim2.fromOffset(8, 146),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "",
            AutoButtonColor = false, Image = "", ZIndex = 501, Parent = popup,
        }, { Corner(2), New("UIGradient", { Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
            ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
            ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
            ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
            ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }) }) })
        local hueKnob = New("Frame", {
            Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            ZIndex = 502, Parent = hue,
        }, { Corner(9), Stroke(Color3.new(1,1,1), 0, 2) })
        local abar = New("ImageButton", {
            Size = UDim2.fromOffset(164, 10), Position = UDim2.fromOffset(8, 166),
            BackgroundColor3 = Color3.fromHSV(h, s, v), BorderSizePixel = 0, Text = "",
            AutoButtonColor = false, Image = "", ZIndex = 501, Parent = popup,
        }, { Corner(2), New("UIGradient", { Transparency = NumberSequence.new(1, 0) }) })
        local aKnob = New("Frame", {
            Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(a, 0, 0.5, 0), BackgroundColor3 = Color3.fromHSV(h, s, v),
            ZIndex = 502, Parent = abar,
        }, { Corner(9), Stroke(Color3.new(1,1,1), 0, 2) })
        local drag
        local function dragSV(pos)
            s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            svKnob.Position = UDim2.fromScale(s, 1 - v)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            fire()
        end
        local function dragH(pos)
            h = math.clamp((pos.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 0.999)
            hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
            hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            fire()
        end
        local function dragA(pos)
            a = math.clamp((pos.X - abar.AbsolutePosition.X) / abar.AbsoluteSize.X, 0, 1)
            aKnob.Position = UDim2.new(a, 0, 0.5, 0)
            abar.BackgroundColor3 = Color3.fromHSV(h, s, v)
            fire()
        end
        sv.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = dragSV; dragSV(i.Position) end end)
        hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = dragH; dragH(i.Position) end end)
        abar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = dragA; dragA(i.Position) end end)
        local c1 = UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then drag(i.Position) end
        end)
        local c2 = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = nil end
        end)
        table.insert(Library.Connections, c1); table.insert(Library.Connections, c2)
        local closeConn
        closeConn = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 and popup and popup.Parent then
                local m = i.Position; local p = popup.AbsolutePosition; local sz = popup.AbsoluteSize
                local b = btn.AbsolutePosition; local bs = btn.AbsoluteSize
                local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
                local inBtn = m.X >= b.X and m.X <= b.X + bs.X and m.Y >= b.Y and m.Y <= b.Y + bs.Y
                if not inPop and not inBtn then popup:Destroy(); popup = nil; closeConn:Disconnect() end
            end
        end)
    end
    btn.MouseButton1Click:Connect(function()
        if popup and popup.Parent then popup:Destroy(); popup = nil else buildPicker() end
    end)
    local api = {}
    function api:Set(c, al)
        if typeof(c) == "Color3" then h, s, v = c:ToHSV() end
        if al then a = al end
        btn.BackgroundColor3 = Color3.fromHSV(h, s, v)
        fire()
    end
    function api:Get() return Color3.fromHSV(h, s, v), a end
    return api
end

--=== Section widgets ===
local Section = {}
Section.__index = Section

local function nextRow(section, h)
    section._rowIdx = section._rowIdx + 1
    return New("Frame", {
        Size = UDim2.new(1, 0, 0, h or 24), BackgroundTransparency = 1,
        LayoutOrder = section._rowIdx, Parent = section.Content,
    })
end

function Section:Spacing(px)
    local s = nextRow(self, px or 6); s.BackgroundTransparency = 1; return s
end

function Section:Separator()
    local row = nextRow(self, 1)
    New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Library.Theme.Stroke, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = row })
end

function Section:Label(text)
    local row = nextRow(self, 18)
    local l = Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.TextDim, Size = UDim2.fromScale(1, 1), TextWrapped = true, Parent = row })
    local api = {}
    function api:Set(v) l.Text = tostring(v) end
    function api:Get() return l.Text end
    return api
end

function Section:Button(text, callback)
    local row = nextRow(self, 30)
    local b = New("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Library.Theme.Element,
        Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.Text,
        Text = tostring(text), AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1), Gradient() })
    local overlay = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 0.5, Parent = b }, { Corner(2) })
    b.MouseEnter:Connect(function() Tween(overlay, 0.15, { BackgroundTransparency = 0.2 }) end)
    b.MouseLeave:Connect(function() Tween(overlay, 0.15, { BackgroundTransparency = 0.5 }) end)
    b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
    return b
end

function Section:TextInput(text, default, callback, placeholder, flag)
    flag = flag or text
    local row = nextRow(self, 26)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local box = New("Frame", { Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -130, 0.5, -11), BackgroundColor3 = Library.Theme.Element, BorderSizePixel = 0, Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local tb = New("TextBox", {
        Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1, Font = PIXEL_FONT, TextSize = 8, TextColor3 = Library.Theme.Text,
        PlaceholderText = placeholder or "", PlaceholderColor3 = Library.Theme.TextDim,
        ClearTextOnFocus = false, Text = default or "", TextXAlignment = Enum.TextXAlignment.Left, Parent = box,
    })
    Library.Flags[flag] = tb.Text
    tb.FocusLost:Connect(function(enter)
        Library.Flags[flag] = tb.Text
        if callback then task.spawn(callback, tb.Text, enter) end
    end)
    local api = {}
    function api:Set(v) tb.Text = tostring(v); Library.Flags[flag] = tb.Text end
    function api:Get() return tb.Text end
    RegisterFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:Keybind(text, default, callback, flag, opts)
    opts = opts or {}
    flag = flag or text
    local row = nextRow(self, 24)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -80, 1, 0), Parent = row })
    local b = MakeBinder(row, default, function(k)
        Library.Flags[flag] = k
        if callback then task.spawn(callback, k) end
    end, opts.mode, opts.onMode, opts.onActive)
    b.btn.Position = UDim2.new(1, -76, 0.5, -11)
    b.modeBtn.Position = UDim2.new(1, -20, 0.5, -11)
    Library.Flags[flag] = default
    RegisterFlag(flag, function(v) b:set(v) end)
    local api = {}
    function api:Set(k) b:set(k) end
    function api:Get() return b.key end
    function api:SetMode(m) b:setMode(m) end
    function api:GetMode() return b.mode end
    function api:GetActive() return b.isActive end
    return api
end

function Section:ColorPicker(text, default, callback, alpha, flag)
    flag = flag or text
    local row = nextRow(self, 24)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -30, 1, 0), Parent = row })
    local c = default or Library.Theme.Accent
    local a = alpha or 1
    Library.Flags[flag] = c; Library.Flags[flag .. "_alpha"] = a
    local btn = MakeColorButton(row, c, a, function(col, al)
        Library.Flags[flag] = col; Library.Flags[flag .. "_alpha"] = al
        if callback then task.spawn(callback, col, al) end
    end)
    btn.btn.Position = UDim2.new(1, -22, 0.5, -10); btn.btn.Size = UDim2.fromOffset(22, 22)
    local api = {}
    function api:Set(col, al) btn:Set(col, al) end
    function api:Get() return btn:Get() end
    RegisterFlag(flag, function(v) if typeof(v) == "Color3" then btn:Set(v) end end)
    return api
end

function Section:SliderInt(text, min, max, default, callback, format, flag)
    flag = flag or text
    format = format or "%d"
    local row = nextRow(self, 36)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local vl = Label({ Text = "", TextXAlignment = Enum.TextXAlignment.Right, Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.Accent, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local track = New("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local fill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = track }, { Corner(2) })
    local grab = New("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1), Parent = track }, { Corner(2), Stroke(Library.Theme.Accent, 0, 2) })
    table.insert(Library.ThemeListeners, function(t)
        fill.BackgroundColor3 = t.Accent; vl.TextColor3 = t.Accent; track.BackgroundColor3 = t.Element
        local s = grab:FindFirstChildOfClass("UIStroke"); if s then s.Color = t.Accent end
    end)
    local val = math.clamp(default or min, min, max)
    local function apply(v, instant)
        v = math.clamp(v, min, max)
        val = v
        local p = (v - min) / math.max(max - min, 0.0001)
        local t = instant and 0 or 0.12
        Tween(fill, t, { Size = UDim2.new(p, 0, 1, 0) })
        Tween(grab, t, { Position = UDim2.new(p, 0, 0.5, 0) })
        vl.Text = string.format(format, math.floor(v + 0.5))
        Library.Flags[flag] = v
        if callback then task.spawn(callback, v) end
    end
    local sliding = false
    local function upd(x)
        local p = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        apply(min + (max - min) * p)
    end
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; upd(i.Position.X) end end)
    Connect(UserInputService.InputChanged, function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
    Connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    apply(val, true)
    RegisterFlag(flag, function(v) apply(v) end)
    local api = {}
    function api:Set(v) apply(v) end
    function api:Get() return val end
    return api
end

function Section:SliderFloat(text, min, max, default, callback, format, flag)
    flag = flag or text
    format = format or "%.1f"
    local row = nextRow(self, 36)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local vl = Label({ Text = "", TextXAlignment = Enum.TextXAlignment.Right, Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.Accent, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local track = New("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local fill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = track }, { Corner(2) })
    local grab = New("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1), Parent = track }, { Corner(2), Stroke(Library.Theme.Accent, 0, 2) })
    table.insert(Library.ThemeListeners, function(t)
        fill.BackgroundColor3 = t.Accent; vl.TextColor3 = t.Accent; track.BackgroundColor3 = t.Element
        local s = grab:FindFirstChildOfClass("UIStroke"); if s then s.Color = t.Accent end
    end)
    local val = math.clamp(default or min, min, max)
    local function apply(v, instant)
        v = math.clamp(v, min, max)
        val = v
        local p = (v - min) / math.max(max - min, 0.0001)
        local t = instant and 0 or 0.12
        Tween(fill, t, { Size = UDim2.new(p, 0, 1, 0) })
        Tween(grab, t, { Position = UDim2.new(p, 0, 0.5, 0) })
        vl.Text = string.format(format, v)
        Library.Flags[flag] = v
        if callback then task.spawn(callback, v) end
    end
    local sliding = false
    local function upd(x)
        local p = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        apply(min + (max - min) * p)
    end
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; upd(i.Position.X) end end)
    Connect(UserInputService.InputChanged, function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
    Connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    apply(val, true)
    RegisterFlag(flag, function(v) apply(v) end)
    local api = {}
    function api:Set(v) apply(v) end
    function api:Get() return val end
    return api
end

function Section:Slider(text, min, max, default, callback, opts)
    opts = opts or {}
    if opts.float then return self:SliderFloat(text, min, max, default, callback, opts.format, opts.flag) end
    return self:SliderInt(text, min, max, default, callback, opts.format, opts.flag)
end

function Section:Combo(text, items, default, callback, flag)
    flag = flag or text
    items = items or {}
    local row = nextRow(self, 24)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local box = New("TextButton", { Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -130, 0.5, -11), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local preview = Label({ Text = "", Font = PIXEL_FONT, TextSize = 8, Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(6, 0), Parent = box, TextTruncate = Enum.TextTruncate.AtEnd })
    Label({ Text = "v", Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(16, 22), Position = UDim2.new(1, -18, 0, 0), Parent = box })
    local gui = self.Window and self.Window.Gui
    local popup = New("Frame", { Visible = false, Size = UDim2.fromOffset(160, 200), BackgroundColor3 = Library.Theme.Panel, BorderSizePixel = 0, ZIndex = 500, Parent = gui }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    local scroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = popup,
    })
    New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
    local index = 1
    if type(default) == "number" then index = math.clamp(default, 1, math.max(1, #items))
    elseif default ~= nil then
        for i, v in ipairs(items) do if v == default then index = i break end end
    end
    local function refresh()
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, it in ipairs(items) do
            local b = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = i == index and Library.Theme.Accent or Library.Theme.Element,
                BackgroundTransparency = i == index and 0.3 or 0.6,
                Font = PIXEL_FONT, TextSize = 8, Text = tostring(it), TextColor3 = Library.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, LayoutOrder = i, Parent = scroll,
            }, { Corner(2) })
            New("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = b })
            b.MouseButton1Click:Connect(function()
                index = i
                preview.Text = tostring(items[i])
                Library.Flags[flag] = items[i]
                if callback then task.spawn(callback, items[i], i) end
                popup.Visible = false
                refresh()
            end)
        end
        popup.Size = UDim2.fromOffset(160, math.min(#items * 24 + 8, 200))
    end
    preview.Text = tostring(items[index] or "")
    Library.Flags[flag] = items[index]
    box.MouseButton1Click:Connect(function()
        if popup.Visible then popup.Visible = false
        else
            local ap = box.AbsolutePosition
            popup.Position = UDim2.fromOffset(ap.X + box.AbsoluteSize.X - 160, ap.Y + box.AbsoluteSize.Y + 4)
            popup.Visible = true
            refresh()
        end
    end)
    local closeConn = UserInputService.InputBegan:Connect(function(i)
        if popup.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m = i.Position; local p = popup.AbsolutePosition; local sz = popup.AbsoluteSize
            local b = box.AbsolutePosition; local bs = box.AbsoluteSize
            local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
            local inBtn = m.X >= b.X and m.X <= b.X + bs.X and m.Y >= b.Y and m.Y <= b.Y + bs.Y
            if not inPop and not inBtn then popup.Visible = false end
        end
    end)
    table.insert(Library.Connections, closeConn)
    local api = {}
    function api:Set(v)
        if type(v) == "number" then index = math.clamp(v, 1, #items)
        else for i, it in ipairs(items) do if it == v then index = i break end end end
        preview.Text = tostring(items[index])
        Library.Flags[flag] = items[index]
        if callback then task.spawn(callback, items[index], index) end
    end
    function api:Get() return items[index], index end
    function api:SetItems(newItems, sel)
        items = newItems or {}; index = 1
        if sel then for i, it in ipairs(items) do if it == sel then index = i break end end end
        preview.Text = tostring(items[index]); Library.Flags[flag] = items[index]
    end
    RegisterFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:MultiCombo(text, items, defaults, callback, flag)
    flag = flag or text
    items = items or {}
    local selected = {}
    for _, d in ipairs(defaults or {}) do
        if type(d) == "number" then selected[d] = true
        else for i, v in ipairs(items) do if v == d then selected[i] = true end end end
    end
    local row = nextRow(self, 24)
    Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local box = New("TextButton", { Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -130, 0.5, -11), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local preview = Label({ Text = "", Font = PIXEL_FONT, TextSize = 8, Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(6, 0), Parent = box, TextTruncate = Enum.TextTruncate.AtEnd })
    Label({ Text = "v", Font = PIXEL_FONT, TextSize = 9, TextColor3 = Library.Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(16, 22), Position = UDim2.new(1, -18, 0, 0), Parent = box })
    local gui = self.Window and self.Window.Gui
    local popup = New("Frame", { Visible = false, Size = UDim2.fromOffset(160, 200), BackgroundColor3 = Library.Theme.Panel, BorderSizePixel = 0, ZIndex = 500, Parent = gui }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    local scroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = popup,
    })
    New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
    local function listValue()
        local o = {}
        for i, v in ipairs(items) do if selected[i] then o[#o+1] = v end end
        return o
    end
    local function refreshPreview()
        local list = listValue()
        preview.Text = #list > 0 and table.concat(list, ",") or "None"
        Library.Flags[flag] = list
        if callback then task.spawn(callback, list) end
    end
    local function rebuild()
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, it in ipairs(items) do
            local sel = selected[i]
            local b = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = sel and Library.Theme.Accent or Library.Theme.Element,
                BackgroundTransparency = sel and 0.3 or 0.6,
                Font = PIXEL_FONT, TextSize = 8, Text = (sel and "[x] " or "[ ] ") .. tostring(it),
                TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0, LayoutOrder = i, Parent = scroll,
            }, { Corner(2) })
            New("UIPadding", { PaddingLeft = UDim.new(0, 4), Parent = b })
            b.MouseButton1Click:Connect(function()
                selected[i] = not selected[i]
                rebuild(); refreshPreview()
            end)
        end
        popup.Size = UDim2.fromOffset(160, math.min(#items * 24 + 8, 200))
    end
    refreshPreview()
    box.MouseButton1Click:Connect(function()
        if popup.Visible then popup.Visible = false
        else
            local ap = box.AbsolutePosition
            popup.Position = UDim2.fromOffset(ap.X + box.AbsoluteSize.X - 160, ap.Y + box.AbsoluteSize.Y + 4)
            popup.Visible = true; rebuild()
        end
    end)
    local closeConn = UserInputService.InputBegan:Connect(function(i)
        if popup.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m = i.Position; local p = popup.AbsolutePosition; local sz = popup.AbsoluteSize
            local b = box.AbsolutePosition; local bs = box.AbsoluteSize
            local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
            local inBtn = m.X >= b.X and m.X <= b.X + bs.X and m.Y >= b.Y and m.Y <= b.Y + bs.Y
            if not inPop and not inBtn then popup.Visible = false end
        end
    end)
    table.insert(Library.Connections, closeConn)
    local api = {}
    function api:Set(list)
        selected = {}
        for _, v in ipairs(list or {}) do for i, it in ipairs(items) do if it == v then selected[i] = true end end end
        refreshPreview()
    end
    function api:Get() return listValue() end
    RegisterFlag(flag, function(v) if type(v) == "table" then api:Set(v) end end)
    return api
end

function Section:Checkbox(text, default, callback, opts)
    opts = opts or {}
    local flag = opts.flag or text
    local value = default and true or false
    local colorList = {}
    if opts.color then
        if typeof(opts.color) == "Color3" then colorList = { opts.color }
        elseif type(opts.color) == "table" then colorList = opts.color end
    end
    local hasKeybind = opts.keybind ~= nil or opts.keybindFlag ~= nil
    local hasOptions = opts.options ~= nil
    local row = nextRow(self, 26)
    local box = New("Frame", { Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(0, 7), BackgroundColor3 = Library.Theme.Element, BorderSizePixel = 0, Parent = row }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local lbl = Label({ Text = tostring(text), Font = PIXEL_FONT, TextSize = 9, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -80, 1, 0), TextColor3 = value and Library.Theme.Text or Library.Theme.TextDim, Parent = row })
    local hit = New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = row })
    local api = { Colors = {} }
    Library.Flags[flag] = value

    local extras = {}
    -- options (…) on right
    if hasOptions then
        local optsBtn = New("TextButton", {
            Size = UDim2.fromOffset(20, 22), BackgroundColor3 = Library.Theme.Element,
            Font = PIXEL_FONT, TextSize = 10, Text = "...", TextColor3 = Library.Theme.Accent,
            AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
        }, { Corner(2), Stroke(Library.Theme.Stroke, 0.3, 1) })
        local gui = self.Window and self.Window.Gui
        local subPopup = New("Frame", { Visible = false, Size = UDim2.fromOffset(200, 200), BackgroundColor3 = Library.Theme.Panel, BorderSizePixel = 0, ZIndex = 500, Parent = gui }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
        local subContent = New("Frame", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1, Parent = subPopup }, { New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
        local subSection = { Content = subContent, Window = self.Window, _rowIdx = 0 }
        for _, fn in pairs(Section) do end
        setmetatable(subSection, { __index = Section })
        opts.options(subSection)
        optsBtn.MouseButton1Click:Connect(function()
            if subPopup.Visible then subPopup.Visible = false
            else
                local ap = optsBtn.AbsolutePosition
                subPopup.Position = UDim2.fromOffset(ap.X - 180, ap.Y + 24)
                subPopup.Visible = true
            end
        end)
        local c = UserInputService.InputBegan:Connect(function(i)
            if subPopup.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = i.Position; local p = subPopup.AbsolutePosition; local sz = subPopup.AbsoluteSize
                local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
                if not inPop then subPopup.Visible = false end
            end
        end)
        table.insert(Library.Connections, c)
        table.insert(extras, { type = "options", obj = optsBtn, w = 20 })
    end
    -- color buttons
    for i, c in ipairs(colorList) do
        local colorFlag = flag .. "_color" .. (i > 1 and tostring(i) or "")
        Library.Flags[colorFlag] = c
        Library.Flags[colorFlag .. "_alpha"] = 1
        local btn = MakeColorButton(row, c, 1, function(col, al)
            Library.Flags[colorFlag] = col
            Library.Flags[colorFlag .. "_alpha"] = al
            if opts.onColor then task.spawn(opts.onColor, col, al, i) end
        end)
        btn.btn.Size = UDim2.fromOffset(20, 20)
        api.Colors[i] = btn
        table.insert(extras, { type = "color", obj = btn.btn, w = 20, api = btn })
    end
    -- keybind
    if hasKeybind then
        local kFlag = flag .. "_key"
        local b = MakeBinder(row, opts.keybind, function(k)
            Library.Flags[kFlag] = k
            if opts.onKey then task.spawn(opts.onKey, k) end
        end, opts.mode, opts.onMode, opts.onActive)
        b.btn.Size = UDim2.fromOffset(50, 22)
        b.modeBtn.Size = UDim2.fromOffset(18, 22)
        Library.Flags[kFlag] = opts.keybind
        api.Binder = b
        table.insert(extras, { type = "keybind", obj = b.btn, obj2 = b.modeBtn, w = 74, api = b })
    end
    -- layout extras from right
    local x = 0
    for i = #extras, 1, -1 do
        local e = extras[i]
        x = x + e.w + 4
        if e.type == "keybind" then
            e.obj2.Position = UDim2.new(1, -x, 0.5, -11)
            e.obj.Position = UDim2.new(1, -x + 20, 0.5, -11)
        else
            e.obj.Position = UDim2.new(1, -x, 0.5, -11)
        end
    end
    lbl.Size = UDim2.new(1, -(18 + x + 6), 1, 0)

    local function set(v, silent)
        value = v and true or false
        Library.Flags[flag] = value
        box.BackgroundColor3 = value and Library.Theme.Accent or Library.Theme.Element
        lbl.TextColor3 = value and Library.Theme.Text or Library.Theme.TextDim
        if api.Binder and api.Binder.mode == "Always On" then api.Binder:setActive(value, true) end
        if not silent and callback then task.spawn(callback, value) end
    end
    hit.MouseButton1Click:Connect(function() set(not value) end)
    set(value, true)

    table.insert(Library.ThemeListeners, function(t)
        box.BackgroundColor3 = value and t.Accent or t.Element
        lbl.TextColor3 = value and t.Text or t.TextDim
    end)

    function api:Set(v) set(v) end
    function api:Get() return value end
    function api:Toggle() set(not value) end
    function api:SetColor(c, a, i) if api.Colors[i or 1] then api.Colors[i or 1]:Set(c, a) end end
    function api:SetKey(k) if api.Binder then api.Binder:set(k) end end

    RegisterFlag(flag, function(v) set(v) end)
    return api
end

--=== Section factory ===
local function CreateSection(parentContent, title, icon, Window, order)
    local Section_obj = { Name = title, Window = Window, _rowIdx = 0 }
    setmetatable(Section_obj, { __index = Section })
    local holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Library.Theme.Player, BackgroundTransparency = 0.35,
        BorderSizePixel = 0, LayoutOrder = order or 1, Parent = parentContent,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
    New("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = holder })
    table.insert(Library.ThemeListeners, function(t) holder.BackgroundColor3 = t.Player end)
    local header = New("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0, Parent = holder })
    if icon then
        local hi = New("ImageLabel", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 4), BackgroundTransparency = 1, Image = icon, ImageColor3 = Library.Theme.Accent, Parent = header })
        table.insert(Library.ThemeListeners, function(t) hi.ImageColor3 = t.Accent end)
    end
    Label({ Text = title, Font = PIXEL_FONT, TextSize = 10, Position = UDim2.fromOffset(icon and 22 or 0, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Library.Theme.Accent, Parent = header })
    local content = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 1, Parent = holder,
    }, { New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
    Section_obj.Holder, Section_obj.Content = holder, content
    return Section_obj
end

--=== Window ===
local winCounter = 0
local function BuildWindow(self, cfg)
    cfg = cfg or {}
    winCounter += 1
    local Window = { Tabs = {}, CurrentTab = nil, Title = cfg.Title or "9-Bit UI" }
    local gui = New("ScreenGui", { Name = "9BitUI_" .. winCounter, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 9999990 + winCounter, Parent = GetParentGui() })
    Window.Gui = gui

    local blur = Lighting:FindFirstChild("9BitBlur") or New("BlurEffect", { Name = "9BitBlur", Size = 0, Parent = Lighting })
    Window.Blur = blur

    -- OpenFrame center top
    local openFrame = New("Frame", {
        Name = "OpenFrame", Size = UDim2.fromOffset(304, 47),
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14 + (winCounter - 1) * 60),
        BackgroundColor3 = Library.Theme.BG, BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = gui,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    Window.OpenFrame = openFrame
    table.insert(Library.ThemeListeners, function(t) openFrame.BackgroundColor3 = t.BG end)
    Label({ Text = Window.Title, Font = PIXEL_FONT, TextSize = 12, Size = UDim2.fromOffset(185, 42), Position = UDim2.fromOffset(60, 2), TextWrapped = true, Parent = openFrame })
    New("ImageLabel", { Image = LOGO_ICON, BackgroundTransparency = 1, Size = UDim2.fromOffset(42, 41), Position = UDim2.new(1, -48, 0, 3), Parent = openFrame }, { Corner(2), Gradient() })
    local openBtn = New("TextButton", {
        Size = UDim2.fromOffset(26, 27), Position = UDim2.fromOffset(20, 10),
        BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6,
        Font = PIXEL_FONT, Text = "+", TextColor3 = Library.Theme.Text, TextSize = 12,
        AutoButtonColor = false, Parent = openFrame,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) openBtn.BackgroundColor3 = t.Button; openBtn.TextColor3 = t.Text end)
    MakeDraggable(openFrame, openFrame)

    -- Main
    local mainFrame = New("Frame", {
        Name = "MainFrame", Size = UDim2.fromOffset(550, 349),
        Position = UDim2.new(0.5, -275 + (winCounter - 1) * 20, 0.5, -175 + (winCounter - 1) * 20),
        BackgroundColor3 = Library.Theme.BG, BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Visible = false, ClipsDescendants = true, Parent = gui,
    }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    Window.MainFrame = mainFrame
    table.insert(Library.ThemeListeners, function(t) mainFrame.BackgroundColor3 = t.BG end)

    local topBar = New("Frame", { Size = UDim2.new(0, 550, 0, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3, Parent = mainFrame }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) topBar.BackgroundColor3 = t.Panel end)
    MakeDraggable(mainFrame, topBar)

    Label({ Text = Window.Title, Font = PIXEL_FONT, TextSize = 12, Size = UDim2.fromOffset(178, 42), Position = UDim2.fromOffset(66, 0), TextWrapped = true, Parent = topBar })
    New("ImageLabel", { Image = LOGO_ICON, BackgroundTransparency = 1, Size = UDim2.fromOffset(42, 41), Position = UDim2.fromOffset(8, 0), Parent = topBar }, { Corner(2), Gradient() })
    Label({ Text = "Exec: " .. SafeExec(), Font = PIXEL_FONT, TextSize = 7, Size = UDim2.fromOffset(120, 34), Position = UDim2.fromOffset(255, 4), TextWrapped = true, Parent = topBar })
    local playersLbl = Label({ Text = "Players: " .. #Players:GetPlayers(), Font = PIXEL_FONT, TextSize = 7, Size = UDim2.fromOffset(93, 34), Position = UDim2.fromOffset(372, 4), TextWrapped = true, Parent = topBar })
    Players.PlayerAdded:Connect(function() playersLbl.Text = "Players: " .. #Players:GetPlayers() end)
    Players.PlayerRemoving:Connect(function() playersLbl.Text = "Players: " .. #Players:GetPlayers() end)

    local miniBtn = New("TextButton", { Size = UDim2.fromOffset(26, 27), Position = UDim2.new(0, 483, 0, 7), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6, Font = PIXEL_FONT, Text = "-", TextColor3 = Library.Theme.Text, TextSize = 14, AutoButtonColor = false, Parent = topBar }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    local closeBtn = New("TextButton", { Size = UDim2.fromOffset(26, 27), Position = UDim2.new(0, 516, 0, 7), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6, Font = PIXEL_FONT, Text = "X", TextColor3 = Library.Theme.Text, TextSize = 12, AutoButtonColor = false, Parent = topBar }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) miniBtn.BackgroundColor3 = t.Button; closeBtn.BackgroundColor3 = t.Button end)

    local sidebar = New("Frame", { Size = UDim2.new(0, 120, 0, 307), Position = UDim2.fromOffset(0, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = mainFrame }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) sidebar.BackgroundColor3 = t.Panel end)
    local tabList = New("Frame", { Size = UDim2.new(1, -8, 1, -66), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1, Parent = sidebar }, { New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
    local playerInfo = New("Frame", { Size = UDim2.new(1, 0, 0, 58), Position = UDim2.new(0, 0, 1, -58), BackgroundColor3 = Library.Theme.Player, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = sidebar }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    table.insert(Library.ThemeListeners, function(t) playerInfo.BackgroundColor3 = t.Player end)
    local av = New("ImageLabel", { Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", BackgroundColor3 = Library.Theme.Panel, Size = UDim2.fromOffset(39, 39), Position = UDim2.fromOffset(8, 9), BorderSizePixel = 0, Parent = playerInfo }, { Corner(20), Stroke(Library.Theme.Stroke, 0, 2) })
    pcall(function() av.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
    Label({ Text = "Hi, " .. LP.DisplayName, Font = PIXEL_FONT, TextSize = 7, Size = UDim2.fromOffset(64, 40), Position = UDim2.fromOffset(52, 9), TextWrapped = true, Parent = playerInfo })

    local pageFrame = New("Frame", { Size = UDim2.new(0, 429, 0, 307), Position = UDim2.fromOffset(120, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, ClipsDescendants = true, Parent = mainFrame }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2) })
    Window.PageFrame = pageFrame
    table.insert(Library.ThemeListeners, function(t) pageFrame.BackgroundColor3 = t.Panel end)
    local pageHolder = New("Frame", { Size = UDim2.new(1, -16, 1, -16), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Parent = pageFrame })

    function Window:SetVisible(v)
        mainFrame.Visible = v
        Tween(blur, 0.3, { Size = v and 10 or 0 })
        if v then mainFrame.Size = UDim2.fromOffset(550, 349) end
    end
    function Window:Toggle() self:SetVisible(not mainFrame.Visible) end
    function Window:SetToggleKey(k) Library.ToggleKey = k end
    function Window:Destroy() if blur then blur:Destroy() end; gui:Destroy() end

    openBtn.MouseButton1Click:Connect(function() Window:SetVisible(not mainFrame.Visible) end)
    closeBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)
    miniBtn.MouseButton1Click:Connect(function()
        local min = mainFrame.Size.Y.Offset > 100
        miniBtn.Text = min and "+" or "-"
        Tween(mainFrame, 0.2, { Size = UDim2.fromOffset(550, min and 42 or 349) })
    end)

    -- Watermark
    function Window:AddWatermark()
        local wm = New("Frame", { Size = UDim2.fromOffset(240, 26), Position = UDim2.fromOffset(14, 70), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = gui }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = wm })
        local l = Label({ Size = UDim2.fromScale(1, 1), Text = "9-bit | ...", Font = PIXEL_FONT, TextColor3 = Library.Theme.Text, TextScaled = true, Parent = wm })
        New("UITextSizeConstraint", { MaxTextSize = 10, MinTextSize = 7, Parent = l })
        local frames = 0
        Connect(RunService.RenderStepped, function() frames += 1 end)
        task.spawn(function()
            while task.wait(1) do
                local ping = 0
                pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                l.Text = string.format("9-bit | %dfps | %dms | %s", frames, ping, os.date("%H:%M:%S"))
                frames = 0
            end
        end)
        return wm
    end

    -- KeybindList
    function Window:AddKeybindList()
        local kl = New("Frame", { Size = UDim2.fromOffset(200, 40), Position = UDim2.fromOffset(14, 104), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = gui }, { Corner(2), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = kl })
        New("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6), Parent = kl })
        task.spawn(function()
            while task.wait(0.5) do
                local found = {}
                for flag, v in pairs(Library.Flags) do
                    if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then found[flag] = v.Name end
                end
                local count = 0
                for k in pairs(found) do count += 1 end
                for _, c in ipairs(kl:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
                local idx = 0
                for flag, kname in pairs(found) do
                    idx += 1
                    local l = Label({ Size = UDim2.new(1, 0, 0, 14), Text = "[" .. kname .. "] " .. flag, Font = PIXEL_FONT, TextColor3 = Library.Theme.Accent, TextScaled = true, LayoutOrder = idx, Parent = kl })
                    New("UITextSizeConstraint", { MaxTextSize = 9, MinTextSize = 7, Parent = l })
                end
                kl.Size = UDim2.fromOffset(200, math.max(28, count * 18 + 12))
            end
        end)
        return kl
    end

    -- Tabs
    function Window:AddTab(name, icon)
        local Tab = { Name = name, Sections = {}, Window = Window, _columns = {} }
        local btn = New("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", LayoutOrder = #Window.Tabs + 1, Parent = tabList }, { Corner(2) })
        local ind = New("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Visible = false, Parent = btn }, { Corner(2) })
        local ico = New("ImageLabel", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 6), BackgroundTransparency = 1, Image = icon or "", ImageColor3 = Library.Theme.TextDim, Parent = btn })
        local lbl = Label({ Text = name, Font = PIXEL_FONT, TextSize = 8, TextColor3 = Library.Theme.TextDim, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -38, 1, 0), Parent = btn })
        Tab.Button, Tab.Indicator, Tab.TabIcon, Tab.TabLabel = btn, ind, ico, lbl
        table.insert(Library.ThemeListeners, function(t)
            ind.BackgroundColor3 = t.Accent
            if Window.CurrentTab ~= Tab then ico.ImageColor3 = t.TextDim; lbl.TextColor3 = t.TextDim
            else ico.ImageColor3 = t.Accent; lbl.TextColor3 = t.Text end
        end)
        local page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 4, ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = pageHolder,
        }, { Corner(2) })
        Tab.Page = page
        table.insert(Library.ThemeListeners, function(t) page.ScrollBarImageColor3 = t.Accent end)
        local contentContainer = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page })
        New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = contentContainer })

        function Tab:AddSection(title, icon)
            local s = CreateSection(contentContainer, title, icon, Window, #Tab.Sections + 1)
            table.insert(Tab.Sections, s)
            return s
        end

        local function select()
            if Window.CurrentTab == Tab then return end
            for _, t in ipairs(Window.Tabs) do
                t.Indicator.Visible = false; t.TabIcon.ImageColor3 = Library.Theme.TextDim; t.TabLabel.TextColor3 = Library.Theme.TextDim
                Tween(t.Button, 0.2, { BackgroundTransparency = 1 }); t.Page.Visible = false
            end
            Window.CurrentTab = Tab; ind.Visible = true; ico.ImageColor3 = Library.Theme.Accent; lbl.TextColor3 = Library.Theme.Text
            Tween(btn, 0.2, { BackgroundTransparency = 0.55 }); page.Visible = true
        end
        btn.MouseButton1Click:Connect(select)
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then select() end
        return Tab
    end

    task.delay(0.4, function()
        Library:Notify({ Title = "Welcome!", Text = "Hello, " .. LP.DisplayName, Type = "Success", Duration = 3 })
    end)
    return Window
end

function Library:CreateWindow(cfg) return BuildWindow(self, cfg) end

--=== Config system ===
local CONFIG_FOLDER = "9BitUI"

local function ensureCfg()
    if not (isfolder and writefile and readfile and makefolder and isfile) then return false end
    return pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        if not isfolder(CONFIG_FOLDER .. "/configs") then makefolder(CONFIG_FOLDER .. "/configs") end
    end)
end

local function encodeVal(v)
    if typeof(v) == "Color3" then return { __t = "c3", r = v.R, g = v.G, b = v.B } end
    if typeof(v) == "EnumItem" then return { __t = "e", enum = v.EnumType.Name, name = v.Name } end
    return v
end
local function decodeVal(v)
    if type(v) == "table" then
        if v.__t == "c3" then return Color3.new(v.r, v.g, v.b) end
        if v.__t == "e" then local e = Enum[v.enum]; if e and e[v.name] then return e[v.name] end return nil end
    end
    return v
end

function Library:GetConfig()
    local out = {}
    for flag, v in pairs(self.Flags) do
        if not self.ConfigIgnore[flag] then out[flag] = encodeVal(v) end
    end
    return out
end

function Library:ApplyConfig(data)
    if type(data) ~= "table" then return false end
    for flag, v in pairs(data) do
        if not self.ConfigIgnore[flag] then
            local decoded = decodeVal(v)
            if decoded ~= nil then
                Library.Flags[flag] = decoded
                if Library.Registry[flag] then pcall(Library.Registry[flag], decoded) end
            end
        end
    end
    return true
end

function Library:ListConfigs()
    if not ensureCfg() or not listfiles then return {} end
    local ok, files = pcall(listfiles, CONFIG_FOLDER .. "/configs")
    if not ok or not files then return {} end
    local out = {}
    for _, f in ipairs(files) do
        local n = tostring(f):match("([^/\\]+)%.json$")
        if n then out[#out + 1] = n end
    end
    return out
end

function Library:SaveConfig(name)
    if not ensureCfg() then self:Notify({ Title = "Config", Text = "IO unsupported", Type = "Error" }); return false end
    local ok, err = pcall(function()
        writefile(CONFIG_FOLDER .. "/configs/" .. name .. ".json", HttpService:JSONEncode(self:GetConfig()))
    end)
    if ok then self:Notify({ Title = "Saved", Text = name, Type = "Success" }) return true end
    self:Notify({ Title = "Error", Text = tostring(err), Type = "Error" }); return false
end

function Library:LoadConfig(name)
    if not ensureCfg() then self:Notify({ Title = "Config", Text = "IO unsupported", Type = "Error" }); return false end
    local p = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(p) then self:Notify({ Title = "Not found", Text = name, Type = "Warning" }) return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(p)) end)
    if not ok then self:Notify({ Title = "Parse error", Text = "corrupt", Type = "Error" }) return false end
    self:ApplyConfig(data)
    self:Notify({ Title = "Loaded", Text = name, Type = "Success" })
    return true
end

function Library:DeleteConfig(name)
    if not ensureCfg() then return false end
    local p = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(p) then return false end
    local ok = pcall(delfile, p)
    if ok then self:Notify({ Title = "Deleted", Text = name, Type = "Success" }) end
    return ok
end

-- Toggle key (J default)
Connect(UserInputService.InputBegan, function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Library.ToggleKey then
        if not UserInputService:GetFocusedTextBox() then
            for _, w in pairs(Library.Registry) do end
            -- find a window
            for _, s in ipairs(Library.Connections) do end
            -- simpler: fire on all windows
            for _, win in ipairs(Library._Windows or {}) do win:SetVisible(not win.MainFrame.Visible) end
        end
    end
end)

Library._Windows = {}
local _origCreate = Library.CreateWindow
function Library:CreateWindow(cfg)
    local w = _origCreate(self, cfg)
    table.insert(self._Windows, w)
    return w
end

return Library
