-- Script mejorado para Auto-Teletransporte en Legends of Speed
-- Desarrollado por Gemini para una experiencia "ultra rota"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local autoFarmEnabled = false
local autoTeleportToMapsEnabled = false
local moveDelay = 0.005 -- Ajusta esto si experimentas lag o quieres ir más rápido
local teleportOffset = Vector3.new(0, 3, 0) -- Un poco por encima del orbe/gema

-- --- Configuración de Mundos/Mapas ---
-- Aquí puedes añadir las coordenadas o los nombres de las partes que actúan como teletransportadores
-- Si conoces las coordenadas exactas de los puntos de inicio de cada mundo, puedes usarlas directamente.
-- Ejemplo: WorldName = Vector3.new(X, Y, Z)
-- O si son objetos en el workspace, puedes usar su nombre o parte del nombre para identificarlos.
local worldTeleportTargets = {
    -- Si sabes coordenadas exactas (ejemplo hipotético):
    -- ["Mundo 2"] = Vector3.new(1000, 10, 500),
    -- ["Mundo de Hielo"] = Vector3.new(2500, 10, 1500),

    -- Si son objetos en el juego que actúan como portales (puedes añadir más patrones):
    "Portal", -- Busca objetos con el nombre "Portal"
    "WorldEntrance", -- Busca objetos con el nombre "WorldEntrance"
    "TeleporterPad", -- Busca objetos con el nombre "TeleporterPad"
    -- Puedes añadir más nombres o patrones aquí según lo que encuentres en el juego.
    -- Ejemplo: "Area_Forest_Teleport", "Zone2_Entrance"
}

local currentWorldIndex = 1 -- Para ciclar entre los mundos

-- --- GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendsOfSpeed_AutoFarm"
ScreenGui.Parent = game.CoreGui

-- Botón de AutoFarm
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleAutoFarm"
toggleBtn.Text = "AutoFarm ALL: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Size = UDim2.new(0, 170, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 180) -- Posición inicial
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = ScreenGui

local uicorner = Instance.new("UICorner", toggleBtn)
uicorner.CornerRadius = UDim.new(0, 10)

-- Botón de Auto-Teletransporte entre Mundos
local toggleMapTPBtn = Instance.new("TextButton")
toggleMapTPBtn.Name = "ToggleMapTeleport"
toggleMapTPBtn.Text = "AutoTP Mundos: OFF"
toggleMapTPBtn.Font = Enum.Font.GothamBold
toggleMapTPBtn.TextSize = 22
toggleMapTPBtn.TextColor3 = Color3.new(1, 1, 1)
toggleMapTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleMapTPBtn.Size = UDim2.new(0, 170, 0, 50)
toggleMapTPBtn.Position = UDim2.new(0, 20, 0, 240) -- Debajo del botón de AutoFarm
toggleMapTPBtn.AutoButtonColor = false
toggleMapTPBtn.Parent = ScreenGui

local uicornerMapTP = Instance.new("UICorner", toggleMapTPBtn)
uicornerMapTP.CornerRadius = UDim.new(0, 10)

-- Drag functionality (Copied from your original, it's good!)
local dragging = false
local dragInput, mousePos, framePos

local function setupDraggable(button)
    local isDragging = false
    local lastMousePosition = Vector2.zero
    local lastButtonPosition = UDim2.new()

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            lastMousePosition = input.Position
            lastButtonPosition = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            local delta = input.Position - lastMousePosition
            button.Position = UDim2.new(
                lastButtonPosition.X.Scale,
                lastButtonPosition.X.Offset + delta.X,
                lastButtonPosition.Y.Scale,
                lastButtonPosition.Y.Offset + delta.Y
            )
        end
    end)
end

setupDraggable(toggleBtn)
setupDraggable(toggleMapTPBtn)

-- --- Funciones de Auto-Farm ---
local function isFarmable(obj)
    if obj:IsA("BasePart") then
        local nameLower = obj.Name:lower()
        if nameLower:find("gem") or nameLower:find("orb") or nameLower:find("collectible") or
           nameLower:find("token") or nameLower:find("coin") or nameLower:find("crystal") or
           nameLower:find("point") or nameLower:find("step") then
            return true
        end
    end
    return false
end

local function getAllFarmablesAcrossMaps()
    local farmables = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isFarmable(obj) then
            if obj.Transparency < 1 and obj.CanCollide == false and obj.Parent then
                if not obj.Parent:IsDescendantOf(LocalPlayer.Character) and not string.find(obj.Parent.Name:lower(), "effect") then
                     table.insert(farmables, obj)
                end
            end
        end
    end
    return farmables
end

local function findWorldTeleporter(targetNameOrCoord)
    if type(targetNameOrCoord) == "Vector3" then
        -- Si es una coordenada, solo devuelve la coordenada.
        return targetNameOrCoord
    elseif type(targetNameOrCoord) == "string" then
        -- Si es un nombre, busca el objeto en el workspace.
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(targetNameOrCoord:lower()) then
                return obj.CFrame.p -- Devuelve la posición del objeto
            end
        end
    end
    return nil
end

-- Coroutine principal para el Auto-Farm
coroutine.wrap(function()
    while task.wait(0.5) do
        if autoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local farmables = getAllFarmablesAcrossMaps()

            if #farmables > 0 then
                for _, obj in pairs(farmables) do
                    if obj and obj.Parent then
                        pcall(function()
                            root.CFrame = obj.CFrame + teleportOffset
                        end)
                        task.wait(moveDelay)
                    end
                end
            else
                print("⚠️ No se encontraron orbes/gemas recolectables en este momento.")
            end
        end
    end
end)()

-- Coroutine para el Auto-Teletransporte entre Mundos
coroutine.wrap(function()
    while task.wait(5) do -- Espera 5 segundos antes de intentar el siguiente teletransporte entre mundos
        if autoTeleportToMapsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and #worldTeleportTargets > 0 then
            local root = LocalPlayer.Character.HumanoidRootPart

            local target = worldTeleportTargets[currentWorldIndex]
            local targetPosition = findWorldTeleporter(target)

            if targetPosition then
                pcall(function()
                    root.CFrame = CFrame.new(targetPosition) + teleportOffset
                    print("🚀 Teletransportándose a: " .. (type(target) == "string" and target or "Coordenada " .. tostring(target)))
                end)
                currentWorldIndex = currentWorldIndex % #worldTeleportTargets + 1 -- Cicla al siguiente mundo
            else
                print("❌ No se encontró el objetivo de teletransporte para: " .. (type(target) == "string" and target or "Coordenada " .. tostring(target)))
            }
        end
    end
end)()


-- --- Toggle del botón de AutoFarm ---
toggleBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    toggleBtn.Text = "AutoFarm ALL: " .. (autoFarmEnabled and "ON" or "OFF")
    if autoFarmEnabled then
        print("🟢 AutoFarm TODOS los mapas y ORBES/GEMAS ACTIVADO.")
    else
        print("🔴 AutoFarm TODOS los mapas y ORBES/GEMAS DESACTIVADO.")
    end
end)

-- --- Toggle del botón de Auto-Teletransporte entre Mundos ---
toggleMapTPBtn.MouseButton1Click:Connect(function()
    autoTeleportToMapsEnabled = not autoTeleportToMapsEnabled
    toggleMapTPBtn.Text = "AutoTP Mundos: " .. (autoTeleportToMapsEnabled and "ON" or "OFF")
    if autoTeleportToMapsEnabled then
        print("🌐 Auto-Teletransporte entre Mundos ACTIVADO. Ciclando entre " .. #worldTeleportTargets .. " objetivos.")
    else
        print("🚫 Auto-Teletransporte entre Mundos DESACTIVADO.")
    end
end)

print("✅ Script de Auto-Farm y Navegación entre Mundos para Legends of Speed cargado.")
