-- [[ XPEL HUB - ULTRA V4 PROFESSIONAL UI ]]
local user = "PAPAINOEL9643"
local repo = "hubluam"

-- Carregamento da Lógica Externa
local success, Logic = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/"..user.."/"..repo.."/main/Functions.lua"))()
end)

if not success then 
    warn("Erro ao carregar Logic: " .. tostring(Logic))
    return 
end

local Settings = Logic.Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ================= FUNÇÃO DE ARRASTAR =================
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

-- ================= UI DESIGN PROFESSIONAL =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_V4_" .. math.random(100, 999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Logic.GetSafeParent()

-- Menu Principal
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Settings.ThemeColor; MainStroke.Thickness = 1.8
MakeDraggable(MainFrame)

-- Sidebar (Lateral)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- Perfil do Usuário (Dinamico)
local UserFrame = Instance.new("Frame", Sidebar)
UserFrame.Size = UDim2.new(1, 0, 0, 140)
UserFrame.BackgroundTransparency = 1

local UserImage = Instance.new("ImageLabel", UserFrame)
UserImage.Size = UDim2.new(0, 70, 0, 70)
UserImage.Position = UDim2.new(0.5, -35, 0.2, 0)
UserImage.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
-- Puxa a foto de quem está usando:
UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
local ImgStroke = Instance.new("UIStroke", UserImage)
ImgStroke.Color = Settings.ThemeColor; ImgStroke.Thickness = 2

local UserName = Instance.new("TextLabel", UserFrame)
UserName.Size = UDim2.new(1, 0, 0, 30)
UserName.Position = UDim2.new(0, 0, 0.75, 0)
UserName.BackgroundTransparency = 1
UserName.Text = "Olá, " .. LocalPlayer.DisplayName
UserName.TextColor3 = Color3.new(1,1,1)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 14

-- Container de Abas
local TabHolder = Instance.new("Frame", Sidebar)
TabHolder.Size = UDim2.new(1, -10, 1, -150)
TabHolder.Position = UDim2.new(0, 5, 0, 140)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 5); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Page Container
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 170, 0, 20)
PageContainer.Size = UDim2.new(1, -180, 1, -40)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 2, 0)
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false
            p.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            p.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Settings.ThemeColor
        TabBtn.TextColor3 = Color3.new(1,1,1)
    end)

    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- Componentes de UI Melhorados
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 40, 0, 22)
    Btn.Position = UDim2.new(1, -50, 0.5, -11)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = active and Settings.ThemeColor or Color3.fromRGB(45, 45, 50)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        callback(active)
    end)
end

-- ================= CRIAÇÃO DAS ABAS =================
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visuals")
local TabPerformance = CreateTab("System")

-- ABA AIMBOT
AddToggle(TabAimbot, "Ativar Master Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Ignorar FOV (360)", function(v) Settings.Aimbot360 = v end)

-- ABA VISUAL
AddToggle(TabVisual, "Master ESP", function(v) Settings.ESP.Enabled = v end)
AddToggle(TabVisual, "Show Box", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "Show Names", function(v) Settings.ESP.Names = v end)

-- ABA SYSTEM
AddToggle(TabPerformance, "FPS Boost", function(v) Logic.OptimizePerformance(v) end)

-- ================= RENDER LOOP (FINAL) =================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Color = Settings.ThemeColor; FOVCircle.Transparency = 0.7; FOVCircle.Filled = false

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Logic.CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then Logic.CreateESP(p) end end)

RunService.RenderStepped:Connect(function()
    if not Settings.Running then return end
    
    FOVCircle.Visible = Settings.Aimbot and not Settings.Aimbot360
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    
    if Settings.Aimbot then
        local target = Logic.GetClosest()
        local isClicking = (Settings.AimMode == "Sempre") or 
                           (Settings.AimMode == "Ao Mirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        
        if target and isClicking then
            local targetPos = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetPos, Settings.Smoothness)
        end
    end
end)

-- Botão Fechar
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "×"; Close.TextColor3 = Color3.new(1,0,0); Close.BackgroundTransparency = 1; Close.TextSize = 25
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false; FOVCircle:Remove() end)

-- Inicialização
Pages["Aimbot"].Page.Visible = true
Pages["Aimbot"].Btn.BackgroundColor3 = Settings.ThemeColor
Pages["Aimbot"].Btn.TextColor3 = Color3.new(1,1,1)
