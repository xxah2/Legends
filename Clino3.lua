-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local LocalPlayer = Players.LocalPlayer

-- ESTADOS
local noclip1 = false -- CanCollide false
local noclip2 = false -- Velocidad hacia adelante
local noclip3 = false -- CollisionGroup personalizado
local noclip4 = false -- Teleport suave con CFrame incremental
local noclip5 = false -- BodyVelocity

-- CREAR GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotMultiNoclip"
gui.ResetOnSpawn = false

local function createButton(text, posY, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 220, 0, 40)
    button.Position = UDim2.new(0, 20, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = text
    button.Parent = gui
    button.MouseButton1Click:Connect(callback)
end

-- Noclip 1: CanCollide false clásico
createButton("Noclip 1: CanCollide False", 50, function()
    noclip1 = not noclip1
end)

RunService.Stepped:Connect(function()
    if noclip1 and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Noclip 2: Velocidad hacia adelante (push)
createButton("Noclip 2: Velocity Push", 100, function()
    noclip2 = not noclip2
end)

RunService.Heartbeat:Connect(function()
    if noclip2 and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.CFrame.LookVector * 80
        end
    end
end)

-- Noclip 3: CollisionGroup personalizado
pcall(function()
    PhysicsService:CreateCollisionGroup("NoClipGroup")
    PhysicsService:CollisionGroupSetCollidable("NoClipGroup", "Default", false)
end)

createButton("Noclip 3: CollisionGroup", 150, function()
    noclip3 = not noclip3
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, noclip3 and "NoClipGroup" or "Default")
            end
        end
    end
end)

-- Noclip 4: Teleport suave incremental (CFrame)
createButton("Noclip 4: Teleport Suave", 200, function()
    noclip4 = not noclip4
end)

RunService.Heartbeat:Connect(function()
    if noclip4 and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 0.6
            -- Opcional para reforzar noclip
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Noclip 5: BodyVelocity aplicado
local bodyVel = Instance.new("BodyVelocity")
bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bodyVel.Velocity = Vector3.new(0, 0, 0)

createButton("Noclip 5: BodyVelocity", 250, function()
    if noclip5 then
        noclip5 = false
        bodyVel.Parent = nil
    else
        noclip5 = true
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            bodyVel.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 60
            bodyVel.Parent = LocalPlayer.Character.HumanoidRootPart
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if noclip5 and LocalPlayer.Character and bodyVel.Parent == LocalPlayer.Character.HumanoidRootPart then
        bodyVel.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 60
    end
end)
