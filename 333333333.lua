-- 📦 Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- 🧠 Estados
local flying, noclip, espOn, aura = false, false, false, false
local speed = 50

-- 🖼 GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotModMenu"
gui.ResetOnSpawn = false

-- 🔘 Botón flotante
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(0, 20, 0.5, -20)
toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggle.Text = "☰"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 24
toggle.ZIndex = 10

-- 🧱 Menú
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0, 70, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Active = true
frame.Draggable = true

-- 🎛 Scroll
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4

-- 📋 Creador de botones
local function createToggle(name, callback)
	local btn = Instance.new("TextButton", scroll)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, #scroll:GetChildren() * 45)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.MouseButton1Click:Connect(callback)
end

-- ✈️ Fly
createToggle("Fly (Toggle)", function()
	flying = not flying
	if flying then
		local bp = Instance.new("BodyVelocity")
		bp.Name = "FlyVelocity"
		bp.MaxForce = Vector3.new(1e9,1e9,1e9)
		bp.Velocity = Vector3.zero
		bp.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		RunService.RenderStepped:Connect(function()
			if flying and bp and bp.Parent then
				local dir = Vector3.new()
				if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
				bp.Velocity = dir.Unit * speed
			end
		end)
	else
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
	end
end)

-- 🧱 Noclip
createToggle("Noclip (Toggle)", function()
	noclip = not noclip
	RunService.Stepped:Connect(function()
		if noclip and LocalPlayer.Character then
			for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)
end)

-- 🔍 ESP básico
createToggle("ESP Jugadores", function()
	espOn = not espOn
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPBox") then
			local box = Instance.new("BillboardGui", p.Character:WaitForChild("Head"))
			box.Name = "ESPBox"
			box.Size = UDim2.new(0,100,0,40)
			box.AlwaysOnTop = true
			local txt = Instance.new("TextLabel", box)
			txt.Size = UDim2.new(1,0,1,0)
			txt.Text = p.Name
			txt.TextColor3 = Color3.new(1,0,0)
			txt.BackgroundTransparency = 1
			txt.TextScaled = true
		end
	end
end)

-- 🧠 ESP Bases (temporizador simulado)
createToggle("ESP Bases (Tiempo)", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Locked") then
			local gui = Instance.new("BillboardGui", v.PrimaryPart or v:FindFirstChildOfClass("BasePart"))
			gui.Size = UDim2.new(0,100,0,40)
			gui.AlwaysOnTop = true
			local txt = Instance.new("TextLabel", gui)
			txt.Size = UDim2.new(1,0,1,0)
			txt.Text = "Base: " .. v.Locked.Text
			txt.TextColor3 = Color3.new(0,1,0)
			txt.BackgroundTransparency = 1
			txt.TextScaled = true
		end
	end
end)

-- 🚪 Auto-Rob
createToggle("Auto-Rob", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:lower():find("bank") then
			fireclickdetector(v)
		end
	end
end)

-- 🚀 Teleport Brainrot
createToggle("TP a Brainrots", function()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name:lower():find("brain") and obj:IsA("BasePart") then
			LocalPlayer.Character:MoveTo(obj.Position)
			wait(0.3)
		end
	end
end)

-- ☠️ Kill Aura
createToggle("Kill Aura (Cerca)", function()
	aura = not aura
	RunService.Stepped:Connect(function()
		if aura then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and (p.Character:FindFirstChild("HumanoidRootPart").Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 10 then
					p.Character:BreakJoints()
				end
			end
		end
	end)
end)

-- 👻 Invisibility
createToggle("Invisibilidad", function()
	for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
		end
	end
end)

-- 🦘 Super Salto
createToggle("Super Salto", function()
	LocalPlayer.Character.Humanoid.JumpPower = 200
end)

-- 📦 Mostrar/Ocultar menú
toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)
