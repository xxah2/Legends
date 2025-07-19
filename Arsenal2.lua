-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Estados
local espEnabled = false
local aimbotEnabled = false
local aimbotFOV = 70 -- FOV en pixeles
local aimbotAimPart = "Head"

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalModMenu"
ScreenGui.Parent = game.CoreGui

-- Botón flotante para abrir/cerrar menú
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleMenu"
toggleBtn.Text = "G"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
toggleBtn.ZIndex = 10
toggleBtn.Parent = ScreenGui

-- Drag functionality
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
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.Position = UDim2.new(0, 60, 0.5, -65)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 9
mainFrame.Parent = ScreenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 12)
uicorner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Arsenal Mod Menu"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = mainFrame

-- Botón ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -20, 0, 40)
espBtn.Position = UDim2.new(0, 10, 0, 40)
espBtn.Text = "ESP: OFF"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 18
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.BorderSizePixel = 0
espBtn.AutoButtonColor = false
espBtn.Parent = mainFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espBtn

-- Botón Aimbot
local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(1, -20, 0, 40)
aimBtn.Position = UDim2.new(0, 10, 0, 90)
aimBtn.Text = "Aimbot: OFF"
aimBtn.Font = Enum.Font.GothamBold
aimBtn.TextSize = 18
aimBtn.TextColor3 = Color3.new(1, 1, 1)
aimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimBtn.BorderSizePixel = 0
aimBtn.AutoButtonColor = false
aimBtn.Parent = mainFrame

local aimCorner = Instance.new("UICorner")
aimCorner.CornerRadius = UDim.new(0, 8)
aimCorner.Parent = aimBtn

-- Mostrar/ocultar menú
toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- ESP: Crear adornos para jugadores enemigos
local espObjects = {}

local function createESPForPlayer(plr)
	local adornment = Instance.new("BoxHandleAdornment")
	adornment.Name = "ESPBox"
	adornment.Adornee = nil
	adornment.AlwaysOnTop = true
	adornment.ZIndex = 10
	adornment.Color3 = Color3.fromRGB(255, 0, 0)
	adornment.Transparency = 0.5
	adornment.Size = Vector3.new(4, 6, 2)
	adornment.Parent = nil

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPBillboard"
	billboard.Adornee = nil
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = nil

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Parent = billboard

	return adornment, billboard, label
end

local function removeESPForPlayer(plr)
	if espObjects[plr] then
		if espObjects[plr].box then
			espObjects[plr].box:Destroy()
		end
		if espObjects[plr].billboard then
			espObjects[plr].billboard:Destroy()
		end
		espObjects[plr] = nil
	end
end

local function updateESP()
	for plr, objects in pairs(espObjects) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			objects.box.Adornee = plr.Character.HumanoidRootPart
			objects.billboard.Adornee = plr.Character.HumanoidRootPart
			objects.billboard.TextLabel.Text = plr.Name
		else
			removeESPForPlayer(plr)
		end
	end
end

local function toggleESP(state)
	espEnabled = state
	if not espEnabled then
		for plr, _ in pairs(espObjects) do
			removeESPForPlayer(plr)
		end
		espObjects = {}
		return
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not espObjects[plr] then
				local box, billboard, label = createESPForPlayer(plr)
				box.Parent = plr.Character.HumanoidRootPart
				billboard.Parent = plr.Character.HumanoidRootPart
				label.Text = plr.Name
				espObjects[plr] = {box = box, billboard = billboard}
			end
		end
	end
end

-- Actualizar ESP en cada frame si está activado
RunService.Heartbeat:Connect(function()
	if espEnabled then
		updateESP()
	end
end)

-- Aimbot: Encontrar enemigo más cercano al centro de pantalla dentro del FOV
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

-- Aplicar aimbot (mover mouse)
RunService.Heartbeat:Connect(function()
	if aimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local mouse = LocalPlayer:GetMouse()
		local target = getClosestEnemy()
		if target and target.Character and target.Character:FindFirstChild(aimbotAimPart) then
			local pos = Camera:WorldToViewportPoint(target.Character[aimbotAimPart].Position)
			pcall(function()
				mouse.X = pos.X
				mouse.Y = pos.Y
			end)
		end
	end
end)

-- Botón ESP toggle
espBtn.MouseButton1Click:Connect(function()
	toggleESP(not espEnabled)
	espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

-- Botón Aimbot toggle
aimBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)
