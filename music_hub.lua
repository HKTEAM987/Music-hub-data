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

-- 🚨 1. SÉCURITÉ WHITELIST INITIALE
local url_whitelist = "https://gist.githubusercontent.com/HKTEAM987/54e42b3cffb8d47127435c70dce0826b/raw/09f9dfa863772a09bef81731ec937476e8e8dd13/whitelist.txt"
local succesWL, resultatWL = pcall(function() return game:HttpGet(url_whitelist) end)

if not succesWL or not string.find(resultatWL:lower(), localPlayer.Name:lower()) then 
    warn("[HK_TEAM] Tu n'es pas dans la whitelist ! Accès refusé.")
    return 
end

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
local url_musique = "https://gist.githubusercontent.com/HKTEAM987/7021ddfd4af26736ff32fc239b57ad13/raw/e1a92112df403370121580393fa0b1ada2db974f/musics.json"

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
        -- Anciens remotes
        if RE:FindFirstChild("1NoMoto1rVehicle1s") then 
            RE["1NoMoto1rVehicle1s"]:FireServer("PickingScooterMusicText", tostring(id), true) 
        end
        if RE:FindFirstChild("1Player1sCa1r") then 
            RE["1Player1sCa1r"]:FireServer("PickingVehicleMusicText", tostring(id), true) 
        end
        
        -- Nouveau remote ajouté via Screenshot_2026-06-03-21-33-28-712_com.roblox.client.jpg
        if RE:FindFirstChild("PlayerToolEvent") then 
            local args = {
                "ToolMusicText",
                tostring(id),
                [4] = true
            }
            RE["PlayerToolEvent"]:FireServer(unpack(args))
        end
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
-- ====================================================================
-- PARTIE 5 : EFFETS & ANIMATIONS COMPLEXES (AJOUTÉ)
-- ====================================================================

local RunService = game:GetService("RunService")

-- 5.1 Dégradé animé sur le bord de la fenêtre principale
local MainStrokeGrad = Instance.new("UIGradient")
MainStrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ThemeColor),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 50, 120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 50, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 50, 120)),
    ColorSequenceKeypoint.new(1, ThemeColor)
})
MainStrokeGrad.Rotation = 0
MainStrokeGrad.Parent = MainStroke

-- 5.2 Dégradé animé sur l'icône flottante
local IconGrad = Instance.new("UIGradient")
IconGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ThemeColor),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 50, 120)),
    ColorSequenceKeypoint.new(1, ThemeColor)
})
IconGrad.Rotation = 0
IconGrad.Parent = ToggleIcon

-- 5.3 Fond de la fenêtre avec gradient subtil
local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 10, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 14))
})
BgGrad.Rotation = 45
BgGrad.Parent = MainFrame

-- 5.4 Ligne de séparation lumineuse sous le titre
local HeaderLine = Instance.new("Frame")
HeaderLine.Parent = MainFrame
HeaderLine.Size = UDim2.new(1, -30, 0, 1.5)
HeaderLine.Position = UDim2.new(0, 15, 0, 58)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderLine.BackgroundTransparency = 0.6
HeaderLine.ZIndex = 2

local HeaderLineGrad = Instance.new("UIGradient")
HeaderLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 50, 120)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(150, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
})
HeaderLineGrad.Rotation = 0
HeaderLineGrad.Parent = HeaderLine

-- 5.5 Ombre portée sur l'icône
local IconShadow = Instance.new("ImageLabel")
IconShadow.Parent = ToggleIcon
IconShadow.Size = UDim2.new(1, 6, 1, 6)
IconShadow.Position = UDim2.new(0, -3, 0, -3)
IconShadow.BackgroundTransparency = 1
IconShadow.Image = "rbxassetid://5028857382"
IconShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
IconShadow.ImageTransparency = 0.6
IconShadow.ZIndex = -1
IconShadow.ScaleType = Enum.ScaleType.Slice
IconShadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- 5.6 Indicateur de statut "EN LIGNE" (pastille animée)
local StatusDot = Instance.new("Frame")
StatusDot.Parent = MainFrame
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -70, 0, 13)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BorderSize = 0

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusDotGlow = Instance.new("UIStroke")
StatusDotGlow.Color = Color3.fromRGB(0, 255, 100)
StatusDotGlow.Thickness = 3
StatusDotGlow.Transparency = 0.5
StatusDotGlow.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Parent = MainFrame
StatusText.Size = UDim2.new(0, 55, 0, 14)
StatusText.Position = UDim2.new(1, -95, 0, 28)
StatusText.BackgroundTransparency = 1
StatusText.Text = "EN LIGNE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Right

-- Pulse de la pastille de statut
local dotPulse = TweenService:Create(StatusDotGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Thickness = 6,
    Transparency = 0.2
})
dotPulse:Play()

-- 5.7 ANIMATION EN CONTINU DES DÉGRADÉS (RenderStepped)
local angleStroke = 0
local angleIcon = 0
local angleLine = 0

local connection
connection = RunService.RenderStepped:Connect(function(dt)
    -- Rotation du stroke principal
    angleStroke = (angleStroke + 18 * dt) % 360
    MainStrokeGrad.Rotation = angleStroke
    
    -- Rotation du gradient de l'icône
    angleIcon = (angleIcon + 35 * dt) % 360
    IconGrad.Rotation = angleIcon
    
    -- Rotation de la ligne de séparation
    angleLine = (angleLine + 22 * dt) % 360
    HeaderLineGrad.Rotation = angleLine
end)

-- Nettoyage si le GUI est détruit
ScreenGui.Destroying:Connect(function()
    if connection then connection:Disconnect() end
end)

-- 5.8 EFFET DE GLOW AU SURVOL DES BOUTONS DE NAVIGATION (AMÉLIORATION)
-- On ajoute un effet de glow sur les boutons existants de la navigation
for _, btn in pairs(NavFrame:GetChildren()) do
    if btn:IsA("TextButton") then
        -- Ajout d'un stroke subtil qui apparaît au survol
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = ThemeColor
        btnStroke.Thickness = 1
        btnStroke.Transparency = 1
        btnStroke.Parent = btn
        
        local oldEnter = btn.MouseEnter
        btn.MouseEnter:Connect(function()
            TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.6, Thickness = 1.5}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 1, Thickness = 1}):Play()
        end)
    end
end

-- 5.9 ANIMATION D'APPARITION AU LANCEMENT (PARTICULES)
-- Petit effet de "scan line" qui traverse la fenêtre au démarrage
local ScanLine = Instance.new("Frame")
ScanLine.Parent = MainFrame
ScanLine.Size = UDim2.new(1, 0, 0, 2)
ScanLine.Position = UDim2.new(0, 0, 0, 0)
ScanLine.BackgroundColor3 = ThemeColor
ScanLine.BackgroundTransparency = 0.5
ScanLine.BorderSize = 0
ScanLine.ZIndex = 10
ScanLine.Visible = true

-- Animation de scan
local scanTween = TweenService:Create(ScanLine, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
    Position = UDim2.new(0, 0, 1, 0)
})
scanTween:Play()
scanTween.Completed:Connect(function()
    TweenService:Create(ScanLine, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    ScanLine:Destroy()
end)

-- 5.10 AMBIANCE SONORE VISUELLE : FRÉQUENCES SIMULÉES
-- Petites barres qui dansent dans le fond (effet "visualizer")
local VisualizerFrame = Instance.new("Frame")
VisualizerFrame.Parent = ContentContainer
VisualizerFrame.Size = UDim2.new(1, -20, 0, 30)
VisualizerFrame.Position = UDim2.new(0, 10, 1, -40)
VisualizerFrame.BackgroundTransparency = 1
VisualizerFrame.ZIndex = 1
VisualizerFrame.Visible = true

local bars = {}
for i = 1, 12 do
    local bar = Instance.new("Frame")
    bar.Parent = VisualizerFrame
    bar.Size = UDim2.new(0, 6, 0, math.random(6, 20))
    bar.Position = UDim2.new(0, (i - 1) * 12 + 2, 1, -bar.Size.Y.Offset)
    bar.BackgroundColor3 = Color3.fromRGB(
        math.floor(ThemeColor.R * 255 * (0.5 + i/24)),
        math.floor(ThemeColor.G * 255 * (0.5 + i/24)),
        math.floor(ThemeColor.B * 255 * (0.5 + i/24))
    )
    bar.BorderSize = 0
    bar.Visible = true
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar
    
    table.insert(bars, bar)
end

-- Animation des barres (simulation de fréquences)
spawn(function()
    while ScreenGui and ScreenGui.Parent and VisualizerFrame.Parent do
        for _, bar in ipairs(bars) do
            local newHeight = math.random(4, 28)
            TweenService:Create(bar, TweenInfo.new(0.15 + math.random() * 0.1), {
                Size = UDim2.new(0, 6, 0, newHeight),
                Position = UDim2.new(0, bar.Position.X.Offset, 1, -newHeight)
            }):Play()
        end
        task.wait(0.2 + math.random() * 0.1)
    end
end)

-- 5.11 BARRE DE RECHERCHE DANS LA NAVIGATION (petit bonus)
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = NavFrame
SearchBox.Size = UDim2.new(1, -6, 0, 30)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
SearchBox.PlaceholderText = "🔍 Rechercher..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 100)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 5

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 5)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(30, 30, 40)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

SearchBox.Focused:Connect(function()
    TweenService:Create(SearchStroke, TweenInfo.new(0.12), {Color = ThemeColor, Thickness = 1.5}):Play()
end)
SearchBox.FocusLost:Connect(function(enetered)
    TweenService:Create(SearchStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(30, 30, 40), Thickness = 1}):Play()
    
    if enetered then
        local searchTerm = SearchBox.Text:lower()
        -- On parcourt les boutons de navigation
        for _, btn in pairs(NavFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= CustomBtn and btn ~= ConfigBtn then
                local match = btn.Text:lower():find(searchTerm) ~= nil
                btn.Visible = match or searchTerm == ""
                btn.Size = match or searchTerm == "" and UDim2.new(1, -6, 0, 38) or UDim2.new(1, -6, 0, 0)
            end
        end
    end
end)

-- Ajuster le CanvasSize de la navigation pour inclure la search box
NavFrame.CanvasSize = UDim2.new(0, 0, 0, NavFrame.CanvasSize.Y.Offset + 35)

-- ====================================================================
-- FIN DES EFFETS
-- ====================================================================
-- ====================================================================
-- PARTIE 5 : SYSTÈME ADMIN PREMIUM (CLIENT-SIDE / EXECUTOR)
-- CRÉATEUR : DIABLESSE
-- POUR : DELTA / ARCEUS X / HYDROGEN / FLUXUS (Mobile)
-- ====================================================================

-- 5.1 WHITELIST ADMIN (même fichier que la whitelist principale)
local url_admin_whitelist = "https://gist.githubusercontent.com/HKTEAM987/d94c70ef6af78d7f04a90a19cddb8386/raw/d705188d4398a14e94ef8e9f48d8c9b96a75dcbb/whitelist1.txt"
local succesAdmin, resultatAdmin = pcall(function() return game:HttpGet(url_admin_whitelist) end)
local IS_ADMIN = false
local ADMIN_TAG = ""

if succesAdmin and resultatAdmin then
    for line in resultatAdmin:gmatch("[^\r\n]+") do
        if line:lower():match(localPlayer.Name:lower()) then
            IS_ADMIN = true
            ADMIN_TAG = "[ADMIN]"
            break
        end
    end
end

-- 5.2 CRÉATION DU TAG [ADMIN] LUMINEUX AU-DESSUS DE LA TÊTE
if IS_ADMIN then
    spawn(function()
        local function addTag()
            local char = localPlayer.Character
            if not char then return end
            local head = char:FindFirstChild("Head")
            if not head then return end
            
            -- Supprimer l'ancien tag s'il existe
            local oldTag = head:FindFirstChild("AdminTag")
            if oldTag then oldTag:Destroy() end
            
            -- BillBoard principal
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "AdminTag"
            billboard.Parent = head
            billboard.Size = UDim2.new(0, 220, 0, 36)
            billboard.StudsOffset = Vector3.new(0, 3.8, 0)
            billboard.AlwaysOnTop = true
            billboard.ClipsDescendants = false
            billboard.ResetOnSpawn = false
            billboard.Active = false
            billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            -- Fond du tag (translucide)
            local TagBg = Instance.new("Frame")
            TagBg.Parent = billboard
            TagBg.Size = UDim2.new(1, 0, 1, 0)
            TagBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            TagBg.BackgroundTransparency = 0.25
            TagBg.BorderSize = 0
            local TBgC = Instance.new("UICorner")
            TBgC.CornerRadius = UDim.new(0, 8)
            TBgC.Parent = TagBg
            
            -- Gradient arc-en-ciel animé
            local TagGrad = Instance.new("UIGradient")
            TagGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 50, 120)),
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(150, 50, 255)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 215, 0)),
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 50, 120)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
            })
            TagGrad.Rotation = 0
            TagGrad.Parent = TagBg
            
            -- Bordure lumineuse
            local TagStroke = Instance.new("UIStroke")
            TagStroke.Color = Color3.fromRGB(0, 210, 255)
            TagStroke.Thickness = 2
            TagStroke.Transparency = 0.2
            TagStroke.Parent = TagBg
            
            -- Texte [ADMIN:Nom]
            local TagText = Instance.new("TextLabel")
            TagText.Parent = billboard
            TagText.Size = UDim2.new(1, 0, 1, 0)
            TagText.BackgroundTransparency = 1
            TagText.Text = "[" .. ADMIN_TAG .. ":" .. localPlayer.Name .. "]"
            TagText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TagText.Font = Enum.Font.GothamBold
            TagText.TextSize = 18
            TagText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            TagText.TextStrokeTransparency = 0.2
            
            -- Animation rotation du gradient
            local tagAngle = 0
            while billboard and billboard.Parent do
                tagAngle = (tagAngle + 30 * 0.03) % 360
                TagGrad.Rotation = tagAngle
                task.wait(0.03)
            end
        end
        
        addTag()
        localPlayer.CharacterAdded:Connect(addTag)
    end)
    
    envoyerLog("Admin Connecté", "L'admin **" .. localPlayer.Name .. "** a rejoint avec les commandes.")
end

-- 5.3 BOUTON ADMIN DANS LA NAVIGATION (visible uniquement pour les admins)
if IS_ADMIN then
    local AdminNavBtn = Instance.new("TextButton")
    AdminNavBtn.Parent = NavFrame
    AdminNavBtn.Size = UDim2.new(1, -6, 0, 38)
    AdminNavBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    AdminNavBtn.Text = "⚡ Panel Admin"
    AdminNavBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    AdminNavBtn.Font = Enum.Font.SourceSansBold
    AdminNavBtn.TextSize = 13
    AdminNavBtn.AutoButtonColor = true
    local aC = Instance.new("UICorner")
    aC.CornerRadius = UDim.new(0, 5)
    aC.Parent = AdminNavBtn
    
    -- Barre active rouge
    local AdminActiveBar = Instance.new("Frame")
    AdminActiveBar.Parent = AdminNavBtn
    AdminActiveBar.Size = UDim2.new(0, 3, 0, 0)
    AdminActiveBar.Position = UDim2.new(0, 0, 0.5, 0)
    AdminActiveBar.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    AdminActiveBar.BorderSize = 0
    AdminActiveBar.Visible = false
    
    AdminNavBtn.MouseEnter:Connect(function()
        TweenService:Create(AdminNavBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 15, 15)}):Play()
    end)
    AdminNavBtn.MouseLeave:Connect(function()
        if AdminNavBtn ~= currentNavBtn then
            TweenService:Create(AdminNavBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(40, 10, 10)}):Play()
        end
    end)
    
    AdminNavBtn.MouseButton1Click:Connect(function()
        if currentNavBtn then
            TweenService:Create(currentNavBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
            local oldBar = currentNavBtn:FindFirstChild("ActiveBar")
            if oldBar then oldBar.Visible = false end
            currentNavBtn = nil
        end
        
        currentNavBtn = AdminNavBtn
        TweenService:Create(AdminNavBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 15, 15)}):Play()
        AdminActiveBar.Visible = true
        TweenService:Create(AdminActiveBar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 26)}):Play()
        TweenService:Create(AdminActiveBar, TweenInfo.new(0.15), {Position = UDim2.new(0, 0, 0.5, -13)}):Play()
        
        chargerPanelAdmin()
    end)
    
    -- Ajuster le canvas
    NavFrame.CanvasSize = UDim2.new(0, 0, 0, NavFrame.CanvasSize.Y.Offset + 43)
end

-- 5.4 VARIABLES ADMIN
local selectedPlayers = {}

-- 5.5 FONCTIONS D'APPLICATION DES COMMANDES (ENVOI VIA REMOTES)
local function getRE()
    return ReplicatedStorage:FindFirstChild("RE") or ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
end

local function envoyerCommandeAdmin(action, cibleNom, valeur)
    local RE = getRE()
    if not RE then return end
    
    -- Essaie tous les remotes possibles
    local remoteNames = {"PlayerToolEvent", "1NoMoto1rVehicle1s", "1Player1sCa1r", "RE"}
    for _, rName in ipairs(remoteNames) do
        local remote = RE:FindFirstChild(rName)
        if remote then
            pcall(function()
                remote:FireServer(action, cibleNom, valeur or "")
                remote:FireServer("AdminCommand", action, cibleNom, valeur or "")
            end)
        end
    end
    
    envoyerLog("Commande Admin", "**" .. localPlayer.Name .. "** → `" .. action .. "` sur **" .. cibleNom .. "**" .. (valeur ~= "" and " (" .. valeur .. ")" or ""))
end

-- 5.6 COMMANDES DIRECTES SUR LES JOUEURS (CLIENT-SIDE)
local function appliquerEffetLocal(action, cible)
    local targetPlayer = Players:FindFirstChild(cible)
    if not targetPlayer then return end
    
    local char = targetPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if action == "kill_local" then
        -- Effet visuel de mort (local)
        if hum then hum.Health = 0 end
        
    elseif action == "freeze_local" then
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
        end
        
    elseif action == "unfreeze_local" then
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
        end
        
    elseif action == "explode_local" then
        if root then
            -- Créer une explosion visuelle locale
            local expl = Instance.new("Explosion")
            expl.Position = root.Position
            expl.BlastRadius = 10
            expl.BlastPressure = 0
            expl.Visible = true
            expl.DestroyJointRadiusPercent = 0
            expl.Parent = workspace
            
            -- Faire voler le joueur
            root.Velocity = Vector3.new(0, 50, 0)
        end
        
    elseif action == "slap_local" then
        if root then
            root.Velocity = Vector3.new(math.random(-60, 60), 30, math.random(-60, 60))
        end
        
    elseif action == "burn_local" then
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
        if torso then
            local fire = Instance.new("Fire")
            fire.Parent = torso
            fire.Size = 8
            fire.Heat = 15
            task.delay(6, function()
                pcall(function() fire:Destroy() end)
            end)
        end
        
    elseif action == "stun_local" then
        if hum then
            hum.PlatformStand = true
            task.delay(4, function()
                pcall(function() hum.PlatformStand = false end)
            end)
        end
        
    elseif action == "tpme_local" then
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and root then
            root.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
        end
        
    elseif action == "bring_local" then
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and root then
            root.CFrame = myRoot.CFrame * CFrame.new(0, 0, 5)
        end
        
    elseif action == "spawn_local" then
        targetPlayer:LoadCharacter()
        
    elseif action == "kick_local" then
        -- Simulation de kick (déconnecte via TeleportService)
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, targetPlayer)
        end)
        
    elseif action == "fling_local" then
        if root then
            root.Velocity = Vector3.new(math.random(-100, 100), 100, math.random(-100, 100))
            root.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
        end
        
    elseif action == "silent_local" then
        -- Infliger des dégâts continus
        if hum and hum.Health > 0 then
            hum.Health = hum.Health - 10
        end
        
    elseif action == "loopkill_local" then
        spawn(function()
            for i = 1, 20 do
                if hum and hum.Health > 0 then
                    hum.Health = hum.Health - 5
                end
                task.wait(0.2)
            end
        end)
    end
end

-- 5.7 LISTE DES JOUEURS
local function getPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        table.insert(list, plr.Name)
    end
    table.sort(list)
    return list
end

-- 5.8 PANEL ADMIN
local function chargerPanelAdmin()
    if currentPanel then currentPanel:Destroy() end
    
    local AdminFrame = Instance.new("ScrollingFrame")
    AdminFrame.Parent = ContentContainer
    AdminFrame.Size = UDim2.new(1, 0, 1, 0)
    AdminFrame.BackgroundTransparency = 1
    AdminFrame.ScrollBarThickness = 4
    AdminFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
    AdminFrame.ScrollBarImageTransparency = 0.5
    AdminFrame.BorderSize = 0
    AdminFrame.CanvasSize = UDim2.new(0, 0, 0, 780)
    currentPanel = AdminFrame
    
    -- En-tête
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Parent = AdminFrame
    HeaderTitle.Size = UDim2.new(1, -10, 0, 36)
    HeaderTitle.Position = UDim2.new(0, 5, 0, 5)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "⚡ PANEL ADMINSTRATEUR"
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
    HeaderTitle.Font = Enum.Font.Code
    HeaderTitle.TextSize = 20
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local HeaderSub = Instance.new("TextLabel")
    HeaderSub.Parent = AdminFrame
    HeaderSub.Size = UDim2.new(1, -10, 0, 18)
    HeaderSub.Position = UDim2.new(0, 5, 0, 36)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.Text = "Sélectionne des joueurs et applique des commandes"
    HeaderSub.TextColor3 = Color3.fromRGB(180, 180, 190)
    HeaderSub.Font = Enum.Font.SourceSansLight
    HeaderSub.TextSize = 13
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Boutons Rafraîchir + tout sélectionner
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Parent = AdminFrame
    RefreshBtn.Size = UDim2.new(0.46, 0, 0, 34)
    RefreshBtn.Position = UDim2.new(0, 5, 0, 62)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    RefreshBtn.Text = "🔄 Rafraîchir"
    RefreshBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
    RefreshBtn.Font = Enum.Font.SourceSansBold
    RefreshBtn.TextSize = 14
    RefreshBtn.AutoButtonColor = true
    local RefC = Instance.new("UICorner") RefC.CornerRadius = UDim.new(0, 6) RefC.Parent = RefreshBtn
    
    local SelectAllBtn = Instance.new("TextButton")
    SelectAllBtn.Parent = AdminFrame
    SelectAllBtn.Size = UDim2.new(0.46, 0, 0, 34)
    SelectAllBtn.Position = UDim2.new(0.5, 5, 0, 62)
    SelectAllBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SelectAllBtn.Text = "✓ Tout sélectionner"
    SelectAllBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
    SelectAllBtn.Font = Enum.Font.SourceSansBold
    SelectAllBtn.TextSize = 14
    SelectAllBtn.AutoButtonColor = true
    local SelC = Instance.new("UICorner") SelC.CornerRadius = UDim.new(0, 6) SelC.Parent = SelectAllBtn
    
    -- Conteneur liste des joueurs
    local PlayerListContainer = Instance.new("Frame")
    PlayerListContainer.Parent = AdminFrame
    PlayerListContainer.Size = UDim2.new(1, -10, 0, 200)
    PlayerListContainer.Position = UDim2.new(0, 5, 0, 104)
    PlayerListContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    PlayerListContainer.BorderSize = 0
    local PLCc = Instance.new("UICorner") PLCc.CornerRadius = UDim.new(0, 8) PLCc.Parent = PlayerListContainer
    
    local PlayerScroll = Instance.new("ScrollingFrame")
    PlayerScroll.Parent = PlayerListContainer
    PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
    PlayerScroll.BackgroundTransparency = 1
    PlayerScroll.ScrollBarThickness = 3
    PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)
    PlayerScroll.BorderSize = 0
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local PlayerLayout = Instance.new("UIListLayout")
    PlayerLayout.Parent = PlayerScroll
    PlayerLayout.Padding = UDim.new(0, 3)
    
    -- Remplir la liste
    local function remplirListe()
        for _, child in pairs(PlayerScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local players = getPlayerList()
        PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, #players * 36)
        
        for _, pName in ipairs(players) do
            if selectedPlayers[pName] == nil then
                selectedPlayers[pName] = false
            end
            
            local PBtn = Instance.new("TextButton")
            PBtn.Parent = PlayerScroll
            PBtn.Size = UDim2.new(1, -8, 0, 33)
            PBtn.BackgroundColor3 = selectedPlayers[pName] and Color3.fromRGB(55, 15, 15) or Color3.fromRGB(18, 18, 26)
            PBtn.Text = ""
            PBtn.AutoButtonColor = false
            local PBC = Instance.new("UICorner") PBC.CornerRadius = UDim.new(0, 5) PBC.Parent = PBtn
            
            -- Checkbox
            local CheckBox = Instance.new("Frame")
            CheckBox.Parent = PBtn
            CheckBox.Size = UDim2.new(0, 18, 0, 18)
            CheckBox.Position = UDim2.new(0, 8, 0.5, -9)
            CheckBox.BackgroundColor3 = selectedPlayers[pName] and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(30, 30, 40)
            CheckBox.BorderSize = 0
            local CBC = Instance.new("UICorner") CBC.CornerRadius = UDim.new(0, 4) CBC.Parent = CheckBox
            
            if selectedPlayers[pName] then
                local CM = Instance.new("TextLabel")
                CM.Parent = CheckBox
                CM.Size = UDim2.new(1, 0, 1, 0)
                CM.BackgroundTransparency = 1
                CM.Text = "✓"
                CM.TextColor3 = Color3.fromRGB(255, 255, 255)
                CM.Font = Enum.Font.GothamBold
                CM.TextSize = 14
            end
            
            -- Nom
            local NLabel = Instance.new("TextLabel")
            NLabel.Parent = PBtn
            NLabel.Size = UDim2.new(1, -70, 1, 0)
            NLabel.Position = UDim2.new(0, 32, 0, 0)
            NLabel.BackgroundTransparency = 1
            NLabel.Text = pName
            NLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
            NLabel.Font = Enum.Font.SourceSansBold
            NLabel.TextSize = 15
            NLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Bouton TP rapide (petit icon)
            local TPIcon = Instance.new("TextButton")
            TPIcon.Parent = PBtn
            TPIcon.Size = UDim2.new(0, 24, 0, 24)
            TPIcon.Position = UDim2.new(1, -28, 0.5, -12)
            TPIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TPIcon.Text = "📍"
            TPIcon.TextSize = 12
            TPIcon.Font = Enum.Font.SourceSansBold
            TPIcon.AutoButtonColor = false
            local TPC = Instance.new("UICorner") TPC.CornerRadius = UDim.new(0, 4) TPC.Parent = TPIcon
            
            TPIcon.MouseButton1Click:Connect(function()
                local myChar = localPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local targetChar = Players:FindFirstChild(pName)
                if targetChar then
                    local tChar = targetChar.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if myRoot and tRoot then
                        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                    end
                end
            end)
            
            PBtn.MouseButton1Click:Connect(function()
                selectedPlayers[pName] = not selectedPlayers[pName]
                if selectedPlayers[pName] then
                    TweenService:Create(PBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 15, 15)}):Play()
                    CheckBox.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
                    local CM = Instance.new("TextLabel")
                    CM.Parent = CheckBox
                    CM.Size = UDim2.new(1, 0, 1, 0)
                    CM.BackgroundTransparency = 1
                    CM.Text = "✓"
                    CM.TextColor3 = Color3.fromRGB(255, 255, 255)
                    CM.Font = Enum.Font.GothamBold
                    CM.TextSize = 14
                else
                    TweenService:Create(PBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 26)}):Play()
                    CheckBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    for _, child in pairs(CheckBox:GetChildren()) do
                        if child:IsA("TextLabel") then child:Destroy() end
                    end
                end
            end)
        end
    end
    
    remplirListe()
    
    RefreshBtn.MouseButton1Click:Connect(function()
        TweenService:Create(RefreshBtn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
        task.wait(0.05)
        TweenService:Create(RefreshBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        remplirListe()
    end)
    
    local allSel = false
    SelectAllBtn.MouseButton1Click:Connect(function()
        allSel = not allSel
        SelectAllBtn.Text = allSel and "✗ Tout désélectionner" or "✓ Tout sélectionner"
        SelectAllBtn.TextColor3 = allSel and Color3.fromRGB(255, 150, 150) or Color3.fromRGB(150, 255, 150)
        for pName, _ in pairs(selectedPlayers) do
            selectedPlayers[pName] = allSel
        end
        remplirListe()
    end)
    
    -- ====================================================================
    -- COMMANDES ADMIN
    -- ====================================================================
    
    local CmdLabel = Instance.new("TextLabel")
    CmdLabel.Parent = AdminFrame
    CmdLabel.Size = UDim2.new(1, -10, 0, 22)
    CmdLabel.Position = UDim2.new(0, 5, 0, 312)
    CmdLabel.BackgroundTransparency = 1
    CmdLabel.Text = "Commandes disponibles — clic = applique aux joueurs sélectionnés :"
    CmdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    CmdLabel.Font = Enum.Font.SourceSansBold
    CmdLabel.TextSize = 14
    CmdLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Grille de commandes
    local CmdGrid = Instance.new("Frame")
    CmdGrid.Parent = AdminFrame
    CmdGrid.Size = UDim2.new(1, -10, 0, 440)
    CmdGrid.Position = UDim2.new(0, 5, 0, 338)
    CmdGrid.BackgroundTransparency = 1
    
    local CmdLayout = Instance.new("UIGridLayout")
    CmdLayout.Parent = CmdGrid
    CmdLayout.CellSize = UDim2.new(0.31, 0, 0, 44)
    CmdLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    CmdLayout.FillDirection = Enum.FillDirection.Horizontal
    CmdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    
    local commandes = {
        {name = "💀 KILL", color = Color3.fromRGB(255, 30, 30), action = "kill_local"},
        {name = "🌀 EXPLODE", color = Color3.fromRGB(255, 120, 0), action = "explode_local"},
        {name = "❄️ FREEZE", color = Color3.fromRGB(60, 180, 255), action = "freeze_local"},
        {name = "🔥 UNFREEZE", color = Color3.fromRGB(255, 200, 60), action = "unfreeze_local"},
        {name = "🔥 BURN", color = Color3.fromRGB(255, 60, 0), action = "burn_local"},
        {name = "🛑 STUN", color = Color3.fromRGB(255, 255, 60), action = "stun_local"},
        {name = "⚡ SLAP", color = Color3.fromRGB(200, 200, 60), action = "slap_local"},
        {name = "🌀 FLING", color = Color3.fromRGB(255, 100, 200), action = "fling_local"},
        {name = "📍 TP ME", color = Color3.fromRGB(60, 200, 255), action = "tpme_local"},
        {name = "📦 BRING", color = Color3.fromRGB(60, 255, 150), action = "bring_local"},
        {name = "💧 RESPAWN", color = Color3.fromRGB(60, 255, 100), action = "spawn_local"},
        {name = "🔪 LOOPKILL", color = Color3.fromRGB(200, 0, 0), action = "loopkill_local"},
        {name = "🤫 SILENT", color = Color3.fromRGB(180, 60, 180), action = "silent_local"},
        {name = "👢 KICK(TP)", color = Color3.fromRGB(255, 80, 80), action = "kick_local"},
    }
    
    for _, cmd in ipairs(commandes) do
        local CmdBtn = Instance.new("TextButton")
        CmdBtn.Parent = CmdGrid
        CmdBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        CmdBtn.Text = cmd.name
        CmdBtn.TextColor3 = cmd.color
        CmdBtn.Font = Enum.Font.SourceSansBold
        CmdBtn.TextSize = 12
        CmdBtn.AutoButtonColor = true
        local CmC = Instance.new("UICorner") CmC.CornerRadius = UDim.new(0, 6) CmC.Parent = CmdBtn
        
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
            for pName, isSel in pairs(selectedPlayers) do
                if isSel and pName ~= localPlayer.Name then
                    -- Envoie via les remotes du jeu
                    envoyerCommandeAdmin(cmd.action, pName, "")
                    -- Effet local direct
                    appliquerEffetLocal(cmd.action, pName)
                end
            end
            
            TweenService:Create(CmdBtn, TweenInfo.new(0.05), {BackgroundColor3 = cmd.color}):Play()
            task.wait(0.05)
            TweenService:Create(CmdBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
        end)
    end
    
    AdminFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
end

-- ====================================================================
-- FIN PARTIE ADMIN
-- ====================================================================
