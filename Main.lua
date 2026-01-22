-- [[ SECTION 1: CONFIGURATIONS & LOAD ]]
local user = "PAPAINOEL9643"
local repo = "hubluam"
local Logic = loadstring(game:HttpGet("https://raw.githubusercontent.com/"..user.."/"..repo.."/main/Functions.lua"))()

local Settings = Logic.Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- [[ SECTION 2: UTILITIES ]]
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- [[ SECTION 3: MAIN INTERFACE DESIGN ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_PRO_" .. math.random(100, 999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Logic.GetSafeParent()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Settings.ThemeColor; MainStroke.Thickness = 2
MakeDraggable(MainFrame)

-- Sidebar (Barra Lateral)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- [[ SECTION 4: DYNAMIC USER PROFILE ]]
local ProfileFrame = Instance.new("Frame", Sidebar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 130)
ProfileFrame.BackgroundTransparency = 1

local UserImage = Instance.new("ImageLabel", ProfileFrame)
UserImage.Size = UDim2.new(0, 65, 0, 65)
UserImage.Position = UDim2.new(0.5, -32, 0.2, 0)
UserImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
local ImgStroke = Instance.new("UIStroke", UserImage)
ImgStroke.Color = Settings.ThemeColor; ImgStroke.Thickness = 2

local UserName = Instance.new("TextLabel", ProfileFrame)
UserName.Size = UDim2.new(1, 0, 0, 20)
UserName.Position = UDim2.new(0, 0, 0.75, 0)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.DisplayName
UserName.TextColor3 = Color3.new(1,1,1)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 13

-- [[ SECTION 5: TABS SYSTEM ]]
local TabHolder = Instance.new("ScrollingFrame", Sidebar)
TabHolder.Size = UDim2.new(1, 0, 1, -140)
TabHolder.Position = UDim2.new(0, 0, 0, 135)
TabHolder.BackgroundTransparency = 1
TabHolder.ScrollBarThickness = 0
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 5); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 175, 0, 20)
PageContainer.Size = UDim2.new(1, -190, 1, -40)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false; p.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            p.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        Page.Visible = true; TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.BackgroundColor3 = Settings.ThemeColor
    end)
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- [[ SECTION 6: UI COMPONENTS ]]
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("TextButton", parent)
    Frame.Size = UDim2.new(1, -5, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.Text = "    " .. text
    Frame.Font = Enum.Font.GothamMedium
    Frame.TextColor3 = Color3.new(1,1,1)
    Frame.TextXAlignment = Enum.TextXAlignment.Left; Frame.TextSize = 14
    Instance.new("UICorner", Frame)

    local Indicator = Instance.new("Frame", Frame)
    Indicator.Position = UDim2.new(1, -45, 0.5, -10)
    Indicator.Size = UDim2.new(0, 35, 0, 20)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Indicator)
    Circle.Size = UDim2.new(0, 16, 0, 16); Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local active = false
    Frame.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = active and Settings.ThemeColor or Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.3), {Position = active and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(active)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, -5, 0, 50); SliderFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.new(1,1,1); Label.Font = Enum.Font.Gotham; Label.TextSize = 13; Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, 0, 0, 6); Bar.Position = UDim2.new(0, 0, 0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Settings.ThemeColor; Instance.new("UICorner", Fill)

    local Trigger = Instance.new("TextButton", Bar)
    Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""

    local dragging = false
    local function Update()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = Bar.AbsolutePosition.X; local barSize = Bar.AbsoluteSize.X
        local ratio = math.clamp((mousePos - barPos) / barSize, 0, 1)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        local value = math.floor(min + (max - min) * ratio)
        Label.Text = text .. ": " .. value; callback(value)
    end
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- [[ SECTION 7: CREATING CONTENT ]]
local TabInicio = CreateTab("Início")
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visual")
local TabPerf = CreateTab("Performance")

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 50); FPSLabel.Text = "Status: Online"; FPSLabel.TextColor3 = Settings.ThemeColor
FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 20; FPSLabel.BackgroundTransparency = 1

AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddSlider(TabAimbot, "Suavidade", 1, 100, 50, function(v) Settings.Smoothness = math.clamp(v/100, 0.01, 1) end)
AddToggle(TabVisual, "Ativar ESP", function(v) Settings.ESP.Enabled = v end)
AddToggle(TabVisual, "ESP Box", function(v) Settings.ESP.Box = v end)
AddToggle(TabPerf, "Boost FPS", function(v) Logic.OptimizePerformance(v) end)

-- [[ SECTION 8: RENDER LOOP ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Settings.ThemeColor; FOVCircle.Transparency = 0.5; FOVCircle.Filled = false

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Logic.CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then Logic.CreateESP(p) end end)

RunService.RenderStepped:Connect(function()
    if not Settings.Running then return end
    FOVCircle.Visible = Settings.Aimbot and not Settings.Aimbot360
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    
    if Settings.Aimbot then
        local target = Logic.GetClosest()
        local isMirando = (Settings.AimMode == "Sempre") or (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if target and isMirando then
            local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, Settings.Smoothness)
        end
    end
end)

-- [[ SECTION 9: WINDOW CONTROLS ]]
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1,0,0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextSize = 25
CloseBtn.MouseButton1Click:Connect(function() Settings.Running = false; FOVCircle:Remove(); ScreenGui:Destroy() end)

Pages["Início"].Page.Visible = true; Pages["Início"].Btn.BackgroundColor3 = Settings.ThemeColor; Pages["Início"].Btn.TextColor3 = Color3.new(1,1,1)
