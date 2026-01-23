-- [[ XPEL HUB - VISUAL INTERFACE V2.1 (FULL FIXED) ]]

-- Tenta carregar as funções. Se falhar, cria uma tabela vazia para não crashar a UI.
local success, Functions = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/main/Functions.lua"))()
end)

-- Caso o arquivo externo falhe, define funções básicas de segurança para a UI abrir
if not success or type(Functions) ~= "table" then
    Functions = {}
    Functions.GetSafeParent = function() 
        return (game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    end
    Functions.Init = function() warn("XPEL: Funções lógicas não carregadas corretamente.") end
end

local Settings = _G.XPEL_Settings or {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MakeDraggable(MainFrame)

-- SIDEBAR
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 170, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SideBar.BackgroundTransparency = 0.2
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 12)

-- SEÇÃO DE PERFIL
local ProfileFrame = Instance.new("Frame", SideBar)
ProfileFrame.Size = UDim2.new(1, 0, 0, 120)
ProfileFrame.BackgroundTransparency = 1

local UserImage = Instance.new("ImageLabel", ProfileFrame)
UserImage.Size = UDim2.new(0, 60, 0, 60)
UserImage.Position = UDim2.new(0.5, -30, 0, 20)
UserImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UserImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", UserImage).Color = Color3.fromRGB(0, 150, 255)

local UserName = Instance.new("TextLabel", ProfileFrame)
UserName.Text = LocalPlayer.DisplayName
UserName.Position = UDim2.new(0, 0, 0, 85)
UserName.Size = UDim2.new(1, 0, 0, 20)
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 14
UserName.BackgroundTransparency = 1

local Line = Instance.new("Frame", SideBar)
Line.Size = UDim2.new(0.8, 0, 0, 1)
Line.Position = UDim2.new(0.1, 0, 0, 120)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Line.BorderSizePixel = 0

-- CONTAINER DOS BOTÕES
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Position = UDim2.new(0, 10, 0, 130)
TabHolder.Size = UDim2.new(1, -20, 1, -140)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 6)

-- CONTAINER DE PÁGINAS
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 180, 0, 40)
PageContainer.Size = UDim2.new(1, -195, 1, -55)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 13
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Page.Visible = false
            TweenService:Create(p.Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 150, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTE TOGGLE
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "    " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local Indicator = Instance.new("Frame", btn)
    Indicator.Size = UDim2.new(0, 28, 0, 14)
    Indicator.Position = UDim2.new(1, -40, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Indicator)
    Circle.Size = UDim2.new(0, 10, 0, 10)
    Circle.Position = UDim2.new(0, 2, 0.5, -5)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        local goalPos = active and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        local goalCol = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = goalPos}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = goalCol}):Play()
        callback(active)
    end)
end

-- CONTROLES (FECHAR E MINIMIZAR)
local ControlFrame = Instance.new("Frame", MainFrame)
ControlFrame.Size = UDim2.new(0, 60, 0, 30)
ControlFrame.Position = UDim2.new(1, -65, 0, 5)
ControlFrame.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", ControlFrame)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 25, 1, 0)
CloseBtn.Position = UDim2.new(0.5, 5, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() if Settings then Settings.Running = false end end)

local MinimizeBtn = Instance.new("TextButton", ControlFrame)
MinimizeBtn.Text = "−"
MinimizeBtn.Size = UDim2.new(0, 25, 1, 0)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    SideBar.Visible = not minimized
    PageContainer.Visible = not minimized
    MainFrame:TweenSize(minimized and UDim2.new(0, 580, 0, 40) or UDim2.new(0, 580, 0, 380), "Out", "Quart", 0.3, true)
end)

-- CRIANDO AS ABAS
local PaginaInicio = CreateTab("Início")
local PaginaAimbot = CreateTab("Aimbot")
local PaginaVisual = CreateTab("Visual")

-- CONTEÚDO INÍCIO
local Welcome = Instance.new("TextLabel", PaginaInicio)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.Text = "XPEL HUB - Status: Online"
Welcome.TextColor3 = Color3.fromRGB(0, 150, 255)
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 14

local FPSLabel = Instance.new("TextLabel", PaginaInicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 30)
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSLabel.BackgroundTransparency = 1
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "Performance: " .. math.floor(1/dt) .. " FPS"
end)

-- CONTEÚDO AIMBOT
AddToggle(PaginaAimbot, "Ativar Aimbot", function(v) if Settings then Settings.Aimbot = v end end)
AddToggle(PaginaAimbot, "Aimbot 360", function(v) if Settings then Settings.Aimbot360 = v end end)

-- CONTEÚDO VISUAL
AddToggle(PaginaVisual, "ESP Geral", function(v) if Settings and Settings.ESP then Settings.ESP.Enabled = v end end)
AddToggle(PaginaVisual, "ESP Box", function(v) if Settings and Settings.ESP then Settings.ESP.Box = v end end)
AddToggle(PaginaVisual, "ESP Nomes", function(v) if Settings and Settings.ESP then Settings.ESP.Names = v end end)

-- INICIALIZAÇÃO FINAL
pcall(function() Functions.Init() end)
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
