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
local url_whitelist = "https://gist.githubusercontent.com/HKTEAM987/54e42b3cffb8d47127435c70dce0826b/raw/34a4e06d6900d3828120fa4e7378d2c1f7e1d063/whitelist.txt"
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
