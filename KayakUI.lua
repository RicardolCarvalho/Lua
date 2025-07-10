-- KayakUI.lua - Interface do usuário para o jogo de caiaques
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar a interface principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KayakRaceUI"
screenGui.Parent = playerGui

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🏆 Corrida de Caiaques 🏆"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Informações do jogador
local playerInfoLabel = Instance.new("TextLabel")
playerInfoLabel.Name = "PlayerInfo"
playerInfoLabel.Size = UDim2.new(1, 0, 0, 30)
playerInfoLabel.Position = UDim2.new(0, 0, 0, 40)
playerInfoLabel.BackgroundTransparency = 1
playerInfoLabel.Text = "Você é o LÍDER! Apenas dance! 💃"
playerInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerInfoLabel.TextScaled = true
playerInfoLabel.Font = Enum.Font.Gotham
playerInfoLabel.Parent = mainFrame

-- Timer da corrida
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(1, 0, 0, 40)
timerLabel.Position = UDim2.new(0, 0, 0, 70)
timerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
timerLabel.BackgroundTransparency = 0.5
timerLabel.Text = "Tempo: 02:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = mainFrame

-- Instruções
local instructionsLabel = Instance.new("TextLabel")
instructionsLabel.Name = "Instructions"
instructionsLabel.Size = UDim2.new(1, 0, 0, 50)
instructionsLabel.Position = UDim2.new(0, 0, 0, 110)
instructionsLabel.BackgroundTransparency = 1
instructionsLabel.Text = "🎵 Dance para motivar o remador! 🎵"
instructionsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsLabel.TextScaled = true
instructionsLabel.Font = Enum.Font.Gotham
instructionsLabel.Parent = mainFrame

-- Atualizar timer
local function updateTimer()
    local startTime = tick()
    local raceDuration = 120 -- 2 minutos
    
    spawn(function()
        while true do
            local elapsed = tick() - startTime
            local remaining = math.max(0, raceDuration - elapsed)
            
            local minutes = math.floor(remaining / 60)
            local seconds = math.floor(remaining % 60)
            
            timerLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
            
            if remaining <= 0 then
                break
            end
            
            wait(1)
        end
    end)
end

-- Iniciar timer quando a corrida começar
updateTimer()

-- Efeitos visuais para o líder
local function createDanceEffects()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Criar partículas de música
            local musicParticles = Instance.new("ParticleEmitter")
            musicParticles.Parent = humanoidRootPart
            musicParticles.Texture = "rbxassetid://241629427" -- Textura de nota musical
            musicParticles.Rate = 10
            musicParticles.Lifetime = NumberRange.new(2, 4)
            musicParticles.Speed = NumberRange.new(5, 10)
            musicParticles.SpreadAngle = Vector2.new(45, 45)
            musicParticles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
            musicParticles.Size = NumberSequence.new(0.5, 0)
        end
    end
end

-- Aplicar efeitos quando o personagem carregar
player.CharacterAdded:Connect(function(character)
    wait(2)
    createDanceEffects()
end)

-- Botão de loja de lootboxes
local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 60, 0, 60)
shopButton.Position = UDim2.new(1, -80, 0.5, -30)
shopButton.AnchorPoint = Vector2.new(0, 0)
shopButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
shopButton.Text = "🛒\nLoja"
shopButton.TextColor3 = Color3.fromRGB(0, 0, 0)
shopButton.TextScaled = true
shopButton.Font = Enum.Font.GothamBold
shopButton.Parent = screenGui

-- Frame da loja
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 350, 0, 400)
shopFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 50)
shopTitle.Position = UDim2.new(0, 0, 0, 0)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "Loja de Lootboxes"
shopTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
shopTitle.TextScaled = true
shopTitle.Font = Enum.Font.GothamBold
shopTitle.Parent = shopFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Text = "✖"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

closeButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

shopButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = not shopFrame.Visible
end)

-- Exemplo de conteúdo da loja
local lootboxInfo = Instance.new("TextLabel")
lootboxInfo.Size = UDim2.new(1, -40, 0, 60)
lootboxInfo.Position = UDim2.new(0, 20, 0, 70)
lootboxInfo.BackgroundTransparency = 1
lootboxInfo.Text = "Compre lootboxes para desbloquear novas danças!\n(Em breve: sistema de compra)"
lootboxInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
lootboxInfo.TextScaled = true
lootboxInfo.Font = Enum.Font.Gotham
lootboxInfo.Parent = shopFrame

print("Interface do usuário carregada!") 