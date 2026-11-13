
--[[
    9-bit UI
    Repo: https://github.com/satdot/9-Bit-UI
    - Green pixel gradient theme (PressStart2P)
    - OpenFrame: centered top by default, draggable
    - Smooth open/close animation, drag with tween
    - Optimized Dropdown: search + multi + outside-click close
    - ColorPicker: SV square + hue bar + hex
    - Welcome notification
]]

local Library = {}
Library.Flags = {}
Library.Theme = {}

--// Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--// Constants
local PIXEL_FONT = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local LOGO_ICON  = "rbxassetid://121387754739937"
local OPEN_ICON  = "rbxassetid://140645673217739"

--// Theme
Library.Theme = {
    GradientStart   = Color3.fromRGB(130, 240, 148),
    GradientEnd     = Color3.fromRGB(78,  144,  88),
    StrokeColor     = Color3.fromRGB(143, 239, 157),
    HolderBg        = Color3.fromRGB(35,  35,  35),
    SidebarBg       = Color3.fromRGB(0,   0,   0),
    CloseBtnBg      = Color3.fromRGB(43,  53,  44),
    CloseBtnText    = Color3.fromRGB(255, 0,   0),
    OpenBtnBg       = Color3.fromRGB(62,  77,  64),
    OpenBtnText     = Color3.fromRGB(86,  255, 0),
    Text            = Color3.fromRGB(255, 255, 255),
    SubText         = Color3.fromRGB(180, 180, 180),
    ElementBg       = Color3.fromRGB(50,  50,  55),
    ElementBgHover  = Color3.fromRGB(70,  70,  78),
    Accent          = Color3.fromRGB(130, 240, 148),
}

--// Utilities
local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function ApplyGradient(parent, c1, c2, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1 or Library.Theme.GradientStart),
            ColorSequenceKeypoint.new(1, c2 or Library.Theme.GradientEnd),
        }),
        Rotation = rotation or 106,
        Parent = parent,
    })
end

local function ApplyStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Library.Theme.StrokeColor,
        Thickness = thickness or 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function ApplyCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 4),
        Parent = parent,
    })
end

--// Smooth tweened drag
local function MakeDraggable(dragFrame, targetFrame)
    local dragStart, startPos, dragConn
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos  = targetFrame.Position
            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    local delta = inp.Position - dragStart
                    local newPos = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                    TweenService:Create(
                        targetFrame,
                        TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Position = newPos }
                    ):Play()
                end
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragConn then dragConn:Disconnect(); dragConn = nil end
        end
    end)
end

local function getExecutor()
    local ok, name = pcall(function()
        return (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname())
    end)
    if ok and type(name) == "string" and name ~= "" then return name end
    return "Unknown"
end

--// Notifications
local notificationGui
local function PushNotify(text, color)
    if not notificationGui or not notificationGui.Parent then
        notificationGui = Create("ScreenGui", {
            Name = "9BitUINotify",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
    end
    local popup = Create("Frame", {
        Size = UDim2.new(0, 220, 0, 42),
        Position = UDim2.new(0, -240, 0, 20),
        BackgroundColor3 = Library.Theme.HolderBg,
        BorderSizePixel = 0,
        Parent = notificationGui,
    })
    ApplyCorner(popup, UDim.new(0, 4))
    ApplyStroke(popup, color or Library.Theme.StrokeColor, 2)
    ApplyGradient(popup, Library.Theme.GradientStart, Library.Theme.GradientEnd, 106)
    Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Library.Theme.HolderBg,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        Parent = popup,
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = PIXEL_FONT,
        TextSize = 8,
        TextColor3 = Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = popup,
    })
    popup:TweenPosition(UDim2.new(0, 20, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.delay(4, function()
        popup:TweenPosition(UDim2.new(0, -240, 0, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
            popup:Destroy()
        end)
    end)
end
Library.Notify = PushNotify

--// CreateWindow
function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "9-Bit UI"

    local gui = Create("ScreenGui", {
        Name = "9-bit-UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui,
    })

    ------------------------------------------------------------------
    -- OPEN FRAME (centered top by default, draggable)
    ------------------------------------------------------------------
    local openFrame = Create("Frame", {
        Name = "OpenFrame",
        Size = UDim2.new(0, 355, 0, 48),
        AnchorPoint = Vector2.new(0.5, 0),  -- centered horizontally
        Position = UDim2.new(0.5, 0, 0, 20),
        BackgroundColor3 = Color3.fromRGB(60, 149, 69),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = gui,
    })
    ApplyStroke(openFrame)
    ApplyGradient(openFrame)
    ApplyCorner(openFrame, UDim.new(0, 2))

    local openIcon = Create("ImageLabel", {
        Name = "icon",
        Size = UDim2.new(0, 59, 0, 47),
        Position = UDim2.new(0.83164, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = OPEN_ICON,
        BorderSizePixel = 0,
        Parent = openFrame,
    })
    ApplyGradient(openIcon)
    ApplyStroke(openIcon)

    local openBtn = Create("TextButton", {
        Name = "OpenButton",
        Size = UDim2.new(0, 34, 0, 33),
        Position = UDim2.new(0.04466, 0, 0.13167, 0),
        BackgroundColor3 = Library.Theme.OpenBtnBg,
        Text = "+",
        Font = PIXEL_FONT,
        TextSize = 14,
        TextColor3 = Library.Theme.OpenBtnText,
        BorderSizePixel = 0,
        Parent = openFrame,
    })
    ApplyStroke(openBtn)
    ApplyCorner(openBtn, UDim.new(0, 2))

    local openLabel = Create("TextLabel", {
        Name = "UiName",
        Size = UDim2.new(0, 160, 0, 51),
        Position = UDim2.new(0.31991, 0, -0.04833, 0),
        BackgroundTransparency = 1,
        Text = windowTitle,
        Font = PIXEL_FONT,
        TextSize = 14,
        TextScaled = true,
        TextColor3 = Library.Theme.Text,
        TextWrapped = true,
        Parent = openFrame,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = openLabel,
    })

    -- Draggable openFrame
    MakeDraggable(openFrame, openFrame)

    ------------------------------------------------------------------
    -- MAIN FRAME
    ------------------------------------------------------------------
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 504, 0, 448),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = gui,
        Visible = false,
    })
    ApplyStroke(mainFrame)
    ApplyGradient(mainFrame)
    ApplyCorner(mainFrame, UDim.new(0, 4))

    local holder = Create("Frame", {
        Name = "Holder",
        Size = UDim2.new(0, 475, 0, 423),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.HolderBg,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    ApplyStroke(holder)
    ApplyGradient(holder)
    ApplyCorner(holder, UDim.new(0, 3))

    local topbar = Create("Frame", {
        Name = "topbar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = holder,
    })

    local titleLabel = Create("TextLabel", {
        Name = "UiName",
        Size = UDim2.new(0, 160, 0, 51),
        Position = UDim2.new(0.13963, 0, 0.16, 0),
        BackgroundTransparency = 1,
        Text = windowTitle,
        Font = PIXEL_FONT,
        TextSize = 14,
        TextScaled = true,
        TextColor3 = Library.Theme.Text,
        TextWrapped = true,
        Parent = topbar,
    })

    local logo = Create("ImageLabel", {
        Size = UDim2.new(0, 52, 0, 51),
        Position = UDim2.new(0.01474, 0, 0.16, 0),
        BackgroundTransparency = 1,
        Image = LOGO_ICON,
        BorderSizePixel = 0,
        Parent = topbar,
    })
    ApplyStroke(logo)
    ApplyGradient(logo)

    local execLabel = Create("TextLabel", {
        Name = "ExecutorName",
        Size = UDim2.new(0, 160, 0, 33),
        Position = UDim2.new(0.54384, 0, 0.34, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        Text = "Executor: " .. getExecutor(),
        Font = PIXEL_FONT,
        TextSize = 8,
        TextScaled = true,
        TextColor3 = Library.Theme.Text,
        TextWrapped = true,
        BorderSizePixel = 0,
        Parent = topbar,
    })
    ApplyStroke(execLabel)
    ApplyCorner(execLabel, UDim.new(0, 2))

    local closeBtn = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 34, 0, 33),
        Position = UDim2.new(0.91226, 0, 0.34, 0),
        BackgroundColor3 = Library.Theme.CloseBtnBg,
        Text = "X",
        Font = PIXEL_FONT,
        TextSize = 12,
        TextColor3 = Library.Theme.CloseBtnText,
        BorderSizePixel = 0,
        Parent = topbar,
    })
    ApplyStroke(closeBtn)
    ApplyGradient(closeBtn)
    ApplyCorner(closeBtn, UDim.new(0, 2))

    MakeDraggable(topbar, mainFrame)

    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "SideBar",
        Size = UDim2.new(0, 120, 1, -70),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Library.Theme.SidebarBg,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Parent = holder,
    })
    ApplyGradient(sidebar)
    ApplyCorner(sidebar, UDim.new(0, 2))

    local tabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.StrokeColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabScroll,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = tabScroll,
    })

    -- Player info
    local playerInfo = Create("Frame", {
        Name = "PlayerInfo",
        Size = UDim2.new(0, 120, 0, 70),
        Position = UDim2.new(0, 0, 1, -70),
        BackgroundColor3 = Library.Theme.SidebarBg,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    ApplyCorner(playerInfo, UDim.new(0, 2))

    local playerIcon = Create("ImageLabel", {
        Name = "PlayerIconSkin",
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0.06667, 0, 0.24286, 0),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        BorderSizePixel = 0,
        Parent = playerInfo,
    })
    ApplyStroke(playerIcon)
    ApplyCorner(playerIcon, UDim.new(0, 2))

    local playerName = Create("TextLabel", {
        Name = "PlayerNickname",
        Size = UDim2.new(0, 67, 0, 38),
        Position = UDim2.new(0.43533, 0, 0.24286, 0),
        BackgroundTransparency = 1,
        Text = "Hello - " .. LocalPlayer.Name,
        Font = PIXEL_FONT,
        TextSize = 7,
        TextScaled = true,
        TextColor3 = Library.Theme.Text,
        TextWrapped = true,
        Parent = playerInfo,
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
        Parent = playerName,
    })

    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and content then playerIcon.Image = content end
    end)

    local pageFrame = Create("Frame", {
        Name = "Pageframe",
        Size = UDim2.new(1, -128, 1, -70),
        Position = UDim2.new(0, 124, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = holder,
    })

    ------------------------------------------------------------------
    -- Open / close logic (position follows openFrame)
    ------------------------------------------------------------------
    local function openWindow()
        local openAbs = openFrame.AbsolutePosition
        local openSize = openFrame.AbsoluteSize
        -- Center of mainFrame on openFrame's horizontal center, top at openFrame's Y
        local centerX = openAbs.X + openSize.X / 2
        local topY    = openAbs.Y
        local centerY = topY + 448 / 2

        openFrame.Visible = false
        mainFrame.Visible = true
        mainFrame.Position = UDim2.new(0, centerX, 0, centerY)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 504, 0, 448),
        }):Play()
    end

    local function closeWindow()
        local absPos = mainFrame.AbsolutePosition
        local absSize = mainFrame.AbsoluteSize
        local centerAbsX = absPos.X + absSize.X / 2
        local topAbsY    = absPos.Y

        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.delay(0.2, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 504, 0, 448)
            openFrame.Visible = true
            -- Place openFrame so its top-center matches mainFrame's top-center
            openFrame.Position = UDim2.new(0, centerAbsX, 0, topAbsY)
        end)
    end

    openBtn.MouseButton1Click:Connect(openWindow)
    closeBtn.MouseButton1Click:Connect(closeWindow)

    ------------------------------------------------------------------
    -- Tab system
    ------------------------------------------------------------------
    local tabs = {}
    local activePage
    local tabCount = 0

    local window = { Gui = gui, MainFrame = mainFrame, OpenFrame = openFrame }

    function window:CreateTab(name)
        tabCount = tabCount + 1
        local page = Create("Frame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pageFrame,
        })

        local scroll = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.StrokeColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroll,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            Parent = scroll,
        })

        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Library.Theme.ElementBg,
            Text = name,
            Font = PIXEL_FONT,
            TextSize = 7,
            TextColor3 = Library.Theme.Text,
            BorderSizePixel = 0,
            LayoutOrder = tabCount,
            Parent = tabScroll,
        })
        ApplyStroke(tabBtn, Library.Theme.StrokeColor, 1)
        ApplyCorner(tabBtn, UDim.new(0, 2))

        local function activate()
            for _, t in pairs(tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = Library.Theme.ElementBg
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Library.Theme.GradientEnd
            activePage = page
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if page ~= activePage then tabBtn.BackgroundColor3 = Library.Theme.ElementBgHover end
        end)
        tabBtn.MouseLeave:Connect(function()
            if page ~= activePage then tabBtn.BackgroundColor3 = Library.Theme.ElementBg end
        end)

        local tab = { Name = name, Page = page, Btn = tabBtn, Scroll = scroll }
        tabs[#tabs + 1] = tab
        if #tabs == 1 then activate() end

        ------------------------------------------------------------------
        -- Section
        ------------------------------------------------------------------
        function tab:AddSection(sectionName)
            local section = {}
            local sectionFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 32),
                BackgroundColor3 = Library.Theme.HolderBg,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Parent = scroll,
            })
            ApplyStroke(sectionFrame, Library.Theme.StrokeColor, 1)
            ApplyGradient(sectionFrame, Library.Theme.GradientStart, Library.Theme.GradientEnd, 106)
            ApplyCorner(sectionFrame, UDim.new(0, 2))

            local overlay = Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Library.Theme.HolderBg,
                BackgroundTransparency = 0.55,
                BorderSizePixel = 0,
                Parent = sectionFrame,
            })
            ApplyCorner(overlay, UDim.new(0, 2))

            Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 22),
                Position = UDim2.new(0, 8, 0, 4),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = PIXEL_FONT,
                TextSize = 8,
                TextColor3 = Library.Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame,
            })

            local container = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 28),
                BackgroundTransparency = 1,
                Parent = sectionFrame,
            })
            local layout = Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = container,
            })
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                Parent = container,
            })

            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, -8, 0, 28 + layout.AbsoluteContentSize.Y + 8)
            end)

            ------------------------------------------------------------------
            -- Toggle
            ------------------------------------------------------------------
            function section:AddToggle(cfg)
                cfg = cfg or {}
                local flag = cfg.Flag or cfg.Name or "toggle"
                local state = cfg.Default or false

                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                ApplyCorner(row, UDim.new(0, 2))
                ApplyStroke(row, Library.Theme.StrokeColor, 1)

                Create("TextLabel", {
                    Size = UDim2.new(1, -56, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Toggle",
                    Font = PIXEL_FONT,
                    TextSize = 7,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = row,
                })

                local switch = Create("TextButton", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -52, 0.5, -11),
                    BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ElementBgHover,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = row,
                })
                ApplyCorner(switch, UDim.new(0, 2))
                ApplyStroke(switch, Library.Theme.StrokeColor, 1)

                local knob = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = switch,
                })
                ApplyCorner(knob, UDim.new(0, 1))

                local function setState(ns, doCb)
                    state = ns
                    Library.Flags[flag] = state
                    TweenService:Create(switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ElementBgHover,
                    }):Play()
                    TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    }):Play()
                    if doCb and cfg.Callback then cfg.Callback(state) end
                end

                switch.MouseButton1Click:Connect(function() setState(not state, true) end)
                Library.Flags[flag] = state
                return row
            end

            ------------------------------------------------------------------
            -- Slider
            ------------------------------------------------------------------
            function section:AddSlider(cfg)
                cfg = cfg or {}
                local flag = cfg.Flag or cfg.Name or "slider"
                local min  = cfg.Min or 0
                local max  = cfg.Max or 100
                local value = cfg.Default or min

                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                ApplyCorner(row, UDim.new(0, 2))
                ApplyStroke(row, Library.Theme.StrokeColor, 1)

                local lbl = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 16),
                    Position = UDim2.new(0, 8, 0, 4),
                    BackgroundTransparency = 1,
                    Text = (cfg.Name or "Slider") .. ": " .. tostring(value),
                    Font = PIXEL_FONT,
                    TextSize = 7,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local barBg = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 8),
                    Position = UDim2.new(0, 8, 0, 24),
                    BackgroundColor3 = Library.Theme.SidebarBg,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                ApplyCorner(barBg, UDim.new(0, 1))

                local fill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = barBg,
                })
                ApplyCorner(fill, UDim.new(0, 1))
                ApplyGradient(fill, Library.Theme.GradientStart, Library.Theme.GradientEnd, 0)

                local dragging = false
                local function update(x)
                    local rel = math.clamp((x - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
                    value = math.floor(min + (max - min) * rel + 0.5)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    lbl.Text = (cfg.Name or "Slider") .. ": " .. tostring(value)
                    Library.Flags[flag] = value
                    if cfg.Callback then cfg.Callback(value) end
                end

                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                Library.Flags[flag] = value
                return row
            end

            ------------------------------------------------------------------
            -- Button
            ------------------------------------------------------------------
            function section:AddButton(cfg)
                cfg = cfg or {}
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    Text = cfg.Name or "Button",
                    Font = PIXEL_FONT,
                    TextSize = 8,
                    TextColor3 = Library.Theme.Text,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                ApplyCorner(btn, UDim.new(0, 2))
                ApplyStroke(btn, Library.Theme.StrokeColor, 1)
                ApplyGradient(btn, Library.Theme.GradientStart, Library.Theme.GradientEnd, 106)

                local ov = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    BackgroundTransparency = 0.55,
                    BorderSizePixel = 0,
                    Parent = btn,
                })
                ApplyCorner(ov, UDim.new(0, 2))

                btn.MouseEnter:Connect(function()
                    TweenService:Create(ov, TweenInfo.new(0.15), { BackgroundTransparency = 0.25 }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(ov, TweenInfo.new(0.15), { BackgroundTransparency = 0.55 }):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then cfg.Callback() end
                end)
                return btn
            end

            ------------------------------------------------------------------
            -- ColorPicker
            ------------------------------------------------------------------
            function section:AddColorPicker(cfg)
                cfg = cfg or {}
                local flag = cfg.Flag or cfg.Name or "color"
                local color = cfg.Default or Library.Theme.Accent
                local h, s, v = Color3.toHSV(color)

                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                ApplyCorner(row, UDim.new(0, 2))
                ApplyStroke(row, Library.Theme.StrokeColor, 1)

                Create("TextLabel", {
                    Size = UDim2.new(1, -64, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Color",
                    Font = PIXEL_FONT,
                    TextSize = 7,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = row,
                })

                local preview = Create("TextButton", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -52, 0.5, -11),
                    BackgroundColor3 = color,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = row,
                })
                ApplyCorner(preview, UDim.new(0, 2))
                ApplyStroke(preview, Library.Theme.StrokeColor, 1)

                local popup
                local function commit()
                    color = Color3.fromHSV(h, s, v)
                    preview.BackgroundColor3 = color
                    Library.Flags[flag] = color
                    if cfg.Callback then cfg.Callback(color) end
                end
                local function destroyPopup()
                    if popup then popup:Destroy(); popup = nil end
                end

                local function buildPopup()
                    destroyPopup()
                    local px = preview.AbsolutePosition
                    popup = Create("Frame", {
                        Name = "ColorPopup",
                        Size = UDim2.new(0, 190, 0, 240),
                        Position = UDim2.new(0, px.X - 100, 0, px.Y + 30),
                        BackgroundColor3 = Library.Theme.HolderBg,
                        BorderSizePixel = 0,
                        Parent = gui,
                        ZIndex = 50,
                    })
                    ApplyCorner(popup, UDim.new(0, 4))
                    ApplyStroke(popup, Library.Theme.StrokeColor, 2)
                    ApplyGradient(popup, Library.Theme.GradientStart, Library.Theme.GradientEnd, 106)
                    local popOv = Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Library.Theme.HolderBg,
                        BackgroundTransparency = 0.1,
                        BorderSizePixel = 0,
                        Parent = popup,
                        ZIndex = 50,
                    })
                    ApplyCorner(popOv, UDim.new(0, 4))

                    Create("TextLabel", {
                        Size = UDim2.new(1, -16, 0, 16),
                        Position = UDim2.new(0, 8, 0, 6),
                        BackgroundTransparency = 1,
                        Text = "Color Picker",
                        Font = PIXEL_FONT,
                        TextSize = 8,
                        TextColor3 = Library.Theme.Accent,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = popup,
                        ZIndex = 51,
                    })

                    local svSquare = Create("Frame", {
                        Size = UDim2.new(0, 174, 0, 140),
                        Position = UDim2.new(0, 8, 0, 28),
                        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                        BorderSizePixel = 0,
                        Parent = popup,
                        ZIndex = 51,
                    })
                    ApplyCorner(svSquare, UDim.new(0, 2))

                    local satOverlay = Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Parent = svSquare,
                        ZIndex = 52,
                    })
                    Create("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                        Parent = satOverlay,
                    })

                    local valOverlay = Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        Parent = svSquare,
                        ZIndex = 53,
                    })
                    Create("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0),
                        }),
                        Rotation = 90,
                        Parent = valOverlay,
                    })

                    local svMarker = Create("Frame", {
                        Size = UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(s, 0, 1 - v, 0),
                        Parent = svSquare,
                        ZIndex = 54,
                    })
                    ApplyCorner(svMarker, UDim.new(1, 0))
                    ApplyStroke(svMarker, Color3.new(0, 0, 0), 1)

                    local svDragging = false
                    local function svUpdate(x, y)
                        s = math.clamp((x - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
                        svMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                        commit()
                    end
                    svSquare.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            svDragging = true
                            svUpdate(input.Position.X, input.Position.Y)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                            svUpdate(input.Position.X, input.Position.Y)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            svDragging = false
                        end
                    end)

                    local hueBar = Create("Frame", {
                        Size = UDim2.new(0, 174, 0, 14),
                        Position = UDim2.new(0, 8, 0, 174),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Parent = popup,
                        ZIndex = 51,
                    })
                    ApplyCorner(hueBar, UDim.new(0, 2))
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
                        }),
                        Parent = hueBar,
                    })

                    local hueMarker = Create("Frame", {
                        Size = UDim2.new(0, 6, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(h, 0, 0, 0),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Parent = hueBar,
                        ZIndex = 54,
                    })
                    ApplyCorner(hueMarker, UDim.new(0, 1))
                    ApplyStroke(hueMarker, Color3.new(0, 0, 0), 1)

                    local hueDragging = false
                    local function hueUpdate(x)
                        h = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                        hueMarker.Position = UDim2.new(h, 0, 0, 0)
                        svSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        commit()
                    end
                    hueBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = true
                            hueUpdate(input.Position.X)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                            hueUpdate(input.Position.X)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = false
                        end
                    end)

                    local swatch = Create("Frame", {
                        Size = UDim2.new(0, 40, 0, 24),
                        Position = UDim2.new(0, 8, 0, 200),
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        Parent = popup,
                        ZIndex = 51,
                    })
                    ApplyCorner(swatch, UDim.new(0, 2))
                    ApplyStroke(swatch, Library.Theme.StrokeColor, 1)

                    local hexLabel = Create("TextLabel", {
                        Size = UDim2.new(0, 120, 0, 24),
                        Position = UDim2.new(0, 56, 0, 200),
                        BackgroundTransparency = 1,
                        Text = string.format("#%02X%02X%02X",
                            math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)),
                        Font = PIXEL_FONT,
                        TextSize = 8,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = popup,
                        ZIndex = 51,
                    })

                    local origCommit = commit
                    commit = function()
                        origCommit()
                        swatch.BackgroundColor3 = color
                        hexLabel.Text = string.format("#%02X%02X%02X",
                            math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
                    end
                end

                preview.MouseButton1Click:Connect(function()
                    if popup then destroyPopup() else buildPopup() end
                end)
                return row
            end

            ------------------------------------------------------------------
            -- Dropdown (optimized: search + multi + outside-close)
            ------------------------------------------------------------------
            function section:AddDropdown(cfg)
                cfg = cfg or {}
                local flag = cfg.Flag or cfg.Name or "dropdown"
                local options = cfg.Options or {}
                local multi = cfg.Multi or false

                local current
                if multi then
                    current = {}
                    if cfg.Default then
                        if type(cfg.Default) == "table" then
                            for _, v in ipairs(cfg.Default) do current[v] = true end
                        else
                            current[cfg.Default] = true
                        end
                    end
                else
                    current = cfg.Default or options[1]
                end

                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                ApplyCorner(row, UDim.new(0, 2))
                ApplyStroke(row, Library.Theme.StrokeColor, 1)

                Create("TextLabel", {
                    Size = UDim2.new(0.5, -8, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Dropdown",
                    Font = PIXEL_FONT,
                    TextSize = 7,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local valueLabel = Create("TextLabel", {
                    Size = UDim2.new(0.5, -34, 1, 0),
                    Position = UDim2.new(0.5, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Font = PIXEL_FONT,
                    TextSize = 7,
                    TextColor3 = Library.Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "v",
                    Font = PIXEL_FONT,
                    TextSize = 8,
                    TextColor3 = Library.Theme.Text,
                    Parent = row,
                })

                local clickBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                })

                local function summarize()
                    if multi then
                        local picked = {}
                        for opt, on in pairs(current) do
                            if on then picked[#picked + 1] = opt end
                        end
                        if #picked == 0 then return "None" end
                        if #picked == 1 then return picked[1] end
                        return picked[1] .. " +" .. (#picked - 1)
                    end
                    return current or "None"
                end

                local function commit()
                    if multi then
                        local t = {}
                        for opt, on in pairs(current) do
                            if on then t[#t + 1] = opt end
                        end
                        Library.Flags[flag] = t
                        if cfg.Callback then cfg.Callback(t) end
                    else
                        Library.Flags[flag] = current
                        if cfg.Callback then cfg.Callback(current) end
                    end
                    valueLabel.Text = summarize()
                end
                commit()

                local listFrame, outsideConn

                local function closeList()
                    if listFrame then listFrame:Destroy(); listFrame = nil end
                    if outsideConn then outsideConn:Disconnect(); outsideConn = nil end
                    arrow.Text = "v"
                end

                local function buildList()
                    local abs = row.AbsolutePosition
                    local sz  = row.AbsoluteSize
                    listFrame = Create("Frame", {
                        Size = UDim2.new(0, sz.X, 0, 180),
                        Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 2),
                        BackgroundColor3 = Library.Theme.HolderBg,
                        BorderSizePixel = 0,
                        Parent = gui,
                        ZIndex = 60,
                    })
                    ApplyCorner(listFrame, UDim.new(0, 3))
                    ApplyStroke(listFrame, Library.Theme.StrokeColor, 2)
                    ApplyGradient(listFrame, Library.Theme.GradientStart, Library.Theme.GradientEnd, 106)

                    local popOv = Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Library.Theme.HolderBg,
                        BackgroundTransparency = 0.05,
                        BorderSizePixel = 0,
                        Parent = listFrame,
                        ZIndex = 60,
                    })
                    ApplyCorner(popOv, UDim.new(0, 3))

                    local searchBox = Create("TextBox", {
                        Size = UDim2.new(1, -8, 0, 22),
                        Position = UDim2.new(0, 4, 0, 4),
                        BackgroundColor3 = Library.Theme.SidebarBg,
                        BackgroundTransparency = 0.3,
                        Text = "",
                        PlaceholderText = "Search...",
                        PlaceholderColor3 = Library.Theme.SubText,
                        Font = PIXEL_FONT,
                        TextSize = 8,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false,
                        Parent = listFrame,
                        ZIndex = 61,
                    })
                    ApplyCorner(searchBox, UDim.new(0, 2))
                    Create("UIPadding", { PaddingLeft = UDim.new(0, 4), Parent = searchBox })

                    local scroll = Create("ScrollingFrame", {
                        Size = UDim2.new(1, -8, 1, -34),
                        Position = UDim2.new(0, 4, 0, 30),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Library.Theme.StrokeColor,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        Parent = listFrame,
                        ZIndex = 61,
                    })
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = scroll,
                    })

                    local rendered = {}
                    local function clearRendered()
                        for _, b in ipairs(rendered) do b:Destroy() end
                        rendered = {}
                    end

                    local function render(filter)
                        clearRendered()
                        local f = string.lower(filter or "")
                        for i, opt in ipairs(options) do
                            if f == "" or string.find(string.lower(opt), f, 1, true) then
                                local isSel = multi and current[opt] or (current == opt)
                                local b = Create("TextButton", {
                                    Size = UDim2.new(1, 0, 0, 24),
                                    BackgroundColor3 = isSel and Library.Theme.GradientEnd or Library.Theme.ElementBg,
                                    BackgroundTransparency = isSel and 0.3 or 0,
                                    Text = opt,
                                    Font = PIXEL_FONT,
                                    TextSize = 7,
                                    TextColor3 = isSel and Library.Theme.Accent or Library.Theme.Text,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    TextTruncate = Enum.TextTruncate.AtEnd,
                                    BorderSizePixel = 0,
                                    LayoutOrder = i,
                                    Parent = scroll,
                                    ZIndex = 61,
                                })
                                ApplyCorner(b, UDim.new(0, 2))
                                ApplyStroke(b, Library.Theme.StrokeColor, 1)
                                Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = b })

                                b.MouseEnter:Connect(function()
                                    if not isSel then b.BackgroundColor3 = Library.Theme.ElementBgHover end
                                end)
                                b.MouseLeave:Connect(function()
                                    b.BackgroundColor3 = isSel and Library.Theme.GradientEnd or Library.Theme.ElementBg
                                end)
                                b.MouseButton1Click:Connect(function()
                                    if multi then
                                        if current[opt] then current[opt] = nil else current[opt] = true end
                                        commit()
                                        render(searchBox.Text)
                                    else
                                        current = opt
                                        commit()
                                        closeList()
                                    end
                                end)
                                rendered[#rendered + 1] = b
                            end
                        end
                    end

                    render("")
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        render(searchBox.Text)
                    end)

                    -- Click-outside detection
                    outsideConn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            local pos = input.Position
                            local lp = listFrame and listFrame.AbsolutePosition or Vector2.new(-1, -1)
                            local ls = listFrame and listFrame.AbsoluteSize or Vector2.new(0, 0)
                            local rp = row.AbsolutePosition
                            local rs = row.AbsoluteSize
                            local inList = pos.X >= lp.X and pos.X <= lp.X + ls.X
                                         and pos.Y >= lp.Y and pos.Y <= lp.Y + ls.Y
                            local inRow  = pos.X >= rp.X and pos.X <= rp.X + rs.X
                                         and pos.Y >= rp.Y and pos.Y <= rp.Y + rs.Y
                            if not inList and not inRow then closeList() end
                        end
                    end)
                end

                clickBtn.MouseButton1Click:Connect(function()
                    if listFrame then
                        closeList()
                    else
                        buildList()
                        arrow.Text = "^"
                    end
                end)

                return row
            end

            return section
        end

        return tab
    end

    -- Welcome
    task.delay(0.4, function()
        PushNotify("Welcome, " .. LocalPlayer.Name .. "!")
    end)

    return window
end

return Library
