-- 🚀 Auto TP entre TODOS los mapas a TODAS las gemas y orbes (Legends of Speed ultra roto)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local autoFarmEnabled = false
local moveDelay = 0.005 -- más rápido, ajusta si da lag

-- Crear GUI botón flotante
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraAutoFarmMultiMap"
ScreenGui.Parent = game.CoreGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleAutoFarm"
toggleBtn.Text = "AutoFarm ALL: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.Size = UDim2.new(0, 170, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 180)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = ScreenGui

local uicorner = Instance.new("UICorner", toggleBtn)
uicorner.CornerRadius = UDim.new(0, 10)

-- Drag variables
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

-- Función para obtener todas las gemas/orbes en todos los mapas (modelos o carpetas dentro de workspace)
local function getAllFarmables()
	local farmables = {}
	for _, map in pairs(workspace:GetChildren()) do
		-- Solo modelos o carpetas grandes de mapas, evitemos partes sueltas
		if map:IsA("Model") or map:IsA("Folder") then
			for _, obj in pairs(map:GetDescendants()) do
				if obj:IsA("BasePart") then
					local nameLower = obj.Name:lower()
					if nameLower:find("gem") or nameLower:find("orb") or nameLower:find("collectible") or nameLower:find("step") then
						table.insert(farmables, obj)
					end
				end
			end
		end
	end
	return farmables
end

-- Coroutine para teletransportar el personaje rapidísimo a cada gema/orbe
coroutine.wrap(function()
	while true do
		if autoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local root = LocalPlayer.Character.HumanoidRootPart
			local farmables = getAllFarmables()
			for _, obj in pairs(farmables) do
				pcall(function()
					root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
				end)
				task.wait(moveDelay)
			end
		end
		task.wait(0.5)
	end
end)()

-- Toggle botón
toggleBtn.MouseButton1Click:Connect(function()
	autoFarmEnabled = not autoFarmEnabled
	toggleBtn.Text = "AutoFarm ALL: " .. (autoFarmEnabled and "ON" or "OFF")
	if autoFarmEnabled then
		print("🟢 AutoFarm todos los mapas ACTIVADO")
	else
		print("🔴 AutoFarm todos los mapas DESACTIVADO")
	end
end)
