-- [[ XPEL HUB - LOGIC ENGINE PRO V4 - UNIVERSAL EDITION ]]
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

-- ================= FUNÇÃO DE BUSCA DE PERSONAGEM (UNIVERSAL) =================
-- Esta função encontra o corpo do jogador não importa onde ele esteja ou o nome das partes
local function GetCharacterData(plr)
    local char = plr.Character
    if not char then return nil end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    
    -- Tenta achar a cabeça ou o tronco por nome ou por classe
    local head = char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("UpperTorso")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso")
    
    -- Se ainda não achou, pega a primeira parte base que encontrar
    if not head or not root then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                root = root or v
                head = head or v
            end
        end
    end
    
    return {Character = char, Humanoid = humanoid, RootPart = root, Head = head}
end

-- ================= LÓGICA DE VISIBILIDADE (RAYCAST UNIVERSAL) =================
local function IsVisible(TargetPart, Character)
    if not Logic.Settings.WallCheck then return true end
    
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, Character}
    RayParams.IgnoreWater = true
    
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * 1000
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, RayParams)
    
    -- Se não houver nada bloqueando o caminho até o personagem, retorna true
    return Result == nil
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

-- ================= ESP ENGINE UNIVERSAL =================
Logic.ESP_Table = {}

Logic.CreateESP = function(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Line = Drawing.new("Line")

    local function Hide()
        Box.Visible = false; Name.Visible = false; Line.Visible = false
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Logic.Settings.Running or not Logic.Settings.ESP.Enabled then
            Hide() return
        end

        local data = GetCharacterData(Player)
        if not data then Hide() return end
        if Logic.Settings.TeamCheck and Player.Team == LocalPlayer.Team then Hide() return end

        local pos, onScreen = Camera:WorldToViewportPoint(data.RootPart.Position)
        if not onScreen then Hide() return end

        -- Tamanho adaptativo para qualquer tipo de corpo
        local sizeY = math.abs(Camera:WorldToViewportPoint(data.RootPart.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(data.RootPart.Position - Vector3.new(0, 3, 0)).Y)
        local sizeX = sizeY * 0.6

        Box.Visible = Logic.Settings.ESP.Box
        Box.Size = Vector2.new(sizeX, sizeY)
        Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
        Box.Color = Logic.Settings.ESP.Colors.Main

        Name.Visible = Logic.Settings.ESP.Names
        Name.Text = Player.DisplayName or Player.Name
        Name.Position = Vector2.new(pos.X, pos.Y - (sizeY/2) - 16)
        Name.Outline = true; Name.Center = true; Name.Size = 13; Name.Color = Color3.new(1,1,1)

        Line.Visible = Logic.Settings.ESP.Lines
        Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        Line.To = Vector2.new(pos.X, pos.Y + (sizeY/2))
        Line.Color = Logic.Settings.ESP.Colors.Main
    end)

    Logic.ESP_Table[Player] = {
        Remove = function()
            if Connection then Connection:Disconnect() end
            Box:Remove(); Name:Remove(); Line:Remove()
        end
    }
end

-- ================= LÓGICA DO AIMBOT UNIVERSAL =================
Logic.GetClosest = function()
    local target, shortest = nil, (Logic.Settings.Aimbot360 and math.huge or Logic.Settings.FOV)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if Logic.Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            
            local data = GetCharacterData(plr)
            if data then
                -- Define a parte alvo com base nas configurações ou no que estiver disponível
                local targetPart = data.Character:FindFirstChild(Logic.Settings.TargetPart) or data.Head or data.RootPart
                
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen or Logic.Settings.Aimbot360 then
                        if IsVisible(targetPart, data.Character) then
                            local mouseLoc = UserInputService:GetMouseLocation()
                            local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                            
                            if dist < shortest then
                                shortest = dist
                                target = targetPart
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
