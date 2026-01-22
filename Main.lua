-- [[ XPEL HUB - UI ENGINE ]]
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

-- ================= FUNÇÃO DE ARRASTAR =================
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
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

-- ================= UI CORE DESIGN =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_" .. math.random(100, 999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Logic.GetSafeParent()

local FloatingIcon = Instance.new("TextButton", ScreenGui)
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Position = UDim2.new(0, 20, 0.5, 0)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingIcon.Text = "XP"
FloatingIcon.TextColor3 = Settings.ThemeColor
FloatingIcon.Font = Enum.Font.GothamBold
FloatingIcon.TextSize = 20
FloatingIcon.Visible = false
Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", FloatingIcon)
IconStroke.Color = Settings.ThemeColor
IconStroke.Thickness = 2
MakeDraggable(FloatingIcon)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 420) 
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Settings.ThemeColor
MainStroke.Thickness = 1.5
MakeDraggable(MainFrame)

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(1, 0, 0, 45)
TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 15, 0, 60)
PageContainer.Size = UDim2.new(1, -30, 1, -75)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name, order)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 12
    TabBtn.LayoutOrder = order

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false 
            p.Btn.TextColor3 = Color3.fromRGB(150,150,150) 
        end
        Page.Visible = true
        TabBtn.TextColor3 = Settings.ThemeColor
    end)

    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- Componentes de UI (Toggle/Slider)
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("TextButton", parent)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.Text = "    " .. text
    Frame.Font = Enum.Font.GothamMedium
    Frame.TextColor3 = Color3.new(1,1,1)
    Frame.TextXAlignment = Enum.TextXAlignment.Left
    Frame.TextSize = 14
    Instance.new("UICorner", Frame)

    local Indicator = Instance.new("Frame", Frame)
    Indicator.Position = UDim2.new(1, -45, 0.5, -10)
    Indicator.Size = UDim2.new(0, 35, 0, 20)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Indicator)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
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
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Settings.ThemeColor
    Instance.new("UICorner", Fill)

    local Trigger = Instance.new("TextButton", Bar)
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""

    local dragging = false
    local function Update()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = Bar.AbsolutePosition.X
        local barSize = Bar.AbsoluteSize.X
        local ratio = math.clamp((mousePos - barPos) / barSize, 0, 1)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        local value = math.floor(min + (max - min) * ratio)
        Label.Text = text .. ": " .. value
        callback(value)
    end
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- ================= CRIAÇÃO DAS ABAS =================
local TabInicio = CreateTab("Início", 1)
local TabAimbot = CreateTab("Aimbot", 2)
local TabVisual = CreateTab("Visual", 3)
local TabPerf = CreateTab("Performance", 4)
local TabAjustes = CreateTab("Temas", 5)

-- ABA INÍCIO
local Welcome = Instance.new("TextLabel", TabInicio)
Welcome.Size = UDim2.new(1, 0, 0, 30)
Welcome.Text = "Bem-vindo ao xPel Ultra V4"
Welcome.TextColor3 = Color3.new(1,1,1)
Welcome.Font = Enum.Font.GothamBold
Welcome.BackgroundTransparency = 1

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 50)
FPSLabel.Text = "Calculando FPS..."
FPSLabel.TextColor3 = Settings.ThemeColor
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 25
FPSLabel.BackgroundTransparency = 1

-- ABA AIMBOT
AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)

local TargetPartBtn = Instance.new("TextButton", TabAimbot)
TargetPartBtn.Size = UDim2.new(1, -10, 0, 40)
TargetPartBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TargetPartBtn.Text = "GRUDAR EM: CABEÇA"
TargetPartBtn.TextColor3 = Color3.new(1,1,1)
TargetPartBtn.Font = Enum.Font.GothamBold
TargetPartBtn.TextSize = 14
Instance.new("UICorner", TargetPartBtn)

TargetPartBtn.MouseButton1Click:Connect(function()
    if Settings.TargetPart == "Head" then
        Settings.TargetPart = "HumanoidRootPart"
        TargetPartBtn.Text = "GRUDAR EM: PEITO"
    else
        Settings.TargetPart = "Head"
        TargetPartBtn.Text = "GRUDAR EM: CABEÇA"
    end
end)

AddSlider(TabAimbot, "Força da Grudada", 1, 100, 50, function(v)
    Settings.VisualSmoothness = v
    Settings.Smoothness = math.clamp(v / 100, 0.01, 1)
end)

AddToggle(TabAimbot, "Aimbot 360º (Ignora Campo de Visão)", function(v) Settings.Aimbot360 = v end)

local ModeBtn = Instance.new("TextButton", TabAimbot)
ModeBtn.Size = UDim2.new(1, -10, 0, 40)
ModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ModeBtn.Text = "MODO: " .. Settings.AimMode
ModeBtn.TextColor3 = Color3.new(1,1,1)
ModeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ModeBtn)

local modes = {"Sempre", "Ao Mirar", "Ao Atirar"}
local curIdx = 1
ModeBtn.MouseButton1Click:Connect(function()
    curIdx = curIdx + 1
    if curIdx > #modes then curIdx = 1 end
    Settings.AimMode = modes[curIdx]
    ModeBtn.Text = "MODO: " .. Settings.AimMode
end)

-- ABA PERFORMANCE
AddToggle(TabPerf, "Remover Texturas (Boost FPS)", function(v) Logic.OptimizePerformance(v) end)
AddToggle(TabPerf, "Remover Sombras", function(v) Lighting.GlobalShadows = not v end)

-- ABA VISUAL
AddToggle(TabVisual, "Ativar ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(TabVisual, "ESP Box (Caixa)", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "ESP Linhas", function(v) Settings.ESP.Lines = v end)
AddToggle(TabVisual, "ESP Nomes", function(v) Settings.ESP.Names = v end)

-- ================= RENDER LOOP =================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Settings.ThemeColor
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false

for _, p in ipairs(Players:GetPlayers()) do if p ~= Players.LocalPlayer then Logic.CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= Players.LocalPlayer then Logic.CreateESP(p) end end)

RunService.RenderStepped:Connect(function()
    if not Settings.Running then return end
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    FPSLabel.Text = fps .. " FPS"
    FOVCircle.Visible = Settings.Aimbot and not Settings.Aimbot360
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    
    if Settings.Aimbot then
        local target = Logic.GetClosest()
        local isClicking = (Settings.AimMode == "Sempre") or 
                           (Settings.AimMode == "Ao Mirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or
                           (Settings.AimMode == "Ao Atirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
        
        if target and isClicking then
            local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, Settings.Smoothness)
        end
    end
end)

-- ================= CONTROLES DE JANELA =================
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1,0,0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextSize = 25

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 7)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.BackgroundTransparency = 1; MinBtn.TextSize = 25

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatingIcon.Visible = true end)
FloatingIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatingIcon.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
    Settings.Running = false; FOVCircle:Remove()
    for _, esp in pairs(Logic.ESP_Table) do esp.Remove() end
    ScreenGui:Destroy()
end)

Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Settings.ThemeColor
