-- DanceSystem.lua - Sistema de danças e lootboxes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Configurações das danças
local DANCE_ANIMATIONS = {
	{
		id = "rbxassetid://507770677",
		name = "Dance 1",
		rarity = "Common",
		color = Color3.fromRGB(255, 255, 255),
		image = "rbxassetid://2617982884"
	},
	{
		id = "rbxassetid://507770677", -- Substitua por IDs reais
		name = "Dance 2", 
		rarity = "Common",
		color = Color3.fromRGB(255, 255, 255),
		image = "rbxassetid://2617982884" -- troque pelo assetId da imagem da Dance 2
	},
	{
		id = "rbxassetid://507770677",
		name = "Dance 3",
		rarity = "Rare",
		color = Color3.fromRGB(0, 255, 255),
		image = "rbxassetid://2617982884"
	},
	{
		id = "rbxassetid://507770677",
		name = "Dance 4",
		rarity = "Rare",
		color = Color3.fromRGB(0, 255, 255),
		image = "rbxassetid://2617982884"
	},
	{
		id = "rbxassetid://507770677",
		name = "Dance 5",
		rarity = "Epic",
		color = Color3.fromRGB(255, 0, 255),
		image = "rbxassetid://2617982884"
	},
	{
		id = "rbxassetid://507770677",
		name = "Dance 6",
		rarity = "Epic",
		color = Color3.fromRGB(255, 0, 255),
		image = "rbxassetid://2617982884"
	},
	{
		id = "rbxassetid://507770677",
		name = "Dance 7",
		rarity = "Legendary",
		color = Color3.fromRGB(255, 215, 0),
		image = "rbxassetid://2617982884"
	}
}

-- Sistema de Lootbox
local LootboxSystem = {}

function LootboxSystem.new()
	local self = {}
	self.lootboxes = {}

	return self
end

function LootboxSystem:createLootbox(position)
	local lootbox = Instance.new("Part")
	lootbox.Name = "Lootbox"
	lootbox.Size = Vector3.new(2, 2, 2)
	lootbox.Position = position
	lootbox.Anchored = true
	lootbox.Material = Enum.Material.Neon
	lootbox.BrickColor = BrickColor.new("Bright yellow")
	lootbox.Shape = Enum.PartType.Ball
	lootbox.Parent = workspace

	-- Efeito de brilho
	local pointLight = Instance.new("PointLight")
	pointLight.Parent = lootbox
	pointLight.Color = Color3.fromRGB(255, 255, 0)
	pointLight.Range = 15
	pointLight.Brightness = 2

	-- Efeito de rotação
	local rotationTween = TweenService:Create(lootbox, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
		CFrame = lootbox.CFrame * CFrame.Angles(0, math.rad(360), 0)
	})
	rotationTween:Play()

	-- Colisão para coletar
	local touchConnection
	touchConnection = lootbox.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)

		if player then
			self:collectLootbox(player, lootbox)
			touchConnection:Disconnect()
		end
	end)

	table.insert(self.lootboxes, lootbox)
	return lootbox
end

function LootboxSystem:collectLootbox(player, lootbox)
	-- Remover lootbox
	lootbox:Destroy()

	-- Dar dança aleatória
	local dance = self:getRandomDance()
	self:giveDanceToPlayer(player, dance)

	-- Efeito visual
	self:createCollectionEffect(lootbox.Position, dance.color)

	-- Notificar jogador
	self:notifyPlayer(player, "Você ganhou: " .. dance.name .. " (" .. dance.rarity .. ")")
end

function LootboxSystem:getRandomDance()
	local rand = math.random(1, 100)

	if rand <= 60 then
		-- Common (60%)
		return DANCE_ANIMATIONS[math.random(1, 2)]
	elseif rand <= 90 then
		-- Rare (30%)
		return DANCE_ANIMATIONS[math.random(3, 4)]
	elseif rand <= 99 then
		-- Epic (9%)
		return DANCE_ANIMATIONS[math.random(5, 6)]
	else
		-- Legendary (1%)
		return DANCE_ANIMATIONS[7]
	end
end

function LootboxSystem:giveDanceToPlayer(player, dance)
	-- Salvar dança no jogador (você pode usar DataStore aqui)
	if not player:FindFirstChild("Dances") then
		local dancesFolder = Instance.new("Folder")
		dancesFolder.Name = "Dances"
		dancesFolder.Parent = player
	end

	local danceValue = Instance.new("StringValue")
	danceValue.Name = dance.name
	danceValue.Value = dance.id
	danceValue.Parent = player.Dances
end

function LootboxSystem:createCollectionEffect(position, color)
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(1, 1, 1)
	effect.Position = position
	effect.Anchored = true
	effect.Material = Enum.Material.Neon
	effect.BrickColor = BrickColor.new(color)
	effect.Shape = Enum.PartType.Ball
	effect.Parent = workspace

	-- Animação de expansão
	local expandTween = TweenService:Create(effect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, 5),
		Transparency = 1
	})
	expandTween:Play()

	expandTween.Completed:Connect(function()
		effect:Destroy()
	end)
end

function LootboxSystem:notifyPlayer(player, message)
	-- Criar notificação na tela do jogador
	local screenGui = player:WaitForChild("PlayerGui")
	local notification = Instance.new("ScreenGui")
	notification.Name = "DanceNotification"
	notification.Parent = screenGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 60)
	frame.Position = UDim2.new(0.5, -150, 0.8, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = notification

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = message
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame

	-- Animação de entrada
	frame.Position = UDim2.new(0.5, -150, 1, 0)
	local slideIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -150, 0.8, 0)
	})
	slideIn:Play()

	-- Remover após 3 segundos
	wait(3)
	local slideOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -150, 1, 0)
	})
	slideOut:Play()

	slideOut.Completed:Connect(function()
		notification:Destroy()
	end)
end

-- Sistema de Danças do Jogador
local PlayerDanceSystem = {}

function PlayerDanceSystem.new(player)
	local self = {}
	self.player = player
	self.currentDance = nil
	self.animationTrack = nil

	return self
end

function PlayerDanceSystem:playDance(danceId)
	if self.player.Character then
		local humanoid = self.player.Character:FindFirstChild("Humanoid")
		if humanoid then
			-- Parar dança atual
			if self.animationTrack then
				self.animationTrack:Stop()
			end

			-- Carregar nova dança
			local animation = Instance.new("Animation")
			animation.AnimationId = danceId

			self.animationTrack = humanoid:LoadAnimation(animation)
			self.animationTrack.Looped = true
			self.animationTrack:Play()

			self.currentDance = danceId
		end
	end
end

function PlayerDanceSystem:stopDance()
	if self.animationTrack then
		self.animationTrack:Stop()
		self.animationTrack = nil
		self.currentDance = nil
	end
end

-- Criar sistema global
local lootboxSystem = LootboxSystem.new()

-- Verificar se o sistema foi criado corretamente
if not lootboxSystem then
	print("ERRO: Não foi possível criar o sistema de lootbox")
else
	print("Sistema de lootbox criado com sucesso")
end

-- Função para spawnar lootboxes periodicamente
local function spawnLootboxes()
	while true do
		wait(30) -- Spawn a cada 30 segundos

		-- Verificar se o sistema existe
		if lootboxSystem and lootboxSystem.createLootbox then
			-- Posições aleatórias no rio
			local positions = {
				Vector3.new(50, 0, 0),
				Vector3.new(150, 0, 0),
				Vector3.new(250, 0, 0),
				Vector3.new(350, 0, 0)
			}

			for _, pos in pairs(positions) do
				if math.random(1, 3) == 1 then -- 33% de chance
					local success, error = pcall(function()
						lootboxSystem:createLootbox(pos)
					end)
					if not success then
						print("Erro ao criar lootbox: " .. tostring(error))
					else
						print("Lootbox criada com sucesso em: " .. tostring(pos))
					end
				end
			end
		else
			print("Sistema de lootbox não está disponível")
			print("lootboxSystem: " .. tostring(lootboxSystem))
			print("createLootbox: " .. tostring(lootboxSystem and lootboxSystem.createLootbox))
		end
	end
end

-- Adicionar integração com a loja para dar dança ao clicar na caixa
local giveDanceEvent = ReplicatedStorage:FindFirstChild("GiveDanceFromShop")
if not giveDanceEvent then
	giveDanceEvent = Instance.new("RemoteEvent")
	giveDanceEvent.Name = "GiveDanceFromShop"
	giveDanceEvent.Parent = ReplicatedStorage
end

local giveDanceResultEvent = ReplicatedStorage:FindFirstChild("GiveDanceResult")
if not giveDanceResultEvent then
	giveDanceResultEvent = Instance.new("RemoteEvent")
	giveDanceResultEvent.Name = "GiveDanceResult"
	giveDanceResultEvent.Parent = ReplicatedStorage
end

local claimDanceRewardEvent = ReplicatedStorage:FindFirstChild("ClaimDanceReward")
if not claimDanceRewardEvent then
	claimDanceRewardEvent = Instance.new("RemoteEvent")
	claimDanceRewardEvent.Name = "ClaimDanceReward"
	claimDanceRewardEvent.Parent = ReplicatedStorage
end

-- Tabela para guardar recompensas pendentes por jogador
local pendingDanceReward = {}

giveDanceEvent.OnServerEvent:Connect(function(player)
	-- Evita múltiplos pedidos simultâneos
	if pendingDanceReward[player] then return end
	-- Sorteia a dança
	local dance, danceIndex
	dance = LootboxSystem:getRandomDance()
	-- Descobre o índice da dança sorteada (para animar a roleta corretamente)
	for i, d in ipairs(DANCE_ANIMATIONS) do
		if d.name == dance.name then
			danceIndex = i
			break
		end
	end
	if not danceIndex then danceIndex = 1 end
	-- Salva recompensa pendente
	pendingDanceReward[player] = dance
	-- Monta lista de imagens de todas as danças
	local images = {}
	for i, d in ipairs(DANCE_ANIMATIONS) do
		images[i] = d.image or d.id
	end
	-- Envia índice, nome, raridade e lista de imagens
	giveDanceResultEvent:FireClient(player, danceIndex, dance.name, dance.rarity, images)
end)

claimDanceRewardEvent.OnServerEvent:Connect(function(player)
	local dance = pendingDanceReward[player]
	if dance then
		LootboxSystem:giveDanceToPlayer(player, dance)
		pendingDanceReward[player] = nil
	end
end)

-- Iniciar spawn de lootboxes
spawn(spawnLootboxes)

print("Sistema de danças e lootboxes carregado!")