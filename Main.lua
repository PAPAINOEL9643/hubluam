-- [[ XPEL HUB - VISUAL INTERFACE REVISADO ]]
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))()

local Settings = _G.XPEL_Settings
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local GameInfo = MarketService:GetProductInfo(game.PlaceId)

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_ULTRA_V4"
ScreenGui.Parent = Functions.GetSafeParent()
ScreenGui.ResetOnSpawn = false

-- FUNÇÃO ARRASTAR
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
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
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.8
MakeDraggable(MainFrame)

-- ================= SIDEBAR (ESQUERDA) =================
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 160, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 10)

-- Fix para não mostrar curva no lado direito da sidebar
local SideFix = Instance.new("Frame", SideBar)
SideFix.Size = UDim2.new(0, 20, 1, 0)
SideFix.Position = UDim2.new(1, -20, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SideFix.BorderSizePixel = 0

-- PERFIL
local ProfileFrame = Instance.new("Frame", SideBar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 100)
ProfileFrame.BackgroundTransparency = 1

local PlayerImage = Instance.new("ImageLabel", ProfileFrame)
PlayerImage.Size = UDim2.new(0, 55, 0, 55)
PlayerImage.Position = UDim2.new(0.5, -27, 0, 15)
PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", PlayerImage).CornerRadius = UDim.new(1, 0)

local PlayerName = Instance.new("TextLabel", ProfileFrame)
PlayerName.Size = UDim2.new(1, 0, 0, 20)
PlayerName.Position = UDim2.new(0, 0, 0, 75)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.DisplayName
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextSize = 11

-- BOTÕES DA SIDEBAR
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Size = UDim2.new(1, 0, 1, -110)
TabHolder.Position = UDim2.new(0, 0, 0, 110)
TabHolder.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 8)

-- ================= ÁREA DE CONTEÚDO (PAGINAS) =================
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 175, 0, 15)
PageContainer.Size = UDim2.new(1, -190, 1, -30)
PageContainer.BackgroundTransparency = 1

local Pages = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 130, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.TextSize = 10
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 8)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Ajuste automático do tamanho do scroll
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false 
            p.Btn.TextColor3 = Color3.fromRGB(140,140,140)
            p.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTE TOGGLE (CORRIGIDO E CENTRALIZADO)
local function AddToggle(parent, text, callback)
    local ToggleFrame = Instance.new("TextButton", parent)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleFrame.Text = "      " .. text
    ToggleFrame.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleFrame.Font = Enum.Font.GothamMedium
    ToggleFrame.TextSize = 13
    ToggleFrame.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", ToggleFrame)

    local StatusIndicator = Instance.new("Frame", ToggleFrame)
    StatusIndicator.Size = UDim2.new(0, 4, 0, 20)
    StatusIndicator.Position = UDim2.new(0, 10, 0.5, -10)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", StatusIndicator)

    local active = false
    ToggleFrame.MouseButton1Click:Connect(function()
        active = not active
        StatusIndicator.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        ToggleFrame.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(active)
    end)
end

-- CRIANDO ABAS
local TabInicio = CreateTab("Início")
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visual")

-- ================= CONTEÚDO INÍCIO =================
local Welcome = Instance.new("TextLabel", TabInicio)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.BackgroundTransparency = 1
Welcome.Text = "BEM-VINDO, " .. LocalPlayer.DisplayName:upper()
Welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 14

local GameCard = Instance.new("Frame", TabInicio)
GameCard.Size = UDim2.new(1, -10, 0, 60)
GameCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", GameCard)

local GName = Instance.new("TextLabel", GameCard)
GName.Size = UDim2.new(1, 0, 1, 0)
GName.BackgroundTransparency = 1
GName.Text = "JOGO ATUAL:\n" .. GameInfo.Name
GName.TextColor3 = Color3.fromRGB(180, 180, 180)
GName.Font = Enum.Font.GothamSemibold
GName.TextSize = 12

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.Code
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "DESEMPENHO: " .. math.floor(1/dt) .. " FPS"
end)

-- ================= CONTEÚDO AIMBOT =================
AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Aimbot 360 Graus", function(v) Settings.Aimbot360 = v end)
AddToggle(TabAimbot, "Verificar Paredes (WallCheck)", function(v) Settings.WallCheck = v end)

-- ================= CONTEÚDO VISUAL =================
AddToggle(TabVisual, "ESP Box (Caixas)", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "ESP Nomes", function(v) Settings.ESP.Names = v end)
AddToggle(TabVisual, "ESP Distância", function(v) Settings.ESP.Distance = v end)
AddToggle(TabVisual, "Linhas (Tracers)", function(v) Settings.ESP.Tracers = v end)

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 25
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- INICIALIZAÇÃO
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0, 150, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

Functions.Init()
