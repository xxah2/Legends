local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PrisonLifeModMenu"

-- Botón simple creador
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. MODO DIOS PERMANENTE
local godModeEnabled = false
createButton("Modo Dios", 50, function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        print("Modo Dios ACTIVADO")
        spawn(function()
            while godModeEnabled do
                task.wait(0.5)
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end
        end)
    else
        print("Modo Dios DESACTIVADO")
    end
end)

-- 2. KILL ALL (mata a todos los enemigos)
createButton("Kill All", 100, function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local humanoid = plr.Character.Humanoid
            if humanoid.Health > 0 then
                -- Forzar la muerte modificando la salud
                pcall(function()
                    humanoid.Health = 0
                end)
            end
        end
    end
    print("Kill All ejecutado.")
end)

-- 3. OBTENER AK47 FUNCIONAL (con el evento correcto)
createButton("Obtener AK47", 150, function()
    local gunName = "AK47"
    local giveGunEvent = RS:FindFirstChild("GiveGun") or RS:WaitForChild("GiveGun")
    if giveGunEvent then
        giveGunEvent:FireServer(gunName)
        print(gunName .. " solicitada.")
    else
        print("Evento GiveGun no encontrado.")
    end
end)

-- 4. NO RECARGAR
local noReloadEnabled = false
createButton("No Recargar", 200, function()
    noReloadEnabled = not noReloadEnabled
    if noReloadEnabled then
        print("No Recargar ACTIVADO")
        spawn(function()
            while noReloadEnabled do
                task.wait(0.1)
                -- Manipular evento Reload para cancelar la recarga
                local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") 
                    or LocalPlayer.Backpack:FindFirstChild("Gun")
                if gun then
                    local reloadEvent = RS:FindFirstChild("Reload")
                    if reloadEvent then
                        -- Cancelar recarga enviando datos vacíos o falsos
                        pcall(function()
                            reloadEvent:FireServer(false)
                        end)
                    end
                    -- Además aseguramos munición máxima (si la hay)
                    if gun:FindFirstChild("Ammo") and gun:FindFirstChild("Ammo").Value < gun:FindFirstChild("Ammo").MaxValue then
                        gun.Ammo.Value = gun.Ammo.MaxValue
                    end
                end
            end
        end)
    else
        print("No Recargar DESACTIVADO")
    end
end)

print("Prison Life Mod Menu cargado y listo para usar.")
