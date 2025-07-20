-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ESTADO
local noclip = false
local speed = false
local fastSpeed = 100
local normalSpeed = 16

-- GUI BASE
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

-- BOTÓN FLOTANTE (G)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 50, 0, 50)
openButton.Position = UDim2.new(0, 100, 0, 100)
openButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
openButton.Text = "G"
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 22
openButton.TextWrapped = true
openButton.AnchorPoint = Vector2.new(0.5, 0.5)
openButton.ClipsDescendants = true
openButton.Parent = gui
openButton.ZIndex = 10
openButton.AutoButtonColor = true
openButton.BorderSizePixel = 0
openButton.BackgroundTransparency = 0
openButton.TextStrokeTransparency = 0.5
openButton.TextScaled = true
openButton.TextStrokeColor3 = Color3.new(0, 0, 0)
openButton.TextWrapped = true
openButton.TextYAlignment = Enum.TextYAlignment.Center
openButton.TextXAlignment = Enum.TextXAlignment.Center
openButton.Shape = Enum.PartType.Ball

-- MENU
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 180, 0, 120)
menuFrame.Position = UDim2.new(0, 100, 0, 160)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.Visible = false
menuFrame.BorderSizePixel = 0

-- DRAG
local dragging = false
local dragInput, dragStart, startPos

openButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = openButton.Position
    end
end)

openButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        openButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 60)
    end
end)

openButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- TOGGLE MENU
openButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- CREAR BOTÓN DE FUNCIÓN
local function createToggle(name, posY, callback)
    local button = Instance.new("TextButton", menuFrame)
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Text = name .. ": OFF"
    local state = false

    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Noclip funcional
createToggle("Noclip", 10, function(enabled)
    noclip = enabled
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Speed funcional
createToggle("Speed", 60, function(enabled)
    speed = enabled
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and fastSpeed or normalSpeed
    end
end)

-- Reseteo automático al reaparecer
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = speed and fastSpeed or normalSpeed
end)
