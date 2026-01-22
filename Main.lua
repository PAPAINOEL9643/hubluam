-- [[ XPEL HUB - VISUAL INTERFACE ]]
-- Certifique-se que o Functions.lua foi carregado ou use a lógica abaixo:

local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))() -- Se estiver no GitHub
-- Para testes locais, você pode apenas colar o código de Functions acima antes deste.

local Settings = _G.XPEL_Settings
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_UI_" .. math.random(100,999)
ScreenGui.Parent = Functions.GetSafeParent()

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
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5
MakeDraggable(MainFrame)

-- FLOATING ICON
local FloatingIcon = Instance.new("TextButton", ScreenGui)
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Visible = false
FloatingIcon.Text = "XP"
FloatingIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingIcon.TextColor3 = Color3.fromRGB(0, 150, 255)
Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)
MakeDraggable(FloatingIcon)

-- TAB SYSTEM
local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(1, 0, 0, 45)
TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 15, 0, 60)
PageContainer.Size = UDim2.new(1, -30, 1, -75)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 12

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Page.Visible = false; p.Btn.TextColor3 = Color3.fromRGB(150,150,150) end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
    end)
    Pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- COMPONENTS (Toggle & Slider)
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(30, 60, 90) or Color3.fromRGB(25, 25, 25)
        callback(active)
    end)
end

-- MONTAGEM DAS ABAS
local Inicio = CreateTab("Início")
local AimbotTab = CreateTab("Aimbot")
local VisualTab = CreateTab("Visual")

-- ABA INÍCIO
local FPSLabel = Instance.new("TextLabel", Inicio)
FPSLabel.Size = UDim2.new(1, 0, 0, 50)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.new(0, 1, 1)
FPSLabel.TextSize = 20
RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = math.floor(1/dt) .. " FPS"
end)

-- ABA AIMBOT
AddToggle(AimbotTab, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(AimbotTab, "Aimbot 360", function(v) Settings.Aimbot360 = v end)

-- ABA VISUAL
AddToggle(VisualTab, "ESP Geral", function(v) Settings.ESP.Enabled = v end)
AddToggle(VisualTab, "ESP Box", function(v) Settings.ESP.Box = v end)
AddToggle(VisualTab, "ESP Nomes", function(v) Settings.ESP.Names = v end)

-- BOTÕES DE CONTROLE
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Settings.Running = false end)

-- INICIAR TUDO
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0, 150, 255)
