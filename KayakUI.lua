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

-- Adicionar item de lootbox com imagem
local lootboxItemFrame = Instance.new("Frame")
lootboxItemFrame.Name = "LootboxItem"
lootboxItemFrame.Size = UDim2.new(0, 120, 0, 160)
lootboxItemFrame.Position = UDim2.new(0, 30, 0, 150)
lootboxItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
lootboxItemFrame.BorderSizePixel = 0
lootboxItemFrame.Parent = shopFrame

local lootboxImage = Instance.new("ImageLabel")
lootboxImage.Name = "LootboxImage"
lootboxImage.Size = UDim2.new(0, 100, 0, 100)
lootboxImage.Position = UDim2.new(0.5, -50, 0, 10)
lootboxImage.BackgroundTransparency = 1
lootboxImage.Image = "rbxassetid://970264637" -- Imagem de caixa de madeira para UI
lootboxImage.Parent = lootboxItemFrame

local lootboxName = Instance.new("TextLabel")
lootboxName.Size = UDim2.new(1, 0, 0, 30)
lootboxName.Position = UDim2.new(0, 0, 0, 115)
lootboxName.BackgroundTransparency = 1
lootboxName.Text = "Caixa de Danças"
lootboxName.TextColor3 = Color3.fromRGB(255, 215, 0)
lootboxName.TextScaled = true
lootboxName.Font = Enum.Font.GothamBold
lootboxName.Parent = lootboxItemFrame

local lootboxPrice = Instance.new("TextLabel")
lootboxPrice.Size = UDim2.new(1, 0, 0, 20)
lootboxPrice.Position = UDim2.new(0, 0, 0, 140)
lootboxPrice.BackgroundTransparency = 1
lootboxPrice.Text = "Preço: ?"
lootboxPrice.TextColor3 = Color3.fromRGB(255, 255, 255)
lootboxPrice.TextScaled = true
lootboxPrice.Font = Enum.Font.Gotham
lootboxPrice.Parent = lootboxItemFrame

-- Segundo item de lootbox com imagem
local lootboxItemFrame2 = Instance.new("Frame")
lootboxItemFrame2.Name = "LootboxItem2"
lootboxItemFrame2.Size = UDim2.new(0, 120, 0, 160)
lootboxItemFrame2.Position = UDim2.new(0, 170, 0, 150) -- posição ao lado da primeira
lootboxItemFrame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
lootboxItemFrame2.BorderSizePixel = 0
lootboxItemFrame2.Parent = shopFrame

local lootboxImage2 = Instance.new("ImageLabel")
lootboxImage2.Name = "LootboxImage2"
lootboxImage2.Size = UDim2.new(0, 100, 0, 100)
lootboxImage2.Position = UDim2.new(0.5, -50, 0, 10)
lootboxImage2.BackgroundTransparency = 1
lootboxImage2.Image = "rbxassetid://970263355" -- troque pelo assetId desejado
lootboxImage2.Parent = lootboxItemFrame2

local lootboxName2 = Instance.new("TextLabel")
lootboxName2.Size = UDim2.new(1, 0, 0, 30)
lootboxName2.Position = UDim2.new(0, 0, 0, 115)
lootboxName2.BackgroundTransparency = 1
lootboxName2.Text = "Caixa de Kaiques"
lootboxName2.TextColor3 = Color3.fromRGB(0, 255, 255)
lootboxName2.TextScaled = true
lootboxName2.Font = Enum.Font.GothamBold
lootboxName2.Parent = lootboxItemFrame2

local lootboxPrice2 = Instance.new("TextLabel")
lootboxPrice2.Size = UDim2.new(1, 0, 0, 20)
lootboxPrice2.Position = UDim2.new(0, 0, 0, 140)
lootboxPrice2.BackgroundTransparency = 1
lootboxPrice2.Text = "Preço: ?"
lootboxPrice2.TextColor3 = Color3.fromRGB(255, 255, 255)
lootboxPrice2.TextScaled = true
lootboxPrice2.Font = Enum.Font.Gotham
lootboxPrice2.Parent = lootboxItemFrame2

local giveDanceEvent = ReplicatedStorage:WaitForChild("GiveDanceFromShop")

-- Botão invisível sobre o lootboxItemFrame
local lootboxButton = Instance.new("ImageButton")
lootboxButton.Name = "LootboxButton"
lootboxButton.Size = UDim2.new(1, 0, 1, 0)
lootboxButton.Position = UDim2.new(0, 0, 0, 0)
lootboxButton.BackgroundTransparency = 1
lootboxButton.ImageTransparency = 1
lootboxButton.Parent = lootboxItemFrame

-- Frame da roleta (inicialmente invisível)
local rouletteFrame = Instance.new("Frame")
rouletteFrame.Name = "RouletteFrame"
rouletteFrame.Size = UDim2.new(0, 400, 0, 120)
rouletteFrame.Position = UDim2.new(0.5, -200, 0.5, -60)
rouletteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rouletteFrame.BorderSizePixel = 0
rouletteFrame.Visible = false
rouletteFrame.Parent = screenGui

-- ScrollingFrame para as imagens das danças
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "RouletteScroll"
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 120 * 14, 0, 120) -- 2x o número de danças para looping
scroll.ScrollBarThickness = 0
scroll.BackgroundTransparency = 1
scroll.Parent = rouletteFrame

-- Remover a criação fixa de imagens da roleta
-- Adicionar imagens das danças (duas vezes para looping)
local rouletteImages = {}
local function updateRouletteImages(images)
	for _, img in ipairs(rouletteImages) do
		img:Destroy()
	end
	rouletteImages = {}
	for i = 1,2 do
		for idx, imageId in ipairs(images) do
			local img = Instance.new("ImageLabel")
			img.Name = "RouletteImage" .. tostring(idx)
			img.Size = UDim2.new(0, 100, 0, 100)
			img.Position = UDim2.new(0, 120 * ((i-1)*#images + idx - 1), 0, 10)
			img.BackgroundTransparency = 1
			img.Image = imageId
			img.Parent = scroll
			table.insert(rouletteImages, img)
		end
	end
end

-- Texto de resultado
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, 0, 0, 40)
resultLabel.Position = UDim2.new(0, 0, 1, 0)
resultLabel.BackgroundTransparency = 1
resultLabel.Text = ""
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
resultLabel.TextScaled = true
resultLabel.Font = Enum.Font.GothamBold
resultLabel.Parent = rouletteFrame

-- Função para animar a roleta
local function animateRoulette(targetIndex, totalItems, callback)
	rouletteFrame.Visible = true
	scroll.CanvasPosition = Vector2.new(0, 0)
	resultLabel.Text = ""

	local loops = 3
	local endPos = 120 * ((loops * totalItems) + targetIndex - 1)
	local duration = 2.5

	local tween = TweenService:Create(scroll, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(endPos, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		if callback then callback() end
	end)
end

-- Substituir o clique do lootboxButton para abrir a roleta e pedir o resultado ao servidor
lootboxButton.MouseButton1Click:Connect(function()
	rouletteFrame.Visible = true
	scroll.CanvasPosition = Vector2.new(0, 0)
	resultLabel.Text = ""
	giveDanceEvent:FireServer()
end)

-- Receber resultado do servidor (precisa de um RemoteEvent para resposta)
local resultEvent = ReplicatedStorage:FindFirstChild("GiveDanceResult")
if not resultEvent then
	resultEvent = Instance.new("RemoteEvent")
	resultEvent.Name = "GiveDanceResult"
	resultEvent.Parent = ReplicatedStorage
end

resultEvent.OnClientEvent:Connect(function(danceIndex, danceName, rarity, images)
	updateRouletteImages(images)
	animateRoulette(danceIndex, #images, function()
		resultLabel.Text = "Você ganhou: " .. danceName .. " (" .. rarity .. ")"
		wait(2)
		rouletteFrame.Visible = false
		local claimDanceReward = ReplicatedStorage:FindFirstChild("ClaimDanceReward")
		if claimDanceReward then
			claimDanceReward:FireServer()
		end
	end)
end)

print("Interface do usuário carregada!")