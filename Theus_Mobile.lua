-- ===== SCRIPT THEUS TELEPORT - MOBILE VERSION =====
-- Otimizado para dispositivos móveis
-- ===================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

local teleportLocations = {}
local carpetInHand = nil
local guiOpen = false
local selectedLocation = nil

print("[THEUS] 📱 Iniciando versão MOBILE...")

-- ===== CRIAR GUI MOBILE =====
local function createGui()
    print("[THEUS] Criando GUI Mobile...")
    
    -- Limpar GUI anterior
    local oldGui = player.PlayerGui:FindFirstChild("TheusGuiMobile")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TheusGuiMobile"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- ===== FRAME PRINCIPAL =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- ===== HEADER (TOPO) =====
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 60)
    headerFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🌀 THEUS TELEPORT"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame
    
    -- Botao Fechar (X)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(1, -55, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 1
    closeButton.Parent = headerFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        guiOpen = false
        if carpetInHand then carpetInHand:Destroy() end
    end)
    
    closeButton.TouchTap:Connect(function()
        screenGui:Destroy()
        guiOpen = false
        if carpetInHand then carpetInHand:Destroy() end
    end)
    
    -- ===== CONTAINER PRINCIPAL =====
    local containerFrame = Instance.new("Frame")
    containerFrame.Name = "Container"
    containerFrame.Size = UDim2.new(1, 0, 1, -70)
    containerFrame.Position = UDim2.new(0, 0, 0, 60)
    containerFrame.BackgroundTransparency = 1
    containerFrame.Parent = mainFrame
    
    -- ===== ABAS (TABS) =====
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(1, 0, 0, 50)
    tabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabsFrame.BorderSizePixel = 1
    tabsFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    tabsFrame.Parent = containerFrame
    
    -- Tab 1: Teleportar
    local tab1Button = Instance.new("TextButton")
    tab1Button.Name = "Tab1"
    tab1Button.Size = UDim2.new(0.5, -1, 1, 0)
    tab1Button.Position = UDim2.new(0, 0, 0, 0)
    tab1Button.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    tab1Button.Text = "📍 TELEPORTAR"
    tab1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab1Button.Font = Enum.Font.GothamBold
    tab1Button.TextScaled = true
    tab1Button.BorderSizePixel = 1
    tab1Button.Parent = tabsFrame
    
    -- Tab 2: Salvar
    local tab2Button = Instance.new("TextButton")
    tab2Button.Name = "Tab2"
    tab2Button.Size = UDim2.new(0.5, -1, 1, 0)
    tab2Button.Position = UDim2.new(0.5, 1, 0, 0)
    tab2Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tab2Button.Text = "💾 SALVAR"
    tab2Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab2Button.Font = Enum.Font.GothamBold
    tab2Button.TextScaled = true
    tab2Button.BorderSizePixel = 1
    tab2Button.Parent = tabsFrame
    
    -- ===== CONTEUDO ABA 1: TELEPORTAR =====
    local content1Frame = Instance.new("Frame")
    content1Frame.Name = "Content1"
    content1Frame.Size = UDim2.new(1, 0, 1, -50)
    content1Frame.Position = UDim2.new(0, 0, 0, 50)
    content1Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    content1Frame.BorderSizePixel = 0
    content1Frame.Parent = containerFrame
    content1Frame.Visible = true
    
    local scrollingFrame1 = Instance.new("ScrollingFrame")
    scrollingFrame1.Name = "LocationsList"
    scrollingFrame1.Size = UDim2.new(1, -10, 1, -10)
    scrollingFrame1.Position = UDim2.new(0, 5, 0, 5)
    scrollingFrame1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scrollingFrame1.BorderSizePixel = 1
    scrollingFrame1.BorderColor3 = Color3.fromRGB(80, 80, 80)
    scrollingFrame1.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame1.ScrollBarThickness = 12
    scrollingFrame1.Parent = content1Frame
    
    local uiListLayout1 = Instance.new("UIListLayout")
    uiListLayout1.Padding = UDim.new(0, 5)
    uiListLayout1.Parent = scrollingFrame1
    
    -- Funcao para atualizar lista de teleporte
    local function updateLocationsList()
        for _, child in ipairs(scrollingFrame1:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local count = 0
        for name, pos in pairs(teleportLocations) do
            count = count + 1
            local locButton = Instance.new("TextButton")
            locButton.Name = name
            locButton.Size = UDim2.new(1, -5, 0, 50)
            locButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            locButton.Text = "📍 " .. name
            locButton.TextColor3 = Color3.fromRGB(200, 255, 200)
            locButton.Font = Enum.Font.Gotham
            locButton.TextScaled = true
            locButton.BorderSizePixel = 1
            locButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
            locButton.Parent = scrollingFrame1
            
            local function teleport()
                selectedLocation = name
                humanoidRootPart.CFrame = CFrame.new(Vector3.new(pos.x, pos.y, pos.z) + Vector3.new(0, 3, 0))
                print("[THEUS] 📍 Teleportado para: " .. name)
                
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
            end
            
            locButton.MouseButton1Click:Connect(teleport)
            locButton.TouchTap:Connect(teleport)
        end
        
        if count == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 1, 0)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "📭 Nenhuma localização salva\n\nVá para 'SALVAR' para criar uma!"
            emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.TextScaled = true
            emptyLabel.Parent = scrollingFrame1
        end
        
        scrollingFrame1.CanvasSize = UDim2.new(0, 0, 0, count * 55)
    end
    
    -- ===== CONTEUDO ABA 2: SALVAR =====
    local content2Frame = Instance.new("Frame")
    content2Frame.Name = "Content2"
    content2Frame.Size = UDim2.new(1, 0, 1, -50)
    content2Frame.Position = UDim2.new(0, 0, 0, 50)
    content2Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    content2Frame.BorderSizePixel = 0
    content2Frame.Parent = containerFrame
    content2Frame.Visible = false
    
    -- Campo de Entrada
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -10, 0, 50)
    nameInput.Position = UDim2.new(0, 5, 0, 10)
    nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nameInput.Text = "Nome da localização"
    nameInput.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextScaled = true
    nameInput.BorderSizePixel = 1
    nameInput.BorderColor3 = Color3.fromRGB(100, 100, 100)
    nameInput.Parent = content2Frame
    
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
    
    -- Info Label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(1, -10, 0, 50)
    infoLabel.Position = UDim2.new(0, 5, 0, 70)
    infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoLabel.Text = "📌 Posição Atual:\nX: " .. math.floor(humanoidRootPart.Position.X) .. " | Y: " .. math.floor(humanoidRootPart.Position.Y) .. " | Z: " .. math.floor(humanoidRootPart.Position.Z)
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextScaled = true
    infoLabel.BorderSizePixel = 1
    infoLabel.Parent = content2Frame
    
    -- Botao Salvar
    local saveLocButton = Instance.new("TextButton")
    saveLocButton.Name = "SaveLocButton"
    saveLocButton.Size = UDim2.new(1, -10, 0, 55)
    saveLocButton.Position = UDim2.new(0, 5, 0, 130)
    saveLocButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    saveLocButton.Text = "✅ SALVAR LOCALIZAÇÃO"
    saveLocButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveLocButton.Font = Enum.Font.GothamBold
    saveLocButton.TextScaled = true
    saveLocButton.BorderSizePixel = 1
    saveLocButton.Parent = content2Frame
    
    local function saveLocation()
        if nameInput.Text ~= "" and nameInput.Text ~= "Nome da localização" then
            teleportLocations[nameInput.Text] = {
                x = humanoidRootPart.Position.X,
                y = humanoidRootPart.Position.Y,
                z = humanoidRootPart.Position.Z
            }
            print("[THEUS] ✅ Localização '" .. nameInput.Text .. "' salva!")
            updateLocationsList()
            nameInput.Text = "Nome da localização"
            
            -- Animacao
            saveLocButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            wait(0.3)
            saveLocButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
    end
    
    saveLocButton.MouseButton1Click:Connect(saveLocation)
    saveLocButton.TouchTap:Connect(saveLocation)
    
    -- ScrollingFrame para deletar
    local scrollingFrame2 = Instance.new("ScrollingFrame")
    scrollingFrame2.Name = "DeleteList"
    scrollingFrame2.Size = UDim2.new(1, -10, 0, 150)
    scrollingFrame2.Position = UDim2.new(0, 5, 0, 195)
    scrollingFrame2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scrollingFrame2.BorderSizePixel = 1
    scrollingFrame2.BorderColor3 = Color3.fromRGB(80, 80, 80)
    scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame2.ScrollBarThickness = 12
    scrollingFrame2.Parent = content2Frame
    
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim.new(0, 3)
    uiListLayout2.Parent = scrollingFrame2
    
    local function updateDeleteList()
        for _, child in ipairs(scrollingFrame2:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local count = 0
        for name, pos in pairs(teleportLocations) do
            count = count + 1
            local delButton = Instance.new("TextButton")
            delButton.Name = name
            delButton.Size = UDim2.new(1, -5, 0, 40)
            delButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            delButton.Text = "🗑️ " .. name
            delButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            delButton.Font = Enum.Font.Gotham
            delButton.TextScaled = true
            delButton.BorderSizePixel = 1
            delButton.Parent = scrollingFrame2
            
            local function delete()
                teleportLocations[name] = nil
                print("[THEUS] 🗑️ Localização '" .. name .. "' deletada!")
                updateDeleteList()
                updateLocationsList()
            end
            
            delButton.MouseButton1Click:Connect(delete)
            delButton.TouchTap:Connect(delete)
        end
        
        scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, count * 43)
    end
    
    updateDeleteList()
    
    -- ===== MUDAR ABAS =====
    tab1Button.MouseButton1Click:Connect(function()
        content1Frame.Visible = true
        content2Frame.Visible = false
        tab1Button.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        tab2Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tab1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab2Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    tab1Button.TouchTap:Connect(function()
        content1Frame.Visible = true
        content2Frame.Visible = false
        tab1Button.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        tab2Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tab1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab2Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    tab2Button.MouseButton1Click:Connect(function()
        content1Frame.Visible = false
        content2Frame.Visible = true
        tab1Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tab2Button.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        tab1Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateDeleteList()
    end)
    
    tab2Button.TouchTap:Connect(function()
        content1Frame.Visible = false
        content2Frame.Visible = true
        tab1Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tab2Button.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        tab1Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateDeleteList()
    end)
    
    updateLocationsList()
    print("[THEUS] ✅ GUI Mobile criada!")
end

-- ===== TOGGLE GUI =====
local function toggleGui()
    if guiOpen then
        local gui = player.PlayerGui:FindFirstChild("TheusGuiMobile")
        if gui then gui:Destroy() end
        guiOpen = false
    else
        createGui()
        guiOpen = true
    end
end

-- ===== INPUT - TECLADO =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggleGui()
    end
end)

-- ===== INPUT - TOQUE =====
local floatingButton = nil
local function createFloatingButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    floatingButton = Instance.new("TextButton")
    floatingButton.Name = "OpenButton"
    floatingButton.Size = UDim2.new(0, 60, 0, 60)
    floatingButton.Position = UDim2.new(1, -70, 1, -70)
    floatingButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    floatingButton.Text = "T"
    floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingButton.TextScaled = true
    floatingButton.Font = Enum.Font.GothamBold
    floatingButton.BorderSizePixel = 2
    floatingButton.BorderColor3 = Color3.fromRGB(100, 200, 255)
    floatingButton.Parent = screenGui
    
    local function openGui()
        toggleGui()
    end
    
    floatingButton.MouseButton1Click:Connect(openGui)
    floatingButton.TouchTap:Connect(openGui)
end

createFloatingButton()

-- ===== ATUALIZAR AO RESPAWNAR =====
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("[THEUS] 📱 Script Mobile Carregado!")
print("[THEUS] Pressione T ou toque no botão flutuante para abrir!")