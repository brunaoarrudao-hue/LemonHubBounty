_G.LemonAutoBounty = true
_G.TargetPlayer = nil

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- ==========================================
-- 1. CRIANDO A INTERFACE PRÓPRIA (LEMON HUB)
-- ==========================================
local LemonGui = Instance.new("ScreenGui")
LemonGui.Name = "LemonHubBounty"
LemonGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Parent = LemonGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🍋 Lemon Hub - Auto Bounty"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local BountyLabel = Instance.new("TextLabel")
BountyLabel.Size = UDim2.new(1, 0, 0, 30)
BountyLabel.Position = UDim2.new(0, 0, 0, 30)
BountyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BountyLabel.BackgroundTransparency = 1
BountyLabel.Parent = MainFrame

local SkipButton = Instance.new("TextButton")
SkipButton.Size = UDim2.new(0.8, 0, 0, 30)
SkipButton.Position = UDim2.new(0.1, 0, 0, 65)
SkipButton.Text = "Pular Jogador ⏭️"
SkipButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SkipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SkipButton.Parent = MainFrame

-- Lógica do botão de pular
SkipButton.MouseButton1Click:Connect(function()
    _G.TargetPlayer = nil
    print("Buscando novo alvo...")
end)

-- ==========================================
-- 2. FUNÇÕES DE COMBATE E MOVIMENTO
-- ==========================================

-- Função para atualizar o Bounty na tela
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local bounty = player.leaderstats:FindFirstChild("Bounty") or player.leaderstats:FindFirstChild("Honor")
            if bounty then
                BountyLabel.Text = "Bounty: " .. tostring(bounty.Value)
            end
        end)
    end
end)

-- Função de Spam de Skills e Clique Clássico
local function SpamSkills()
    -- Clique clássico
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    -- Spam de teclas (Z, X, C, V) e Raça (T, Y)
    local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.T, Enum.KeyCode.Y}
    for _, key in pairs(keys) do
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, key, false, game)
    end
end

-- ==========================================
-- 3. O LOOP DE CAÇA (TWEEN + LOW HEALTH)
-- ==========================================
task.spawn(function()
    while _G.LemonAutoBounty do
        task.wait()
        pcall(function()
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if not hrp or not hum then return end

            -- SISTEMA DE FUGA (Low Health)
            if hum.Health < (hum.MaxHealth * 0.3) then -- Se a vida ficar menor que 30%
                -- Voa para o céu para recuperar a vida
                local safeCFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 2000, hrp.Position.Z)
                hrp.CFrame = safeCFrame
                task.wait(1) -- Fica lá em cima até curar
                return -- Pausa o ataque
            end

            -- SISTEMA DE BUSCA DE ALVO
            if not _G.TargetPlayer or not _G.TargetPlayer.Character or _G.TargetPlayer.Character.Humanoid.Health <= 0 then
                -- Acha o jogador mais próximo que não seja da mesma tripulação (simplificado)
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        _G.TargetPlayer = v
                        break
                    end
                end
            end

            -- SISTEMA DE PERSEGUIÇÃO (Tween) E ATAQUE
            if _G.TargetPlayer and _G.TargetPlayer.Character then
                local targetHrp = _G.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    -- Vai para cima do inimigo (Tween rápido/Teleporte)
                    local tweenInfo = TweenInfo.new(3.0, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)})
                    tween:Play()
                    
                    -- Fica virado para o inimigo
                    hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
                    
                    -- Ataca
                    SpamSkills()
                end
            end
        end)
    end
end)
