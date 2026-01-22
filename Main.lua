-- [[ XPEL HUB - VISUAL INTERFACE CORRIGIDO ]]
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
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5
MakeDraggable(MainFrame)

-- ================= SIDEBAR (ESQUERDA) =================
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 170, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 10)

-- Esconder cantos direitos da sidebar para unificar com o fundo
local SideFix = Instance.new("Frame", SideBar)
SideFix.Size = UDim2.new(0, 15, 1, 0)
SideFix.Position = UDim2.new(1, -15, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SideFix.BorderSizePixel = 0
SideFix.ZIndex = 0

-- PERFIL DO PLAYER
local ProfileFrame = Instance.new("Frame", SideBar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 100)
ProfileFrame.BackgroundTransparency = 1

local PlayerImage = Instance.new("ImageLabel", ProfileFrame)
PlayerImage.Size = UDim2.new(0, 50, 0, 50)
PlayerImage.Position = UDim2.new(0.5, -25, 0, 15)
PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", PlayerImage).CornerRadius = UDim.new(1, 0)

local PlayerName = Instance.new("TextLabel", ProfileFrame)
PlayerName.Size = UDim2.new(1, 0, 0, 20)
PlayerName.Position = UDim2.new(0, 0, 0, 70)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.DisplayName
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextSize = 12

-- CONTAINER DAS ABAS (LISTAGEM VERTICAL)
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Size = UDim2.new(1, 0, 1, -110)
TabHolder.Position = UDim2.new(0, 0, 0, 100)
TabHolder.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 8)

-- ================= ÁREA DE CONTEÚDO =================
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 185, 0, 15) -- Começa após a sidebar
PageContainer.Size = UDim2.new(1, -200, 1, -30)
PageContainer.BackgroundTransparency = 1

local Pages = {}

local function CreateTab(name, order)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 140, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 11
    TabBtn.LayoutOrder = order
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0) -- Ajuste automático via UIList
    
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 10)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Auto-ajuste do tamanho do scroll
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false 
            p.Btn.TextColor3 = Color3.fromRGB(150,150,150)
            p.Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    end)
    
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTE TOGGLE
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "      " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.TextColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(200, 200, 200)
        callback(active)
    end)
end

-- CRIANDO AS ABAS (Com ordem definida)
local TabInicio = CreateTab("Início", 1)
local TabAimbot = CreateTab("Aimbot", 2)
local TabVisual = CreateTab("Visual", 3)

-- ================= CONTEÚDO INÍCIO =================
local GameSection = Instance.new("Frame", TabInicio)
GameSection.Size = UDim2.new(1, -10, 0, 100)
GameSection.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", GameSection)

local GName = Instance.new("TextLabel", GameSection)
GName.Size = UDim2.new(1, -20, 1, 0)
GName.Position = UDim2.new(0, 15, 0, 0)
GName.BackgroundTransparency = 1
GName.Text = "Jogo: " .. GameInfo.Name
GName.TextColor3 = Color3.new(1, 1, 1)
GName.Font = Enum.Font.GothamBold
GName.TextSize = 14
GName.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.Code
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "FPS: " .. math.floor(1/dt)
end)

-- ================= CONTEÚDO AIMBOT =================
AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Aimbot 360", function(v) Settings.Aimbot360 = v end)

-- ================= CONTEÚDO VISUAL =================
AddToggle(TabVisual, "ESP Box", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "ESP Names", function(v) Settings.ESP.Names = v end)

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 30
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- INICIAR NA PRIMEIRA ABA
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0, 150, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

Functions.Init()
