local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local espEnabled = false
local aimbotEnabled = false
local aimbotFOV = 70 -- FOV en pixeles
local aimbotAimPart = "Head"
local smoothness = 0.15 -- Ajusta para que el movimiento sea más suave (0 = instantáneo)

-- ScreenGui y botones (asumiendo que ya tenés el ESP funcionando)
-- Por si no, acá van los botones para activar/desactivar (puedes integrarlo con tu GUI actual)

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ArsenalAimESP"

local function createButton(text, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.ZIndex = 10
    btn.Parent = ScreenGui
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    return btn
end

local espBtn = createButton("ESP: OFF", UDim2.new(0, 20, 0.4, 0))
local aimBtn = createButton("Aimbot: OFF", UDim2.new(0, 20, 0.5, 0))

local espObjects = {}

-- Funciones ESP (igual que antes, no las repito aquí para abreviar)

-- [Inserta acá tu código ESP o mantené el que usás]

local function getClosestEnemy()
    local closestDist = math.huge
    local target = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild(aimbotAimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[aimbotAimPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < aimbotFOV and dist < closestDist then
                    closestDist = dist
                    target = plr
                end
            end
        end
    end
    return target
end

-- Función para apuntar suavemente la cámara hacia el objetivo
local function aimAt(targetPos)
    local camCFrame = Camera.CFrame
    local lookVector = (targetPos - camCFrame.Position).Unit
    local newCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + lookVector)
    -- Interpolamos para suavizar
    Camera.CFrame = camCFrame:Lerp(newCFrame, smoothness)
end

-- Loop de Aimbot
RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(aimbotAimPart) then
            aimAt(target.Character[aimbotAimPart].Position)
        end
    end
end)

-- Toggle botones
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    -- Lógica ESP acá (igual que antes)
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)
