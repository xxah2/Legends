-- 🔥 Ultra OP Auto Farm infinito para Legends of Speed (gems, orbs, pasos y más)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local autoFarmEnabled = false
local moveDelay = 0.01 -- tiempo entre teletransportes (más bajo = más rápido)

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraAutoFarmGUI"
ScreenGui.Parent = game.CoreGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleAutoFarm"
toggleBtn.Text = "AutoFarm: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleBtn.Size = UDim2.new(0, 150, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 180)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = ScreenGui

local uicorner = Instance.new("UICorner", toggleBtn)
uicorner.CornerRadius = UDim.new(0, 10)

-- Variables para drag
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

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Función para encontrar todos los objetos farmables
local function getFarmables()
	local farmables = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local nameLower = obj.Name:lower()
			if nameLower:find("gem") or nameLower:find("orb") or nameLower:find("step") or nameLower:find("collectible") then
				table.insert(farmables, obj)
			end
		end
	end
	return farmables
end

-- Loop ultra rápido para teletransportar al jugador
RunService.Heartbeat:Connect(function()
	if autoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		local farmables = getFarmables()
		for _, obj in pairs(farmables) do
			pcall(function()
				root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
				task.wait(moveDelay)
			end)
		end
	end
end)

-- Toggle botón
toggleBtn.MouseButton1Click:Connect(function()
	autoFarmEnabled = not autoFarmEnabled
	toggleBtn.Text = "AutoFarm: " .. (autoFarmEnabled and "ON" or "OFF")
	if autoFarmEnabled then
		print("🟢 Auto Farm ACTIVADO")
	else
		print("🔴 Auto Farm DESACTIVADO")
	end
end)
