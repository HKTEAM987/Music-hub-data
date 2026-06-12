-- ====================================================================
-- HK_ADMIN v3.0 — ULTRA SIMPLE & FONCTIONNEL
-- CRÉATEUR : DIABLESSE
-- POUR : TOUS LES EXECUTORS (Delta, Arceus, etc.)
-- SCRIPT 100% AUTONOME
-- ====================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

-- Whitelist
local HttpService = game:GetService("HttpService")
local url_wl = "https://gist.githubusercontent.com/HKTEAM987/54e42b3cffb8d47127435c70dce0826b/raw/836ef1d974f3facf848bf25d20c0b807de1638b0/whitelist.txt"
local s, r = pcall(function() return game:HttpGet(url_wl) end)
if not s or not string.find(r:lower(), localPlayer.Name:lower()) then
    warn("[HK] Pas whitelisté")
    return
end

-- ====================================================================
-- FONCTIONS DE COMMANDES (LOCALES)
-- ====================================================================

local function getChar(plr)
    return plr and plr.Character
end

local function getHum(plr)
    local c = getChar(plr)
    return c and c:FindFirstChild("Humanoid")
end

local function getRoot(plr)
    local c = getChar(plr)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function cmd_kill(plr)
    local h = getHum(plr)
    if h then h.Health = 0 end
end

local function cmd_freeze(plr)
    local c = getChar(plr)
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = true end
        end
    end
end

local function cmd_unfreeze(plr)
    local c = getChar(plr)
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = false end
        end
    end
end

local function cmd_explode(plr)
    local r = getRoot(plr)
    if r then
        local e = Instance.new("Explosion")
        e.Position = r.Position
        e.BlastRadius = 10
        e.BlastPressure = 0
        e.Visible = true
        e.Parent = workspace
        r.Velocity = Vector3.new(0, 50, 0)
    end
end

local function cmd_burn(plr)
    local c = getChar(plr)
    if c then
        local torso = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") or getRoot(plr)
        if torso then
            local f = Instance.new("Fire")
            f.Parent = torso
            f.Size = 10
            f.Heat = 20
            task.delay(8, function() pcall(function() f:Destroy() end) end)
        end
    end
end

local function cmd_slap(plr)
    local r = getRoot(plr)
    if r then
        r.Velocity = Vector3.new(math.random(-60, 60), 30, math.random(-60, 60))
    end
end

local function cmd_fling(plr)
    local r = getRoot(plr)
    if r then
        r.Velocity = Vector3.new(math.random(-150, 150), 100, math.random(-150, 150))
        r.RotVelocity = Vector3.new(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))
    end
end

local function cmd_bring(plr)
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = getRoot(plr)
    if myRoot and tRoot then
        tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, 5)
    end
end

local function cmd_tp_to(plr)
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = getRoot(plr)
    if myRoot and tRoot then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
    end
end

local function cmd_respawn(plr)
    plr:LoadCharacter()
end

local function cmd_stun(plr)
    local h = getHum(plr)
    if h then
        h.PlatformStand = true
        task.delay(5, function() pcall(function() h.PlatformStand = false end) end)
    end
end

local function cmd_loopkill(plr)
    spawn(function()
        for i = 1, 30 do
            local h = getHum(plr)
            if h and h.Health > 0 then
                h.Health = h.Health - 5
            end
            task.wait(0.15)
        end
    end)
end

local function cmd_kick(plr)
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, plr)
    end)
end

local function cmd_crash(plr)
    local r = getRoot(plr)
    if r then
        for i = 1, 40 do
            local p = Instance.new("Part")
            p.Parent = workspace
            p.Size = Vector3.new(1, 1, 1)
            p.Position = r.Position + Vector3.new(math.random(-10, 10), math.random(0, 20), math.random(-10, 10))
            p.Anchored = true
            p.BrickColor = BrickColor.Random()
            p.Material = Enum.Material.Neon
            task.wait()
        end
    end
end

local function cmd_fire_remotes(plr, action)
    local RE = ReplicatedStorage:FindFirstChild("RE") or ReplicatedStorage
    for _, remote in pairs(RE:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(action, plr.Name, "")
                remote:FireServer("AdminCommand", action, plr.Name, "")
            end)
        end
    end
end

-- Map des commandes
local COMMANDS = {
    kill = {name = "💀 KILL", color = Color3.fromRGB(255, 30, 30), fn = cmd_kill},
    explode = {name = "🌀 EXPLODE", color = Color3.fromRGB(255, 120, 0), fn = cmd_explode},
    freeze = {name = "❄️ FREEZE", color = Color3.fromRGB(60, 180, 255), fn = cmd_freeze},
    unfreeze = {name = "🔥 UNFREEZE", color = Color3.fromRGB(255, 200, 60), fn = cmd_unfreeze},
    burn = {name = "🔥 BURN", color = Color3.fromRGB(255, 60, 0), fn = cmd_burn},
    stun = {name = "🛑 STUN", color = Color3.fromRGB(255, 255, 60), fn = cmd_stun},
    slap = {name = "⚡ SLAP", color = Color3.fromRGB(200, 200, 60), fn = cmd_slap},
    fling = {name = "🌀 FLING", color = Color3.fromRGB(255, 80, 200), fn = cmd_fling},
    bring = {name = "📦 BRING", color = Color3.fromRGB(60, 255, 150), fn = cmd_bring},
    tp_to = {name = "📍 TP TO", color = Color3.fromRGB(60, 200, 255), fn = cmd_tp_to},
    respawn = {name = "💧 RESPAWN", color = Color3.fromRGB(60, 255, 100), fn = cmd_respawn},
    loopkill = {name = "🔪 LOOPKILL", color = Color3.fromRGB(200, 0, 0), fn = cmd_loopkill},
    kick = {name = "👢 KICK", color = Color3.fromRGB(200, 80, 80), fn = cmd_kick},
    crash = {name = "💥 CRASH", color = Color3.fromRGB(255, 0, 100), fn = cmd_crash},
}

-- ====================================================================
-- INTERFACE SIMPLE
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HK_Admin"
ScreenGui.ResetOnSpawn = false

-- Fenêtre
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.Position = UDim2.new(0.2, 0, 0.15, 0)
Main.Size = UDim2.new(0, 800, 0, 550)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
local MC = Instance.new("UICorner") MC.CornerRadius = UDim.new(0, 14) MC.Parent = Main
local MS = Instance.new("UIStroke") MS.Color = Color3.fromRGB(255, 40, 40) MS.Thickness = 2 MS.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
local HC = Instance.new("UICorner") HC.CornerRadius = UDim.new(0, 14) HC.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -20, 0, 28)
Title.Position = UDim2.new(0, 15, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "⚡ HK_ADMIN — " .. localPlayer.Name
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Header
SubTitle.Size = UDim2.new(1, -20, 0, 14)
SubTitle.Position = UDim2.new(0, 15, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Coche des joueurs → clic sur une commande"
SubTitle.TextColor3 = Color3.fromRGB(160, 160, 175)
SubTitle.Font = Enum.Font.SourceSansLight
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Bouton close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 18, 18)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
local CC = Instance.new("UICorner") CC.CornerRadius = UDim.new(0, 6) CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ====================================================================
-- PARTIE GAUCHE : LISTE DES JOUEURS
-- ====================================================================

local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = Main
LeftPanel.Position = UDim2.new(0, 12, 0, 60)
LeftPanel.Size = UDim2.new(0, 240, 1, -82)
LeftPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
local LP = Instance.new("UICorner") LP.CornerRadius = UDim.new(0, 8) LP.Parent = LeftPanel

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = LeftPanel
RefreshBtn.Size = UDim2.new(1, -10, 0, 28)
RefreshBtn.Position = UDim2.new(0, 5, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
RefreshBtn.Text = "🔄 Rafraîchir"
RefreshBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 13
local RC = Instance.new("UICorner") RC.CornerRadius = UDim.new(0, 5) RC.Parent = RefreshBtn

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = LeftPanel
PlayerList.Position = UDim2.new(0, 5, 0, 38)
PlayerList.Size = UDim2.new(1, -10, 1, -48)
PlayerList.BackgroundTransparency = 1
PlayerList.ScrollBarThickness = 3
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
PlayerList.BorderSize = 0
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)

local PLayout = Instance.new("UIListLayout")
PLayout.Parent = PlayerList
PLayout.Padding = UDim.new(0, 3)

-- ====================================================================
-- PARTIE DROITE : COMMANDES
-- ====================================================================

local RightPanel = Instance.new("ScrollingFrame")
RightPanel.Parent = Main
RightPanel.Position = UDim2.new(0, 265, 0, 60)
RightPanel.Size = UDim2.new(1, -280, 1, -82)
RightPanel.BackgroundTransparency = 1
RightPanel.ScrollBarThickness = 4
RightPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
RightPanel.BorderSize = 0
RightPanel.CanvasSize = UDim2.new(0, 0, 0, 0)

local CmdTitle = Instance.new("TextLabel")
CmdTitle.Parent = RightPanel
CmdTitle.Size = UDim2.new(1, -15, 0, 28)
CmdTitle.Position = UDim2.new(0, 8, 0, 5)
CmdTitle.BackgroundTransparency = 1
CmdTitle.Text = "COMMANDES"
CmdTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
CmdTitle.Font = Enum.Font.SourceSansBold
CmdTitle.TextSize = 16
CmdTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Conteneur des commandes
local CmdContainer = Instance.new("Frame")
CmdContainer.Parent = RightPanel
CmdContainer.Position = UDim2.new(0, 8, 0, 38)
CmdContainer.Size = UDim2.new(1, -16, 0, 0)
CmdContainer.BackgroundTransparency = 1

local CLayout = Instance.new("UIListLayout")
CLayout.Parent = CmdContainer
CLayout.Padding = UDim.new(0, 5)

-- ====================================================================
-- ÉTAT DES SÉLECTIONS
-- ====================================================================

local selectedPlayers = {}

local function updatePlayerList()
    -- Vider
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Nettoyer
    local currentNames = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            currentNames[plr.Name] = true
            if selectedPlayers[plr.Name] == nil then
                selectedPlayers[plr.Name] = false
            end
        end
    end
    for name, _ in pairs(selectedPlayers) do
        if not currentNames[name] then selectedPlayers[name] = nil end
    end
    
    -- Canvas
    local count = 0
    for _ in pairs(currentNames) do count = count + 1 end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, count * 34)
    
    -- Créer les boutons
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerList
            btn.Size = UDim2.new(1, -4, 0, 31)
            btn.BackgroundColor3 = selectedPlayers[plr.Name] and Color3.fromRGB(55, 15, 15) or Color3.fromRGB(18, 18, 26)
            btn.Text = ""
            btn.AutoButtonColor = false
            local BC = Instance.new("UICorner") BC.CornerRadius = UDim.new(0, 5) BC.Parent = btn
            
            -- Checkbox
            local cb = Instance.new("Frame")
            cb.Parent = btn
            cb.Size = UDim2.new(0, 16, 0, 16)
            cb.Position = UDim2.new(0, 6, 0.5, -8)
            cb.BackgroundColor3 = selectedPlayers[plr.Name] and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(30, 30, 40)
            cb.BorderSize = 0
            local CBC = Instance.new("UICorner") CBC.CornerRadius = UDim.new(0, 3) CBC.Parent = cb
            
            if selectedPlayers[plr.Name] then
                local cm = Instance.new("TextLabel")
                cm.Parent = cb
                cm.Size = UDim2.new(1, 0, 1, 0)
                cm.BackgroundTransparency = 1
                cm.Text = "✓"
                cm.TextColor3 = Color3.fromRGB(255, 255, 255)
                cm.Font = Enum.Font.GothamBold
                cm.TextSize = 13
            end
            
            -- Nom + tag admin si whitelisté
            local nl = Instance.new("TextLabel")
            nl.Parent = btn
            nl.Size = UDim2.new(0.7, -30, 1, 0)
            nl.Position = UDim2.new(0, 28, 0, 0)
            nl.BackgroundTransparency = 1
            nl.Text = plr.Name
            nl.TextColor3 = Color3.fromRGB(200, 200, 215)
            nl.Font = Enum.Font.SourceSansBold
            nl.TextSize = 14
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Indicateur si le joueur est dans la whitelist (utilise le script music)
            local isInWhitelist = string.find(r:lower(), plr.Name:lower()) ~= nil
            if isInWhitelist then
                local tag = Instance.new("TextLabel")
                tag.Parent = btn
                tag.Size = UDim2.new(0, 50, 1, 0)
                tag.Position = UDim2.new(0.7, 0, 0, 0)
                tag.BackgroundTransparency = 1
                tag.Text = "[MUSIC]"
                tag.TextColor3 = Color3.fromRGB(0, 210, 255)
                tag.Font = Enum.Font.SourceSansBold
                tag.TextSize = 11
                tag.TextXAlignment = Enum.TextXAlignment.Right
            end
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayers[plr.Name] = not selectedPlayers[plr.Name]
                if selectedPlayers[plr.Name] then
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 15, 15)}):Play()
                    cb.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
                    local cm = Instance.new("TextLabel")
                    cm.Parent = cb
                    cm.Size = UDim2.new(1, 0, 1, 0)
                    cm.BackgroundTransparency = 1
                    cm.Text = "✓"
                    cm.TextColor3 = Color3.fromRGB(255, 255, 255)
                    cm.Font = Enum.Font.GothamBold
                    cm.TextSize = 13
                else
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 26)}):Play()
                    cb.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    for _, child in pairs(cb:GetChildren()) do
                        if child:IsA("TextLabel") then child:Destroy() end
                    end
                end
            end)
        end
    end
end

-- ====================================================================
-- CRÉATION DES COMMANDES
-- ====================================================================

for action, cmd in pairs(COMMANDS) do
    local frame = Instance.new("Frame")
    frame.Parent = CmdContainer
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    local FC = Instance.new("UICorner") FC.CornerRadius = UDim.new(0, 7) FC.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = cmd.color
    stroke.Thickness = 1.2
    stroke.Transparency = 0.6
    stroke.Parent = frame
    
    -- Nom
    local name = Instance.new("TextLabel")
    name.Parent = frame
    name.Size = UDim2.new(0, 120, 1, 0)
    name.Position = UDim2.new(0, 10, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = cmd.name
    name.TextColor3 = cmd.color
    name.Font = Enum.Font.SourceSansBold
    name.TextSize = 16
    name.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Parent = frame
    desc.Size = UDim2.new(1, -140, 1, 0)
    desc.Position = UDim2.new(0, 130, 0, 0)
    desc.BackgroundTransparency = 1
    desc.Text = "Sur " .. tostring(#Players:GetPlayers() - 1) .. " joueurs dispo"
    desc.TextColor3 = Color3.fromRGB(140, 140, 160)
    desc.Font = Enum.Font.SourceSansItalic
    desc.TextSize = 13
    desc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Bouton clic
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 2
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.1), {Transparency = 0.2, Thickness = 1.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.6, Thickness = 1.2}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        local count = 0
        for pName, isSel in pairs(selectedPlayers) do
            if isSel then
                local plr = Players:FindFirstChild(pName)
                if plr then
                    cmd.fn(plr)
                    cmd_fire_remotes(plr, action)
                    count = count + 1
                end
            end
        end
        
        -- Feedback
        TweenService:Create(frame, TweenInfo.new(0.05), {BackgroundColor3 = cmd.color}):Play()
        task.wait(0.05)
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
        
        -- Mettre à jour la description avec le nombre
        desc.Text = "✅ " .. tostring(count) .. " joueur(s) ciblé(s)"
        task.delay(1.5, function() desc.Text = "Sur " .. tostring(#Players:GetPlayers() - 1) .. " joueurs dispo" end)
    end)
end

-- Calculer la hauteur
local numCmds = 0
for _ in pairs(COMMANDS) do numCmds = numCmds + 1 end
local totalCmdHeight = numCmds * 57 + 50
CmdContainer.Size = UDim2.new(1, -16, 0, totalCmdHeight)
RightPanel.CanvasSize = UDim2.new(0, 0, 0, totalCmdHeight + 60)

-- ====================================================================
-- RAFRAÎCHIR
-- ====================================================================

RefreshBtn.MouseButton1Click:Connect(function()
    TweenService:Create(RefreshBtn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(35, 35, 48)}):Play()
    task.wait(0.05)
    TweenService:Create(RefreshBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
    updatePlayerList()
end)

-- ====================================================================
-- LANCEMENT
-- ====================================================================

updatePlayerList()

-- Rafraîchir auto toutes les 5s
spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(5)
        updatePlayerList()
    end
end)

-- Notification
local notif = Instance.new("TextLabel")
notif.Parent = ScreenGui
notif.Size = UDim2.new(0, 350, 0, 38)
notif.Position = UDim2.new(0.5, -175, 0, 15)
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.Text = "⚡ HK_ADMIN prêt — " .. tostring(#Players:GetPlayers() - 1) .. " joueurs détectés"
notif.TextColor3 = Color3.fromRGB(255, 80, 80)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 15
notif.ZIndex = 100
local NC = Instance.new("UICorner") NC.CornerRadius = UDim.new(0, 8) NC.Parent = notif

spawn(function()
    task.wait(3)
    TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    task.wait(0.5)
    notif:Destroy()
end)

-- ====================================================================
-- TAG [ADMIN] AU-DESSUS DE LA TÊTE
-- ====================================================================

spawn(function()
    local function addTag()
        local char = localPlayer.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        local old = head:FindFirstChild("HK_AdminTag")
        if old then old:Destroy() end
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "HK_AdminTag"
        bb.Parent = head
        bb.Size = UDim2.new(0, 200, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.ClipsDescendants = false
        bb.ResetOnSpawn = false
        
        local bg = Instance.new("Frame")
        bg.Parent = bb
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.3
        bg.BorderSize = 0
        local BGC = Instance.new("UICorner") BGC.CornerRadius = UDim.new(0, 6) BGC.Parent = bg
        
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 40))
        })
        grad.Rotation = 0
        grad.Parent = bg
        
        local txt = Instance.new("TextLabel")
        txt.Parent = bb
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "[ADMIN:" .. localPlayer.Name .. "]"
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 16
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.TextStrokeTransparency = 0.2
        
        spawn(function()
            while bb and bb.Parent do
                grad.Rotation = (grad.Rotation + 30 * 0.03) % 360
                task.wait(0.03)
            end
        end)
    end
    
    addTag()
    localPlayer.CharacterAdded:Connect(addTag)
end)

-- ====================================================================
-- FIN
-- ====================================================================
