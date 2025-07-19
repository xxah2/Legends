local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Botón flotante
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KillAllBtn"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 50)
button.Position = UDim2.new(0, 20, 0, 200)
button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
button.TextColor3 = Color3.new(1,1,1)
button.Text = "KILL ALL 🔥"
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.Parent = gui

local uicorner = Instance.new("UICorner", button)
uicorner.CornerRadius = UDim.new(0, 12)

-- Función de Kill All
button.MouseButton1Click:Connect(function()
    local hitEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("HitPart") -- Remoto de disparo

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            -- Simular disparo a la cabeza
            for i = 1, 3 do -- Mandamos varios hits por seguridad
                pcall(function()
                    hitEvent:FireServer(head, head.Position, head, Vector3.new(), 100, Enum.Material.Plastic, "Headshot")
                end)
            end
        end
    end
end)

print("✅ KILL ALL cargado.")
