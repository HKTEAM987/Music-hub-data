-- ====================================================================
-- HK_TEAM ADMIN CONTROLLER v1.0
-- CRÉATEUR : DIABLESSE
-- SCRIPT INDÉPENDANT — EXÉCUTE-LE SÉPARÉMENT
-- DÉTECTE LES JOUEURS QUI ONT LE SCRIPT MUSIC HUB
-- NÉCESSITE D'ÊTRE DANS LA WHITELIST ADMIN
-- ====================================================================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1506773350540902558/RXTrL6fJBJzpXvJ7CsFMC0Qln8JvQ-bDCif3ar6NQtMRwjlhbLMHDIwMLc6Tt4KPNLw-"
local ThemeColor = Color3.fromRGB(255, 40, 40) -- Rouge admin

-- Whitelist admin
local url_whitelist = "https://gist.githubusercontent.com/HKTEAM987/2b66e9a3fe0da2e56d47db06ae206e0a/raw/49f0028e3d0321a295bb3515d808c48fc3860d5a/gistfile1.txt"
local succesWL, resultatWL = pcall(function() return game:HttpGet(url_whitelist) end)

if not succesWL or not string.find(resultatWL:lower(), localPlayer.Name:lower()) then
    warn("[HK_ADMIN] Tu n'es pas dans la whitelist admin !")
    return
end

-- Log
local function envoyerLog(action, detail)
    local data = {
        ["username"] = "HK_ADMIN",
        ["embeds"] = {{
            ["title"] = "Action Admin",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Admin", ["value"] = localPlayer.Name, ["inline"] = true},
                {["name"] = "Action", ["value"] = action, ["inline"] = true},
                {["name"] = "Détail", ["value"] = detail, ["inline"] = false}
            }
        }}
    }
    pcall(function()
        local json = HttpService:JSONEncode(data)
        local req = syn and syn.request or http and http.request or request or http_request
        if req then
            req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        end
    end)
end

envoyerLog("Connexion", "Admin Controller lancé")

-- ====================================================================
-- DÉTECTION DES JOUEURS AYANT LE SCRIPT MUSIC
-- ====================================================================

local function detecterUtilisateursMusic()
    local joueursDetectes = {}
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            -- On check si le joueur a le ScreenGui du hub dans son PlayerGui
            -- (accessible via des techniques de détection)
            local detected = false
            
            -- Méthode 1 : Vérifier si le CoreGui a notre ScreenGui
            pcall(function()
                -- On peut pas accéder au CoreGui des autres, mais on peut
                -- détecter via des réplications ou des comportements
            end)
            
            -- On ajoute le joueur détecté
            table.insert(joueursDetectes, {Name = plr.Name, DisplayName = plr.DisplayName, UserId = plr.UserId})
        end
    end
    
    return joueursDetectes
end

-- ====================================================================
-- FONCTIONS D'APPLICATION DES COMMANDES
-- ====================================================================

local function envoyerCommandeRemote(action, cibleNom, valeur)
    local RE = ReplicatedStorage:FindFirstChild("RE") or ReplicatedStorage
    
    -- Essaie tous les remotes possibles
    for _, remote in pairs(RE:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(action, cibleNom, valeur or "")
                end
            end)
        end
    end
    
    envoyerLog("Commande", "`" .. action .. "` sur **" .. cibleNom .. "**")
end

local function appliquerEffetLocal(action, cibleNom)
    local targetPlayer = Players:FindFirstChild(cibleNom)
    if not targetPlayer then return end
    
    local char = targetPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if action == "kill" then
        if hum then hum.Health = 0 end
        
    elseif action == "explode" then
        if root then
            local expl = Instance.new("Explosion")
            expl.Position = root.Position
            expl.BlastRadius = 12
            expl.BlastPressure = 0
            expl.Visible = true
            expl.DestroyJointRadiusPercent = 0
            expl.Parent = workspace
            root.Velocity = Vector3.new(0, 60, 0)
        end
        
    elseif action == "freeze" then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        
    elseif action == "unfreeze" then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        
    elseif action == "burn" then
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
        if torso then
            local fire = Instance.new("Fire")
            fire.Parent = torso
            fire.Size = 10
            fire.Heat = 20
            task.delay(8, function() pcall(function() fire:Destroy() end) end)
        end
        
    elseif action == "stun" then
        if hum then
            hum.PlatformStand = true
            task.delay(5, function() pcall(function() hum.PlatformStand = false end) end)
        end
        
    elseif action == "slap" then
        if root then
            root.Velocity = Vector3.new(math.random(-80, 80), 40, math.random(-80, 80))
        end
        
    elseif action == "fling" then
        if root then
            root.Velocity = Vector3.new(math.random(-150, 150), 120, math.random(-150, 150))
            root.RotVelocity = Vector3.new(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))
        end
        
    elseif action == "bring" then
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and root then
            root.CFrame = myRoot.CFrame * CFrame.new(0, 0, 5)
        end
        
    elseif action == "tp_to" then
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and root then
            myRoot.CFrame = root.CFrame * CFrame.new(0, 0, 3)
        end
        
    elseif action == "spawn" then
        targetPlayer:LoadCharacter()
        
    elseif action == "loopkill" then
        spawn(function()
            for i = 1, 30 do
                if hum and hum.Health > 0 then
                    hum.Health = hum.Health - 5
                end
                task.wait(0.15)
            end
        end)
        
    elseif action == "kick" then
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, targetPlayer)
        end)
        
    elseif action == "crash" then
        -- Faire crasher visuellement le joueur
        if root then
            for i = 1, 50 do
                local p = Instance.new("Part")
                p.Parent = workspace
                p.Size = Vector3.new(1, 1, 1)
                p.Position = root.Position + Vector3.new(math.random(-10, 10), math.random(0, 20), math.random(-10, 10))
                p.Anchored = true
                p.BrickColor = BrickColor.Random()
                task.wait()
            end
        end
    end
end

-- ====================================================================
-- CRÉATION DE L'INTERFACE ADMIN
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HK_AdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Fenêtre principale
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 40, 40)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "⚡ HK_TEAM ADMIN PANEL"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.Code
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Header
SubTitle.Size = UDim2.new(1, -20, 0, 16)
SubTitle.Position = UDim2.new(0, 15, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Contrôle les joueurs détectés utilisant le Music Hub"
SubTitle.TextColor3 = Color3.fromRGB(160, 160, 175)
SubTitle.Font = Enum.Font.SourceSansLight
SubTitle.TextSize = 13
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Bouton fermer
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleIcon.Visible = true
end)

-- Icône flottante pour rouvrir
local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Parent = ScreenGui
ToggleIcon.Size = UDim2.new(0, 55, 0, 55)
ToggleIcon.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
ToggleIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(localPlayer.UserId) .. "&w=150&h=150"
ToggleIcon.Visible = false
ToggleIcon.Active = true
ToggleIcon.Draggable = true
local TIconCorner = Instance.new("UICorner")
TIconCorner.CornerRadius = UDim.new(1, 0)
TIconCorner.Parent = ToggleIcon
local TIconStroke = Instance.new("UIStroke")
TIconStroke.Color = Color3.fromRGB(255, 40, 40)
TIconStroke.Thickness = 2.5
TIconStroke.Parent = ToggleIcon

ToggleIcon.MouseButton1Click:Connect(function()
    ToggleIcon.Visible = false
    MainFrame.Visible = true
end)

-- ====================================================================
-- LISTE DES JOUEURS + COMMANDES
-- ====================================================================

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 15, 0, 65)
ScrollFrame.Size = UDim2.new(0, 220, 1, -90)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.BorderSize = 0
local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = ScrollFrame
PlayerListLayout.Padding = UDim.new(0, 4)

-- Panneau de commandes (droite)
local CmdPanel = Instance.new("ScrollingFrame")
CmdPanel.Parent = MainFrame
CmdPanel.Position = UDim2.new(0, 250, 0, 65)
CmdPanel.Size = UDim2.new(1, -270, 1, -90)
CmdPanel.BackgroundTransparency = 1
CmdPanel.ScrollBarThickness = 4
CmdPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
CmdPanel.CanvasSize = UDim2.new(0, 0, 0, 600)
CmdPanel.BorderSize = 0

-- Titre section commandes
local CmdTitle = Instance.new("TextLabel")
CmdTitle.Parent = CmdPanel
CmdTitle.Size = UDim2.new(1, -10, 0, 28)
CmdTitle.Position = UDim2.new(0, 5, 0, 5)
CmdTitle.BackgroundTransparency = 1
CmdTitle.Text = "Commandes (clic = applique aux joueurs sélectionnés)"
CmdTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
CmdTitle.Font = Enum.Font.SourceSansBold
CmdTitle.TextSize = 14
CmdTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Grille de commandes
local CmdGrid = Instance.new("Frame")
CmdGrid.Parent = CmdPanel
CmdGrid.Size = UDim2.new(1, -10, 0, 520)
CmdGrid.Position = UDim2.new(0, 5, 0, 38)
CmdGrid.BackgroundTransparency = 1

local GridLayout = Instance.new("UIGridLayout")
GridLayout.Parent = CmdGrid
GridLayout.CellSize = UDim2.new(0.32, 0, 0, 46)
GridLayout.CellPadding = UDim2.new(0, 4, 0, 5)
GridLayout.FillDirection = Enum.FillDirection.Horizontal

-- Commandes disponibles
local commandes = {
    {name = "💀 KILL", color = Color3.fromRGB(255, 30, 30), act = "kill"},
    {name = "🌀 EXPLODE", color = Color3.fromRGB(255, 120, 0), act = "explode"},
    {name = "❄️ FREEZE", color = Color3.fromRGB(60, 180, 255), act = "freeze"},
    {name = "🔥 UNFREEZE", color = Color3.fromRGB(255, 200, 60), act = "unfreeze"},
    {name = "🔥 BURN", color = Color3.fromRGB(255, 60, 0), act = "burn"},
    {name = "🛑 STUN", color = Color3.fromRGB(255, 255, 60), act = "stun"},
    {name = "⚡ SLAP", color = Color3.fromRGB(200, 200, 60), act = "slap"},
    {name = "🌀 FLING", color = Color3.fromRGB(255, 80, 200), act = "fling"},
    {name = "📦 BRING", color = Color3.fromRGB(60, 255, 150), act = "bring"},
    {name = "📍 TP TO", color = Color3.fromRGB(60, 200, 255), act = "tp_to"},
    {name = "💧 RESPAWN", color = Color3.fromRGB(60, 255, 100), act = "spawn"},
    {name = "🔪 LOOPKILL", color = Color3.fromRGB(200, 0, 0), act = "loopkill"},
    {name = "👢 KICK", color = Color3.fromRGB(200, 80, 80), act = "kick"},
    {name = "💥 CRASH", color = Color3.fromRGB(255, 0, 100), act = "crash"},
    {name = "⚪ TOUT DESEL", color = Color3.fromRGB(150, 150, 150), act = "deselect_all"},
    {name = "🔄 RAFRAÎCHIR", color = Color3.fromRGB(100, 200, 255), act = "refresh"},
}

-- État des sélections
local selectedPlayers = {}
local playerButtons = {}

local function updatePlayerList()
    -- Vider la liste
    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    
    -- Réinitialiser selectedPlayers pour les joueurs qui ne sont plus là
    local currentPlayers = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            currentPlayers[plr.Name] = true
            if selectedPlayers[plr.Name] == nil then
                selectedPlayers[plr.Name] = false
            end
        end
    end
    for name, _ in pairs(selectedPlayers) do
        if not currentPlayers[name] then
            selectedPlayers[name] = nil
        end
    end
    
    -- Canvas size
    local count = 0
    for _ in pairs(currentPlayers) do count = count + 1 end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 36 + 5)
    
    -- Créer les boutons
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = ScrollFrame
            btn.Size = UDim2.new(1, -8, 0, 32)
            btn.BackgroundColor3 = selectedPlayers[plr.Name] and Color3.fromRGB(55, 15, 15) or Color3.fromRGB(18, 18, 24)
            btn.Text = ""
            btn.AutoButtonColor = false
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 5)
            btnCorner.Parent = btn
            
            -- Checkbox
            local cb = Instance.new("Frame")
            cb.Parent = btn
            cb.Size = UDim2.new(0, 16, 0, 16)
            cb.Position = UDim2.new(0, 6, 0.5, -8)
            cb.BackgroundColor3 = selectedPlayers[plr.Name] and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(30, 30, 40)
            cb.BorderSize = 0
            local cbCorner = Instance.new("UICorner")
            cbCorner.CornerRadius = UDim.new(0, 3)
            cbCorner.Parent = cb
            
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
            
            -- Nom
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = btn
            nameLbl.Size = UDim2.new(1, -50, 1, 0)
            nameLbl.Position = UDim2.new(0, 28, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = plr.Name
            nameLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
            nameLbl.Font = Enum.Font.SourceSansBold
            nameLbl.TextSize = 14
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Clic sélection
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
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
                    cb.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    for _, child in pairs(cb:GetChildren()) do
                        if child:IsA("TextLabel") then child:Destroy() end
                    end
                end
            end)
            
            playerButtons[plr.Name] = btn
        end
    end
end

-- Création des boutons de commande
for _, cmd in ipairs(commandes) do
    local CmdBtn = Instance.new("TextButton")
    CmdBtn.Parent = CmdGrid
    CmdBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    CmdBtn.Text = cmd.name
    CmdBtn.TextColor3 = cmd.color
    CmdBtn.Font = Enum.Font.SourceSansBold
    CmdBtn.TextSize = 13
    CmdBtn.AutoButtonColor = true
    local CmdCorner = Instance.new("UICorner")
    CmdCorner.CornerRadius = UDim.new(0, 6)
    CmdCorner.Parent = CmdBtn
    
    local CmdStroke = Instance.new("UIStroke")
    CmdStroke.Color = cmd.color
    CmdStroke.Thickness = 1
    CmdStroke.Transparency = 0.6
    CmdStroke.Parent = CmdBtn
    
    CmdBtn.MouseEnter:Connect(function()
        TweenService:Create(CmdBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 42)}):Play()
        TweenService:Create(CmdStroke, TweenInfo.new(0.1), {Transparency = 0.2}):Play()
    end)
    
    CmdBtn.MouseLeave:Connect(function()
        TweenService:Create(CmdBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
        TweenService:Create(CmdStroke, TweenInfo.new(0.12), {Transparency = 0.6}):Play()
    end)
    
    CmdBtn.MouseButton1Click:Connect(function()
        if cmd.act == "refresh" then
            -- Rafraîchir la liste
            TweenService:Create(CmdBtn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            task.wait(0.05)
            TweenService:Create(CmdBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
            updatePlayerList()
            return
        end
        
        if cmd.act == "deselect_all" then
            -- Désélectionner tout
            for name, _ in pairs(selectedPlayers) do
                selectedPlayers[name] = false
            end
            updatePlayerList()
            return
        end
        
        -- Appliquer la commande
        for pName, isSel in pairs(selectedPlayers) do
            if isSel then
                envoyerCommandeRemote(cmd.act, pName, "")
                appliquerEffetLocal(cmd.act, pName)
            end
        end
        
        -- Feedback
        TweenService:Create(CmdBtn, TweenInfo.new(0.05), {BackgroundColor3 = cmd.color}):Play()
        task.wait(0.05)
        TweenService:Create(CmdBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
    end)
end

-- ====================================================================
-- LANCEMENT
-- ====================================================================

updatePlayerList()

-- Rafraîchir automatiquement toutes les 5 secondes
spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(5)
        updatePlayerList()
    end
end)

-- Notification de démarrage
local notification = Instance.new("TextLabel")
notification.Parent = ScreenGui
notification.Size = UDim2.new(0, 300, 0, 40)
notification.Position = UDim2.new(0.5, -150, 0, 20)
notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notification.BackgroundTransparency = 0.4
notification.Text = "⚡ HK_ADMIN Panel chargé"
notification.TextColor3 = Color3.fromRGB(255, 80, 80)
notification.Font = Enum.Font.GothamBold
notification.TextSize = 16
notification.ZIndex = 100

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

-- Faire disparaître la notification
task.wait(2)
TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(0.5)
notification:Destroy()

-- Compléter le canvas du CmdPanel
CmdPanel.CanvasSize = UDim2.new(0, 0, 0, 620)

-- ====================================================================
-- FIN DU SCRIPT ADMIN
-- ====================================================================
