-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Estados
local espEnabled = false
local aimbotEnabled = false
local aimbotFOV = 70
local aimbotAimPart = "Head"
local smoothness = 0.15

-- GUI base
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ArsenalMod"

local function createButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.ZIndex = 10
    btn.Parent = ScreenGui
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    -- Drag
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    local function update(input)
        local delta = input.Position - mousePos
        btn.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
    return btn
end

-- Crear botones
local espBtn = createButton("ESP: OFF", UDim2.new(0, 20, 0.4, 0))
local aimBtn = createButton("Aimbot: OFF", UDim2.new(0, 20, 0.5, 0))

-- ESP
local espObjects = {}

local function createESPForPlayer(plr, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = nil
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Color3 = color
    box.Transparency = 0.5
    box.Size = Vector3.new(4, 6, 2)
    box.Parent = nil

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.Adornee = nil
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.Parent = nil

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = billboard

    return box, billboard, label
end

local function removeESPForPlayer(plr)
    if espObjects[plr] then
        if espObjects[plr].box then espObjects[plr].box:Destroy() end
        if espObjects[plr].billboard then espObjects[plr].billboard:Destroy() end
        espObjects[plr] = nil
    end
end

local function updateESP()
    for plr, objs in pairs(espObjects) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            objs.box.Adornee = plr.Character.HumanoidRootPart
            objs.billboard.Adornee = plr.Character.HumanoidRootPart
            objs.billboard.TextLabel.Text = plr.Name
        else
            removeESPForPlayer(plr)
        end
    end
end

local function toggleESP(state)
    espEnabled = state
    if not espEnabled then
        for plr, _ in pairs(espObjects) do removeESPForPlayer(plr) end
        espObjects = {}
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local teamColor = plr.TeamColor.Color
            local localTeamColor = LocalPlayer.TeamColor.Color
            local colorESP = (teamColor == localTeamColor) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0) -- azul para equipo, rojo enemigo
            if not espObjects[plr] then
                local box, billboard, label = createESPForPlayer(plr, colorESP)
                box.Parent = plr.Character.HumanoidRootPart
                billboard.Parent = plr.Character.HumanoidRootPart
                label.Text = plr.Name
                espObjects[plr] = {box = box, billboard = billboard}
            end
        end
    end
end

-- Aimbot
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

local function aimAt(targetPos)
    local camCFrame = Camera.CFrame
    local lookVector = (targetPos - camCFrame.Position).Unit
    local newCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + lookVector)
    Camera.CFrame = camCFrame:Lerp(newCFrame, smoothness)
end

RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(aimbotAimPart) then
            aimAt(target.Character[aimbotAimPart].Position)
        end
    end

    if espEnabled then
        updateESP()
    end
end)

espBtn.MouseButton1Click:Connect(function()
    toggleESP(not espEnabled)
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)
