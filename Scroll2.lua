-- 📦 Servicios local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local RunService = game:GetService("RunService") local UIS = game:GetService("UserInputService")

-- 🧠 Estados local states = { noclip = false, espPlayers = false, espBases = false, autoRob = false, tpBrainrots = false, killAura = false, invis = false, superJump = false, speed = false }

-- 🖼 GUI local gui = Instance.new("ScreenGui", game.CoreGui) gu.ResetOnSpawn = false gu.Name = "BrainrotModMenu"

-- 🔘 Botón flotante local toggle = Instance.new("TextButton", gui) toggle.Size = UDim2.new(0, 40, 0, 40) toggle.Position = UDim2.new(0, 20, 0.5, -20) toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20) toggle.Text = "☰" toggle.TextColor3 = Color3.new(1, 1, 1) toggle.TextSize = 24 toggle.ZIndex = 10

-- 🧱 Menú local frame = Instance.new("Frame", gui) frame.Size = UDim2.new(0, 250, 0, 400) frame.Position = UDim2.new(0, 70, 0.5, -200) frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) frame.Visible = false frame.Active = true frame.Draggable = true

-- 🎛 Scroll local scroll = Instance.new("ScrollingFrame", frame) scroll.Size = UDim2.new(1, 0, 1, 0) scroll.CanvasSize = UDim2.new(0, 0, 0, 1000) scroll.BackgroundTransparency = 1 scroll.ScrollBarThickness = 4

-- 📋 Creador de botones con interruptor local buttonCount = 0 local function createToggle(name, stateKey, callback) buttonCount += 1 local btn = Instance.new("TextButton", scroll) btn.Size = UDim2.new(1, -20, 0, 40) btn.Position = UDim2.new(0, 10, 0, (buttonCount - 1) * 45) btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) btn.TextColor3 = Color3.new(1, 1, 1) btn.Font = Enum.Font.SourceSansBold btn.TextSize = 18 btn.Text = name .. " [OFF]"

btn.MouseButton1Click:Connect(function()
    states[stateKey] = not states[stateKey]
    btn.Text = name .. (states[stateKey] and " [ON]" or " [OFF]")
    callback(states[stateKey])
end)

end

-- 🧱 Noclip solo para paredes createToggle("Noclip paredes/bases", "noclip", function(enabled) RunService.Stepped:Connect(function() if enabled and LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then local touching = part:GetTouchingParts() for _, hit in pairs(touching) do if hit:IsDescendantOf(workspace) and (hit.Name:lower():match("wall") or hit.Name:lower():match("base")) then part.CanCollide = false end end end end end end) end)

-- 🔍 ESP jugadores createToggle("ESP Jugadores", "espPlayers", function(enabled) if enabled then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPBox") then local box = Instance.new("BillboardGui", p.Character:WaitForChild("Head")) box.Name = "ESPBox" box.Size = UDim2.new(0,100,0,40) box.AlwaysOnTop = true local txt = Instance.new("TextLabel", box) txt.Size = UDim2.new(1,0,1,0) txt.Text = p.Name txt.TextColor3 = Color3.new(1,0,0) txt.BackgroundTransparency = 1 txt.TextScaled = true end end else for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESPBox") then p.Character.ESPBox:Destroy() end end end end)

-- 🧠 ESP bases con temporizador createToggle("ESP Bases (Tiempo)", "espBases", function(enabled) for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Model") and v:FindFirstChild("Locked") then if enabled then local gui = Instance.new("BillboardGui", v.PrimaryPart or v:FindFirstChildOfClass("BasePart")) gui.Size = UDim2.new(0,100,0,40) gui.AlwaysOnTop = true gui.Name = "BaseESP" local txt = Instance.new("TextLabel", gui) txt.Size = UDim2.new(1,0,1,0) txt.Text = "Base: " .. v.Locked.Text txt.TextColor3 = Color3.new(0,1,0) txt.BackgroundTransparency = 1 txt.TextScaled = true else local esp = v:FindFirstChild("BaseESP") if esp then esp:Destroy() end end end end end)

-- 🚪 Auto Rob createToggle("Auto-Rob", "autoRob", function(enabled) if enabled then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:lower():find("bank") then fireclickdetector(v) end end end end)

-- 🚀 TP Brainrots createToggle("TP a Brainrots", "tpBrainrots", function(enabled) if enabled then for _, obj in pairs(workspace:GetDescendants()) do if obj.Name:lower():find("brain") and obj:IsA("BasePart") then LocalPlayer.Character:MoveTo(obj.Position) wait(0.3) end end end end)

-- ☠️ Kill Aura createToggle("Kill Aura (Cerca)", "killAura", function(enabled) RunService.Stepped:Connect(function() if enabled then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and (p.Character:FindFirstChild("HumanoidRootPart").Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 10 then p.Character:BreakJoints() end end end end) end)

-- 👻 Invisibilidad createToggle("Invisibilidad", "invis", function(enabled) for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = enabled and 1 or 0 end end end)

-- 🦘 Super salto createToggle("Super Salto", "superJump", function(enabled) LocalPlayer.Character.Humanoid.JumpPower = enabled and 200 or 50 end)

-- ⚡ Speed x120 (mantiene velocidad con Brainrot) createToggle("Speed x120", "speed", function(enabled) if enabled then LocalPlayer.Character.Humanoid.WalkSpeed = 120 else LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)

RunService.RenderStepped:Connect(function() if states.speed and LocalPlayer.Character then local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if tool and tool.Name:lower():find("brain") then LocalPlayer.Character.Humanoid.WalkSpeed = 120 end end end)

-- Mostrar/Ocultar menú toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

