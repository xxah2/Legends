-- 🔧 SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ⚙️ ESTADOS
local noclipEnabled = false
local speedEnabled = false
local normalSpeed = 16
local fastSpeed = 150

-- 🖼️ GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotMod"
gui.ResetOnSpawn = false

-- FUNCIONES
local function createButton(text, posY, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 40)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = text
    button.Parent = gui
    button.MouseButton1Click:Connect(callback)
end

-- 🏃 SPEED x150 (Siempre activa si está ON, incluso con brainrot en mano)
createButton("Speed x150", 60, function()
    speedEnabled = not speedEnabled
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = fastSpeed
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = normalSpeed
    end
end)

-- 🚪 NOCLIP
createButton("Noclip", 110, function()
    noclipEnabled = not noclipEnabled
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 🧠 1 CLICK STEAL
createButton("1 Click Steal", 160, function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and string.find(obj.Name:lower(), "steal") then
            fireproximityprompt(obj)
        end
    end
end)
