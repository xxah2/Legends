-- Variables básicas
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Estados
local espEnabled = false
local aimbotEnabled = false
local aimbotFOV = 50 -- radio en pixeles para detectar objetivo
local aimbotAimPart = "Head" -- parte a apuntar

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ArsenalModMenu"

-- Botón flotante para abrir/cerrar menú
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Name = "ToggleMenu"
toggleBtn.Text = "G"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
toggleBtn.ZIndex = 10

-- Función para arrastrar botón
local dragging = false
local dragInput, mousePos, framePos

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

-- Panel principal (invisible al principio)
local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 180, 0, 120)
mainFrame.Position = UDim2.new(0, 60, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 9
local uicorner = Instance.new("UICorner", mainFrame)
uicorner.CornerRadius = UDim.new(0, 10)

-- Título
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Arsenal Mod Menu"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

-- Botón ESP
local espBtn = Instance.new("TextButton", mainFrame)
espBtn.Size = UDim2.new(1, -20, 0, 40)
espBtn.Position = UDim2.new(0, 10, 0, 40)
espBtn.Text = "ESP: OFF"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 18
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espBtn.AutoButtonColor = false
espBtn.BorderSizePixel = 0
local espCorner = Instance.new("UICorner", espBtn)
espCorner.CornerRadius = UDim.new(0, 8)

-- Botón Aimbot
local aimBtn = Instance.new("TextButton", mainFrame)
aimBtn.Size = UDim2.new(1, -20, 0, 40)
aimBtn.Position = UDim2.new(0, 10, 0, 85)
aimBtn.Text = "Aimbot: OFF"
aimBtn.Font = Enum.Font.GothamBold
aimBtn.TextSize = 18
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
aimBtn.AutoButtonColor = false
aimBtn.BorderSizePixel = 0
local aimCorner = Instance.new("UICorner", aimBtn)
aimCorner.CornerRadius = UDim.new(0, 8)

-- Mostrar/ocultar menú al presionar toggleBtn
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Función para crear ESP para un jugador
local function createESP(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = nil
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Color3 = Color3.new(1, 0, 0)
    box.Transparency = 0.5
    box.Size = Vector3.new(4, 6, 2)
    box.Name = "ESPBox"
    box.Parent = nil

    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "ESPNameTag"
    nameTag.AlwaysOnTop = true
    nameTag.Size = UDim2.new(0, 100, 0, 20)
    nameTag.Adornee = nil
    nameTag.Parent = nil

    local label = Instance.new("TextLabel", nameTag)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = Color3.new(1, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true

    return box, nameTag, label
end

-- Tabla para guardar adornos ESP
local espPlayers = {}

-- Función para activar/desactivar ESP
local function toggleESP(state)
    espEnabled = state
    if not espEnabled then
        -- Limpiar adornos
        for plr, adorns in pairs(espPlayers) do
            if adorns.box then adorns.box:Destroy() end
            if adorns.nameTag then adorns.nameTag:Destroy() end
        end
        espPlayers = {}
        return
    end

    -- Crear adornos para jugadores enemigos
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local box, nameTag, label = createESP(plr)
            box.Adornee = plr.Character.HumanoidRootPart
            box.Parent = plr.Character.HumanoidRootPart
            nameTag.Adornee = plr.Character.HumanoidRootPart
            nameTag.Parent = plr.Character.HumanoidRootPart
            label.Text = plr.Name

            espPlayers[plr] = {box = box, nameTag = nameTag}
        end
    end
end

-- Cambiar texto y estado de ESP con botón
espBtn.MouseButton1Click:Connect(function()
    toggleESP(not espEnabled)
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

-- Función para obtener el enemigo más cercano al centro de pantalla dentro del FOV
local function getClosestEnemy()
    local closestDistance = math.huge
    local target = nil

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild(aimbotAimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[aimbotAimPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < aimbotFOV and dist < closestDistance then
                    closestDistance = dist
                    target = plr
                end
            end
        end
    end

    return target
end

-- Loop del aimbot
RunService.Heartbeat:Connect(function()
    if aimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(aimbotAimPart) then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local targetPos = Camera:WorldToViewportPoint(target.Character[aimbotAimPart].Position)
            -- Mover mouse hacia objetivo (función específica de algunos exploits)
            pcall(function()
                mouse.X = targetPos.X
                mouse.Y = targetPos.Y
            end)
        end
    end
end)

-- Cambiar texto y estado de Aimbot con botón
aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)
