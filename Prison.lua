local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PrisonLifeModMenu"

local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. Modo Dios permanente (aura protectora)
local godModeEnabled = false
local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        print("🟢 Modo Dios ACTIVADO")
        -- El aura protectora es un efecto que evita daño
        -- Aquí simulamos revivir con aura permanente
        spawn(function()
            while godModeEnabled and task.wait(1) do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    -- Setea la salud al máximo constantemente
                    LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                    -- Además si existe Aura en workspace lo mantenemos o creamos uno
                    -- Podés agregar aquí un efecto visual si querés
                end
            end
        end)
    else
        print("🔴 Modo Dios DESACTIVADO")
    end
end

-- 2. Kill All funcional (matan todos en un botón)
local function killAll()
    local players = Players:GetPlayers()
    for _, plr in pairs(players) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            pcall(function()
                plr.Character.Humanoid.Health = 0
            end)
        end
    end
    print("💀 Kill All ejecutado.")
end

-- 3. Obtener AK47 con 1 botón
local function giveAK47()
    local weaponFolder = LocalPlayer.Backpack
    if not weaponFolder:FindFirstChild("AK47") then
        -- Si existe evento para pedir arma, usarlo
        local giveGunEvent = RS:FindFirstChild("GiveGun") or RS:WaitForChild("GiveGun")
        if giveGunEvent then
            giveGunEvent:FireServer("AK47")
            print("🔫 AK47 solicitada.")
        else
            print("⚠️ Evento GiveGun no encontrado.")
        end
    else
        print("⚠️ Ya tienes AK47.")
    end
end

-- 4. No recargar (funciona para disparo continuo sin recarga)
local noReloadEnabled = false
local function toggleNoReload()
    noReloadEnabled = not noReloadEnabled
    if noReloadEnabled then
        print("🎯 No recargar ACTIVADO")
        -- Hook para evitar recarga o mantener munición infinita
        -- Ejemplo básico: cancelar evento recarga o resetear munición
        spawn(function()
            while noReloadEnabled and task.wait(0.1) do
                if LocalPlayer.Backpack:FindFirstChild("AK47") then
                    local gun = LocalPlayer.Backpack.AK47
                    if gun:FindFirstChild("Ammo") then
                        gun.Ammo.Value = gun.Ammo.MaxValue
                    end
                end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47") then
                    local gun = LocalPlayer.Character.AK47
                    if gun:FindFirstChild("Ammo") then
                        gun.Ammo.Value = gun.Ammo.MaxValue
                    end
                end
            end
        end)
    else
        print("🔴 No recargar DESACTIVADO")
    end
end

-- Crear botones
createButton("Modo Dios", 50, toggleGodMode)
createButton("Kill All", 100, killAll)
createButton("Obtener AK47", 150, giveAK47)
createButton("No Recargar", 200, toggleNoReload)

print("✅ Prison Life Mod Menu cargado.")
