-- Variables servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- Crear ScreenGui principal
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KillAllPrisonLife"

-- Crear frame para botones
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 260)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.BorderSizePixel = 0
Frame.Visible = true

-- Función para crear botones
local function createButton(text, position, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 180, 0, 50)
    btn.Position = UDim2.new(0, 10, 0, position)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.Text = text
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Función para conseguir enemigos (sin incluir local player y con humano y vivos)
local function getEnemies()
    local enemies = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            table.insert(enemies, plr)
        end
    end
    return enemies
end

-- Método 1: Ataque cuerpo a cuerpo simple (Golpeando el torso con arma melee)
local function killAllMelee()
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not weapon then
        warn("No tienes un arma equipada para melee")
        return
    end
    for _, enemy in pairs(getEnemies()) do
        if enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            -- Teletransportar cerca y atacar
            local hrp = enemy.Character.HumanoidRootPart
            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
            -- Ataque simple (trigger activación tool)
            weapon:Activate()
            wait(0.3)
            weapon:Deactivate()
            wait(0.3)
        end
    end
end

-- Método 2: Disparar con arma (solo si el arma es de fuego)
local function killAllShoot()
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not weapon then
        warn("No tienes un arma equipada para disparar")
        return
    end

    for _, enemy in pairs(getEnemies()) do
        if enemy.Character and enemy.Character:FindFirstChild("Head") then
            -- Apuntar al head enemigo
            local targetPos = enemy.Character.Head.Position
            -- Simular disparo (varía según el arma, aquí se usa tool:Activate() y apuntar el mouse)
            Mouse.Target = enemy.Character.Head
            weapon:Activate()
            wait(0.2)
            weapon:Deactivate()
            wait(0.3)
        end
    end
end

-- Método 3: Teletransportarse detrás y atacar melee
local function killAllTeleportMelee()
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not weapon then
        warn("No tienes un arma equipada para melee")
        return
    end
    for _, enemy in pairs(getEnemies()) do
        if enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = enemy.Character.HumanoidRootPart
            -- Teletransportar justo detrás
            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            weapon:Activate()
            wait(0.3)
            weapon:Deactivate()
            wait(0.3)
        end
    end
end

-- Método 4: Matar usando evento de disparo o golpe (ejemplo con RemoteEvent)
local function killAllRemote()
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not weapon then
        warn("No tienes un arma equipada")
        return
    end

    local remote = LocalPlayer.Backpack:FindFirstChild("RemoteEvent") or LocalPlayer.Character:FindFirstChild("RemoteEvent")

    for _, enemy in pairs(getEnemies()) do
        if enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            if remote then
                -- Intenta disparar directo con el remoto si es posible (esto depende de la estructura del juego)
                remote:FireServer(enemy.Character.HumanoidRootPart.Position)
            else
                -- Si no hay remoto, hacer ataque melee normal
                local hrp = enemy.Character.HumanoidRootPart
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                weapon:Activate()
                wait(0.3)
                weapon:Deactivate()
            end
            wait(0.3)
        end
    end
end

-- Crear botones en GUI
createButton("Kill All Melee", 10, killAllMelee)
createButton("Kill All Shoot", 70, killAllShoot)
createButton("Kill All Teleport Melee", 130, killAllTeleportMelee)
createButton("Kill All Remote Event", 190, killAllRemote)
