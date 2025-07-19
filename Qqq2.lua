-- Script mejorado para Auto-Teletransporte en Legends of Speed
-- Desarrollado por Gemini para una experiencia "ultra rota"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local autoFarmEnabled = false
local moveDelay = 0.005 -- Ajusta esto si experimentas lag o quieres ir más rápido
local teleportOffset = Vector3.new(0, 3, 0) -- Un poco por encima del orbe/gema

-- --- GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendsOfSpeed_AutoFarm"
ScreenGui.Parent = game.CoreGui

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

-- Drag functionality (Copied from your original, it's good!)
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

-- --- Funciones de Auto-Farm ---
local function isFarmable(obj)
    -- Verifica si el objeto es una parte base (BasePart) y si su nombre
    -- sugiere que es un recolectable (gema, orbe, etc.).
    -- También puedes añadir un filtro por tamaño si quieres, por ejemplo:
    -- and obj.Size.Y < 10 -- para evitar objetos muy grandes
    
    if obj:IsA("BasePart") then
        local nameLower = obj.Name:lower()
        if nameLower:find("gem") or nameLower:find("orb") or nameLower:find("collectible") or 
           nameLower:find("token") or nameLower:find("coin") or nameLower:find("crystal") or
           nameLower:find("point") or nameLower:find("step") then -- "step" puede ser para puntos de velocidad
            return true
        end
    end
    return false
end

local function getAllFarmablesAcrossMaps()
    local farmables = {}
    -- Recorre todo el workspace para encontrar objetos, sin importar la jerarquía.
    -- Esto es crucial para detectar orbes y gemas que no estén en "Modelos" o "Carpetas" explícitas de mapas.
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isFarmable(obj) then
            -- Añade una verificación extra para asegurar que el objeto sea visible y no esté "muerto"
            if obj.Transparency < 1 and obj.CanCollide == false and obj.Parent and obj.Parent:IsA("Model") then
                -- A veces, los objetos recolectables están en modelos, podemos verificar si el padre es un modelo
                -- y si el modelo no está en el carácter del jugador o es un efecto visual.
                if not obj.Parent:IsDescendantOf(LocalPlayer.Character) and not string.find(obj.Parent.Name:lower(), "effect") then
                     table.insert(farmables, obj)
                end
            elseif obj.Transparency < 1 and obj.CanCollide == false then
                 -- Si no es parte de un modelo explícito, lo agregamos igual
                 table.insert(farmables, obj)
            end
        end
    end
    return farmables
end

-- Coroutine principal para el Auto-Farm
coroutine.wrap(function()
    while task.wait(0.5) do -- Espera 0.5 segundos para no sobrecargar el sistema
        if autoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local farmables = getAllFarmablesAcrossMaps()

            if #farmables > 0 then
                for _, obj in pairs(farmables) do
                    -- Verificar si el objeto aún existe en el juego antes de intentar teletransportarse
                    if obj and obj.Parent then
                        pcall(function()
                            -- Teletransporte a la posición del objeto más un offset
                            root.CFrame = obj.CFrame + teleportOffset
                        end)
                        task.wait(moveDelay) -- Pequeña pausa entre teletransportes
                    end
                end
            else
                print("⚠️ No se encontraron orbes/gemas recolectables en este momento.")
            end
        end
    end
end)()

-- --- Toggle del botón ---
toggleBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    toggleBtn.Text = "AutoFarm ALL: " .. (autoFarmEnabled and "ON" or "OFF")
    if autoFarmEnabled then
        print("🟢 AutoFarm TODOS los mapas y ORBES/GEMAS ACTIVADO.")
    else
        print("🔴 AutoFarm TODOS los mapas y ORBES/GEMAS DESACTIVADO.")
    end
end)

print("✅ Script de Auto-Farm para Legends of Speed cargado.")
