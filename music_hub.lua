-- ====================================================================
-- SCRIPT : HK_TEAM987 MUSIC HUB | MASTER PREMIUM HUB V2
-- CRÉATEUR : DIABLESSE
-- DESIGN : ANIMATION TOGGLE | SLIDES | DÉGRADÉS | NUANCES
-- ====================================================================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- 🚨 1. SÉCURITÉ WHITELIST INITIALE
local url_whitelist = "https://gist.githubusercontent.com/HKTEAM987/54e42b3cffb8d47127435c70dce0826b/raw/836ef1d974f3facf848bf25d20c0b807de1638b0/whitelist.txt"
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
local AccentColor = Color3.fromRGB(255, 50, 120)
local GlowColor = Color3.fromRGB(0, 150, 255)

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

-- 🎵 CHARGEMENT DYNAMIQUE DE LA PLAYLIST
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
            warn("[HK_TEAM] Erreur décodage JSON.")
        end
    else
        warn("[HK_TEAM] Erreur connexion Gist.")
    end
    return {}
end

Playlist = chargerPlaylist()

-- ====================================================================
-- SYSTÈME D'ANIMATIONS AVANCÉ
-- ====================================================================

-- Crée un dégradé animé en rotation continue
local function creerGradientAnime(parent, couleurs, vitesse)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(couleurs)
    grad.Parent = parent
    grad.Rotation = 0
    local angle = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        angle = (angle + (vitesse or 30) * dt) % 360
        grad.Rotation = angle
    end)
    return grad, conn
end

-- Crée un dégradé qui pulse (va-et-vient)
local function creerGradientPulse(parent, couleurs, duree)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(couleurs)
    grad.Parent = parent
    local info = TweenInfo.new(duree or 3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(grad, info, {Rotation = 360})
    tween:Play()
    return grad, tween
end

-- Animation de "glow pulse" sur un UIStroke
local function animerGlowStroke(stroke, couleur, duree)
    local info = TweenInfo.new(duree or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local t1 = TweenService:Create(stroke, info, {Thickness = 4})
    local t2 = TweenService:Create(stroke, TweenInfo.new(duree or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false), {Thickness = 1.5})
    t1:Play()
    t2:Play()
    return t1, t2
end

-- Animation d'ouverture/fermeture avec easing élastique
local function animerOuverture(objet, tailleCible, posCible, duree)
    objet.Visible = true
    objet.Size = UDim2.new(0, 0, 0, 0)
    local info = TweenInfo.new(duree or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local t1 = TweenService:Create(objet, info, {Size = tailleCible})
    if posCible then
        local t2 = TweenService:Create(objet, TweenInfo.new(duree or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = posCible})
        t2:Play()
    end
    t1:Play()
    return t1
end

local function animerFermeture(objet, duree)
    local info = TweenInfo.new(duree or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local t = TweenService:Create(objet, info, {Size = UDim2.new(0, 0, 0, 0)})
    t:Play()
    t.Completed:Connect(function()
        objet.Visible = false
    end)
    return t
end

-- ====================================================================
-- PARTIE 2 : INTERFACE GRAPHIQUE
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HK_TEAM_Hub_V15"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Fond flouté / overlay
local BlurOverlay = Instance.new("Frame")
BlurOverlay.Parent = ScreenGui
BlurOverlay.Size = UDim2.new(1, 0, 1, 0)
BlurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlurOverlay.BackgroundTransparency = 0.5
BlurOverlay.Visible = false
BlurOverlay.ZIndex = 998
local BlurEffect = Instance.new("UIGradient")
BlurEffect.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,15))})
BlurEffect.Rotation = 90
BlurEffect.Parent = BlurOverlay

-- ====================================================================
-- ICÔNE FLOTTANTE PREMIUM
-- ====================================================================

local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Parent = ScreenGui
ToggleIcon.Size = UDim2.new(0, 65, 0, 65)
ToggleIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
ToggleIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(CREATOR_ID) .. "&w=150&h=150"
ToggleIcon.Visible = false
ToggleIcon.Active = true
ToggleIcon.Draggable = true
ToggleIcon.ZIndex = 999

-- Coins arrondis parfaits
local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = ToggleIcon

-- Dégradé animé sur le bord
local IconGrad, IconGradConn = creerGradientAnime(ToggleIcon, {Color3.fromRGB(0,210,255), Color3.fromRGB(255,50,120), Color3.fromRGB(120,50,255), Color3.fromRGB(0,210,255)}, 45)

-- Stroke lumineux
local IconStroke = Instance.new("UIStroke")
IconStroke.Color = ThemeColor
IconStroke.Thickness = 2.5
IconStroke.Transparency = 0.3
IconStroke.Parent = ToggleIcon

-- Glow pulse sur l'icône
local glowT1, glowT2 = animerGlowStroke(IconStroke, ThemeColor, 1.2)

-- Ombre portée
local IconShadow = Instance.new("ImageLabel")
IconShadow.Parent = ToggleIcon
IconShadow.Size = UDim2.new(1, 8, 1, 8)
IconShadow.Position = UDim2.new(0, -4, 0, -4)
IconShadow.BackgroundTransparency = 1
IconShadow.Image = "rbxassetid://5028857382"
IconShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
IconShadow.ImageTransparency = 0.7
IconShadow.ZIndex = -1

-- ====================================================================
-- FENÊTRE PRINCIPALE — DESIGN COMPLEXE
-- ====================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.Position = UDim2.new(0.3, 0, 0.22, 0)
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 999

-- Bordure + coins
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Fond avec gradient subtil
local MainBgGrad = Instance.new("UIGradient")
MainBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 14)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 12))
})
MainBgGrad.Rotation = 45
MainBgGrad.Parent = MainFrame

-- Stroke principal avec rainbow lent
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ThemeColor
MainStroke.Thickness = 1.8
MainStroke.Parent = MainFrame
local MainStrokeGrad, _ = creerGradientAnime(MainStroke, {ThemeColor, AccentColor, Color3.fromRGB(120,50,255), ThemeColor}, 20)

-- ====================================================================
-- BANNIÈRE HAUTE AVEC EFFET DE GLOW
-- ====================================================================

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Parent = MainFrame
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
HeaderFrame.ZIndex = 1000
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = HeaderFrame
local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 18)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(8, 8, 14)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
})
HeaderGrad.Rotation = 90
HeaderGrad.Parent = HeaderFrame

-- Ligne de séparation lumineuse sous le header
local HeaderLine = Instance.new("Frame")
HeaderLine.Parent = HeaderFrame
HeaderLine.Size = UDim2.new(1, -30, 0, 1.5)
HeaderLine.Position = UDim2.new(0, 15, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
HeaderLine.BackgroundTransparency = 0.7
local HeaderLineGrad = Instance.new("UIGradient")
HeaderLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,210,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,50,120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,210,255))
})
HeaderLineGrad.Rotation = 0
HeaderLineGrad.Parent = HeaderLine
local HLGradAnim, _ = creerGradientAnime(HeaderLineGrad, {ThemeColor, AccentColor, Color3.fromRGB(120,50,255), ThemeColor}, 35)

-- Titre avec glow
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = HeaderFrame
TitleLabel.Size = UDim2.new(0, 300, 0, 35)
TitleLabel.Position = UDim2.new(0, 25, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HK_TEAM"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 26
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Sous-titre
local CreatorLabel = Instance.new("TextLabel")
CreatorLabel.Parent = HeaderFrame
CreatorLabel.Size = UDim2.new(0, 250, 0, 18)
CreatorLabel.Position = UDim2.new(0, 25, 0, 38)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "par " .. CREATOR_NAME .. "  •  Music Hub"
CreatorLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
CreatorLabel.Font = Enum.Font.SourceSansLight
CreatorLabel.TextSize = 13
CreatorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Indicateur de statut en ligne (pastille animée)
local StatusDot = Instance.new("Frame")
StatusDot.Parent = HeaderFrame
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -55, 0, 14)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.ZIndex = 1001
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot
local DotGlow = Instance.new("UIStroke")
DotGlow.Color = Color3.fromRGB(0, 255, 100)
DotGlow.Thickness = 3
DotGlow.Transparency = 0.6
DotGlow.Parent = StatusDot
-- Animation pulse du dot
local dotPulse = TweenService:Create(DotGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Thickness = 6, Transparency = 0.2})
dotPulse:Play()

-- Status text
local StatusText = Instance.new("TextLabel")
StatusText.Parent = HeaderFrame
StatusText.Size = UDim2.new(0, 60, 0, 15)
StatusText.Position = UDim2.new(1, -80, 0, 28)
StatusText.BackgroundTransparency = 1
StatusText.Text = "EN LIGNE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Right

-- ====================================================================
-- BOUTONS DE CONTRÔLE (Minimize / Close)
-- ====================================================================

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = HeaderFrame
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 14)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.ZIndex = 1001
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn
-- Hover anim
MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    animerFermeture(MainFrame, 0.35)
    task.wait(0.35)
    MainFrame.Visible = false
    BlurOverlay.Visible = false
    ToggleIcon.Visible = true
    -- Réapparition avec effet
    ToggleIcon.Size = UDim2.new(0, 0, 0, 0)
    animerOuverture(ToggleIcon, UDim2.new(0, 65, 0, 65), nil, 0.3)
end)

ToggleIcon.MouseButton1Click:Connect(function()
    ToggleIcon.Visible = false
    BlurOverlay.Visible = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    animerOuverture(MainFrame, UDim2.new(0, 720, 0, 480), UDim2.new(0.3, 0, 0.22, 0), 0.45)
    -- Faire apparaître le flou en fondu
    BlurOverlay.BackgroundTransparency = 1
    TweenService:Create(BlurOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
end)

-- ====================================================================
-- PARTIE 3 : SYSTÈME DE NAVIGATION LATÉRALE (SLIDING)
-- ====================================================================

local NavFrame = Instance.new("ScrollingFrame")
NavFrame.Parent = MainFrame
NavFrame.Position = UDim2.new(0, 15, 0, 75)
NavFrame.Size = UDim2.new(0, 170, 1, -100)
NavFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
NavFrame.ScrollBarThickness = 0
NavFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
NavFrame.BorderSize = 0
NavFrame.ZIndex = 1000
local NavCorner = Instance.new("UICorner")
NavCorner.CornerRadius = UDim.new(0, 10)
NavCorner.Parent = NavFrame

-- Fond de navigation avec gradient
local NavBgGrad, _ = creerGradientPulse(NavFrame, {Color3.fromRGB(12,12,18), Color3.fromRGB(14,10,20), Color3.fromRGB(12,12,18)}, 8)

local NavList = Instance.new("UIListLayout")
NavList.Parent = NavFrame
NavList.Padding = UDim.new(0, 6)
NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ====================================================================
-- CONTENEUR PRINCIPAL AVEC SLIDING ANIMATION
-- ====================================================================

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.Position = UDim2.new(0, 200, 0, 75)
ContentContainer.Size = UDim2.new(1, -215, 1, -100)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 999

-- ====================================================================
-- FONCTIONS D'APPLICATION DE MUSIQUE
-- ====================================================================

local function appliquerMusique(id, nomMusique)
    local RE = ReplicatedStorage:FindFirstChild("RE")
    if not RE then return end
    
    envoyerLog("Musique Jouée", "A choisi la piste : **" .. nomMusique .. "**")
    
    pcall(function()
        if RE:FindFirstChild("1NoMoto1rVehicle1s") then 
            RE["1NoMoto1rVehicle1s"]:FireServer("PickingScooterMusicText", tostring(id), true) 
        end
        if RE:FindFirstChild("1Player1sCa1r") then 
            RE["1Player1sCa1r"]:FireServer("PickingVehicleMusicText", tostring(id), true) 
        end
        if RE:FindFirstChild("PlayerToolEvent") then 
            local args = {"ToolMusicText", tostring(id), [4] = true}
            RE["PlayerToolEvent"]:FireServer(unpack(args))
        end
    end)
end

-- ====================================================================
-- GÉNÉRATEUR DE PAGES AVEC SLIDING
-- ====================================================================

local currentPanel = nil
local navIndicator = nil
local currentNavBtn = nil

local function creerBoutonNavigation(texte, couleurTexte, callback)
    local NavBtn = Instance.new("TextButton")
    NavBtn.Parent = NavFrame
    NavBtn.Size = UDim2.new(1, -10, 0, 42)
    NavBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    NavBtn.Text = "  " .. texte
    NavBtn.TextColor3 = couleurTexte or Color3.fromRGB(170, 170, 185)
    NavBtn.Font = Enum.Font.SourceSansBold
    NavBtn.TextSize = 14
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.ZIndex = 1001
    NavBtn.AutoButtonColor = false
    
    local nC = Instance.new("UICorner")
    nC.CornerRadius = UDim.new(0, 8)
    nC.Parent = NavBtn
    
    -- Surbrillance gauche (indicateur actif)
    local ActiveBar = Instance.new("Frame")
    ActiveBar.Parent = NavBtn
    ActiveBar.Size = UDim2.new(0, 3, 0, 0)
    ActiveBar.Position = UDim2.new(0, 0, 0.5, 0)
    ActiveBar.BackgroundColor3 = ThemeColor
    ActiveBar.BorderSize = 0
    ActiveBar.Visible = false
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 2)
    BarCorner.Parent = ActiveBar
    
    -- Hover animations
    NavBtn.MouseEnter:Connect(function()
        if NavBtn ~= currentNavBtn then
            TweenService:Create(NavBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
            TweenService:Create(NavBtn, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(230, 230, 240)}):Play()
        end
    end)
    NavBtn.MouseLeave:Connect(function()
        if NavBtn ~= currentNavBtn then
            TweenService:Create(NavBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}):Play()
            TweenService:Create(NavBtn, TweenInfo.new(0.15), {TextColor3 = couleurTexte or Color3.fromRGB(170, 170, 185)}):Play()
        end
    end)
    
    NavBtn.MouseButton1Click:Connect(function()
        -- Reset previous active button
        if currentNavBtn and currentNavBtn ~= NavBtn then
            TweenService:Create(currentNavBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}):Play()
            TweenService:Create(currentNavBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(170, 170, 185)}):Play()
   
