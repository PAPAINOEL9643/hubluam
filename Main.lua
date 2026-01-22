-- [[ XPEL HUB - VISUAL INTERFACE V3 (FIXED & TESTED) ]]
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/PAPAINOEL9643/hubluam/refs/heads/main/Functions.lua"))()

-- Garante que o Settings existe para não dar erro
if not _G.XPEL_Settings then
    _G.XPEL_Settings = {
        Aimbot = false, Aimbot360 = false, ESP = {Enabled = false, Box = false, Names = false}, Running = true
    }
end

local Settings = _G.XPEL_Settings
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI CORE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPEL_UI_FINAL"
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
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.8
MakeDraggable(MainFrame)

-- SIDEBAR
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 160, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SideBar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", SideBar)
SideCorner.CornerRadius = UDim.new(0, 10)

--- [[ PERFIL DO PLAYER ]] ---
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

-- BOTOES CONTAINER
local TabHolder = Instance.new("Frame", SideBar)
TabHolder.Position = UDim2.new(0, 10, 0, 130)
TabHolder.Size = UDim2.new(1, -20, 1, -140)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 8)

-- CONTAINER DE PAGINAS
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 175, 0, 15)
PageContainer.Size = UDim2.new(1, -190, 1, -30)
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
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

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
    btn.Size = UDim2.new(1, -5, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = "    " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", btn)
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -25, 0.5, -5)
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

-- CRIANDO CONTEUDO
local P1 = CreateTab("Início")
local P2 = CreateTab("Aimbot")
local P3 = CreateTab("Visual")

local Lbl = Instance.new("TextLabel", P1)
Lbl.Size = UDim2.new(1, 0, 0, 30)
Lbl.Text = "Bem-vindo, " .. LocalPlayer.Name
Lbl.TextColor3 = Color3.new(1,1,1)
Lbl.BackgroundTransparency = 1

AddToggle(P2, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(P3, "ESP Box", function(v) Settings.ESP.Box = v end)

-- FECHAR
local Close = Instance.new("TextButton", MainFrame)
Close.Text = "X"
Close.Position = UDim2.new(1, -30, 0, 10)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.TextColor3 = Color3.new(1,0,0)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- START
Functions.Init()
Pages["Início"].Page.Visible = true
Pages["Início"].Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Pages["Início"].Btn.TextColor3 = Color3.new(1,1,1)
