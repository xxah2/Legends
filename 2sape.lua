-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local shootEnabled = false
local aimbotAimPart = "Head"

-- Crear ScreenGui y botón dragable
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "OneShotArsenalGUI"

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 150, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 200)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.Text = "One-Shot: OFF"
toggleBtn.Parent = ScreenGui

local corner = Instance.new("UICorner", toggleBtn)
corner.CornerRadius = UDim.new(0, 10)

-- Drag functionality
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
local function update(input)
    local delta = input.Position - mousePos
    toggleBtn.Position = UDim2.new(
        framePos.X.Scale,
        framePos.X.Offset + delta.X,
        framePos.Y.Scale,
        framePos.Y.Offset + delta.Y
    )
end

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Función para conseguir enemigos
local function getEnemies()
    local enemies = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild(aimbotAimPart) then
            table.insert(enemies, plr)
        end
    end
    return enemies
end

-- Función para apuntar a la cabeza y disparar
local function shootAt(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild(aimbotAimPart)
    if not head then return end

    -- Apuntar la cámara
    local camCFrame = Camera.CFrame
    local lookVector = (head.Position - camCFrame.Position).Unit
    local newCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + lookVector)
    Camera.CFrame = newCFrame

    -- Simular disparo
    local mouse = LocalPlayer:GetMouse()
    mouse1press()
    task.wait(0.05)
    mouse1release()
end

-- Loop para disparar a todos los enemigos
RunService.Heartbeat:Connect(function()
    if shootEnabled then
        local enemies = getEnemies()
        for _, enemy in pairs(enemies) do
            shootAt(enemy)
            task.wait(0.1)
        end
    end
end)

-- Toggle botón
toggleBtn.MouseButton1Click:Connect(function()
    shootEnabled = not shootEnabled
    toggleBtn.Text = "One-Shot: " .. (shootEnabled and "ON" or "OFF")
end)
