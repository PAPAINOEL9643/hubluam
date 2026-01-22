-- [[ XPEL HUB - VISUAL INTERFACE V2 (FIXED SIDEBAR) ]]
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

-- DRAGGABLE
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
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5
MakeDraggable(MainFrame)

-- SIDEBAR (LADO ESQUERDO)
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 150, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 10)

-- Título
local HubTitle = Instance.new("TextLabel", SideBar)
HubTitle.Text = "XPEL HUB"
HubTitle.Size = UDim2.new(1, 0, 0, 60)
HubTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 18
HubTitle.BackgroundTransparency = 1

-- Container dos Botões das Abas
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Position = UDim2.new(0, 10, 0, 60)
TabHolder.Size = UDim2.new(1, -20, 1, -70)
TabHolder.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 8) -- Espaço entre os botões

-- CONTAINER DE PÁGINAS (LADO DIREITO)
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Name = "Pages"
PageContainer.Position = UDim2.new(0, 160, 0, 10) -- Começa após a sidebar
PageContainer.Size = UDim2.new(1, -170, 1, -20)
PageContainer.BackgroundTransparency = 1

local Pages = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 14
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(150,150,150)
            p.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTE TOGGLE
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", btn)
    Indicator.Size = UDim2.new(0, 12, 0, 12)
    Indicator.Position = UDim2.new(1, -25, 0.5, -6)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Indicator, TweenInfo.new(0.3), {
            BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
        }):Play()
        callback(active)
    end)
end

-- CRIANDO AS ABAS
local PaginaInicio = CreateTab("Início")
local PaginaAimbot = CreateTab("Aimbot")
local PaginaVisual = CreateTab("Visual")

-- CONTEÚDO INÍCIO
local Welcome = Instance.new("TextLabel", PaginaInicio)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.Text = "Status: Online"
Welcome.TextColor3 = Color3.new(1, 1, 1)
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.GothamBold

local FPSLabel = Instance.new("TextLabel", PaginaInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 30)
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSLabel.BackgroundTransparency = 1
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "FPS: " .. math.floor(1/dt)
end)

-- CONTEÚDO AIMBOT
AddToggle(PaginaAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(PaginaAimbot, "Aimbot 360", function(v) Settings.Aimbot360 = v end)

-- CONTEÚDO VISUAL
AddToggle(PaginaVisual, "ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(PaginaVisual, "ESP Box", function(v) Settings.ESP.Box = v end)
AddToggle(PaginaVisual, "ESP Nomes", function(v) Settings.ESP.Names = v end)

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Position = UDim2.new(1, -30, 0, 10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false end)

-- ATIVAR PRIMEIRA ABA
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
