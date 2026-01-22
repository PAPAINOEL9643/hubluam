-- [[ XPEL HUB ULTRA V4 - PROFESSIONAL EDITION ]]

-- [ SECTION 1: INICIALIZAÇÃO E LÓGICA ]
local user = "PAPAINOEL9643"
local repo = "hubluam"
local Logic = loadstring(game:HttpGet("https://github.com/PAPAINOEL9643/hubluam/blob/main/Functions.lua"))()

local Settings = Logic.Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MarketPlaceService = game:GetService("MarketplaceService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- [ SECTION 2: FUNÇÕES DE UTILIDADE (DRAG/ANIM) ]
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

-- [ SECTION 3: ESTRUTURA DA UI CORE ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_PRO_" .. math.random(100, 999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Logic.GetSafeParent()

-- Icone Flutuante (Minimizado)
local FloatingIcon = Instance.new("TextButton", ScreenGui)
FloatingIcon.Size = UDim2.new(0, 55, 0, 55)
FloatingIcon.Position = UDim2.new(0, 20, 0.5, 0)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingIcon.Text = "XP"
FloatingIcon.TextColor3 = Settings.ThemeColor
FloatingIcon.Font = Enum.Font.GothamBold
FloatingIcon.TextSize = 22
FloatingIcon.Visible = false
Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatingIcon).Color = Settings.ThemeColor
MakeDraggable(FloatingIcon)

-- Frame Principal
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Settings.ThemeColor
MainStroke.Thickness = 2
MakeDraggable(MainFrame)

-- Sidebar (Barra Lateral)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- [ SECTION 4: PERFIL DINÂMICO DO USUÁRIO ]
local ProfileFrame = Instance.new("Frame", Sidebar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 140)
ProfileFrame.BackgroundTransparency = 1

local UserAvatar = Instance.new("ImageLabel", ProfileFrame)
UserAvatar.Size = UDim2.new(0, 70, 0, 70)
UserAvatar.Position = UDim2.new(0.5, -35, 0.2, 0)
UserAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UserAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", UserAvatar).CornerRadius = UDim.new(1, 0)
local AvStroke = Instance.new("UIStroke", UserAvatar)
AvStroke.Color = Settings.ThemeColor
AvStroke.Thickness = 2

local UserLabel = Instance.new("TextLabel", ProfileFrame)
UserLabel.Size = UDim2.new(1, 0, 0, 30)
UserLabel.Position = UDim2.new(0, 0, 0.75, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = LocalPlayer.DisplayName
UserLabel.TextColor3 = Color3.new(1, 1, 1)
UserLabel.Font = Enum.Font.GothamBold
UserLabel.TextSize = 14

-- [ SECTION 5: SISTEMA DE ABAS ]
local TabHolder = Instance.new("ScrollingFrame", Sidebar)
TabHolder.Size = UDim2.new(1, 0, 1, -150)
TabHolder.Position = UDim2.new(0, 0, 0, 145)
TabHolder.BackgroundTransparency = 1
TabHolder.ScrollBarThickness = 0
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 185, 0, 20)
PageContainer.Size = UDim2.new(1, -200, 1, -40)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            p.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.BackgroundColor3 = Settings.ThemeColor
    end)

    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- [ SECTION 6: COMPONENTES DE INTERFACE ]
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("TextButton", parent)
    Frame.Size = UDim2.new(1, -5, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    Frame.Text = "    " .. text
    Frame.Font = Enum.Font.GothamMedium
    Frame.TextColor3 = Color3.new(1,1,1)
    Frame.TextXAlignment = Enum.TextXAlignment.Left
    Frame.TextSize = 13
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
    SliderFrame.Size = UDim2.new(1, -5, 0, 55)
    SliderFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0, 35)
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
        local ratio = math.clamp((mousePos - barPos) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        local value = math.floor(min + (max - min) * ratio)
        Label.Text = text .. ": " .. value
        callback(value)
    end
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- [ SECTION 7: CRIAÇÃO DE CONTEÚDO DINÂMICO ]
local TabInicio = CreateTab("Início")
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visual")
local TabPerf   = CreateTab("Sistema")

-- Obtendo informações do Jogo Atual
local gameInfo = MarketPlaceService:GetProductInfo(game.PlaceId)

-- Aba Início (Visual Profissional com Jogo)
local GameIcon = Instance.new("ImageLabel", TabInicio)
GameIcon.Size = UDim2.new(0, 100, 0, 100)
GameIcon.Position = UDim2.new(0.5, -50, 0, 10)
GameIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GameIcon.Image = "rbxassetid://" .. game.PlaceId -- Tenta puxar o ícone pelo ID do mapa
-- Caso rbxassetid não carregue o ícone direto, usamos uma thumbnail:
GameIcon.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..game.PlaceId.."&width=420&height=420&format=png"
Instance.new("UICorner", GameIcon).CornerRadius = UDim.new(0, 8)
local IconStroke = Instance.new("UIStroke", GameIcon)
IconStroke.Color = Settings.ThemeColor
IconStroke.Thickness = 2

local GameNameLabel = Instance.new("TextLabel", TabInicio)
GameNameLabel.Size = UDim2.new(1, 0, 0, 30)
GameNameLabel.Position = UDim2.new(0, 0, 0, 115)
GameNameLabel.BackgroundTransparency = 1
GameNameLabel.Text = gameInfo.Name -- Nome do jogo dinâmico
GameNameLabel.TextColor3 = Color3.new(1, 1, 1)
GameNameLabel.Font = Enum.Font.GothamBold
GameNameLabel.TextSize = 18

local Welcome = Instance.new("TextLabel", TabInicio)
Welcome.Size = UDim2.new(1, 0, 0, 20)
Welcome.Position = UDim2.new(0, 0, 0, 145)
Welcome.Text = "XPEL ULTRA V4 - ATIVO"
Welcome.TextColor3 = Settings.ThemeColor
Welcome.Font = Enum.Font.GothamMedium
Welcome.BackgroundTransparency = 1
Welcome.TextSize = 14

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 40)
FPSLabel.Position = UDim2.new(0, 0, 0, 170)
FPSLabel.Text = "Calculando FPS..."
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 22
FPSLabel.BackgroundTransparency = 1

-- Aba Aimbot
AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Aimbot 360º", function(v) Settings.Aimbot360 = v end)
AddSlider(TabAimbot, "Suavidade", 1, 100, 50, function(v) Settings.Smoothness = math.clamp(v/100, 0.01, 1) end)

-- Aba Visual (ESPs)
AddToggle(TabVisual, "Ativar ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(TabVisual, "ESP Box (Caixa)", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "ESP Linhas", function(v) Settings.ESP.Lines = v end)
AddToggle(TabVisual, "ESP Nomes", function(v) Settings.ESP.Names = v end)

-- Aba Performance
AddToggle(TabPerf, "Remover Texturas (Boost)", function(v) Logic.OptimizePerformance(v) end)
AddToggle(TabPerf, "Remover Sombras", function(v) Lighting.GlobalShadows = not v end)

-- [ SECTION 8: LOOP DE RENDERIZAÇÃO ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Settings.ThemeColor; FOVCircle.Transparency = 0.5; FOVCircle.Filled = false

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Logic.CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then Logic.CreateESP(p) end end)

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
                           (Settings.AimMode == "Ao Mirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        
        if target and isClicking then
            local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, Settings.Smoothness)
        end
    end
end)

-- [ SECTION 9: CONTROLES DA JANELA ]
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1,0,0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextSize = 25

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.BackgroundTransparency = 1; MinBtn.TextSize = 25

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatingIcon.Visible = true end)
FloatingIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatingIcon.Visible = false end)

CloseBtn.MouseButton1Click:Connect(function()
    Settings.Running = false
    FOVCircle:Remove()
    for _, esp in pairs(Logic.ESP_Table) do esp.Remove() end
    ScreenGui:Destroy()
end)

-- Default Page
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.BackgroundColor3 = Settings.ThemeColor
Pages["Início"].Btn.TextColor3 = Color3.new(1,1,1)
