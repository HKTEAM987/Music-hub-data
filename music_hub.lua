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
