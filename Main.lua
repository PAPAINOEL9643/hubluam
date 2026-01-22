-- [[ XPEL HUB - DEATH EDITION (V3) ]]
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))()
local Settings = _G.XPEL_Settings
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- CONFIGURAÇÃO DE CORES (STYLE: DEATH)
local MainColor = Color3.fromRGB(150, 0, 0) -- Vermelho Morte
local BGColor = Color3.fromRGB(8, 8, 8)
local AccentColor = Color3.fromRGB(30, 0, 0)

-- GET GAME INFO
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local GameThumb = "rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=420&h=420"

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_DEATH_UI"
ScreenGui.Parent = Functions.GetSafeParent()
ScreenGui.ResetOnSpawn = false

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
MainFrame.BackgroundColor3 = BGColor
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = MainColor
MainStroke.Thickness = 1.8
MakeDraggable(MainFrame)

-- SIDEBAR
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 170, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 12)

-- PERFIL (SIDEBAR)
local ProfileFrame = Instance.new("Frame", SideBar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 120)
ProfileFrame.BackgroundTransparency = 1

local UserImage = Instance.new("ImageLabel", ProfileFrame)
UserImage.Size = UDim2.new(0, 60, 0, 60)
UserImage.Position = UDim2.new(0.5, -30, 0, 20)
UserImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
UserImage.BackgroundColor3 = AccentColor
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", UserImage).Color = MainColor

local UserName = Instance.new("TextLabel", ProfileFrame)
UserName.Text = LocalPlayer.DisplayName
UserName.Position = UDim2.new(0, 0, 0, 85)
UserName.Size = UDim2.new(1, 0, 0, 20)
UserName.TextColor3 = Color3.fromRGB(200, 200, 200)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 13
UserName.BackgroundTransparency = 1

-- ABAS
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Position = UDim2.new(0, 10, 0, 130)
TabHolder.Size = UDim2.new(1, -20, 1, -140)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 6)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 180, 0, 45)
PageContainer.Size = UDim2.new(1, -195, 1, -60)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Page.Visible = false
            p.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            p.Btn.TextColor3 = Color3.fromRGB(100, 100, 100)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = MainColor
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTE INFO BOX (PARA INICIO)
local function AddInfoLabel(parent, title, value, color)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 30)
    f.BackgroundTransparency = 1
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.Text = " " .. title .. ": " .. value
    t.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.BackgroundTransparency = 1
    return t
end

-- CRIAR ABAS
local PaginaInicio = CreateTab("Início")
local PaginaAimbot = CreateTab("Aimbot")
local PaginaVisual = CreateTab("Visual")

-- CONTEÚDO INÍCIO (GAME INFO)
local GameImg = Instance.new("ImageLabel", PaginaInicio)
GameImg.Size = UDim2.new(0, 360, 0, 120)
GameImg.Image = GameThumb
GameImg.BackgroundColor3 = AccentColor
Instance.new("UICorner", GameImg).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", GameImg).Color = MainColor

local GName = Instance.new("TextLabel", PaginaInicio)
GName.Size = UDim2.new(1, 0, 0, 30)
GName.Text = GameName:upper()
GName.Font = Enum.Font.GothamBold
GName.TextColor3 = MainColor
GName.TextSize = 16
GName.BackgroundTransparency = 1

local PlayerCount = AddInfoLabel(PaginaInicio, "Jogadores no Servidor", #Players:GetPlayers(), Color3.fromRGB(255,255,255))
local AdminLabel = AddInfoLabel(PaginaInicio, "Admin Online", "Verificando...", Color3.fromRGB(255,255,255))

-- Verificação de Admin
local function CheckAdmin()
    local adminFound = "Não"
    for _, p in pairs(Players:GetPlayers()) do
        if p:GetRankInGroup(game.CreatorId) >= 200 or p.UserId == game.CreatorId then
            adminFound = "SIM! (Cuidado)"
            AdminLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
    AdminLabel.Text = " Admin Online: " .. adminFound
end
spawn(CheckAdmin)

-- TOGGLE STYLE
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "    " .. text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(30, 30, 30)

    local Indicator = Instance.new("Frame", btn)
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(1, -25, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = active and MainColor or Color3.fromRGB(30, 30, 30)}):Play()
        callback(active)
    end)
end

-- CONTROLES SUPERIORES
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "×"
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.TextColor3 = MainColor
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 25
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() Settings.Running = false end)

local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Text = "−"
MiniBtn.Position = UDim2.new(1, -65, 0, 10)
MiniBtn.Size = UDim2.new(0, 25, 0, 25)
MiniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 25

local min = false
MiniBtn.MouseButton1Click:Connect(function()
    min = not min
    SideBar.Visible = not min
    PageContainer.Visible = not min
    MainFrame:TweenSize(min and UDim2.new(0, 580, 0, 45) or UDim2.new(0, 580, 0, 400), "Out", "Quart", 0.3, true)
end)

-- CONTEÚDO AIMBOT/VISUAL
AddToggle(PaginaAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(PaginaVisual, "ESP Box", function(v) Settings.ESP.Box = v end)

-- INIT
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.BackgroundColor3 = MainColor
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(255,255,255)
