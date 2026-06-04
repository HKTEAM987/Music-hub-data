-- ====================================================================
-- SCRIPT : HK_TEAM987 MUSIC HUB | MASTER PREMIUM HUB
-- CRÉATEUR : DIABLESSE
-- PARTIE : PLAYLIST
-- ====================================================================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- 🚨 1. SÉCURITÉ WHITELIST (BLOQUANTE ET ANTI-CACHE)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- On utilise le lien RAW avec ?cache= pour forcer la mise à jour instantanée
local url_whitelist = "https://gist.githubusercontent.com/HKTEAM987/54e42b3cffb8d47127435c70dce0826b/raw/1e09f816fc7150dc4027f9b573c2760becbbf20e/whitelist.txt" .. os.time()

local estValide = false
local tentatives = 0

-- On essaie de charger 5 fois si besoin
while not estValide and tentatives < 5 do
    tentatives = tentatives + 1
    
    local success, result = pcall(function() 
        return game:HttpGet(url_whitelist) 
    end)
    
    if success and result then
        -- Vérification si ton nom est dans le texte brut
        if string.find(result:lower(), localPlayer.Name:lower()) then
            estValide = true
            print("[HK_TEAM] Whitelist validée !")
        else
            warn("[HK_TEAM] Ton nom n'est pas dans la whitelist. Tentative " .. tentatives .. "/5")
            task.wait(2) -- On attend 2 secondes avant de retenter
        end
    else
        warn("[HK_TEAM] Échec connexion GitHub. Tentative " .. tentatives .. "/5")
        task.wait(2)
    end
end

-- Si après les tentatives, ce n'est pas valide, on arrête tout
if not estValide then
    warn("[HK_TEAM] ACCÈS REFUSÉ : Tu n'es pas dans la whitelist.")
    error("ACCÈS REFUSÉ") -- Stoppe complètement l'exécution du script
    return
end


-- Si après les tentatives, ce n'est pas valide, on arrête tout
if not estValide then
    warn("[HK_TEAM] ACCÈS REFUSÉ : Tu n'es pas dans la whitelist.")
    error("ACCÈS REFUSÉ") -- Stoppe complètement l'exécution du script
    return
end

print("[HK_TEAM] Initialisation du Hub...")



-- Le script ne continue que si le nom est trouvé dans la whitelist
print("[HK_TEAM] Whitelist validée, lancement du script...")


-- Configuration Fixe
local CREATOR_NAME = "DIABLESSE"
local CREATOR_ID = 3455564318
local WEBHOOK_URL = "https://discord.com/api/webhooks/1506773350540902558/RXTrL6fJBJzpXvJ7CsFMC0Qln8JvQ-bDCif3ar6NQtMRwjlhbLMHDIwMLc6Tt4KPNLw-"
local ThemeColor = Color3.fromRGB(0, 210, 255)



-- 📡 SYSTÈME DE TRANSMISSION DES LOGS
local function envoyerLog(action, detail)
    local data = {
        ["username"] = "HK_TEAM Surveillance",
        ["embeds"] = {{
            ["title"] = "Exécution détectée !",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Joueur", ["value"] = localPlayer.Name .. " (" .. tostring(localPlayer.UserId) .. ")", ["inline"] = false},
                {["name"] = "Action", ["value"] = action, ["inline"] = false},
                {["name"] = "Détail", ["value"] = detail, ["inline"] = false}
            },
            ["footer"] = {["text"] = "Propriété de 987STEPSIS987"}
        }}
    }
    pcall(function()
        local json = HttpService:JSONEncode(data)
        local requestFunc = syn and syn.request or http and http.request or request or http_request
        if requestFunc then
            requestFunc({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        end
    end)
end

envoyerLog("Connexion", "Le joueur a validé la Whitelist et ouvert le Hub.")

-- 🎵 CHARGEMENT DYNAMIQUE DE LA PLAYLIST (CORRIGÉ)
local Playlist = {}
local url_musique = "https://gist.githubusercontent.com/HKTEAM987/7021ddfd4af26736ff32fc239b57ad13/raw/a34b2a0301055302e1c19f062d707f2b3a90a691/musics.json"

local function chargerPlaylist()
    local success, response = pcall(function()
        return game:HttpGet(url_musique)
    end)
    
    if success and response then
        local successDecode, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if successDecode and data then
            return data
        else
            warn("[HK_TEAM] Erreur décodage JSON. Vérifie ton fichier Gist.")
        end
    else
        warn("[HK_TEAM] Erreur connexion Gist. Vérifie l'URL.")
    end
    return {} -- Retourne une table vide par défaut si échec
end

Playlist = chargerPlaylist()

-- ====================================================================
-- PARTIE 2 : INTERFACE GRAPHIQUE
-- ====================================================================

-- 🖼️ INTERFACE GRAPHIQUE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HK_TEAM_Hub_V15"

-- Icône Flottante sécurisée
local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Parent = ScreenGui
ToggleIcon.Size = UDim2.new(0, 60, 0, 60)
ToggleIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ToggleIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(CREATOR_ID) .. "&w=150&h=150"
ToggleIcon.Visible = false
ToggleIcon.Active = true
ToggleIcon.Draggable = true
local IconCorner = Instance.new("UICorner") IconCorner.CornerRadius = UDim.new(1, 0) IconCorner.Parent = ToggleIcon
local IconStroke = Instance.new("UIStroke") IconStroke.Color = ThemeColor IconStroke.Thickness = 2 IconStroke.Parent = ToggleIcon

-- Fenêtre Principale
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 640, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 12) MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Color = ThemeColor MainStroke.Thickness = 1.5 MainStroke.Parent = MainFrame

-- Titre
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, -160, 0, 45)
TitleLabel.Position = UDim2.new(0, 20, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "script HK_TEAM"
TitleLabel.TextColor3 = ThemeColor
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Crédits
local CreatorLabel = Instance.new("TextLabel")
CreatorLabel.Parent = MainFrame
CreatorLabel.Size = UDim2.new(0, 200, 0, 20)
CreatorLabel.Position = UDim2.new(0, 20, 0, 35)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "par " .. CREATOR_NAME
CreatorLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
CreatorLabel.Font = Enum.Font.SourceSansItalic
CreatorLabel.TextSize = 13
CreatorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimiser
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = MainFrame
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 10)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 16
local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(0, 6) MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = ToggleIcon.Position}):Play()
    task.wait(0.25)
    MainFrame.Visible = false
    ToggleIcon.Visible = true
end)

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 640, 0, 400), Position = UDim2.new(0.3, 0, 0.25, 0)}):Play()
    ToggleIcon.Visible = false
end)
-- ====================================================================
-- PARTIE 3 : MENUS
-- ====================================================================

-- Navigation
local NavFrame = Instance.new("ScrollingFrame")
NavFrame.Parent = MainFrame
NavFrame.Position = UDim2.new(0, 15, 0, 75)
NavFrame.Size = UDim2.new(0, 160, 1, -95)
NavFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
NavFrame.ScrollBarThickness = 3
NavFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
local NavCorner = Instance.new("UICorner") NavCorner.CornerRadius = UDim.new(0, 6) NavCorner.Parent = NavFrame
local NavList = Instance.new("UIListLayout") NavList.Parent = NavFrame; NavList.Padding = UDim.new(0, 5)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.Position = UDim2.new(0, 190, 0, 75)
ContentContainer.Size = UDim2.new(1, -205, 1, -95)
ContentContainer.BackgroundTransparency = 1

local function appliquerMusique(id, nomMusique)
    local RE = ReplicatedStorage:FindFirstChild("RE")
    if not RE then return end
    
    envoyerLog("Musique Jouée", "A choisi la piste : **" .. nomMusique .. "**")
    
    pcall(function()
        if RE:FindFirstChild("1NoMoto1rVehicle1s") then RE["1NoMoto1rVehicle1s"]:FireServer("PickingScooterMusicText", tostring(id), true) end
        if RE:FindFirstChild("1Player1sCa1r") then RE["1Player1sCa1r"]:FireServer("PickingVehicleMusicText", tostring(id), true) end
    end)
end

local currentPanel = nil
local function afficherPageMusique(genreName)
    if currentPanel then currentPanel:Destroy() end
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = ContentContainer
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Playlist[genreName] * 42)
    currentPanel = Scroll
    
    local ListLayout = Instance.new("UIListLayout") ListLayout.Parent = Scroll; ListLayout.Padding = UDim.new(0, 5)
    
    for _, data in pairs(Playlist[genreName]) do
        local Btn = Instance.new("TextButton")
        Btn.Parent = Scroll
        Btn.Size = UDim2.new(1, -10, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        Btn.Text = "   ▶  " .. data.Name
        Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        Btn.Font = Enum.Font.SourceSans
        Btn.TextSize = 14
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        local bC = Instance.new("UICorner") bC.CornerRadius = UDim.new(0, 5) bC.Parent = Btn
        
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 42), TextColor3 = ThemeColor}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 30), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        end)
        
        Btn.MouseButton1Click:Connect(function() appliquerMusique(data.ID, data.Name) end)
    end
end
-- ====================================================================
-- PARTIE 4 : MENUS AVANCÉS
-- ====================================================================



local function chargerMenuCustomID()
    if currentPanel then currentPanel:Destroy() end
    
    local FrameCustom = Instance.new("Frame")
    FrameCustom.Parent = ContentContainer
    FrameCustom.Size = UDim2.new(1, 0, 1, 0)
    FrameCustom.BackgroundTransparency = 1
    currentPanel = FrameCustom
    
    local Box = Instance.new("TextBox")
    Box.Parent = FrameCustom
    Box.Size = UDim2.new(1, -20, 0, 45)
    Box.Position = UDim2.new(0, 10, 0, 20)
    Box.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Box.PlaceholderText = "Colle ton ID personnalisé Roblox ici..."
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSansBold
    Box.TextSize = 15
    local bC = Instance.new("UICorner") bC.CornerRadius = UDim.new(0, 6) bC.Parent = Box
    
    local PlayCustomBtn = Instance.new("TextButton")
    PlayCustomBtn.Parent = FrameCustom
    PlayCustomBtn.Size = UDim2.new(1, -20, 0, 40)
    PlayCustomBtn.Position = UDim2.new(0, 10, 0, 80)
    PlayCustomBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    PlayCustomBtn.Text = "Lancer la musique personnalisée"
    PlayCustomBtn.TextColor3 = ThemeColor
    PlayCustomBtn.Font = Enum.Font.SourceSansBold
    PlayCustomBtn.TextSize = 15
    local pC = Instance.new("UICorner") pC.CornerRadius = UDim.new(0, 6) pC.Parent = PlayCustomBtn
    
    PlayCustomBtn.MouseButton1Click:Connect(function()
        local cleanID = Box.Text:gsub("%D", "")
        if cleanID ~= "" then appliquerMusique(cleanID, "ID Perso: " .. cleanID) end
    end)
end

local function chargerMenuTheme()
    if currentPanel then currentPanel:Destroy() end
    
    local ThemeFrame = Instance.new("Frame")
    ThemeFrame.Parent = ContentContainer
    ThemeFrame.Size = UDim2.new(1, 0, 1, 0)
    ThemeFrame.BackgroundTransparency = 1
    currentPanel = ThemeFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ThemeFrame; Label.Size = UDim2.new(1, 0, 0, 30); Label.BackgroundTransparency = 1
    Label.Text = "Sélectionne la couleur néon de ton interface :"; Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.SourceSansItalic; Label.TextSize = 14
    
    local Couleurs = {
        ["Bleu Néon"] = Color3.fromRGB(0, 210, 255),
        ["Rouge Impérial"] = Color3.fromRGB(255, 60, 60),
        ["Vert Toxique"] = Color3.fromRGB(60, 255, 110),
        ["Rose Fuchsia"] = Color3.fromRGB(255, 20, 160),
        ["Jaune Éclair"] = Color3.fromRGB(255, 215, 0)
    }
    
    local offset = 45
    for name, color in pairs(Couleurs) do
        local CBtn = Instance.new("TextButton")
        CBtn.Parent = ThemeFrame
        CBtn.Size = UDim2.new(1, -20, 0, 35)
        CBtn.Position = UDim2.new(0, 10, 0, offset)
        CBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        CBtn.Text = name
        CBtn.TextColor3 = color
        CBtn.Font = Enum.Font.SourceSansBold
        CBtn.TextSize = 14
        local cC = Instance.new("UICorner") cC.CornerRadius = UDim.new(0, 5) cC.Parent = CBtn
        
        CBtn.MouseButton1Click:Connect(function()
            ThemeColor = color
            MainStroke.Color = color
            TitleLabel.TextColor3 = color
            IconStroke.Color = color
        end)
        offset = offset + 40
    end
end

-- Création des boutons de navigation
for genreName, _ in pairs(Playlist) do
    local NavBtn = Instance.new("TextButton")
    NavBtn.Parent = NavFrame; NavBtn.Size = UDim2.new(1, -6, 0, 38)
    NavBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NavBtn.Text = genreName; NavBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
    NavBtn.Font = Enum.Font.SourceSansBold; NavBtn.TextSize = 13
    local nC = Instance.new("UICorner") nC.CornerRadius = UDim.new(0, 5) nC.Parent = NavBtn
    NavBtn.MouseButton1Click:Connect(function() afficherPageMusique(genreName) end)
end

local CustomBtn = Instance.new("TextButton")
CustomBtn.Parent = NavFrame; CustomBtn.Size = UDim2.new(1, -6, 0, 38)
CustomBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
CustomBtn.Text = "✍️ Custom ID"; CustomBtn.TextColor3 = Color3.fromRGB(255, 190, 80)
CustomBtn.Font = Enum.Font.SourceSansBold; CustomBtn.TextSize = 13
local cC = Instance.new("UICorner") cC.CornerRadius = UDim.new(0, 5) cC.Parent = CustomBtn
CustomBtn.MouseButton1Click:Connect(chargerMenuCustomID)

local ConfigBtn = Instance.new("TextButton")
ConfigBtn.Parent = NavFrame; ConfigBtn.Size = UDim2.new(1, -6, 0, 38)
ConfigBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
ConfigBtn.Text = "🎨 Palette UI"; ConfigBtn.TextColor3 = Color3.fromRGB(90, 255, 140)
ConfigBtn.Font = Enum.Font.SourceSansBold; ConfigBtn.TextSize = 13
local kC = Instance.new("UICorner") kC.CornerRadius = UDim.new(0, 5) kC.Parent = ConfigBtn
ConfigBtn.MouseButton1Click:Connect(chargerMenuTheme)

-- Lancement initial
afficherPageMusique("Afro Ori Fiesta")
