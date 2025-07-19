-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Estados
local states = {
    noclip = false,
    espPlayers = false,
    espBases = false,
    autoRob = false,
    tpBrainrots = false,
    killAura = false,
    invis = false,
    superJump = false,
    speed = false
}

-- GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotModMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Función para hacer arrastrable cualquier GUI
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Botón flotante para abrir/cerrar menú (ícono negro)
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Text = "☰"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 24
toggleBtn.ZIndex = 10
toggleBtn.AutoButtonColor = false
toggleBtn.BorderSizePixel = 0
makeDraggable(toggleBtn)

-- Frame del menú
local menuFrame = Instance.new("Frame", ScreenGui)
menuFrame.Size = UDim2.new(0, 250, 0, 400)
menuFrame.Position = UDim2.new(0, 70, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.ZIndex = 10
makeDraggable(menuFrame)

-- Scroll arrastrable
local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.ZIndex = 10

-- Crear botones toggle con estado
local buttonCount = 0
local function createToggle(name, stateKey, callback)
    buttonCount += 1
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (buttonCount - 1) * 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name .. " [OFF]"
    btn.ZIndex = 10
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and " [ON]" or " [OFF]")
        callback(states[stateKey])
    end)
end

-- Funciones para cada toggle

-- Noclip normal (activa/desactiva CanCollide de todas las partes del personaje)
createToggle("Noclip Normal", "noclip", function(enabled)
    if enabled then
        if states._noclipConn then states._noclipConn:Disconnect() end
        states._noclipConn = RunService.Stepped:Connect(function()
            if states.noclip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if states._noclipConn then
            states._noclipConn:Disconnect()
            states._noclipConn = nil
        end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- ESP Jugadores
createToggle("ESP Jugadores", "espPlayers", function(enabled)
    if enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPBox") then
                local box = Instance.new("BillboardGui", p.Character:WaitForChild("Head"))
                box.Name = "ESPBox"
                box.Size = UDim2.new(0, 100, 0, 40)
                box.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", box)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Text = p.Name
                txt.TextColor3 = Color3.new(1, 0, 0)
                txt.BackgroundTransparency = 1
                txt.TextScaled = true
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESPBox") then
                p.Character.ESPBox:Destroy()
            end
        end
    end
end)

-- ESP Bases (Tiempo)
createToggle("ESP Bases (Tiempo)", "espBases", function(enabled)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Locked") then
            if enabled then
                local gui = Instance.new("BillboardGui", v.PrimaryPart or v:FindFirstChildOfClass("BasePart"))
                gui.Size = UDim2.new(0, 100, 0, 40)
                gui.AlwaysOnTop = true
                gui.Name = "BaseESP"
                local txt = Instance.new("TextLabel", gui)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Text = "Base: " .. v.Locked.Text
                txt.TextColor3 = Color3.new(0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.TextScaled = true
            else
                local esp = v:FindFirstChild("BaseESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- Auto-Rob
createToggle("Auto-Rob", "autoRob", function(enabled)
    if enabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:lower():find("bank") then
                fireclickdetector(v)
            end
        end
    end
end)

-- TP a Brainrots
createToggle("TP a Brainrots", "tpBrainrots", function(enabled)
    if enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("brain") and obj:IsA("BasePart") then
                LocalPlayer.Character:MoveTo(obj.Position)
                wait(0.3)
            end
        end
    end
end)

-- Kill Aura
createToggle("Kill Aura (Cerca)", "killAura", function(enabled)
    if states._killAuraConn then states._killAuraConn:Disconnect() end
    if enabled then
        states._killAuraConn = RunService.Stepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and (p.Character:FindFirstChild("HumanoidRootPart").Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 10 then
                    p.Character:BreakJoints()
                end
            end
        end)
    end
end)

-- Invisibilidad
createToggle("Invisibilidad", "invis", function(enabled)
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = enabled and 1 or 0
            end
        end
    end
end)

-- Super Salto
createToggle("Super Salto", "superJump", function(enabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = enabled and 200 or 50
    end
end)

-- Speed x120
createToggle("Speed x120", "speed", function(enabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = enabled and 120 or 16
    end
end)

-- Mantener speed con Brainrot en mano
RunService.RenderStepped:Connect(function()
    if states.speed and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool.Name:lower():find("brain") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 120
        end
    end
end)

-- Toggle menú visible
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)
