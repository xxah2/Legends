-- 🔧 SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ⚙️ ESTADO
local menuVisible = false
local noclip = false
local speed = false
local originalSpeed = 16
local fastSpeed = 80

-- 🖼 GUI BASE
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

-- 🔘 BOTÓN FLOTANTE REDONDO CON "G"
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 100, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.Text = "G"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 24
toggleButton.Parent = gui
toggleButton.ZIndex = 10
toggleButton.AutoButtonColor = true
toggleButton.BorderSizePixel = 0
toggleButton.BackgroundTransparency = 0
toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.Active = true
toggleButton.Draggable = true

-- Redondear botón
local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleButton

-- 📦 FRAME DEL MENÚ
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 200, 0, 120)
menuFrame.Position = UDim2.new(0, 80, 0, 160)
menuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuFrame.Visible = false
menuFrame.Parent = gui
menuFrame.Active = true
menuFrame.Draggable = true

local cornerMenu = Instance.new("UICorner")
cornerMenu.CornerRadius = UDim.new(0, 12)
cornerMenu.Parent = menuFrame

-- 🔘 BOTÓN: NOCLIP
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -20, 0, 40)
noclipBtn.Position = UDim2.new(0, 10, 0, 10)
noclipBtn.Text = "No Clip: OFF"
noclipBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 16
noclipBtn.Parent = menuFrame

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = "No Clip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 🔘 BOTÓN: SPEED
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 40)
speedBtn.Position = UDim2.new(0, 10, 0, 60)
speedBtn.Text = "Speed: OFF"
speedBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 16
speedBtn.Parent = menuFrame

speedBtn.MouseButton1Click:Connect(function()
    speed = not speed
    speedBtn.Text = "Speed: " .. (speed and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed and fastSpeed or originalSpeed
    end
end)

-- 📱 ABRIR/CERRAR MENÚ con BOTÓN FLOTANTE
toggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)

-- ⌨️ ABRIR/CERRAR MENÚ con TECLA "G"
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        menuVisible = not menuVisible
        menuFrame.Visible = menuVisible
    end
end)
