-- [[ XPEL HUB - LOGIC ENGINE PRO V4 - RIVAIS OPTIMIZED ]]
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
    VisualSmoothness = 50,
    TargetPart = "Head",
    WallCheck = true, 
    TeamCheck = true, 
    
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

-- ================= LÓGICA DE VISIBILIDADE (RIVAIS FIX) =================
local function IsVisible(TargetPart)
    if not Logic.Settings.WallCheck then return true end
    
    -- No Rivais, o personagem pode estar dentro de pastas específicas
    -- Adicionamos uma verificação mais robusta ignorando o que está perto da câmera
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, workspace:FindFirstChild("Ignore") or workspace}
    RayParams.IgnoreWater = true
    
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * 1000
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, RayParams)
    
    if Result then
        local Hit = Result.Instance
        -- Verifica se o que o raio atingiu pertence ao modelo do inimigo
        if Hit:IsDescendantOf(TargetPart.Parent) or Hit.Parent == TargetPart.Parent then
            return true
        end
    end
    return false
end

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
        local HRP = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Torso")
        local Head = Char:FindFirstChild("Head") or Char:FindFirstChild("FakeHead")

        if not (Hum and HRP and Hum.Health > 0) then Hide() return end
        if Logic.Settings.TeamCheck and Player.Team == LocalPlayer.Team then Hide() return end

        local pos, onScreen = Camera:WorldToViewportPoint(HRP.Position)

        if not onScreen then Hide() return end

        local height = math.abs(Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 3, 0)).Y)
        local width = height * 0.6

        Box.Visible = Logic.Settings.ESP.Box
        Box.Size = Vector2.new(width, height)
        Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
        Box.Color = Logic.Settings.ESP.Colors.Main

        Name.Visible = Logic.Settings.ESP.Names
        Name.Text = Player.DisplayName or Player.Name
        Name.Color = Color3.new(1,1,1)
        Name.Position = Vector2.new(pos.X, pos.Y - (height/2) - 16)

        Line.Visible = Logic.Settings.ESP.Lines
        Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        Line.To = Vector2.new(pos.X, pos.Y + (height/2))
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

-- ================= LÓGICA DO AIMBOT MELHORADA (RIVAIS FIX) =================
Logic.GetClosest = function()
    local target, shortest = nil, (Logic.Settings.Aimbot360 and math.huge or Logic.Settings.FOV)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            -- Team Check (Rivais usa sistema de Times)
            if Logic.Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                -- O Rivais às vezes usa nomes diferentes ou partes invisíveis para o hitbox
                -- Vamos tentar encontrar a melhor parte disponível
                local part = char:FindFirstChild(Logic.Settings.TargetPart) 
                    or char:FindFirstChild("HumanoidRootPart") 
                    or char:FindFirstChild("UpperTorso")
                    or char:FindFirstChild("Torso")
                
                if hum and hum.Health > 0 and part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen or Logic.Settings.Aimbot360 then
                        if IsVisible(part) then
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
        end
    end
    return target
end

return Logic
