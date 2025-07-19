-- 📜 MOD MENU - STEAL A BRAINROT (KRNL ANDROID FRIENDLY)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local LocalPlayer = Players.LocalPlayer

-- 🧠 ESTADOS
local noclip1 = false
local noclip2 = false
local noclip3 = false

-- 🖼 GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotNoclipMenu"
gui.ResetOnSpawn = false

local function createButton(text, posY, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 20, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Text = text
    button.Parent = gui
    button.MouseButton1Click:Connect(callback)
end

-- 🧱 Noclip 1: CanCollide false clásico
createButton("🧱 Noclip 1 (Clásico)", 60, function()
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

-- 🌀 Noclip 2: Velocidad hacia adelante
createButton("🌀 Noclip 2 (Empuje)", 110, function()
    noclip2 = not noclip2
end)

RunService.Heartbeat:Connect(function()
    if noclip2 and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.CFrame.LookVector * 100
        end
    end
end)

-- 🛠 Noclip 3: CollisionGroup personalizado
pcall(function()
    PhysicsService:CreateCollisionGroup("NoClipGroup")
    PhysicsService:CollisionGroupSetCollidable("NoClipGroup", "Default", false)
end)

createButton("🛠 Noclip 3 (Grupo)", 160, function()
    noclip3 = not noclip3
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, noclip3 and "NoClipGroup" or "Default")
            end
        end
    end
end)
