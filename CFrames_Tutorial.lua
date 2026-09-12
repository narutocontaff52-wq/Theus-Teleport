-- ===== MANIPULACAO DE CFRAMES - TUTORIAL COMPLETO =====
-- Entendendo posição e orientação em 3D
-- ======================================================

local part = Instance.new("Part")
part.Parent = workspace

print("\n" .. string.rep("=", 60))
print("TUTORIAL CFRAMES - POSIÇÃO E ORIENTAÇÃO")
print(string.rep("=", 60) .. "\n")

-- ===== 1. OBTENDO O CFRAME =====
print("1️⃣ OBTENDO O CFRAME")
print("-" .. string.rep("-", 58))

local cf = part.CFrame
print("CFrame completo: " .. tostring(cf))
print("")

-- ===== 2. POSICAO (Vector3) =====
print("2️⃣ POSIÇÃO (cf.Position)")
print("-" .. string.rep("-", 58))

local position = cf.Position
print("Posição: " .. tostring(position))
print("X: " .. position.X)
print("Y: " .. position.Y)
print("Z: " .. position.Z)
print("")

-- ===== 3. VETORES UNITARIOS (Unit Vectors / Birim Vektörler) =====
print("3️⃣ VETORES UNITÁRIOS (Magnitude = 1)")
print("-" .. string.rep("-", 58))

-- LOOK VECTOR (Para onde a parte está olhando / Öne bakan)
local lookVector = cf.LookVector
print("🔍 LookVector (Para frente / Öne bakan):")
print("   " .. tostring(lookVector))
print("   Magnitude: " .. lookVector.Magnitude)
print("")

-- RIGHT VECTOR (Direita / Sağ)
local rightVector = cf.RightVector
print("👉 RightVector (Para direita / Sağ):")
print("   " .. tostring(rightVector))
print("   Magnitude: " .. rightVector.Magnitude)
print("")

-- UP VECTOR (Acima / Yukarı)
local upVector = cf.UpVector
print("☝️ UpVector (Para cima / Yukarı):")
print("   " .. tostring(upVector))
print("   Magnitude: " .. upVector.Magnitude)
print("")

-- ===== 4. MATRIZ DE ROTACAO 3x3 =====
print("4️⃣ MATRIZ DE ROTAÇÃO 3x3")
print("-" .. string.rep("-", 58))

local px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()

print("GetComponents() retorna 12 float:")
print("Posição: (px, py, pz)")
print("Rotação: (r00, r01, r02, r10, r11, r12, r20, r21, r22)")
print("")

print("📍 Posição (px, py, pz):")
print("   px=" .. px .. ", py=" .. py .. ", pz=" .. pz)
print("")

print("🔄 Matriz de Rotação 3x3:")
print("   ┌                    ┐")
print("   │ " .. string.format("%.3f", r00) .. "  " .. string.format("%.3f", r01) .. "  " .. string.format("%.3f", r02) .. " │  (LookVector)")
print("   │ " .. string.format("%.3f", r10) .. "  " .. string.format("%.3f", r11) .. "  " .. string.format("%.3f", r12) .. " │  (RightVector)")
print("   │ " .. string.format("%.3f", r20) .. "  " .. string.format("%.3f", r21) .. "  " .. string.format("%.3f", r22) .. " │  (UpVector)")
print("   └                    ┘")
print("")

-- Verificar se os vetores correspondem à matriz
print("✅ Verificação:")
print("   LookVector = (-r02, -r12, -r22) = " .. tostring(Vector3.new(-r02, -r12, -r22)))
print("   RightVector = (r00, r10, r20) = " .. tostring(Vector3.new(r00, r10, r20)))
print("   UpVector = (r01, r11, r21) = " .. tostring(Vector3.new(r01, r11, r21)))
print("")

-- ===== 5. CRIANDO CFRAMES =====
print("5️⃣ CRIANDO NOVOS CFRAMES")
print("-" .. string.rep("-", 58))

-- Apenas posição
local cf1 = CFrame.new(0, 5, 0)
print("✏️ CFrame.new(posição):")
print("   " .. tostring(cf1))
print("")

-- Posição e olhar para um ponto
local cf2 = CFrame.new(Vector3.new(0, 5, 0), Vector3.new(10, 5, 0))
print("✏️ CFrame.new(posição, alvo):")
print("   " .. tostring(cf2))
print("")

-- Usando fromMatrix
local cf3 = CFrame.fromMatrix(Vector3.new(0, 5, 0), rightVector, upVector, -lookVector)
print("✏️ CFrame.fromMatrix(pos, right, up, -look):")
print("   " .. tostring(cf3))
print("")

-- ===== 6. ROTACOES =====
print("6️⃣ ROTAÇÕES (CFrame.Angles)")
print("-" .. string.rep("-", 58))

-- Rotação em torno do eixo X (pitch)
local cf4 = cf * CFrame.Angles(math.rad(45), 0, 0)
print("❌ Rotação X (45°):")
print("   " .. tostring(cf4))
print("")

-- Rotação em torno do eixo Y (yaw)
local cf5 = cf * CFrame.Angles(0, math.rad(90), 0)
print("❌ Rotação Y (90°):")
print("   " .. tostring(cf5))
print("")

-- Rotação em torno do eixo Z (roll)
local cf6 = cf * CFrame.Angles(0, 0, math.rad(180))
print("❌ Rotação Z (180°):")
print("   " .. tostring(cf6))
print("")

-- ===== 7. MOVIMENTACAO USANDO VETORES =====
print("7️⃣ MOVIMENTAÇÃO USANDO VETORES")
print("-" .. string.rep("-", 58))

-- Mover para frente (Look Vector)
local cf7 = cf + cf.LookVector * 10
print("➡️ Mover para frente (10 studs):")
print("   " .. tostring(cf7))
print("")

-- Mover para direita (Right Vector)
local cf8 = cf + cf.RightVector * 5
print("👉 Mover para direita (5 studs):")
print("   " .. tostring(cf8))
print("")

-- Mover para cima (Up Vector)
local cf9 = cf + cf.UpVector * 3
print("☝️ Mover para cima (3 studs):")
print("   " .. tostring(cf9))
print("")

-- ===== 8. COMBINACOES =====
print("8️⃣ COMBINAÇÕES (Posição + Rotação)")
print("-" .. string.rep("-", 58))

local cf10 = (cf + Vector3.new(5, 5, 5)) * CFrame.Angles(math.rad(45), math.rad(90), 0)
print("🔀 Mover + Rotacionar:")
print("   " .. tostring(cf10))
print("")

-- ===== 9. INTERPOLACAO =====
print("9️⃣ INTERPOLAÇÃO (Lerp)")
print("-" .. string.rep("-", 58))

local cf_start = CFrame.new(0, 0, 0)
local cf_end = CFrame.new(10, 5, 10)

local cf_lerp_25 = cf_start:Lerp(cf_end, 0.25)
local cf_lerp_50 = cf_start:Lerp(cf_end, 0.50)
local cf_lerp_75 = cf_start:Lerp(cf_end, 0.75)

print("Interpolação de " .. tostring(cf_start.Position) .. " para " .. tostring(cf_end.Position))
print("   25%: " .. tostring(cf_lerp_25.Position))
print("   50%: " .. tostring(cf_lerp_50.Position))
print("   75%: " .. tostring(cf_lerp_75.Position))
print("")

-- ===== 10. DISTANCIA E DIRECAO =====
print("🔟 DISTÂNCIA E DIREÇÃO")
print("-" .. string.rep("-", 58))

local dist = (cf_start.Position - cf_end.Position).Magnitude
local direction = (cf_end.Position - cf_start.Position).Unit

print("Distância: " .. dist)
print("Direção normalizada: " .. tostring(direction))
print("")

-- ===== 11. APLICANDO CFRAME EM PART =====
print("1️⃣1️⃣ APLICANDO CFRAME EM PART")
print("-" .. string.rep("-", 58))

part.CFrame = CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0)
print("✅ Part movida para (0, 10, 0) com rotação (45°, 45°, 0°)")
print("")

-- ===== FUNCAO UTILITARIA =====
print("1️⃣2️⃣ FUNÇÃO UTILITÁRIA: IMPRIMIR INFO DO CFRAME")
print("-" .. string.rep("-", 58))

local function printCFrameInfo(name, cframe)
    print("\n📋 " .. name .. ":")
    print("   CFrame: " .. tostring(cframe))
    print("   Posição: " .. tostring(cframe.Position))
    print("   LookVector: " .. tostring(cframe.LookVector))
    print("   RightVector: " .. tostring(cframe.RightVector))
    print("   UpVector: " .. tostring(cframe.UpVector))
    
    local px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cframe:GetComponents()
    print("   GetComponents: px=" .. px .. " py=" .. py .. " pz=" .. pz)
    print("                  r00=" .. string.format("%.3f", r00) .. " r01=" .. string.format("%.3f", r01) .. " r02=" .. string.format("%.3f", r02))
    print("                  r10=" .. string.format("%.3f", r10) .. " r11=" .. string.format("%.3f", r11) .. " r12=" .. string.format("%.3f", r12))
    print("                  r20=" .. string.format("%.3f", r20) .. " r21=" .. string.format("%.3f", r21) .. " r22=" .. string.format("%.3f", r22))
end

printCFrameInfo("Exemplo CFrame", part.CFrame)

print("\n" .. string.rep("=", 60))
print("✅ TUTORIAL COMPLETO!")
print(string.rep("=", 60) .. "\n")