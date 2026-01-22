-- [[ XPEL HUB - LOGIC ENGINE PRO V4 - ULTRA EDITION ]]
local Logic = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIGURAÇÕES INICIAIS =================
Logic.Settings = {
    Aimbot = false,
    Aimbot360 = false,
    AimMode = "Sempre", 
    FOV = 150,
    Smoothness = 0.5,
    TargetPart = "Head",
    WallCheck = true,
    TeamCheck = true,
    ESP = {
        Enabled = false,
        Box = false,
        Lines = false,
        Names = false,
        Colors = { Main = Color3.fromRGB(0, 255, 255) }
    },
    Running = true,
    ThemeColor = Color3.fromRGB(0, 150, 255)
}

-- ================= BYPASS & SEGURANÇA AVANÇADA =================
pcall(function()
    local RawIndex; RawIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and self == Camera and (key == "CFrame" or key == "Focus") then
            return RawIndex(self, key)
        end
        return RawIndex(self, key)
    end)
end)

Logic.GetSafeParent = function()
    local target = nil
    local success = pcall(function()
        target = gethui and gethui() or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui")
    end)
    return (success and target) or LocalPlayer:WaitForChild("PlayerGui")
end

-- ================= LÓGICA DE ALVO =================
local function GetBodyPart(char)
    local target = Logic.Settings.TargetPart
    return char:FindFirstChild(target) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function IsVisible(TargetPart)
    if not Logic.Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil or result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- ================= ENGINE DE ESP =================
Logic.ESP_Table = {}

Logic.CreateESP = function(Player)
    if not Player or Player == LocalPlayer then return end
    
    local Box = Drawing.new("Square"); Box.Visible = false; Box.Thickness = 1; Box.Filled = false
    local Name = Drawing.new("Text"); Name.Visible = false; Name.Size = 14; Name.Center = true; Name.Outline = true
    local Line = Drawing.new("Line"); Line.Visible = false; Line.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local function Hide() Box.Visible = false; Name.Visible = false; Line.Visible = false end

        if not Logic.Settings.Running or not Logic.Settings.ESP.Enabled or not Player.Parent then
            Hide()
            if not Player.Parent then connection:Disconnect() end
            return
        end

        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and root and hum.Health > 0 then
            if Logic.Settings.TeamCheck and Player.Team == LocalPlayer.Team then Hide() return end

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local head = char:FindFirstChild("Head") or root
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6

                Box.Visible = Logic.Settings.ESP.Box
                Box.Size = Vector2.new(width, height)
                Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                Box.Color = Logic.Settings.ESP.Colors.Main

                Name.Visible = Logic.Settings.ESP.Names
                Name.Text = Player.DisplayName or Player.Name
                Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                Name.Color = Color3.new(1,1,1)

                Line.Visible = Logic.Settings.ESP.Lines
                Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                Line.To = Vector2.new(pos.X, pos.Y + height/2)
                Line.Color = Logic.Settings.ESP.Colors.Main
            else Hide() end
        else Hide() end
    end)
    Logic.ESP_Table[Player] = { Remove = function() connection:Disconnect(); Box:Remove(); Name:Remove(); Line:Remove() end }
end

-- ================= LÓGICA DO AIMBOT =================
Logic.GetClosest = function()
    local target, shortest = nil, (Logic.Settings.Aimbot360 and math.huge or Logic.Settings.FOV)
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (not Logic.Settings.TeamCheck or plr.Team ~= LocalPlayer.Team) then
            local char = plr.Character
            local part = char and GetBodyPart(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if part and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen or Logic.Settings.Aimbot360 then
                    if IsVisible(part) then
                        local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                        if dist < shortest then
                            shortest = dist
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

Logic.OptimizePerformance = function(v)
    if not v then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1
        elseif obj:IsA("MeshPart") then obj.TextureID = "" end
    end
    Lighting.GlobalShadows = false
end

return Logic
