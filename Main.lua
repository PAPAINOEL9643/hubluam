-- [[ XPEL HUB - VISUAL INTERFACE (REESTRUTURADO) ]]
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

-- FUNÇÃO ARRASTAR OTIMIZADA
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

-- Esconder cantos direitos da sidebar para encaixar no MainFrame
local SideFix = Instance.new("Frame", SideBar)
SideFix.Size = UDim2.new(0, 20, 1, 0)
SideFix.Position = UDim2.new(1, -20, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SideFix.BorderSizePixel = 0

-- PERFIL DO PLAYER (TOPO DA SIDEBAR)
local ProfileFrame = Instance.new("Frame", SideBar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 100)
ProfileFrame.BackgroundTransparency = 1

local PlayerImage = Instance.new("ImageLabel", ProfileFrame)
PlayerImage.Size = UDim2.new(0, 50, 0, 50)
PlayerImage.Position = UDim2.new(0.5, -25, 0, 15)
PlayerImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", PlayerImage).CornerRadius = UDim.new(1, 0)

local PlayerName = Instance.new("TextLabel", ProfileFrame)
PlayerName.Size = UDim2.new(1, 0, 0, 20)
PlayerName.Position = UDim2.new(0, 0, 0, 70)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.DisplayName
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextSize = 13

-- CONTAINER DAS ABAS
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Size = UDim2.new(1, 0, 1, -110)
TabHolder.Position = UDim2.new(0, 0, 0, 110)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 8)

-- ================= ÁREA DE CONTEÚDO (DIREITA) =================
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 180, 0, 15)
PageContainer.Size = UDim2.new(1, -195, 1, -30)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 140, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 12
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 10)

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
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "     " .. text
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

-- CRIANDO AS ABAS
local TabInicio = CreateTab("Início")
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visual")

-- ================= ABA INÍCIO (GAME INFO) =================
local GameSection = Instance.new("Frame", TabInicio)
GameSection.Size = UDim2.new(1, 0, 0, 120)
GameSection.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", GameSection)

local GameIcon = Instance.new("ImageLabel", GameSection)
GameIcon.Size = UDim2.new(0, 90, 0, 90)
GameIcon.Position = UDim2.new(0, 15, 0, 15)
GameIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GameIcon.Image = "rbxassetid://15814516147" -- Placeholder do ícone do Hub
Instance.new("UICorner", GameIcon)

local GName = Instance.new("TextLabel", GameSection)
GName.Size = UDim2.new(1, -130, 0, 40)
GName.Position = UDim2.new(0, 120, 0, 25)
GName.BackgroundTransparency = 1
GName.Text = GameInfo.Name
GName.TextColor3 = Color3.new(1, 1, 1)
GName.Font = Enum.Font.GothamBold
GName.TextSize = 16
GName.TextWrapped = true
GName.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.Gotham
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "TAXA DE QUADROS: " .. math.floor(1/dt) .. " FPS"
end)

-- ================= ABA AIMBOT =================
AddToggle(TabAimbot, "Ativar Aimbot Grudado", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Aimbot 360 Graus (Sem FOV)", function(v) Settings.Aimbot360 = v end)

-- ================= ABA VISUAL =================
AddToggle(TabVisual, "Ativar ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(TabVisual, "ESP Box (Caixas)", function(v) Settings.ESP.Box = v end)
AddToggle(TabVisual, "ESP Nomes dos Jogadores", function(v) Settings.ESP.Names = v end)

-- BOTÃO DE FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 30
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false end)

-- INICIALIZAR
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0, 150, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
