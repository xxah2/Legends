local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local autoCollectEnabled = false
local collectedGems = {}
local moveDelay = 0.01 -- retraso mínimo entre teletransportes, ajustalo si quieres más rápido o estable

-- Activa o desactiva el Auto Collect
local function toggleAutoCollect(state)
	autoCollectEnabled = state
	collectedGems = {}
	if state then
		print("🟢 Auto Collect ULTRA OP ACTIVADO")
	else
		print("🔴 Auto Collect ULTRA OP DESACTIVADO")
	end
end

-- Función para encontrar todas las gemas en el workspace
local function getAllGems()
	local gems = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name:lower():find("gem") or obj.Name:lower():find("collectible")) then
			table.insert(gems, obj)
		end
	end
	return gems
end

-- Coroutine para teletransportar al jugador entre las gemas rapidísimo
coroutine.wrap(function()
	while true do
		if autoCollectEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local root = LocalPlayer.Character.HumanoidRootPart
			local gems = getAllGems()
			for _, gem in pairs(gems) do
				if not collectedGems[gem] then
					pcall(function()
						root.CFrame = gem.CFrame + Vector3.new(0, 3, 0) -- te teleportea encima de la gema
					end)
					-- Opcional: esperar un poco para que se recoja (ajustable)
					task.wait(moveDelay)
					collectedGems[gem] = true
				end
			end
		end
		task.wait(0.5) -- espera para actualizar la lista de gemas nuevas (ajustable)
	end
end)()

-- Ejemplo de uso:
toggleAutoCollect(true)
