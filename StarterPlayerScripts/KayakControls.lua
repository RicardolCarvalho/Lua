local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local KayakInput = ReplicatedStorage:WaitForChild("KayakInput")

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local seat = nil

humanoid.Seated:Connect(function(active, currentSeat)
    if active and currentSeat.Name == "RowerSeat" then
        seat = currentSeat
        -- desancorar do servidor
    else
        seat = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not seat then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        KayakInput:FireServer("Forward", true)
    elseif key == Enum.KeyCode.S then
        KayakInput:FireServer("Backward", true)
    elseif key == Enum.KeyCode.A then
        KayakInput:FireServer("Left", true)
    elseif key == Enum.KeyCode.D then
        KayakInput:FireServer("Right", true)
    end
end)

-- Enviar evento de key up para parar movimento
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not seat then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        KayakInput:FireServer("Forward", false)
    elseif key == Enum.KeyCode.S then
        KayakInput:FireServer("Backward", false)
    elseif key == Enum.KeyCode.A then
        KayakInput:FireServer("Left", false)
    elseif key == Enum.KeyCode.D then
        KayakInput:FireServer("Right", false)
    end
end) 