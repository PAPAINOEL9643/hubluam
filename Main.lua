-- [[ XPEL HUB - VISUAL INTERFACE V2 (SIDEBAR) ]]
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))()

local Settings = _G.XPEL_Settings
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_UI_" .. math.random(100,999)
ScreenGui.Parent = Functions.GetSafeParent()
ScreenGui.ResetOnSpawn = false

-- DRAGGABLE FUNCTION
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.2
MakeDraggable(MainFrame)

-- SIDEBAR (LADO ESQUERDO)
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 8)

-- Título do Hub
local HubTitle = Instance.new("TextLabel", SideBar)
HubTitle.Text = "XPEL HUB"
HubTitle.Size = UDim2.new(1, 0, 0, 50)
HubTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 16
HubTitle.BackgroundTransparency = 1

local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Position = UDim2.new(0, 5, 0, 60)
TabHolder.Size = UDim2.new(1, -10, 1, -70)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 5)

-- CONTAINER DE PÁGINAS (LADO DIREITO)
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 150, 0, 10)
PageContainer.Size = UDim2.new(1, -160, 1, -20)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 13
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(180,180,180)
            p.Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTES MELHORADOS
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 370, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local Indicator = Instance.new("Frame", btn)
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -20, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Indicator, TweenInfo.new(0.3), {
            BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        }):Play()
        callback(active)
    end)
end

-- CRIAÇÃO DAS ABAS
local Inicio = CreateTab("Início")
local AimbotTab = CreateTab("Aimbot")
local VisualTab = CreateTab("Visual")

-- ABA INÍCIO
local InfoLabel = Instance.new("TextLabel", Inicio)
InfoLabel.Size = UDim2.new(0, 370, 0, 40)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.Text = "Bem-vindo ao XPEL HUB"
InfoLabel.Font = Enum.Font.GothamBold

local FPSLabel = Instance.new("TextLabel", Inicio)
FPSLabel.Size = UDim2.new(0, 370, 0, 30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSLabel.TextSize = 14
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "Performance: " .. math.floor(1/dt) .. " FPS"
end)

-- ABA AIMBOT
AddToggle(AimbotTab, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(AimbotTab, "Aimbot 360", function(v) Settings.Aimbot360 = v end)

-- ABA VISUAL
AddToggle(VisualTab, "ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(VisualTab, "ESP Box", function(v) Settings.ESP.Box = v end)
AddToggle(VisualTab, "ESP Nomes", function(v) Settings.ESP.Names = v end)

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "×"
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextSize = 20
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false end)

-- INICIALIZAÇÃO
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
