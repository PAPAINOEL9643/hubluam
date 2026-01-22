-- [[ XPEL HUB - LOGIC & FUNCTIONS ]]
local Functions = {}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÕES (Compartilhadas via Tabela)
_G.XPEL_Settings = {
    Aimbot = false,
    Aimbot360 = false,
    AimMode = "Sempre", 
    FOV = 150,
    Smoothness = 0.5,
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

local Settings = _G.XPEL_Settings
local ESP_Table = {}

-- SEGURANÇA & BYPASS
function Functions.GetSafeParent()
    local success, coregui = pcall(function() return game:GetService("CoreGui") end)
    if not success then return LocalPlayer:WaitForChild("PlayerGui") end
    if gethui then return gethui() end
    return coregui
end

-- PERFORMANCE
function Functions.Optimize(v)
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

-- ESP LOGIC
function Functions.CreateESP(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Line = Drawing.new("Line")

    local function Hide()
        Box.Visible = false; Name.Visible = false; Line.Visible = false
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Settings.Running or not Settings.ESP.Enabled or not Player.Character then
            Hide() return
        end

        local Char = Player.Character
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        local Head = Char:FindFirstChild("Head")
        local Hum = Char:FindFirstChildOfClass("Humanoid")

        if not (HRP and Head and Hum and Hum.Health > 0) then Hide() return end

        local topPos, topOnScreen = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.3, 0))
        local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 3, 0))

        if topOnScreen and bottomOnScreen then
            local height = math.abs(topPos.Y - bottomPos.Y)
            local width = height * 0.5

            Box.Visible = Settings.ESP.Box
            Box.Size = Vector2.new(width, height)
            Box.Position = Vector2.new(topPos.X - width / 2, topPos.Y)
            Box.Color = Settings.ESP.Colors.Main

            Name.Visible = Settings.ESP.Names
            Name.Text = Player.Name
            Name.Position = Vector2.new(topPos.X, topPos.Y - 14)

            Line.Visible = Settings.ESP.Lines
            Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            Line.To = Vector2.new(topPos.X, bottomPos.Y)
            Line.Color = Settings.ESP.Colors.Main
        else
            Hide()
        end
    end)

    ESP_Table[Player] = {
        Remove = function()
            if Connection then Connection:Disconnect() end
            Box:Remove(); Name:Remove(); Line:Remove()
        end
    }
end

-- AIMBOT LOGIC
function Functions.GetClosestTarget()
    local target, shortest = nil, (Settings.Aimbot360 and math.huge or Settings.FOV)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Settings.TargetPart) then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = plr.Character[Settings.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen or Settings.Aimbot360 then
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

-- INICIALIZAÇÃO DE LOOPS
function Functions.Init()
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Functions.CreateESP(p) end end
    Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then Functions.CreateESP(p) end end)
    
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 0.5
    FOVCircle.Color = Color3.fromRGB(0, 150, 255)

    RunService.RenderStepped:Connect(function()
        if not Settings.Running then FOVCircle.Visible = false return end
        
        FOVCircle.Visible = Settings.Aimbot and not Settings.Aimbot360
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOV

        if Settings.Aimbot then
            local target = Functions.GetClosestTarget()
            local isClicking = (Settings.AimMode == "Sempre") or 
                               (Settings.AimMode == "Ao Mirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or
                               (Settings.AimMode == "Ao Atirar" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
            
            if target and isClicking then
                local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetPos, Settings.Smoothness)
            end
        end
    end)
end

return Functions
