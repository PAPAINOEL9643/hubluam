-- [[ XPEL HUB - VISUAL INTERFACE FINAL CORRIGIDO ]]

-- Inicialização das Configurações Globais (Essencial para a Logística funcionar)
_G.XPEL_Settings = {
    Aimbot = false,
    Aimbot360 = false,
    AimMode = "Sempre", 
    FOV = 150,
    Smoothness = 0.2, -- Ajustado para ser mais fluido
    TargetPart = "Head",
    ESP = {
        Enabled = false,
        Box = false,
        Lines = false,
        Names = false,
        Colors = { Main = Color3.fromRGB(0, 255, 255) }
    },
    Running = true
}

-- Carregamento das Funções (Logística)
-- Certifique-se que o link abaixo aponta para o seu arquivo de LOGÍSTICA
local Functions = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"
))()

local Settings = _G.XPEL_Settings
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ================= UI CORE =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_ULTRA_V4"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ================= DRAG SYSTEM =================
local function MakeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ================= MAIN FRAME =================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0,150,255)
Stroke.Thickness = 1.5
MakeDraggable(MainFrame)

-- Sidebar e Profile (Mantidos conforme seu design)
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0,160,1,0)
SideBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0,10)

local Profile = Instance.new("Frame", SideBar)
Profile.Size = UDim2.new(1,0,0,100)
Profile.BackgroundTransparency = 1

local Avatar = Instance.new("ImageLabel", Profile)
Avatar.Size = UDim2.new(0,55,0,55)
Avatar.Position = UDim2.new(0.5,-27,0,15)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)

-- ================= TABS & PAGES =================
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Size = UDim2.new(1,0,1,-110)
TabHolder.Position = UDim2.new(0,0,0,110)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0,8)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0,175,0,15)
PageContainer.Size = UDim2.new(1,-190,1,-30)
PageContainer.BackgroundTransparency = 1

local Pages = {}

local function CreateTab(name)
    local Btn = Instance.new("TextButton", TabHolder)
    Btn.Size = UDim2.new(0,140,0,32)
    Btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Btn.Text = name:upper()
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.TextColor3 = Color3.fromRGB(140,140,140)
    Instance.new("UICorner", Btn)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0,0,0,0)
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,8)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end)

    Btn.MouseButton1Click:Connect(function()
        for _,t in pairs(Pages) do
            t.Page.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(140,140,140)
            t.Btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
        end
        Page.Visible = true
        Btn.TextColor3 = Color3.fromRGB(0,150,255)
        Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    end)

    Pages[name] = {Btn=Btn,Page=Page}
    return Page
end

-- ================= UI COMPONENTS =================
local function AddToggle(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,-10,0,40)
    Btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Btn.Text = "      "..text
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextColor3 = Color3.fromRGB(200,200,200)
    Instance.new("UICorner", Btn)

    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0,4,0,20)
    Indicator.Position = UDim2.new(0,10,0.5,-10)
    Indicator.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", Indicator)

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Indicator.BackgroundColor3 = state and Color3.fromRGB(0,150,255) or Color3.fromRGB(40,40,40)
        Btn.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)
        callback(state)
    end)
end

-- ================= PAGES CONTENT =================
local TabInicio = CreateTab("Início")
local TabAimbot = CreateTab("Aimbot")
local TabVisual = CreateTab("Visual")

-- PÁGINA: INÍCIO
local Welcome = Instance.new("TextLabel", TabInicio)
Welcome.Size = UDim2.new(1,0,0,40)
Welcome.BackgroundTransparency = 1
Welcome.Text = "BEM-VINDO, "..LocalPlayer.DisplayName:upper()
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 14
Welcome.TextColor3 = Color3.new(1,1,1)

local FPSLabel = Instance.new("TextLabel", TabInicio)
FPSLabel.Size = UDim2.new(1,0,0,30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = Enum.Font.Code
FPSLabel.TextSize = 12
FPSLabel.TextColor3 = Color3.fromRGB(0,255,120)

RunService.RenderStepped:Connect(function(dt)
    FPSLabel.Text = "FPS: "..math.floor(1/dt).." | STATUS: ATIVO"
end)

-- PÁGINA: AIMBOT
AddToggle(TabAimbot, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabAimbot, "Aimbot 360 (Sem FOV)", function(v) Settings.Aimbot360 = v end)

-- PÁGINA: VISUAL (ESP)
AddToggle(TabVisual, "Ativar ESP Master", function(v) 
    Settings.ESP.Enabled = v 
end)
AddToggle(TabVisual, "Exibir Caixas (Box)", function(v) 
    Settings.ESP.Box = v 
end)
AddToggle(TabVisual, "Exibir Nomes", function(v) 
    Settings.ESP.Names = v 
end)
AddToggle(TabVisual, "Exibir Linhas (Tracers)", function(v) 
    Settings.ESP.Lines = v 
end)

-- ================= FOOTER & CLOSE =================
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,5)
Close.Text = "×"
Close.TextSize = 25
Close.TextColor3 = Color3.fromRGB(255,80,80)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function()
    Settings.Running = false -- Para o loop da logística
    ScreenGui:Destroy()
end)

-- INIT
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.TextColor3 = Color3.fromRGB(0,150,255)
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Inicia a lógica do seu arquivo externo
task.spawn(function()
    Functions.Init()
end)
