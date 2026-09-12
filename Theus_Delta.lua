-- ===== SCRIPT THEUS TELEPORT - DELTA EXECUTOR V2 =====
-- Versão simplificada e otimizada
-- ====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local teleportLocations = {}
local carpetInHand = nil
local guiOpen = false
local selectedLocation = nil

print("[THEUS] Iniciando script...")

-- ===== CRIAR GUI SIMPLIFICADA =====
local function createGui()
    print("[THEUS] Criando GUI...")
    
    -- Limpar GUI anterior
    local oldGui = player.PlayerGui:FindFirstChild("TheusGui")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TheusGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- Frame Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    mainFrame.Parent = screenGui
    
    -- Titulo
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    titleLabel.Text = "🌀 THEUS TELEPORT 🌀"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = mainFrame
    
    -- Botao Fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -40, 0, 7.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 1
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        guiOpen = false
        if carpetInHand then carpetInHand:Destroy() end
    end)
    
    -- Label Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(1, -10, 0, 40)
    infoLabel.Position = UDim2.new(0, 5, 0, 60)
    infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoLabel.Text = "Localizações Salvas:"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.BorderSizePixel = 1
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextSize = 16
    infoLabel.Parent = mainFrame
    
    -- ScrollingFrame para Localizacoes
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "LocationsList"
    scrollingFrame.Size = UDim2.new(1, -10, 0, 150)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 110)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scrollingFrame.BorderSizePixel = 1
    scrollingFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.Parent = mainFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 3)
    uiListLayout.Parent = scrollingFrame
    
    -- Funcao para atualizar lista
    local function updateLocationsList()
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local count = 0
        for name, pos in pairs(teleportLocations) do
            count = count + 1
            local locButton = Instance.new("TextButton")
            locButton.Name = name
            locButton.Size = UDim2.new(1, -5, 0, 35)
            locButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            locButton.Text = "📍 " .. name
            locButton.TextColor3 = Color3.fromRGB(200, 255, 200)
            locButton.Font = Enum.Font.Gotham
            locButton.TextScaled = true
            locButton.BorderSizePixel = 1
            locButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
            locButton.Parent = scrollingFrame
            
            locButton.MouseButton1Click:Connect(function()
                selectedLocation = name
                humanoidRootPart.CFrame = CFrame.new(Vector3.new(pos.x, pos.y, pos.z) + Vector3.new(0, 3, 0))
                print("[THEUS] Teleportado para: " .. name)
                
                -- Criar tapete
                if carpetInHand then carpetInHand:Destroy() end
                carpetInHand = Instance.new("Part")
                carpetInHand.Name = "TeleportCarpet"
                carpetInHand.Shape = Enum.PartType.Block
                carpetInHand.Material = Enum.Material.Neon
                carpetInHand.Size = Vector3.new(2, 0.3, 2)
                carpetInHand.Color = Color3.fromRGB(255, 150, 0)
                carpetInHand.CanCollide = false
                carpetInHand.CFrame = humanoidRootPart.CFrame
                carpetInHand.Parent = workspace
                
                wait(2)
                if carpetInHand then carpetInHand:Destroy() end
            end)
        end
        
        if count == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 1, 0)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "Nenhuma localização salva"
            emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.Parent = scrollingFrame
        end
        
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 38)
    end
    
    -- Campo de Entrada
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -10, 0, 35)
    nameInput.Position = UDim2.new(0, 5, 0, 270)
    nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nameInput.Text = "Nome da localização"
    nameInput.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextScaled = true
    nameInput.BorderSizePixel = 1
    nameInput.BorderColor3 = Color3.fromRGB(100, 100, 100)
    nameInput.Parent = mainFrame
    
    nameInput.FocusLost:Connect(function()
        if nameInput.Text == "" then
            nameInput.Text = "Nome da localização"
        end
    end)
    
    nameInput.Focused:Connect(function()
        if nameInput.Text == "Nome da localização" then
            nameInput.Text = ""
        end
    end)
    
    -- Botao Salvar
    local saveLocButton = Instance.new("TextButton")
    saveLocButton.Name = "SaveLocButton"
    saveLocButton.Size = UDim2.new(1, -10, 0, 40)
    saveLocButton.Position = UDim2.new(0, 5, 0, 315)
    saveLocButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    saveLocButton.Text = "💾 SALVAR LOCALIZAÇÃO"
    saveLocButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveLocButton.Font = Enum.Font.GothamBold
    saveLocButton.TextScaled = true
    saveLocButton.BorderSizePixel = 1
    saveLocButton.Parent = mainFrame
    
    saveLocButton.MouseButton1Click:Connect(function()
        if nameInput.Text ~= "" and nameInput.Text ~= "Nome da localização" then
            teleportLocations[nameInput.Text] = {
                x = humanoidRootPart.Position.X,
                y = humanoidRootPart.Position.Y,
                z = humanoidRootPart.Position.Z
            }
            print("[THEUS] Localização '" .. nameInput.Text .. "' salva!")
            updateLocationsList()
            nameInput.Text = "Nome da localização"
        end
    end)
    
    -- Botao Deletar
    local deleteLocButton = Instance.new("TextButton")
    deleteLocButton.Name = "DeleteLocButton"
    deleteLocButton.Size = UDim2.new(1, -10, 0, 40)
    deleteLocButton.Position = UDim2.new(0, 5, 0, 365)
    deleteLocButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    deleteLocButton.Text = "🗑️ DELETAR SELECIONADO"
    deleteLocButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteLocButton.Font = Enum.Font.GothamBold
    deleteLocButton.TextScaled = true
    deleteLocButton.BorderSizePixel = 1
    deleteLocButton.Parent = mainFrame
    
    deleteLocButton.MouseButton1Click:Connect(function()
        if selectedLocation then
            teleportLocations[selectedLocation] = nil
            print("[THEUS] Localização '" .. selectedLocation .. "' deletada!")
            updateLocationsList()
            selectedLocation = nil
        end
    end)
    
    updateLocationsList()
    print("[THEUS] GUI Criada com sucesso!")
end

-- ===== TOGGLE GUI =====
local function toggleGui()
    if guiOpen then
        local gui = player.PlayerGui:FindFirstChild("TheusGui")
        if gui then gui:Destroy() end
        guiOpen = false
    else
        createGui()
        guiOpen = true
    end
end

-- ===== INPUT =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggleGui()
    end
end)

-- ===== ATUALIZAR AO RESPAWNAR =====
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("[THEUS] ✅ Script Carregado!")
print("[THEUS] Pressione T para abrir a GUI")