-- ✅ Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ✅ Estados
local noclipEnabled = false
local speedEnabled = false

-- ✅ GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotMenu"
gui.ResetOnSpawn = false

-- ✅ Botón flotante
local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 20, 0.5, -20)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
icon.Text = "≡"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextSize = 20
icon.ZIndex = 10
icon.Active = true
icon.Draggable = true

-- ✅ Marco del menú
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 70, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.ZIndex = 9

-- ✅ Botones
local function createButton(text, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -20, 0, 40)
	button.Position = UDim2.new(0, 10, 0, (#frame:GetChildren() - 1) * 45)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Text = text .. " [OFF]"

	local active = false
	button.MouseButton1Click:Connect(function()
		active = not active
		button.Text = text .. (active and " [ON]" or " [OFF]")
		callback(active)
	end)
end

-- 🟨 Noclip clásico (no se desactiva al morir)
createButton("Noclip", function(enabled)
	noclipEnabled = enabled
end)

RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- 🟨 Speed x120 que persiste con brainrot y tras morir
createButton("Speed x120", function(enabled)
	speedEnabled = enabled
end)

RunService.RenderStepped:Connect(function()
	if LocalPlayer.Character and speedEnabled then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 120
		end
	end
end)

-- 🟥 Asegurar velocidad tras respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	repeat wait() until char:FindFirstChild("Humanoid")
	if speedEnabled then
		char:WaitForChild("Humanoid").WalkSpeed = 120
	end
end)

-- ✅ Mostrar/Ocultar menú
icon.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)
