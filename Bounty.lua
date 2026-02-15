-- // Lemon Hub - Auto Bounty System 2026
_G.LemonAutoBounty = true
_G.TargetPlayer = nil
_G.IgnoredPlayers = {}
_G.TweenSpeed = 50.0 -- Ajuste aqui a velocidade (maior = mais lento)

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

-- ==========================================
-- 1. INTERFACE PRÓPRIA (UI NATIVA)
-- ==========================================
local LemonGui = Instance.new("ScreenGui")
LemonGui.Name = "LemonHubBounty"
LemonGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.5, -110, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Você pode arrastar a janela
MainFrame.Parent = LemonGui

-- Bordas Arredondadas
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🍋 Lemon Hub Bounty"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 25)
InfoLabel.Position = UDim2.new(0, 0, 0, 35)
InfoLabel.Text = "Buscando alvo..."
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = MainFrame

local SkipButton = Instance.new("TextButton")
SkipButton.Size = UDim2.new(0, 180, 0, 35)
SkipButton.Position = UDim2.new(0, 20, 0, 75)
SkipButton.Text = "Pular Jogador ⏭️"
SkipButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
SkipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SkipButton.Font = Enum.Font.GothamBold
SkipButton.Parent = MainFrame

local SkipCorner = Instance.new("UICorner")
SkipCorner.CornerRadius = UDim.new(0, 8)
SkipCorner.Parent = SkipButton

-- ==========================================
-- 2. LÓGICA DE COMBATE E SKILLS
-- ==========================================

local function SpamCombat()
    -- Clique Clássico
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    -- Teclas de Skill e Raça (Z, X, C, V, T, Y)
    local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.T, Enum.KeyCode.Y}
    for _, key in pairs(keys) do
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, key, false, game)
    end
end

-- ==========================================
-- 3. BOTÃO PULAR JOGADOR
-- ==========================================
SkipButton.MouseButton1Click:Connect(function()
    if _G.TargetPlayer then
        _G.IgnoredPlayers[_G.TargetPlayer.Name] = true
        _G.TargetPlayer = nil
        InfoLabel.Text = "Jogador Pulado!"
        task.wait(0.5)
    end
end)

-- ==========================================
-- 4. LOOP PRINCIPAL (TWEEN + CAÇA + FUGA)
-- ==========================================
task.spawn(function()
    while _G.LemonAutoBounty do
        task.wait(0.1)
        pcall(function()
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if not hrp or not hum then return end

            -- SISTEMA DE FUGA (Low Health)
            if hum.Health < (hum.MaxHealth * 0.3) then
                InfoLabel.Text = "Vida Baixa! Fugindo..."
                hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 1500, hrp.Position.Z)
                repeat task.wait(0.5) until hum.Health >= (hum.MaxHealth * 0.85) or not _G.LemonAutoBounty
                return
            end

            -- BUSCA DE ALVO (Com Blacklist)
            if not _G.TargetPlayer or not _G.TargetPlayer.Character or _G.TargetPlayer.Character.Humanoid.Health <= 0 then
                local found = false
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= player and not _G.IgnoredPlayers[v.Name] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        _G.TargetPlayer = v
                        found = true
                        break
                    end
                end
                
                if not found then
                    _G.IgnoredPlayers = {} -- Reseta se todos foram pulados
                    InfoLabel.Text = "Reiniciando Lista..."
                end
            end

            -- PERSEGUIÇÃO E ATAQUE
            if _G.TargetPlayer and _G.TargetPlayer.Character then
                local targetHrp = _G.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = _G.TargetPlayer.Character:FindFirstChild("Humanoid")
                
                if targetHrp and targetHum then
                    InfoLabel.Text = "Caçando: " .. _G.TargetPlayer.DisplayName
                    
                    -- Tween Ajustável
                    local tweenInfo = TweenInfo.new(_G.TweenSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)})
                    tween:Play()
                    
                    -- Girar para o alvo e bater
                    hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
                    SpamCombat()
                end
            end
        end)
    end
end)
