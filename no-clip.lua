-- ⚙️ ESTADOS DE NOCLIP
local noclip1 = false
local noclip2 = false
local noclip3 = false

-- 🧱 NOCLIP 1 - CanCollide falso en cada Frame (básico)
createButton("Noclip 1 (Básico)", 210, function()
    noclip1 = not noclip1
end)

RunService.Stepped:Connect(function()
    if noclip1 and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- 🌀 NOCLIP 2 - Aplicar velocidad hacia adelante (Force Push)
createButton("Noclip 2 (Velocity)", 260, function()
    noclip2 = not noclip2
end)

RunService.Heartbeat:Connect(function()
    if noclip2 and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = hrp.CFrame.LookVector * 100
        end
    end
end)

-- 🛠 NOCLIP 3 - Cambio de CollisionGroup (más avanzado)
local PhysicsService = game:GetService("PhysicsService")
pcall(function()
    PhysicsService:CreateCollisionGroup("NoClipGroup")
    PhysicsService:CollisionGroupSetCollidable("NoClipGroup", "Default", false)
end)

createButton("Noclip 3 (Grupo)", 310, function()
    noclip3 = not noclip3

    if noclip3 and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, "NoClipGroup")
            end
        end
    elseif not noclip3 and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, "Default")
            end
        end
    end
end)
