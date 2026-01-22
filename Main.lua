-- [[ XPEL HUB - VISUAL INTERFACE (SIDEBAR EDITION) ]]
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))()

local Settings = _G.XPEL_Settings
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local GameInfo = MarketService:GetProductInfo(game.PlaceId)

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_UI_SIDEBAR"
ScreenGui.Parent = Functions.GetSafeParent()

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
MainFrame.Size = UDim2.new(0, 580, 0, 400)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5
MakeDraggable(MainFrame)

-- SIDEBAR (LADO ESQUERDO)
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 160, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 10)

-- PERFIL DO USUÁRIO (TOPO DA SIDEBAR)
local UserFrame = Instance.new("Frame", SideBar)
UserFrame.Size = UDim2.new(1, 0, 0, 80)
UserFrame.BackgroundTransparency = 1

local UserImage = Instance.new("ImageLabel", UserFrame)
UserImage.Size = UDim2.new(0, 45, 0, 45)
UserImage.Position = UDim2.new(0.5, -22, 0, 10)
UserImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UserImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)

local UserName = Instance.new("TextLabel", UserFrame)
UserName.Size = UDim2.new(1, 0, 0, 20)
UserName.Position = UDim2.new(0, 0, 0, 55)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.DisplayName
UserName.TextColor3 = Color3.new(1, 1, 1)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 12

-- TAB HOLDER (SIDEBAR)
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Size = UDim2.new(1, 0, 1, -90)
TabHolder.Position = UDim2.new(0, 0, 0, 90)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 5)

-- CONTENT AREA
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 175, 0, 20)
PageContainer.Size = UDim2.new(1, -195, 1, -40)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 140, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0,0,1.2,0)
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Page.Visible = false 
            p.Btn.TextColor3 = Color3.fromRGB(150,150,150)
            p.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -5, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.TextColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.new(0.8,0.8,0.8)
        callback(active)
    end)
end

-- ABAS
local Inicio = CreateTab("Início")
local AimbotTab = CreateTab("Aimbot")
local VisualTab = CreateTab("Visual")

-- --- CONTEÚDO INÍCIO (INFO DO JOGO) ---
local GameIcon = Instance.new("ImageLabel", Inicio)
GameIcon.Size = UDim2.new(0, 100, 0, 100)
GameIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GameIcon.Image = "rbxassetid://" .. game.GameId -- Tenta pegar o ID da imagem do jogo
GameIcon.LayoutOrder = 1
Instance.new("UICorner", GameIcon)

local GameNameLabel = Instance.new("TextLabel", Inicio)
GameNameLabel.Size = UDim2.new(1, 0, 0, 30)
GameNameLabel.BackgroundTransparency = 1
GameNameLabel.Text = "Jogo: " .. GameInfo.Name
GameNameLabel.TextColor3 = Color3.new(1, 1, 1)
GameNameLabel.Font = Enum.Font.GothamBold
GameNameLabel.TextSize = 16
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel", Inicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 20)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSLabel.TextSize = 14
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "Desempenho: " .. math.floor(1/dt) .. " FPS"
end)

-- --- CONTEÚDO AIMBOT ---
AddToggle(AimbotTab, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(AimbotTab, "Aimbot 360 Graus", function(v) Settings.Aimbot360 = v end)

-- --- CONTEÚDO VISUAL ---
AddToggle(VisualTab, "Ativar ESP", function(v) Settings.ESP.Enabled = v end)
AddToggle(VisualTab, "Mostrar Caixas (Box)", function(v) Settings.ESP.Box = v end)
AddToggle(VisualTab, "Mostrar Nomes", function(v) Settings.ESP.Names = v end)

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "×"
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextSize = 30
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false end)

-- INICIALIZAÇÃO
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0, 150, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
