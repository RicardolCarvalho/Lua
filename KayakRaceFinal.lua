-- KayakRaceFinal.lua - Versão final corrigida do jogo de corrida de caiaques
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configurações do jogo
local GAME_CONFIG = {
    KAYAK_SPEED = 20,
    DANCE_ANIMATION_ID = "rbxassetid://507770677", -- ID da animação de dança
    RACE_DURATION = 180, -- 3 minutos
    CHECKPOINT_DISTANCE = 50,
    MAX_PLAYERS_PER_KAYAK = 2
}

-- Classe Kayak
local Kayak = {}
Kayak.__index = Kayak

function Kayak.new(position)
    local self = setmetatable({}, Kayak)
    
    -- Criar o caiaque
    self.model = Instance.new("Model")
    self.model.Name = "Kayak"
    
    -- Corpo do caiaque
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(10, 1.5, 4)
    body.Position = position
    body.Anchored = true
    body.Material = Enum.Material.Wood
    body.BrickColor = BrickColor.new("Brown")
    body.Parent = self.model
    
    -- Definir o corpo como PrimaryPart
    self.model.PrimaryPart = body
    
    -- Assento do líder (frente)
    local leaderSeat = Instance.new("Seat")
    leaderSeat.Name = "LeaderSeat"
    leaderSeat.Size = Vector3.new(2.5, 0.5, 2.5)
    leaderSeat.Position = position + Vector3.new(3.5, 0.5, 0)
    leaderSeat.Anchored = false
    leaderSeat.BrickColor = BrickColor.new("Bright blue")
    leaderSeat.Parent = self.model
    
    -- Assento do remador (trás)
    local rowerSeat = Instance.new("Seat")
    rowerSeat.Name = "RowerSeat"
    rowerSeat.Size = Vector3.new(2.5, 0.5, 2.5)
    rowerSeat.Position = position + Vector3.new(-3.5, 0.5, 0)
    rowerSeat.Anchored = false
    rowerSeat.BrickColor = BrickColor.new("Bright green")
    rowerSeat.Parent = self.model
    
    -- Variáveis do caiaque
    self.leader = nil
    self.rower = nil
    self.speed = GAME_CONFIG.KAYAK_SPEED
    self.direction = Vector3.new(0, 0, 1)
    self.isRacing = false
    self.velocity = Vector3.new(0, 0, 0)
    self.anchored = true
    
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
            self.leader = nil
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
            self.rower = nil
        end
    end)
end

function Kayak:setLeader(player)
    self.leader = player
    print("Líder definido: " .. player.Name)
    -- Fazer o líder dançar automaticamente
    self:startLeaderDance()
end

function Kayak:setRower(player)
    self.rower = player
    print("Remador definido: " .. player.Name)
    -- Configurar controles do remador
    self:setupRowerControls()
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
            
            print("Líder começou a dançar: " .. self.leader.Name)
        end
    end
end

function Kayak:setupRowerControls()
    if self.rower then
        local userInputService = game:GetService("UserInputService")
        
        -- Controles do remador
        local connection
        connection = userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.W then
                self:moveForward()
            elseif input.KeyCode == Enum.KeyCode.S then
                self:moveBackward()
            elseif input.KeyCode == Enum.KeyCode.A then
                self:turnLeft()
            elseif input.KeyCode == Enum.KeyCode.D then
                self:turnRight()
            elseif input.KeyCode == Enum.KeyCode.Space then
                self:toggleAnchor()
            end
        end)
        
        print("Controles configurados para: " .. self.rower.Name)
    end
end

function Kayak:moveForward()
    if self.isRacing and not self.anchored then
        self.velocity = self.velocity + (self.direction * self.speed * 0.1)
        print("Movendo para frente")
    end
end

function Kayak:moveBackward()
    if self.isRacing and not self.anchored then
        self.velocity = self.velocity - (self.direction * self.speed * 0.1)
        print("Movendo para trás")
    end
end

function Kayak:turnLeft()
    if self.isRacing and not self.anchored then
        self.direction = CFrame.fromMatrix(Vector3.new(), self.direction) * CFrame.Angles(0, math.rad(-15), 0).LookVector
        print("Virando para esquerda")
    end
end

function Kayak:turnRight()
    if self.isRacing and not self.anchored then
        self.direction = CFrame.fromMatrix(Vector3.new(), self.direction) * CFrame.Angles(0, math.rad(15), 0).LookVector
        print("Virando para direita")
    end
end

function Kayak:toggleAnchor()
    self.anchored = not self.anchored
    if self.model.PrimaryPart then
        self.model.PrimaryPart.Anchored = self.anchored
    end
    
    if self.anchored then
        self.velocity = Vector3.new(0, 0, 0)
        print("Caiaque ancorado")
    else
        print("Caiaque desancorado")
    end
end

function Kayak:update()
    if not self.anchored and self.isRacing and self.model.PrimaryPart then
        -- Aplicar velocidade
        local newPosition = self.model.PrimaryPart.Position + self.velocity
        
        -- Verificar limites do rio
        if math.abs(newPosition.Z) < 45 then -- Dentro do rio
            self.model.PrimaryPart.Position = newPosition
        else
            -- Bater na margem - reduzir velocidade
            self.velocity = self.velocity * 0.5
        end
        
        -- Aplicar resistência da água
        self.velocity = self.velocity * 0.95
    end
end

function Kayak:startRace()
    self.isRacing = true
    print("Caiaque iniciou a corrida")
end

function Kayak:stopRace()
    self.isRacing = false
    self.velocity = Vector3.new(0, 0, 0)
    print("Caiaque parou a corrida")
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

function RaceManager:update()
    for _, kayak in pairs(self.kayaks) do
        if kayak and type(kayak.update) == "function" then
            kayak:update()
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
    local BASE_Y = 10 -- igual ao do MapBuilder
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
        local x = 40 + ((i-1) * 20)
        local y = BASE_Y + 1
        local position = Vector3.new(x, y, 0)
        local kayak = Kayak.new(position)
        kayak.model.Parent = workspace
        -- Garantir que está ancorado ao criar
        if kayak.model.PrimaryPart then
            kayak.model.PrimaryPart.Anchored = true
        end
        raceManager:addKayak(kayak)
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
        -- Não teleporta mais o jogador para o caiaque!
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

-- Loop de atualização
RunService.Heartbeat:Connect(function()
    if raceManager and raceManager.raceActive then
        raceManager:update()
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