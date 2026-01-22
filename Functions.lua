
-- [[ XPEL HUB - LOGIC ENGINE ]]
local Logic = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIGURAÇÕES =================
Logic.Settings = {
    Aimbot = false,
    Aimbot360 = false,
    AimMode = "Sempre", 
    FOV = 150,
    Smoothness = 0.5,
    VisualSmoothness = 50,
    TargetPart = "Head",
    
    ESP = {
        Enabled = false,
        Box = false,
        Lines = false,
        Skeleton = false,
        Names = false,
        Distance = false,
        FullBody = false,
        Colors = {
            Main = Color3.fromRGB(0, 255, 255),
            Skeleton = Color3.fromRGB(255, 255, 255)
        }
    },
    
    Performance = {
        NoTextures = false,
        NoShadows = false
    },
    
    ThemeColor = Color3.fromRGB(0, 150, 255),
    Running = true
}

-- ================= BYPASS & SECURITY =================
Logic.GetSafeParent = function()
    local success, coregui = pcall(function() return game:GetService("CoreGui") end)
    if not success then return LocalPlayer:WaitForChild("PlayerGui") end
    if gethui then return gethui() end
    if coregui:FindFirstChild("RobloxGui") then return coregui.RobloxGui end
    return coregui
end

pcall(function()
    if hookmetamethod then
        local raw_index
        raw_index = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and (key == "CFrame" or key == "Position") and self == workspace.CurrentCamera then
                return raw_index(self, key)
            end
            return raw_index(self, key)
        end)
    end
end)

-- ================= LÓGICA DE PERFORMANCE =================
Logic.OptimizePerformance = function(v)
    for _, obj in pairs(workspace:GetDescendants()) do
        if v and (obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("MeshPart")) then
            if obj:IsA("MeshPart") then obj.TextureID = "" end
            if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
        end
    end
    if v then
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
end

-- ================= ESP ENGINE =================
Logic.ESP_Table = {}

Logic.CreateESP = function(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Line = Drawing.new("Line")

    Box.Visible = false
    Box.Thickness = 1
    Box.Filled = false

    Name.Visible = false
    Name.Size = 13
    Name.Center = true
    Name.Outline = true

    Line.Visible = false
    Line.Thickness = 1

    local function Hide()
        Box.Visible = false
        Name.Visible = false
        Line.Visible = false
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Logic.Settings.Running or not Logic.Settings.ESP.Enabled then
            Hide()
            return
        end

        local Char = Player.Character
        if not Char then Hide() return end

        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        local Head = Char:FindFirstChild("Head")

        if not (Hum and HRP and Head and Hum.Health > 0) then Hide() return end

        local topPos, topOnScreen = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.3, 0))
        local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 3, 0))

        if not (topOnScreen and bottomOnScreen) then Hide() return end

        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height * 0.5

        Box.Visible = Logic.Settings.ESP.Box
        Box.Size = Vector2.new(width, height)
        Box.Position = Vector2.new(topPos.X - width / 2, topPos.Y)
        Box.Color = Logic.Settings.ESP.Colors.Main

        Name.Visible = Logic.Settings.ESP.Names
        Name.Text = Player.Name
        Name.Color = Color3.new(1,1,1)
        Name.Position = Vector2.new(topPos.X, topPos.Y - 14)

        Line.Visible = Logic.Settings.ESP.Lines
        Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        Line.To = Vector2.new(topPos.X, bottomPos.Y)
        Line.Color = Logic.Settings.ESP.Colors.Main
    end)

    Logic.ESP_Table[Player] = {
        Remove = function()
            if Connection then Connection:Disconnect() end
            Box:Remove()
            Name:Remove()
            Line:Remove()
        end
    }
end

-- ================= LÓGICA DO AIMBOT =================
Logic.GetClosest = function()
    local target, shortest = nil, (Logic.Settings.Aimbot360 and math.huge or Logic.Settings.FOV)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Logic.Settings.TargetPart) then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = plr.Character[Logic.Settings.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen or Logic.Settings.Aimbot360 then
                    local mouseLoc = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    
                    if dist < shortest then
                        shortest = dist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

return Logic
