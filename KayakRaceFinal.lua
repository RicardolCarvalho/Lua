-- KayakRaceFinal.lua - Versão final corrigida do jogo de corrida de caiaques
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
-- Remover import de UserInputService
-- local UserInputService = game:GetService("UserInputService")

-- Criar RemoteEvent para controles se não existir
local KayakInput = ReplicatedStorage:FindFirstChild("KayakInput")
if not KayakInput then
	KayakInput = Instance.new("RemoteEvent")
	KayakInput.Name = "KayakInput"
	KayakInput.Parent = ReplicatedStorage
end

-- Configurações do jogo
local GAME_CONFIG = {
	KAYAK_SPEED = 50, -- Aumentado para melhor controle
	DANCE_ANIMATION_ID = "rbxassetid://507770677", -- ID da animação de dança
	RACE_DURATION = 180, -- 3 minutos
	CHECKPOINT_DISTANCE = 50,
	MAX_PLAYERS_PER_KAYAK = 2,
	BASE_Y = 1, -- altura base do rio (igual ao MapBuilder)
	TURN_SPEED = 2, -- Velocidade de rotação
	WATER_RESISTANCE = 0.98 -- Resistência da água
}

-- Classe Kayak
local Kayak = {}
Kayak.__index = Kayak

function Kayak.new(position)
	local self = setmetatable({}, Kayak)

	-- Criar o caiaque
	self.model = Instance.new("Model")
	self.model.Name = "Kayak"

	-- Corpo do caiaque com física
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(10, 1.5, 4)
	-- Alinhar kayak apontando para frente do rio (eixo Z)
	body.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(0), 0)
	body.Anchored = true -- Começa ancorado para estabilizar
	body.Material = Enum.Material.Wood
	body.BrickColor = BrickColor.new("Brown")
	body.CanCollide = true
	body.Parent = self.model

	-- Adicionar BodyVelocity para física
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(10000, 0, 10000) -- Força horizontal
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = body

	-- Adicionar BodyGyro para rotação
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(0, 10000, 0) -- Torque apenas no eixo Y
	bodyGyro.D = 100 -- Amortecimento
	bodyGyro.P = 1000 -- Proporcional
	bodyGyro.CFrame = CFrame.new()
	bodyGyro.Parent = body

	-- Definir o corpo como PrimaryPart
	self.model.PrimaryPart = body

	-- Assento do líder (frente)
	local leaderSeat = Instance.new("Seat")
	leaderSeat.Name = "LeaderSeat"
	leaderSeat.Size = Vector3.new(2.5, 0.5, 2.5)
	leaderSeat.Anchored = false
	leaderSeat.BrickColor = BrickColor.new("Bright blue")
	leaderSeat.CanCollide = false
	-- Posicionar e orientar o assento para frente (rotacionado 90°)
	leaderSeat.CFrame = body.CFrame * CFrame.new(2.5, 0.5, 0) * CFrame.Angles(0, math.rad(270), 0)
	leaderSeat.Parent = self.model

	-- Weld do assento do líder ao corpo
	local leaderWeld = Instance.new("WeldConstraint")
	leaderWeld.Part0 = body
	leaderWeld.Part1 = leaderSeat
	leaderWeld.Parent = leaderSeat

	-- Assento do remador (trás)
	local rowerSeat = Instance.new("Seat")
	rowerSeat.Name = "RowerSeat"
	rowerSeat.Size = Vector3.new(2.5, 0.5, 2.5)
	rowerSeat.Anchored = false
	rowerSeat.BrickColor = BrickColor.new("Bright green")
	rowerSeat.CanCollide = false
	-- Posicionar e orientar o assento para frente (rotacionado 90°)
	rowerSeat.CFrame = body.CFrame * CFrame.new(-2.5, 0.5, 0) * CFrame.Angles(0, math.rad(270), 0)
	rowerSeat.Parent = self.model

	-- Weld do assento do remador ao corpo
	local rowerWeld = Instance.new("WeldConstraint")
	rowerWeld.Part0 = body
	rowerWeld.Part1 = rowerSeat
	rowerWeld.Parent = rowerSeat

	-- Variáveis do caiaque
	self.leader = nil
	self.rower = nil
	self.speed = GAME_CONFIG.KAYAK_SPEED
	self.direction = Vector3.new(0, 0, 1) -- Direção inicial
	self.isRacing = false
	self.velocity = Vector3.new(0, 0, 0)
	self.anchored = true
	self.controlConnections = {}
	self.bodyVelocity = bodyVelocity
	self.bodyGyro = bodyGyro
	self.currentRotation = 0 -- Rotação atual em radianos
	self.leaderAnimTrack = nil -- Track da animação de dança do líder
	self.inputStates = {Forward=false, Backward=false, Left=false, Right=false} -- Estado contínuo de input
	self.finished = false -- Controla se já finalizou a corrida

	-- Guardar referências aos assentos
	self.leaderSeat = leaderSeat
	self.rowerSeat = rowerSeat

	-- Conectar eventos dos assentos
	self:setupSeatEvents(leaderSeat, rowerSeat)

	return self
end

function Kayak:setupSeatEvents(leaderSeat, rowerSeat)
	-- Evento do assento do líder
	leaderSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if leaderSeat.Occupant then
			local player = Players:GetPlayerFromCharacter(leaderSeat.Occupant.Parent)
			if player then
				self:setLeader(player)
			end
		else
			self:removeLeader()
		end
	end)

	-- Evento do assento do remador
	rowerSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if rowerSeat.Occupant then
			local player = Players:GetPlayerFromCharacter(rowerSeat.Occupant.Parent)
			if player then
				self:setRower(player)
			end
		else
			self:removeRower()
		end
	end)
end

function Kayak:setLeader(player)
	self.leader = player
	print("Líder definido: " .. player.Name)
	self:startLeaderDance()
	self:autoUnanchor()
end

function Kayak:removeLeader()
	-- Parar animação de dança ao remover líder
	if self.leaderAnimTrack then
		self.leaderAnimTrack:Stop()
		self.leaderAnimTrack = nil
	end
	self.leader = nil
	print("Líder removido")
end

function Kayak:setRower(player)
	self.rower = player
	print("Remador definido: " .. player.Name)
	self:autoUnanchor()
end

function Kayak:removeRower()
	self.rower = nil
	-- Limpar controles
	for _, connection in pairs(self.controlConnections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.controlConnections = {}
	print("Remador removido")

	-- Se há líder mas não há remador, o líder pode controlar
	if self.leader then
		-- self:setupLeaderControls() -- REMOVIDO
	end
end

function Kayak:startLeaderDance()
	if self.leader and self.leader.Character then
		local humanoid = self.leader.Character:FindFirstChild("Humanoid")
		if humanoid then
			-- Carregar animação de dança
			local animation = Instance.new("Animation")
			animation.AnimationId = GAME_CONFIG.DANCE_ANIMATION_ID

			local animTrack = humanoid:LoadAnimation(animation)
			animTrack.Looped = true
			animTrack:Play()

			-- Guardar referência para parar depois
			self.leaderAnimTrack = animTrack

			print("Líder começou a dançar: " .. self.leader.Name)
		end
	end
end


function Kayak:autoUnanchor()
	-- Desancorar automaticamente quando alguém sentar
	if self.anchored then
		self.anchored = false

		if self.model.PrimaryPart then
			self.model.PrimaryPart.Anchored = false
		end

		if self.bodyVelocity then
			self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end

		print("Caiaque desancorado automaticamente - Pronto para navegar!")
		print("Use WASD para mover")
	end
end

function Kayak:moveForward()
	if not self.anchored and self.bodyVelocity and self.rowerSeat then
		-- Movimento na direção em que o rowerSeat está virado
		local dir = self.rowerSeat.CFrame.LookVector
		self.bodyVelocity.Velocity = dir * self.speed
	end
end

function Kayak:moveBackward()
	if not self.anchored and self.bodyVelocity and self.rowerSeat then
		-- Movimento na direção oposta ao rowerSeat
		local dir = self.rowerSeat.CFrame.LookVector
		self.bodyVelocity.Velocity = -dir * self.speed
	end
end

function Kayak:turnLeft()
	if not self.anchored and self.bodyGyro then
		self.currentRotation = self.currentRotation + math.rad(15)
		self.bodyGyro.CFrame = CFrame.Angles(0, self.currentRotation, 0)
	end
end

function Kayak:turnRight()
	if not self.anchored and self.bodyGyro then
		self.currentRotation = self.currentRotation - math.rad(15)
		self.bodyGyro.CFrame = CFrame.Angles(0, self.currentRotation, 0)
	end
end

function Kayak:setInputState(action, isDown)
    if self.inputStates[action] ~= nil then
        self.inputStates[action] = isDown
    end
end

-- Atualizado para rotação suave e uso de dt
function Kayak:update(dt)
    if not self.anchored and self.isRacing and self.model.PrimaryPart then
        -- Rotação suave contínua
        if self.inputStates.Left then
            self.currentRotation = self.currentRotation + GAME_CONFIG.TURN_SPEED * dt
        end
        if self.inputStates.Right then
            self.currentRotation = self.currentRotation - GAME_CONFIG.TURN_SPEED * dt
        end
        -- Atualizar giro do corpo
        if self.bodyGyro then
            self.bodyGyro.CFrame = CFrame.Angles(0, self.currentRotation, 0)
        end
        -- Movimentação contínua
        if self.inputStates.Forward then
            self:moveForward()
        end
        if self.inputStates.Backward then
            self:moveBackward()
        end
        -- Verificar limites do rio
        local position = self.model.PrimaryPart.Position
        if math.abs(position.Z) > 45 then
            if self.bodyVelocity then
                self.bodyVelocity.Velocity = self.bodyVelocity.Velocity * 0.3
                local pushDirection = Vector3.new(0, 0, -math.sign(position.Z))
                self.bodyVelocity.Velocity = self.bodyVelocity.Velocity + (pushDirection * 10)
            end
        end
        
        -- Verificar colisão com barreira do final (empurrar de volta)
        if position.X > 790 then -- 800 - 10 = posição da barreira
            if self.bodyVelocity then
                self.bodyVelocity.Velocity = self.bodyVelocity.Velocity * 0.1 -- Reduzir velocidade drasticamente
                local pushDirection = Vector3.new(-1, 0, 0) -- Empurrar de volta para trás
                self.bodyVelocity.Velocity = self.bodyVelocity.Velocity + (pushDirection * 30)
            end
        end
        -- Resistência da água
        if self.bodyVelocity then
            self.bodyVelocity.Velocity = self.bodyVelocity.Velocity * GAME_CONFIG.WATER_RESISTANCE
        end
    end
end

function Kayak:startRace()
	self.isRacing = true
	print("Caiaque iniciou a corrida")
end

function Kayak:stopRace()
	self.isRacing = false
	if self.bodyVelocity then
		self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end
	print("Caiaque parou a corrida")
end

function Kayak:resetToStart()
	-- Resetar posição à origem
	local startPosition = Vector3.new(8, GAME_CONFIG.BASE_Y + 2, 0)
	self.model:SetPrimaryPartCFrame(CFrame.new(startPosition))
	
	-- Resetar estados
	self.finished = false
	self.anchored = true
	self.velocity = Vector3.new(0, 0, 0)
	self.currentRotation = 0
	
	-- Resetar física
	if self.model.PrimaryPart then
		self.model.PrimaryPart.Anchored = true
	end
	if self.bodyVelocity then
		self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end
	if self.bodyGyro then
		self.bodyGyro.CFrame = CFrame.new()
	end
	
	-- Resetar inputs
	self.inputStates = {Forward=false, Backward=false, Left=false, Right=false}
end

-- Sistema de corrida
local RaceManager = {}
RaceManager.__index = RaceManager

function RaceManager.new()
	local self = setmetatable({}, RaceManager)
	self.kayaks = {}
	self.raceActive = false
	self.startTime = 0
	self.checkpoints = {}
	self.playerTeams = {}

	print("RaceManager criado com sucesso")
	return self
end

function RaceManager:addKayak(kayak)
	if kayak then
		table.insert(self.kayaks, kayak)
		print("Caiaque adicionado ao gerenciador de corrida. Total: " .. #self.kayaks)
	else
		print("Erro: Tentativa de adicionar caiaque nulo")
	end
end

function RaceManager:assignPlayersToKayaks()
	local players = Players:GetPlayers()
	local kayakIndex = 1

	for i = 1, #players, 2 do
		if kayakIndex <= #self.kayaks then
			local kayak = self.kayaks[kayakIndex]

			-- Primeiro jogador como líder
			if players[i] then
				self.playerTeams[players[i]] = kayakIndex
				print("Jogador " .. players[i].Name .. " atribuído ao caiaque " .. kayakIndex .. " como líder")
			end

			-- Segundo jogador como remador
			if players[i + 1] then
				self.playerTeams[players[i + 1]] = kayakIndex
				print("Jogador " .. players[i + 1].Name .. " atribuído ao caiaque " .. kayakIndex .. " como remador")
			end

			kayakIndex = kayakIndex + 1
		end
	end
end

function RaceManager:startRace()
	print("Iniciando corrida...")
	self.raceActive = true
	self.startTime = tick()

	-- Atribuir jogadores aos caiaques
	self:assignPlayersToKayaks()

	for i, kayak in pairs(self.kayaks) do
		if kayak and type(kayak.startRace) == "function" then
			kayak:startRace()
			print("Caiaque " .. i .. " iniciou a corrida")
		else
			print("Erro: Caiaque " .. i .. " não tem método startRace")
		end
	end

	print("Corrida iniciada com " .. #self.kayaks .. " caiaques!")

	-- Timer da corrida
	spawn(function()
		wait(GAME_CONFIG.RACE_DURATION)
		self:endRace()
	end)
end

function RaceManager:endRace()
	print("Finalizando corrida...")
	self.raceActive = false

	for i, kayak in pairs(self.kayaks) do
		if kayak and type(kayak.stopRace) == "function" then
			kayak:stopRace()
		end
	end

	print("Corrida terminada!")
end

-- Atualização do jogo (removida verificação de linha de chegada - será feita via Touched)
function RaceManager:update(dt)
    for _, kayak in pairs(self.kayaks) do
        if kayak and type(kayak.update) == "function" then
            kayak:update(dt)
        end
    end
end

-- Inicialização do jogo
print("Iniciando sistema de corrida de caiaques...")

local raceManager = RaceManager.new()

if not raceManager then
	print("ERRO CRÍTICO: Não foi possível criar o RaceManager")
	return
end

print("RaceManager criado: " .. tostring(raceManager))

-- Função para criar caiaques
local function createKayaks()
	local playerCount = #Players:GetPlayers()
	local kayakCount = math.max(1, math.ceil(playerCount / 2)) -- Mínimo 1 caiaque
	print("Criando " .. kayakCount .. " caiaques para " .. playerCount .. " jogadores")

	-- Limpar caiaques existentes
	for _, kayak in pairs(raceManager.kayaks) do
		if kayak.model then
			kayak.model:Destroy()
		end
	end
	raceManager.kayaks = {}

	-- Criar novos caiaques
	for i = 1, kayakCount do
		-- Caiaque nasce no início do rio, sobre a água
		local x = 8
		local y = GAME_CONFIG.BASE_Y + 2
		local z = 0
		local position = Vector3.new(x, y, z)

		local kayak = Kayak.new(position)
		kayak.model.Parent = workspace

		-- Garantir que está ancorado ao criar
		if kayak.model.PrimaryPart then
			kayak.model.PrimaryPart.Anchored = true
		end

		raceManager:addKayak(kayak)
		print("Caiaque " .. i .. " criado na posição: " .. tostring(position))
	end

	print("Caiaques criados: " .. kayakCount .. " caiaques")
end

-- Quando um jogador entra
Players.PlayerAdded:Connect(function(player)
	print("Jogador entrou: " .. player.Name)

	-- Recriar caiaques quando jogador entra
	createKayaks()

	player.CharacterAdded:Connect(function(character)
		print("Personagem carregado para: " .. player.Name)
		wait(2) -- Aguardar o personagem carregar
		print("Jogador " .. player.Name .. " pronto para a corrida")
	end)
end)

-- Quando um jogador sai
Players.PlayerRemoving:Connect(function(player)
	print("Jogador saiu: " .. player.Name)
	-- Remover do sistema de equipes
	raceManager.playerTeams[player] = nil

	-- Recriar caiaques quando jogador sai
	createKayaks()
end)

-- Conectar eventos de input do client
KayakInput.OnServerEvent:Connect(function(player, action, isDown)
    local idx = raceManager.playerTeams[player]
    if not idx then return end
    local kayak = raceManager.kayaks[idx]
    if not kayak then return end
    -- Somente remador controla
    if player ~= kayak.rower then return end
    kayak:setInputState(action, isDown)
end)

-- Loop de atualização (alterado para usar dt e atualização contínua)
RunService.Heartbeat:Connect(function(dt)
    if raceManager and raceManager.raceActive then
        raceManager:update(dt)
    end
end)

-- Criar caiaques iniciais
createKayaks()

-- Iniciar corrida após 10 segundos
wait(10)
if raceManager and not raceManager.raceActive then
	raceManager:startRace()
end

print("Sistema de corrida de caiaques carregado com sucesso!")

-- Leaderstats são criados no ServerScriptService/Leaderboard.lua
-- Função para garantir leaderstats para todos os jogadores
local function ensureLeaderstats()
    for _, player in pairs(Players:GetPlayers()) do
        if not player:FindFirstChild("leaderstats") then
            print("Criando leaderstats para jogador existente: " .. player.Name)
            local leaderstats = Instance.new("Folder")
            leaderstats.Name = "leaderstats"
            leaderstats.Parent = player
            local money = Instance.new("IntValue")
            money.Name = "Money"
            money.Value = 0
            money.Parent = leaderstats
        end
    end
end

-- Configurar linha de chegada e spawn
local function setupFinishLine()
    local finishLine = workspace:FindFirstChild("FinishLine")
    local spawnLocation = workspace:FindFirstChild("SpawnLocation")
    
    if finishLine and spawnLocation then
        finishLine.CanCollide = false  -- permite atravessar
        
        finishLine.Touched:Connect(function(hitPart)
            local model = hitPart.Parent
            if model and model.Name == "Kayak" then
                -- Encontre o kayak correspondente
                for i, kayak in ipairs(raceManager.kayaks) do
                    if kayak.model == model and not kayak.finished then
                        kayak.finished = true  -- Marcar como finalizado para evitar múltiplos triggers
                        
                        -- Conceder 10 moedas e teleportar líder e remador (apenas jogadores existentes)
                        local playersToReward = {}
                        if kayak.leader then table.insert(playersToReward, kayak.leader) end
                        if kayak.rower then table.insert(playersToReward, kayak.rower) end
                        
                        for _, plr in ipairs(playersToReward) do
                            local stats = plr:FindFirstChild("leaderstats")
                            if stats then
                                local money = stats:FindFirstChild("Money")
                                if money then 
                                    money.Value = money.Value + 10
                                end
                            end
                            
                            if plr.Character and plr.Character.PrimaryPart then
                                plr.Character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0,5,0))
                            end
                        end
                        
                        -- Retornar caiaque à origem após pequena pausa
                        spawn(function()
                            wait(2)  -- Pequena pausa para permitir teleporte dos jogadores
                            kayak:resetToStart()
                            -- Permitir nova finalização após reset
                            wait(1)
                            kayak.finished = false
                        end)
                        break
                    end
                end
            end
        end)
    end
end

-- Chamar configuração da linha de chegada
setupFinishLine()

-- Fim do script de corrida de caiaques 