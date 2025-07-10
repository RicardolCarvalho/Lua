local Players = game:GetService("Players")

-- Leaderstats em script separado
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Money"
    money.Value = 0
    money.Parent = leaderstats
end)

for _, player in pairs(Players:GetPlayers()) do
    if not player:FindFirstChild("leaderstats") then
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        local money = Instance.new("IntValue")
        money.Name = "Money"
        money.Value = 0
        money.Parent = leaderstats
    end
end 