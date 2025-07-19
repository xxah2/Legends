-- 🚀 Ultra OP Auto Collect Gems GLOBAL (todos los mapas y sin límite de rango)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local autoCollectEnabled = false

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoCollectGUI"
ScreenGui.Parent = game.CoreGui

-- Botón flotante "C"
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleAutoCollect"
toggleBtn.Text = "Collect: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Size = UDim2.new(0, 140, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 150)
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

-- Toggle función al click
toggleBtn.MouseButton1Click:Connect(function()
	autoCollectEnabled = not autoCollectEnabled
	toggleBtn.Text = "Collect: " .. (autoCollectEnabled and "ON" or "OFF")
	if autoCollectEnabled then
		print("🟢 Auto Collect Gems ACTIVADO")
	else
		print("🔴 Auto Collect Gems DESACTIVADO")
	end
end)

-- Loop para auto recoger gems en todo el juego
RunService.Heartbeat:Connect(function()
	if autoCollectEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		-- Buscamos todas las gemas en workspace
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and (obj.Name:lower():find("gem") or obj.Name:lower():find("collectible")) then
				-- Teletransportamos la gema directo al jugador (abajo de los pies para que la recoja rápido)
				obj.CFrame = root.CFrame * CFrame.new(0, -3, 0)
			end
		end
	end
end)
