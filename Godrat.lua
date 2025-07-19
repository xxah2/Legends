-- 🔧 SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ⚙️ ESTADOS
local noclipEnabled = false
local speedEnabled = false

-- 🖼️ GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotHack"
gui.ResetOnSpawn = false

local function createButton(text, posY, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 40)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = text
    button.Parent = gui
    button.MouseButton1Click:Connect(callback)
    return button
end

-- 🚀 SPEED
createButton("Speed x80", 60, function()
    speedEnabled = not speedEnabled
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and 80 or 16
    end
end)

-- 🚪 NOCLIP
RunService.Stepped:Connect(function()
    if noclipEnabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)

createButton("Noclip", 110, function()
    noclipEnabled = not noclipEnabled
end)

-- 🧠 1 CLICK STEAL
createButton("1 Click Steal", 160, function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and string.find(obj.Name:lower(), "steal") then
            fireproximityprompt(obj)
        end
    end
end)
