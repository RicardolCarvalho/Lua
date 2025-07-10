-- MapBuilder.lua - Construtor do mapa do jogo de caiaques
local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Configurações do mapa
local MAP_CONFIG = {
    RIVER_LENGTH = 800,
    RIVER_WIDTH = 100,
    WATER_DEPTH = 5,
    BANK_HEIGHT = 8,
    CHECKPOINT_COUNT = 8,
    BASE_Y = 10 -- altura base do rio
}

-- Função para criar o rio principal
local function createRiver()
    -- Água principal
    local water = Instance.new("Part")
    water.Name = "MainWater"
    water.Size = Vector3.new(MAP_CONFIG.RIVER_LENGTH, MAP_CONFIG.WATER_DEPTH, MAP_CONFIG.RIVER_WIDTH)
    water.Position = Vector3.new(MAP_CONFIG.RIVER_LENGTH/2, MAP_CONFIG.BASE_Y, 0)
    water.Anchored = true
    water.Material = Enum.Material.Water
    water.Transparency = 0.3
    water.BrickColor = BrickColor.new("Bright blue")
    water.Parent = workspace
    
    -- Margem esquerda
    local leftBank = Instance.new("Part")
    leftBank.Name = "LeftBank"
    leftBank.Size = Vector3.new(MAP_CONFIG.RIVER_LENGTH, MAP_CONFIG.BANK_HEIGHT, 15)
    leftBank.Position = Vector3.new(MAP_CONFIG.RIVER_LENGTH/2, MAP_CONFIG.BASE_Y + MAP_CONFIG.BANK_HEIGHT/2, -MAP_CONFIG.RIVER_WIDTH/2 - 7.5)
    leftBank.Anchored = true
    leftBank.Material = Enum.Material.Grass
    leftBank.BrickColor = BrickColor.new("Bright green")
    leftBank.Parent = workspace
    
    -- Margem direita
    local rightBank = Instance.new("Part")
    rightBank.Name = "RightBank"
    rightBank.Size = Vector3.new(MAP_CONFIG.RIVER_LENGTH, MAP_CONFIG.BANK_HEIGHT, 15)
    rightBank.Position = Vector3.new(MAP_CONFIG.RIVER_LENGTH/2, MAP_CONFIG.BASE_Y + MAP_CONFIG.BANK_HEIGHT/2, MAP_CONFIG.RIVER_WIDTH/2 + 7.5)
    rightBank.Anchored = true
    rightBank.Material = Enum.Material.Grass
    rightBank.BrickColor = BrickColor.new("Bright green")
    rightBank.Parent = workspace
    
    return water, leftBank, rightBank
end

-- Função para criar checkpoints
local function createCheckpoints()
    local checkpoints = {}
    local spacing = MAP_CONFIG.RIVER_LENGTH / (MAP_CONFIG.CHECKPOINT_COUNT + 1)
    
    for i = 1, MAP_CONFIG.CHECKPOINT_COUNT do
        local checkpoint = Instance.new("Part")
        checkpoint.Name = "Checkpoint" .. i
        checkpoint.Size = Vector3.new(2, 20, MAP_CONFIG.RIVER_WIDTH + 10)
        checkpoint.Position = Vector3.new(spacing * i, MAP_CONFIG.BASE_Y + 10, 0)
        checkpoint.Anchored = true
        checkpoint.Material = Enum.Material.Neon
        checkpoint.BrickColor = BrickColor.new("Bright yellow")
        checkpoint.Transparency = 0.3
        checkpoint.Parent = workspace
        
        -- Efeito de brilho
        local pointLight = Instance.new("PointLight")
        pointLight.Parent = checkpoint
        pointLight.Color = Color3.fromRGB(255, 255, 0)
        pointLight.Range = 30
        pointLight.Brightness = 3
        
        -- Texto do checkpoint
        local textLabel = Instance.new("BillboardGui")
        textLabel.Size = UDim2.new(0, 100, 0, 40)
        textLabel.StudsOffset = Vector3.new(0, 15, 0)
        textLabel.Parent = checkpoint
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "CP " .. i
        text.TextColor3 = Color3.fromRGB(255, 255, 0)
        text.TextScaled = true
        text.Font = Enum.Font.GothamBold
        text.Parent = textLabel
        
        table.insert(checkpoints, checkpoint)
    end
    
    return checkpoints
end

-- Função para criar linha de chegada
local function createFinishLine()
    local finishLine = Instance.new("Part")
    finishLine.Name = "FinishLine"
    finishLine.Size = Vector3.new(10, 25, MAP_CONFIG.RIVER_WIDTH + 20)
    finishLine.Position = Vector3.new(MAP_CONFIG.RIVER_LENGTH - 20, MAP_CONFIG.BASE_Y + 12.5, 0)
    finishLine.Anchored = true
    finishLine.Material = Enum.Material.Neon
    finishLine.BrickColor = BrickColor.new("Bright red")
    finishLine.Transparency = 0.2
    finishLine.Parent = workspace
    
    -- Efeito de luz na linha de chegada
    local finishLight = Instance.new("PointLight")
    finishLight.Parent = finishLine
    finishLight.Color = Color3.fromRGB(255, 0, 0)
    finishLight.Range = 60
    finishLight.Brightness = 5
    
    -- Texto da linha de chegada
    local textLabel = Instance.new("BillboardGui")
    textLabel.Size = UDim2.new(0, 200, 0, 60)
    textLabel.StudsOffset = Vector3.new(0, 20, 0)
    textLabel.Parent = finishLine
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "🏁 CHEGADA 🏁"
    text.TextColor3 = Color3.fromRGB(255, 0, 0)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = textLabel
    
    return finishLine
end

-- Função para criar área de spawn
local function createSpawnArea()
    local spawnArea = Instance.new("Part")
    spawnArea.Name = "SpawnArea"
    spawnArea.Size = Vector3.new(30, 2, 30)
    spawnArea.Position = Vector3.new(-20, MAP_CONFIG.BASE_Y + 1, 0)
    spawnArea.Anchored = true
    spawnArea.Material = Enum.Material.Concrete
    spawnArea.BrickColor = BrickColor.new("Medium stone grey")
    spawnArea.Parent = workspace
    
    -- SpawnLocation para jogadores
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(6, 1, 6)
    spawnLocation.Position = Vector3.new(-20, MAP_CONFIG.BASE_Y + 2, 0)
    spawnLocation.Anchored = true
    spawnLocation.Material = Enum.Material.Concrete
    spawnLocation.BrickColor = BrickColor.new("Bright blue")
    spawnLocation.Parent = workspace
    
    return spawnArea, spawnLocation
end

-- Função para criar decorações
local function createDecorations()
    local decorations = {}
    
    -- Árvores nas margens
    local treePositions = {
        -- Margem esquerda
        {pos = Vector3.new(50, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(150, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(250, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(350, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(450, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(550, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(650, MAP_CONFIG.BASE_Y, -70), size = Vector3.new(4, 20, 4)},
        
        -- Margem direita
        {pos = Vector3.new(50, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(150, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(250, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(350, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(450, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(550, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)},
        {pos = Vector3.new(650, MAP_CONFIG.BASE_Y, 70), size = Vector3.new(4, 20, 4)}
    }
    
    for i, treeData in pairs(treePositions) do
        local tree = Instance.new("Part")
        tree.Name = "Tree" .. i
        tree.Size = treeData.size
        tree.Position = treeData.pos
        tree.Anchored = true
        tree.Material = Enum.Material.Wood
        tree.BrickColor = BrickColor.new("Brown")
        tree.Parent = workspace
        
        -- Folhas da árvore
        local leaves = Instance.new("Part")
        leaves.Name = "Leaves" .. i
        leaves.Size = Vector3.new(8, 8, 8)
        leaves.Position = treeData.pos + Vector3.new(0, 14, 0)
        leaves.Anchored = true
        leaves.Material = Enum.Material.Grass
        leaves.BrickColor = BrickColor.new("Bright green")
        leaves.Shape = Enum.PartType.Ball
        leaves.Parent = workspace
        
        table.insert(decorations, tree)
        table.insert(decorations, leaves)
    end
    
    -- Rochas
    local rockPositions = {
        {pos = Vector3.new(100, MAP_CONFIG.BASE_Y, -60), size = Vector3.new(6, 4, 6)},
        {pos = Vector3.new(300, MAP_CONFIG.BASE_Y, 60), size = Vector3.new(6, 4, 6)},
        {pos = Vector3.new(500, MAP_CONFIG.BASE_Y, -60), size = Vector3.new(6, 4, 6)},
        {pos = Vector3.new(700, MAP_CONFIG.BASE_Y, 60), size = Vector3.new(6, 4, 6)}
    }
    
    for i, rockData in pairs(rockPositions) do
        local rock = Instance.new("Part")
        rock.Name = "Rock" .. i
        rock.Size = rockData.size
        rock.Position = rockData.pos
        rock.Anchored = true
        rock.Material = Enum.Material.Rock
        rock.BrickColor = BrickColor.new("Medium stone grey")
        rock.Parent = workspace
        
        table.insert(decorations, rock)
    end
    
    return decorations
end

-- Função para criar obstáculos no rio
local function createObstacles()
    local obstacles = {}
    
    local obstaclePositions = {
        {pos = Vector3.new(200, MAP_CONFIG.BASE_Y, 20), size = Vector3.new(3, 8, 3)},
        {pos = Vector3.new(400, MAP_CONFIG.BASE_Y, -20), size = Vector3.new(3, 8, 3)},
        {pos = Vector3.new(600, MAP_CONFIG.BASE_Y, 15), size = Vector3.new(3, 8, 3)}
    }
    
    for i, obstacleData in pairs(obstaclePositions) do
        local obstacle = Instance.new("Part")
        obstacle.Name = "Obstacle" .. i
        obstacle.Size = obstacleData.size
        obstacle.Position = obstacleData.pos
        obstacle.Anchored = true
        obstacle.Material = Enum.Material.Rock
        obstacle.BrickColor = BrickColor.new("Dark stone grey")
        obstacle.Parent = workspace
        
        table.insert(obstacles, obstacle)
    end
    
    return obstacles
end

-- Função para configurar iluminação
local function setupLighting()
    Lighting.Ambient = Color3.fromRGB(100, 150, 255) -- Luz azul clara
    Lighting.Brightness = 2
    Lighting.ClockTime = 12 -- Meio-dia
    Lighting.FogColor = Color3.fromRGB(150, 200, 255)
    Lighting.FogEnd = 1500
    Lighting.ExposureCompensation = 0.2
end

-- Função principal para construir o mapa
local function buildMap()
    print("Construindo mapa do jogo...")
    
    -- Configurar iluminação
    setupLighting()
    
    -- Criar rio e margens
    local water, leftBank, rightBank = createRiver()
    
    -- Criar checkpoints
    local checkpoints = createCheckpoints()
    
    -- Criar linha de chegada
    local finishLine = createFinishLine()
    
    -- Criar área de spawn
    local spawnArea, spawnLocation = createSpawnArea()
    
    -- Criar decorações
    local decorations = createDecorations()
    
    -- Criar obstáculos
    local obstacles = createObstacles()
    
    print("Mapa construído com sucesso!")
    print("- Rio: " .. MAP_CONFIG.RIVER_LENGTH .. "x" .. MAP_CONFIG.RIVER_WIDTH)
    print("- Checkpoints: " .. #checkpoints)
    print("- Decorações: " .. #decorations)
    print("- Obstáculos: " .. #obstacles)
    
    return {
        water = water,
        leftBank = leftBank,
        rightBank = rightBank,
        checkpoints = checkpoints,
        finishLine = finishLine,
        spawnArea = spawnArea,
        spawnLocation = spawnLocation,
        decorations = decorations,
        obstacles = obstacles
    }
end

-- Construir o mapa
local map = buildMap()

print("Mapa do jogo de caiaques carregado!") 