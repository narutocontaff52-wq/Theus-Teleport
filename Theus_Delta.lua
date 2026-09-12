-- ===== SCRIPT THEUS TELEPORT - DELTA EXECUTOR =====
-- Compatível com Delta Executor Lua
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ===== VARIAVEIS GLOBAIS =====
local teleportLocations = {}
local carpetInHand = nil
local guiOpen = false
local selectedLocation = nil
local saveFilePath = "Theus_Teleport_Locations.txt"

-- ===== FUNCAO: CARREGAR SALVA LOCAL (DELTA EXECUTOR) =====
local function loadLocations()
    local success, data = pcall(function()
        -- Delta Executor usa readfile
        local fileContent = readfile(saveFilePath)
        if fileContent then
            local decoded = {}
            for line in fileContent:gmatch("[^\n]+") do
                if line ~= "" then
                    local parts = {}
                    for part in line:gmatch("[^,]+") do
                        table.insert(parts, part)
                    end
                    if #parts == 4 then
                        decoded[parts[1]] = {
                            x = tonumber(parts[2]),
                            y = tonumber(parts[3]),
                            z = tonumber(parts[4])
                        }
                    end
                end
            end
            return decoded
        end
    end)
    
    if success and data then
        teleportLocations = data
        print("[THEUS] Localizações carregadas!")
    else
        teleportLocations = {}
        print("[THEUS] Nenhuma localização salva encontrada.")
    end
end

-- ===== FUNCAO: SALVAR LOCALIZACOES =====
local function saveLocations()
    local success = pcall(function()
        local content = ""
        for name, pos in pairs(teleportLocations) do
            content = content .. name .. "," .. pos.x .. "," .. pos.y .. "," .. pos.z .. "\n"
        end
        writefile(saveFilePath, content)
    end)
    
    if success then
        print("[THEUS] Localizações salvas com sucesso!")
    else
        print("[THEUS] Erro ao salvar localizações!")
    end
end

-- ===== FUNCAO: CRIAR TAPETE NA MAO =====
local function createCarpet()
    if carpetInHand then 
        pcall(function() carpetInHand:Destroy() end)
    end
    
    pcall(function()
        carpetInHand = Instance.new("Part")
        carpetInHand.Name = "TeleportCarpet"
        carpetInHand.Shape = Enum.PartType.Block
        carpetInHand.Material = Enum.Material.Carpet
        carpetInHand.Size = Vector3.new(1.5, 0.2, 1.5)
        carpetInHand.Color = Color3.fromRGB(200, 100, 50)
        carpetInHand.CanCollide = false
        carpetInHand.CFrame = character:FindFirstChild("RightHand") and character:FindFirstChild("RightHand").CFrame or humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 5
        carpetInHand.Parent = workspace
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = character:FindFirstChild("RightHand") or humanoidRootPart
        weld.Part1 = carpetInHand
        weld.Parent = carpetInHand
    end)
end

-- ===== FUNCAO: REMOVER TAPETE =====
local function removeCarpet()
    if carpetInHand then
        pcall(function() carpetInHand:Destroy() end)
        carpetInHand = nil
    end
end

-- ===== FUNCAO: TELETRANSPORTAR =====
local function teleportTo(position)
    if not character or not humanoidRootPart then return end
    
    pcall(function()
        humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        print("[THEUS] Teleportado para: " .. tostring(position))
    end)
end

-- ===== FUNCAO: CRIAR GUI (OTIMIZADA PARA DELTA) =====
local function createGui()
    pcall(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TheusGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")
        
        -- Frame Principal
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        -- Adicionar UICorner para bordas arredondadas
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 10)
        uiCorner.Parent = mainFrame
        
        -- Titulo
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, 0, 0, 40)
        titleLabel.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        titleLabel.Text = "THEUS TELEPORT"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.BorderSizePixel = 0
        titleLabel.Parent = mainFrame
        
        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = titleLabel
        
        -- Botao Fechar
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0, 5)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        closeButton.BorderSizePixel = 0
        closeButton.Parent = mainFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 5)
        closeCorner.Parent = closeButton
        
        closeButton.MouseButton1Click:Connect(function()
            pcall(function() screenGui:Destroy() end)
            guiOpen = false
            removeCarpet()
        end)
        
        -- ScrollingFrame para Localizacoes
        local scrollingFrame = Instance.new("ScrollingFrame")
        scrollingFrame.Name = "LocationsList"
        scrollingFrame.Size = UDim2.new(1, -10, 0, 200)
        scrollingFrame.Position = UDim2.new(0, 5, 0, 50)
        scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        scrollingFrame.BorderSizePixel = 1
        scrollingFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollingFrame.Parent = mainFrame
        
        -- UIListLayout para ScrollingFrame
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.Parent = scrollingFrame
        
        -- Funcao para atualizar lista
        local function updateLocationsList()
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    pcall(function() child:Destroy() end)
                end
            end
            
            for name, pos in pairs(teleportLocations) do
                local locButton = Instance.new("TextButton")
                locButton.Name = name
                locButton.Size = UDim2.new(1, -10, 0, 30)
                locButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                locButton.Text = name
                locButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                locButton.Font = Enum.Font.Gotham
                locButton.BorderSizePixel = 1
                locButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
                locButton.Parent = scrollingFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 5)
                btnCorner.Parent = locButton
                
                locButton.MouseButton1Click:Connect(function()
                    selectedLocation = name
                    teleportTo(Vector3.new(pos.x, pos.y, pos.z))
                    createCarpet()
                end)
            end
            
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(#scrollingFrame:GetChildren() * 35, 1))
        end
        
        -- Campo de Entrada de Nome
        local nameInput = Instance.new("TextBox")
        nameInput.Name = "NameInput"
        nameInput.Size = UDim2.new(1, -10, 0, 30)
        nameInput.Position = UDim2.new(0, 5, 0, 260)
        nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        nameInput.Text = "Nome da Localização"
        nameInput.TextColor3 = Color3.fromRGB(200, 200, 200)
        nameInput.Font = Enum.Font.Gotham
        nameInput.BorderSizePixel = 1
        nameInput.BorderColor3 = Color3.fromRGB(100, 100, 100)
        nameInput.Parent = mainFrame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 5)
        inputCorner.Parent = nameInput
        
        -- Botao Salvar Localizacao
        local saveLocButton = Instance.new("TextButton")
        saveLocButton.Name = "SaveLocButton"
        saveLocButton.Size = UDim2.new(1, -10, 0, 30)
        saveLocButton.Position = UDim2.new(0, 5, 0, 300)
        saveLocButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        saveLocButton.Text = "SALVAR LOCALIZAÇÃO"
        saveLocButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveLocButton.Font = Enum.Font.GothamBold
        saveLocButton.BorderSizePixel = 0
        saveLocButton.Parent = mainFrame
        
        local saveCorner = Instance.new("UICorner")
        saveCorner.CornerRadius = UDim.new(0, 5)
        saveCorner.Parent = saveLocButton
        
        saveLocButton.MouseButton1Click:Connect(function()
            if nameInput.Text ~= "" and nameInput.Text ~= "Nome da Localização" then
                teleportLocations[nameInput.Text] = {
                    x = humanoidRootPart.Position.X,
                    y = humanoidRootPart.Position.Y,
                    z = humanoidRootPart.Position.Z
                }
                saveLocations()
                updateLocationsList()
                nameInput.Text = "Nome da Localização"
            end
        end)
        
        -- Botao Deletar Localizacao
        local deleteLocButton = Instance.new("TextButton")
        deleteLocButton.Name = "DeleteLocButton"
        deleteLocButton.Size = UDim2.new(1, -10, 0, 30)
        deleteLocButton.Position = UDim2.new(0, 5, 0, 340)
        deleteLocButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        deleteLocButton.Text = "DELETAR SELECIONADO"
        deleteLocButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteLocButton.Font = Enum.Font.GothamBold
        deleteLocButton.BorderSizePixel = 0
        deleteLocButton.Parent = mainFrame
        
        local deleteCorner = Instance.new("UICorner")
        deleteCorner.CornerRadius = UDim.new(0, 5)
        deleteCorner.Parent = deleteLocButton
        
        deleteLocButton.MouseButton1Click:Connect(function()
            if selectedLocation then
                teleportLocations[selectedLocation] = nil
                saveLocations()
                updateLocationsList()
                selectedLocation = nil
            end
        end)
        
        updateLocationsList()
    end)
end

-- ===== FUNCAO: TOGGLE GUI =====
local function toggleGui()
    if guiOpen then
        local gui = pcall(function()
            return player:WaitForChild("PlayerGui"):FindFirstChild("TheusGui")
        end)
        if gui then
            pcall(function() gui:Destroy() end)
        end
        guiOpen = false
        removeCarpet()
    else
        createGui()
        guiOpen = true
        createCarpet()
    end
end

-- ===== CARREGA LOCALIZACOES AO INICIAR =====
loadLocations()

-- ===== INPUT PARA ABRIR GUI =====
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.T then
            toggleGui()
        end
    end)
end)

-- ===== ATUALIZAR PERSONAGEM AO RESPAWNAR =====
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    removeCarpet()
end)

print("[THEUS] Script de Teleporte Carregado para Delta Executor!")
print("[THEUS] Pressione T para abrir a GUI")
print("[THEUS] Localizações salvas em: " .. saveFilePath)