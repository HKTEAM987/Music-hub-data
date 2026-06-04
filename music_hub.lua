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
-- CRÉATION DE L'INTERFACE GRAPHIQUE
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HK_TEAM_Hub_V15"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 100

-- ====================================================================
-- ICÔNE FLOTTANTE (cachée au départ, apparaît après minimisation)
-- ====================================================================

local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Parent = ScreenGui
ToggleIcon.Size = UDim2.new(0, 60, 0, 60)
ToggleIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
ToggleIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(CREATOR_ID) .. "&w=150&h=150"
ToggleIcon.Visible = false
ToggleIcon.Active = true
ToggleIcon.Draggable = true
ToggleIcon.ZIndex = 10

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = ToggleIcon

-- Dégradé animé sur le bord
local IconGrad = Instance.new("UIGradient")
IconGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ThemeColor), ColorSequenceKeypoint.new(0.5, AccentColor), ColorSequenceKeypoint.new(1, ThemeColor)})
IconGrad.Rotation = 0
IconGrad.Parent = ToggleIcon

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = ThemeColor
IconStroke.Thickness = 2
IconStroke.Parent = ToggleIcon

-- Animation rotation gradient de l'icône
spawn(function()
    while ToggleIcon and ToggleIcon.Parent do
        IconGrad.Rotation = (IconGrad.Rotation + 40 * 0.03) % 360
        task.wait(0.03)
    end
end)

-- ====================================================================
-- FENÊTRE PRINCIPALE
-- ====================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 680, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 5
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ThemeColor
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainStrokeGrad = Instance.new("UIGradient")
MainStrokeGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ThemeColor), ColorSequenceKeypoint.new(0.5, AccentColor), ColorSequenceKeypoint.new(1, ThemeColor)})
MainStrokeGrad.Rotation = 0
MainStrokeGrad.Parent = MainStroke

spawn(function()
    while MainStrokeGrad and MainStrokeGrad.Parent do
        MainStrokeGrad.Rotation = (MainStrokeGrad.Rotation + 25 * 0.03) % 360
        task.wait(0.03)
    end
end)

-- Fond gradien subtil
local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 10, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 14))
})
BgGrad.Rotation = 45
BgGrad.Parent = MainFrame

-- ====================================================================
-- HEADER
-- ====================================================================

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Parent = MainFrame
HeaderFrame.Size = UDim2.new(1, 0, 0, 55)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
HeaderFrame.ZIndex = 6

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = HeaderFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = HeaderFrame
TitleLabel.Size = UDim2.new(0, 250, 0, 32)
TitleLabel.Position = UDim2.new(0, 20, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HK_TEAM"
TitleLabel.TextColor3 = ThemeColor
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 7

local CreatorLabel = Instance.new("TextLabel")
CreatorLabel.Parent = HeaderFrame
CreatorLabel.Size = UDim2.new(0, 200, 0, 16)
CreatorLabel.Position = UDim2.new(0, 20, 0, 33)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "par " .. CREATOR_NAME .. " · Music Hub"
CreatorLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
CreatorLabel.Font = Enum.Font.SourceSansItalic
CreatorLabel.TextSize = 13
CreatorLabel.TextXAlignment = Enum.TextXAlignment.Left
CreatorLabel.ZIndex = 7

-- Bouton minimiser
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = HeaderFrame
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -42, 0, 11)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.ZIndex = 7

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
end)

-- ====================================================================
-- NAVIGATION LATÉRALE
-- ====================================================================

local NavFrame = Instance.new("ScrollingFrame")
NavFrame.Parent = MainFrame
NavFrame.Position = UDim2.new(0, 12, 0, 65)
NavFrame.Size = UDim2.new(0, 160, 1, -85)
NavFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
NavFrame.ScrollBarThickness = 2
NavFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
NavFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
NavFrame.BorderSize = 0
NavFrame.ZIndex = 6

local NavCorner = Instance.new("UICorner")
NavCorner.CornerRadius = UDim.new(0, 8)
NavCorner.Parent = NavFrame

local NavList = Instance.new("UIListLayout")
NavList.Parent = NavFrame
NavList.Padding = UDim.new(0, 5)
NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ====================================================================
-- CONTENEUR DE CONTENU
-- ====================================================================

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.Position = UDim2.new(0, 185, 0, 65)
ContentContainer.Size = UDim2.new(1, -200, 1, -85)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 5

-- ====================================================================
-- VARIABLES GLOBALES D'ÉTAT
-- ====================================================================

local currentPanel = nil
local currentNavBtn = nil
local isMinimized = false

-- ====================================================================
-- FONCTIONS D'ANIMATION
-- ====================================================================

local function slideIn(objet, fromX)
    objet.Position = UDim2.new(fromX or 0.3, 0, 0, 0)
    local t = TweenService:Create(objet, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    t:Play()
    return t
end

local function slideOut(objet, toX, callback)
    local t = TweenService:Create(objet, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(toX or 0.3, 0, 0, 0)})
    t:Play()
    if callback then
        t.Completed:Connect(callback)
    end
    return t
end

-- ====================================================================
-- AFFICHAGE DES PAGES MUSIQUE
-- ====================================================================

local function afficherPageMusique(genreName)
    if currentPanel then
        slideOut(currentPanel, 0.3, function()
            currentPanel:Destroy()
            currentPanel = nil
            creerPageMusique(genreName)
        end)
    else
        creerPageMusique(genreName)
    end
end

local function creerPageMusique(genreName)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = ContentContainer
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = ThemeColor
    Scroll.ScrollBarImageTransparency = 0.5
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(#(Playlist[genreName] or {}) * 46, 150))
    Scroll.BorderSize = 0
    Scroll.ZIndex = 5
    currentPanel = Scroll
    
    slideIn(Scroll, 0.3)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = Scroll
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- En-tête de catégorie
    local CatHeader = Instance.new("TextLabel")
    CatHeader.Parent = Scroll
    CatHeader.Size = UDim2.new(1, -10, 0, 34)
    CatHeader.BackgroundTransparency = 1
    CatHeader.Text = genreName
    CatHeader.TextColor3 = ThemeColor
    CatHeader.Font = Enum.Font.Code
    CatHeader.TextSize = 20
    CatHeader.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Liste des musiques
    for _, data in pairs(Playlist[genreName] or {}) do
        local Btn = Instance.new("TextButton")
        Btn.Parent = Scroll
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        Btn.Text = "   ▶  " .. data.Name
        Btn.TextColor3 = Color3.fromRGB(200, 200, 215)
        Btn.Font = Enum.Font.SourceSans
        Btn.TextSize = 15
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.AutoButtonColor = false
        Btn.ZIndex = 5
        
        local bC = Instance.new("UICorner")
        bC.CornerRadius = UDim.new(0, 7)
        bC.Parent = Btn
        
        -- Barre de survol
        local HBar = Instance.new("Frame")
        HBar.Parent = Btn
        HBar.Size = UDim2.new(0, 3, 0, 0)
        HBar.Position = UDim2.new(0, 0, 0.5, 0)
        HBar.BackgroundColor3 = ThemeColor
        HBar.BorderSize = 0
        HBar.Visible = false
        HBar.ZIndex = 6
        
        -- ID label
        local IDLbl = Instance.new("TextLabel")
        IDLbl.Parent = Btn
        IDLbl.Size = UDim2.new(0, 70, 1, 0)
        IDLbl.Position = UDim2.new(1, -75, 0, 0)
        IDLbl.BackgroundTransparency = 1
        IDLbl.Text = "ID: " .. data.ID
        IDLbl.TextColor3 = Color3.fromRGB(90, 90, 110)
        IDLbl.Font = Enum.Font.SourceSansItalic
        IDLbl.TextSize = 11
        IDLbl.TextXAlignment = Enum.TextXAlignment.Right
        IDLbl.ZIndex = 6
        
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 24, 34)}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.1), {TextColor3 = ThemeColor}):Play()
            HBar.Visible = true
            TweenService:Create(HBar, TweenInfo.new(0.12), {Size = UDim2.new(0, 3, 0, 28)}):Play()
            TweenService:Create(HBar, TweenInfo.new(0.12), {Position = UDim2.new(0, 0, 0.5, -14)}):Play()
            TweenService:Create(IDLbl, TweenInfo.new(0.1), {TextColor3 = ThemeColor}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 200, 215)}):Play()
            TweenService:Create(HBar, TweenInfo.new(0.1), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            TweenService:Create(IDLbl, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(90, 90, 110)}):Play()
            task.wait(0.1)
            HBar.Visible = false
        end)
        
        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.05), {BackgroundColor3 = ThemeColor}):Play()
            task.wait(0.05)
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
            appliquerMusique(data.ID, data.Name)
        end)
    end
end

-- ====================================================================
-- MENU CUSTOM ID
-- ====================================================================

local function chargerMenuCustomID()
    if currentPanel then
        slideOut(currentPanel, -0.3, function()
            currentPanel:Destroy()
            currentPanel = nil
            creerPanelCustomID()
        end)
    else
        creerPanelCustomID()
    end
end

local function creerPanelCustomID()
    local Frame = Instance.new("Frame")
    Frame.Parent = ContentContainer
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 5
    currentPanel = Frame
    
    slideIn(Frame, -0.3)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1, -20, 0, 32)
    Title.Position = UDim2.new(0, 10, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "✍️ ID Personnalisé"
    Title.TextColor3 = ThemeColor
    Title.Font = Enum.Font.Code
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Sub = Instance.new("TextLabel")
    Sub.Parent = Frame
    Sub.Size = UDim2.new(1, -20, 0, 18)
    Sub.Position = UDim2.new(0, 10, 0, 42)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Entre un ID de musique Roblox"
    Sub.TextColor3 = Color3.fromRGB(150, 150, 165)
    Sub.Font = Enum.Font.SourceSansLight
    Sub.TextSize = 14
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    
    local Box = Instance.new("TextBox")
    Box.Parent = Frame
    Box.Size = UDim2.new(1, -20, 0, 46)
    Box.Position = UDim2.new(0, 10, 0, 75)
    Box.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Box.PlaceholderText = "Colle ton ID personnalisé ici..."
    Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 100)
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.GothamMedium
    Box.TextSize = 15
    Box.ClearTextOnFocus = false
    Box.ZIndex = 6
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 8)
    BoxCorner.Parent = Box
    
    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(30, 30, 40)
    BoxStroke.Thickness = 1.5
    BoxStroke.Parent = Box
    
    Box.Focused:Connect(function()
        TweenService:Create(Box, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
        TweenService:Create(BoxStroke, TweenInfo.new(0.12), {Color = ThemeColor, Thickness = 2}):Play()
    end)
    Box.FocusLost:Connect(function()
        TweenService:Create(Box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}):Play()
        TweenService:Create(BoxStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(30, 30, 40), Thickness = 1.5}):Play()
    end)
    
    local PlayBtn = Instance.new("TextButton")
    PlayBtn.Parent = Frame
    PlayBtn.Size = UDim2.new(1, -20, 0, 44)
    PlayBtn.Position = UDim2.new(0, 10, 0, 135)
    PlayBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    PlayBtn.Text = "▶  LANCER LA MUSIQUE"
    PlayBtn.TextColor3 = ThemeColor
    PlayBtn.Font = Enum.Font.GothamBold
    PlayBtn.TextSize = 15
    PlayBtn.AutoButtonColor = false
    PlayBtn.ZIndex = 6
    
    local PBCorner = Instance.new("UICorner")
    PBCorner.CornerRadius = UDim.new(0, 8)
    PBCorner.Parent = PlayBtn
    
    local PBStroke = Instance.new("UIStroke")
    PBStroke.Color = ThemeColor
    PBStroke.Thickness = 1.5
    PBStroke.Transparency = 0.6
    PBStroke.Parent = PlayBtn
    
    PlayBtn.MouseEnter:Connect(function()
        TweenService:Create(PlayBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}):Play()
        TweenService:Create(PBStroke, TweenInfo.new(0.12), {Transparency = 0.3}):Play()
    end)
    PlayBtn.MouseLeave:Connect(function()
        TweenService:Create(PlayBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
        TweenService:Create(PBStroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
    end)
    
    PlayBtn.MouseButton1Click:Connect(function()
        local cleanID = Box.Text:gsub("%D", "")
        if cleanID ~= "" then
            TweenService:Create(PlayBtn, TweenInfo.new(0.05), {BackgroundColor3 = ThemeColor}):Play()
            task.wait(0.05)
            TweenService:Create(PlayBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
            appliquerMusique(cleanID, "ID Perso: " .. cleanID)
        end
    end)
    
    -- IDs rapides
    local PresetLbl = Instance.new("TextLabel")
    PresetLbl.Parent = Frame
    PresetLbl.Size = UDim2.new(1, -20, 0, 20)
    PresetLbl.Position = UDim2.new(0, 10, 0, 195)
    PresetLbl.BackgroundTransparency = 1
    PresetLbl.Text = "IDs rapides :"
    PresetLbl.TextColor3 = Color3.fromRGB(130, 130, 145)
    PresetLbl.Font = Enum.Font.SourceSansItalic
    PresetLbl.TextSize = 13
    PresetLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local presets = {
        {"🎵 Phonk", "18350972567"},
        {"🎵 Nightcore", "18401234567"},
        {"🎵 Lofi", "9123456789"},
        {"🎵 Jazz", "18411234567"}
    }
    
    local yOff = 220
    local idx = 0
    for _, p in ipairs(presets) do
        local PBtn = Instance.new("TextButton")
        PBtn.Parent = Frame
        
        if idx % 2 == 0 then
            PBtn.Size = UDim2.new(0.46, 0, 0, 32)
            PBtn.Position = UDim2.new(0, 10, 0, yOff)
        else
            PBtn.Size = UDim2.new(0.46, 0, 0, 32)
            PBtn.Position = UDim2.new(0.5, 5, 0, yOff)
            yOff = yOff + 38
        end
        
        PBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
        PBtn.Text = p[1]
        PBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
        PBtn.Font = Enum.Font.SourceSans
        PBtn.TextSize = 13
        PBtn.AutoButtonColor = false
        PBtn.ZIndex = 6
        
        local PC = Instance.new("UICorner")
        PC.CornerRadius = UDim.new(0, 6)
        PC.Parent = PBtn
        
        PBtn.MouseEnter:Connect(function()
            TweenService:Create(PBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        end)
        PBtn.MouseLeave:Connect(function()
            TweenService:Create(PBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 14, 20)}):Play()
        end)
        PBtn.MouseButton1Click:Connect(function()
            Box.Text = p[2]
            appliquerMusique(p[2], p[1])
        end)
        
        idx = idx + 1
    end
end

-- ====================================================================
-- MENU PALETTE UI (THÈME)
-- ====================================================================

local function chargerMenuTheme()
    if currentPanel then
        slideOut(currentPanel, 0.3, function()
            currentPanel:Destroy()
            currentPanel = nil
            creerPanelTheme()
        end)
    else
        creerPanelTheme()
    end
end

local function creerPanelTheme()
    local Frame = Instance.new("Frame")
    Frame.Parent = ContentContainer
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 5
    currentPanel = Frame
    
    slideIn(Frame, 0.3)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1, -20, 0, 32)
    Title.Position = UDim2.new(0, 10, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "🎨 Palette de Couleurs"
    Title.TextColor3 = ThemeColor
    Title.Font = Enum.Font.Code
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Sub = Instance.new("TextLabel")
    Sub.Parent = Frame
    Sub.Size = UDim2.new(1, -20, 0, 18)
    Sub.Position = UDim2.new(0, 10, 0, 42)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Personnalise l'apparence de ton hub"
    Sub.TextColor3 = Color3.fromRGB(150, 150, 165)
    Sub.Font = Enum.Font.SourceSansLight
    Sub.TextSize = 14
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    
    local Couleurs = {
        {"Bleu Néon", Color3.fromRGB(0, 210, 255)},
        {"Rouge Impérial", Color3.fromRGB(255, 60, 60)},
        {"Vert Toxique", Color3.fromRGB(60, 255, 110)},
        {"Rose Fuchsia", Color3.fromRGB(255, 20, 160)},
        {"Jaune Éclair", Color3.fromRGB(255, 215, 0)},
        {"Orange Magma", Color3.fromRGB(255, 120, 20)},
        {"Violet Mystic", Color3.fromRGB(150, 50, 255)},
        {"Bleu Nuit", Color3.fromRGB(50, 100, 255)}
    }
    
    local offset = 70
    local colIdx = 0
    local maxPerRow = 2
    
    for _, data in ipairs(Couleurs) do
        local name = data[1]
        local color = data[2]
        
        local CBtn = Instance.new("TextButton")
        CBtn.Parent = Frame
        
        if colIdx % maxPerRow == 0 then
            CBtn.Size = UDim2.new(0.46, 0, 0, 40)
            CBtn.Position = UDim2.new(0, 10, 0, offset)
        else
            CBtn.Size = UDim2.new(0.46, 0, 0, 40)
            CBtn.Position = UDim2.new(0.5, 5, 0, offset)
            offset = offset + 46
        end
        
        CBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        CBtn.Text = "   " .. name
        CBtn.TextColor3 = color
        CBtn.Font = Enum.Font.GothamMedium
        CBtn.TextSize = 14
        CBtn.TextXAlignment = Enum.TextXAlignment.Left
        CBtn.AutoButtonColor = false
        CBtn.ZIndex = 6
        CBtn.ClipsDescendants = true
        
        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 8)
        CC.Parent = CBtn
        
        -- Petit cercle de couleur
        local Dot = Instance.new("Frame")
        Dot.Parent = CBtn
        Dot.Size = UDim2.new(0, 14, 0, 14)
        Dot.Position = UDim2.new(0, 8, 0.5, -7)
        Dot.BackgroundColor3 = color
        Dot.ZIndex = 7
        
        local DotC = Instance.new("UICorner")
        DotC.CornerRadius = UDim.new(1, 0)
        DotC.Parent = Dot
        
        local DotS = Instance.new("UIStroke")
        DotS.Color = color
        DotS.Thickness = 2
        DotS.Transparency = 0.5
        DotS.Parent = Dot
        
        CBtn.MouseEnter:Connect(function()
            TweenService:Create(CBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 24, 34)}):Play()
        end)
        CBtn.MouseLeave:Connect(function()
            TweenService:Create(CBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}):Play()
        end)
        
        CBtn.MouseButton1Click:Connect(function()
            ThemeColor = color
            MainStroke.Color = color
            TitleLabel.TextColor3 = color
            IconStroke.Color = color
            
            -- Mise à jour du gradient du stroke
            MainStrokeGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(0.5, AccentColor), ColorSequenceKeypoint.new(1, color)})
            
            -- Feedback flash
            TweenService:Create(CBtn, TweenInfo.new(0.06), {BackgroundColor3 = color}):Play()
            task.wait(0.06)
            TweenService:Create(CBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}):Play()
        end)
        
        colIdx = colIdx + 1
    end
end

-- ====================================================================
-- CRÉATION DES BOUTONS DE NAVIGATION
-- ====================================================================

local function creerBoutonNav(texte, couleur, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = NavFrame
    Btn.Size = UDim2.new(1, -8, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Btn.Text = "  " .. texte
    Btn.TextColor3 = couleur or Color3.fromRGB(160, 160, 175)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.ZIndex = 7
    
    local NC = Instance.new("UICorner")
    NC.CornerRadius = UDim.new(0, 7)
    NC.Parent = Btn
    
    -- Barre active
    local ABar = Instance.new("Frame")
    ABar.Parent = Btn
    ABar.Size = UDim2.new(0, 3, 0, 0)
    ABar.Position = UDim2.new(0, 0, 0.5, 0)
    ABar.BackgroundColor3 = ThemeColor
    ABar.BorderSize = 0
    ABar.Visible = false
    ABar.ZIndex = 8
    
    Btn.MouseEnter:Connect(function()
        if Btn ~= currentNavBtn then
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 24, 34)}):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if Btn ~= currentNavBtn then
            TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
        end
    end)
    
    Btn.MouseButton1Click:Connect(function()
        -- Reset ancien bouton
        if currentNavBtn and currentNavBtn ~= Btn then
            TweenService:Create(currentNavBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
            local oldBar = currentNavBtn:FindFirstChild("ABar")
            if oldBar then
                oldBar.Visible = false
                oldBar.Size = UDim2.new(0, 3, 0, 0)
            end
        end
        
        currentNavBtn = Btn
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        ABar.Visible = true
        TweenService:Create(ABar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 26)}):Play()
        TweenService:Create(ABar, TweenInfo.new(0.15), {Position = UDim2.new(0, 0, 0.5, -13)}):Play()
        
        if callback then callback() end
    end)
    
    return Btn
end

-- Création des boutons pour chaque genre
for genreName, _ in pairs(Playlist) do
    creerBoutonNav(genreName, Color3.fromRGB(160, 160, 175), function()
        afficherPageMusique(genreName)
    end)
end

-- Bouton Custom ID
creerBoutonNav("✍️ Custom ID", Color3.fromRGB(255, 190, 80), chargerMenuCustomID)

-- Bouton Palette
creerBoutonNav("🎨 Palette UI", Color3.fromRGB(90, 255, 140), chargerMenuTheme)

-- ====================================================================
-- SYSTÈME MINIMIZE / TOGGLE
-- ====================================================================

MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = ToggleIcon.Position
    }):Play()
    
    task.wait(0.3)
    MainFrame.Visible = false
    ToggleIcon.Visible = true
    ToggleIcon.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 60, 0, 60)
    }):Play()
end)

ToggleIcon.MouseButton1Click:Connect(function()
    ToggleIcon.Visible = false
    MainFrame.Position = ToggleIcon.Position
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = true
    
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 680, 0, 450),
        Position = UDim2.new(0.3, 0, 0.25, 0)
    }):Play()
    
    task.wait(0.35)
    isMinimized = false
end)

-- ====================================================================
-- LANCEMENT INITIAL
-- ====================================================================

-- Ouvrir la première page
local firstGenre = Playlist["Afro Ori Fiesta"] and "Afro Ori Fiesta" or next(Playlist)
if firstGenre then
    creerPageMusique(firstGenre)
    -- Activer visuellement le premier bouton
    local firstBtn = NavFrame:FindFirstChildOfClass("TextButton")
    if firstBtn then
        currentNavBtn = firstBtn
        TweenService:Create(firstBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        local ab = firstBtn:FindFirstChild("ABar")
        if ab then
            ab.Visible = true
            ab.Size = UDim2.new(0, 3, 0, 26)
            ab.Position = UDim2.new(0, 0, 0.5, -13)
        end
    end
end

-- Nettoyage si le GUI est détruit
ScreenGui.Destroying:Connect(function()
    -- Les RenderStepped loops s'arrêtent avec le parent
end)
