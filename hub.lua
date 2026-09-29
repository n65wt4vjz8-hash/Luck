--[[
    J.A.R.V.I.S. FULL HUB v4.0
    機能: FLY / SPEED / JUMP / NOCLIP / INF JUMP / FULLBRIGHT / NO FOG
         / ESP / Player TP / Mini-map / FPS-MS / JARVIS Decorations
]]

print("[JARVIS] 起動中...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

-- ============================================================
-- カラーパレット
-- ============================================================
local CY = Color3.fromRGB(0, 220, 255)
local CY2 = Color3.fromRGB(0, 150, 220)
local CY3 = Color3.fromRGB(0, 80, 140)
local CY4 = Color3.fromRGB(0, 40, 80)
local BG = Color3.fromRGB(0, 8, 20)
local BG2 = Color3.fromRGB(0, 15, 35)
local BG3 = Color3.fromRGB(0, 25, 50)
local WH = Color3.fromRGB(220, 245, 255)
local RD = Color3.fromRGB(255, 80, 80)
local GN = Color3.fromRGB(80, 255, 150)
local YL = Color3.fromRGB(255, 200, 0)
local PR = Color3.fromRGB(180, 80, 255)

-- ============================================================
-- 状態管理
-- ============================================================
local F = {
    fly = false,
    speed = false,
    jump = false,
    bright = false,
    noclip = false,
    esp = false,
    infjump = false,
    nofog = false,
}

local speedValue = 50
local jumpValue = 100
local flySpeed = 80

local origLight = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
}

print("[JARVIS] 状態OK")

-- ============================================================
-- ヘルパー
-- ============================================================
local function cnr(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
    return c
end

local function strk(o, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = t or 1
    s.Transparency = tr or 0.3
    s.Parent = o
    return s
end

local function grad(o, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = o
    return g
end

local function clk(b, cb)
    local last = 0
    local function go()
        local n = tick()
        if n - last < 0.2 then return end
        last = n
        cb()
    end
    b.MouseButton1Click:Connect(go)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then go() end
    end)
end

local function mkDrag(handle, panel)
    local dragging, dI, dS, sP = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dS = i.Position
            sP = panel.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dI = i
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dI and dragging then
            local d = i.Position - dS
            panel.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================
-- FLY
-- ============================================================
local flyBV, flyBG, flyC

local function startFly()
    local c = plr.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    local u = c:FindFirstChildOfClass("Humanoid")
    if not h or not u then return end
    u.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = h
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.CFrame = h.CFrame
    flyBG.Parent = h
    flyC = RunService.RenderStepped:Connect(function()
        if not F.fly or not h.Parent then return end
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = d.Magnitude > 0 and (d.Unit * flySpeed) or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyC then flyC:Disconnect() flyC = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local c = plr.Character
    if c then
        local u = c:FindFirstChildOfClass("Humanoid")
        if u then u.PlatformStand = false end
    end
end

-- ============================================================
-- SPEED / JUMP
-- ============================================================
local function applySpeed()
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u.WalkSpeed = F.speed and speedValue or 16 end
end

local function applyJump()
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u.JumpPower = F.jump and jumpValue or 50 end
end

-- ============================================================
-- BRIGHT / NO FOG
-- ============================================================
local function applyBright()
    if F.bright then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = origLight.Ambient
        Lighting.OutdoorAmbient = origLight.OutdoorAmbient
        Lighting.Brightness = origLight.Brightness
    end
end

local function applyNoFog()
    if F.nofog then
        Lighting.FogStart = math.huge
        Lighting.FogEnd = math.huge
    else
        Lighting.FogStart = origLight.FogStart
        Lighting.FogEnd = origLight.FogEnd
        Lighting.FogColor = origLight.FogColor
    end
end

-- ============================================================
-- NOCLIP
-- ============================================================
local ncC
local function startNoclip()
    if ncC then return end
    ncC = RunService.Stepped:Connect(function()
        if not F.noclip then return end
        local c = plr.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

-- ============================================================
-- INF JUMP
-- ============================================================
UIS.JumpRequest:Connect(function()
    if not F.infjump then return end
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ============================================================
-- ESP
-- ============================================================
local espData = {}

local function createESP(target)
    if target == plr then return end
    if espData[target] then return end
    local c = target.Character
    if not c then return end
    local head = c:FindFirstChild("Head")
    if not head then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = CY
    hl.OutlineColor = WH
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = c
    hl.Parent = c

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 180, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = BG
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = bb
    cnr(frame, 4)

    local frameStroke = strk(frame, CY, 1, 0.2)

    -- 4隅の装飾
    local function corner(x, y, rx, ry)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(0, 8, 0, 8)
        c.Position = UDim2.new(x, 0, y, 0)
        c.BackgroundTransparency = 1
        c.Parent = frame
        local h = Instance.new("Frame")
        h.Size = UDim2.new(1, 0, 0, 1)
        h.Position = UDim2.new(0, 0, ry, 0)
        h.BackgroundColor3 = CY
        h.BorderSizePixel = 0
        h.Parent = c
        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 1, 1, 0)
        v.Position = UDim2.new(rx, 0, 0, 0)
        v.BackgroundColor3 = CY
        v.BorderSizePixel = 0
        v.Parent = c
    end
    corner(0, 0, 0, 0)
    corner(1, 0, 1, 0)
    corner(0, 1, 0, 1)
    corner(1, 1, 1, 1)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 16)
    nameLbl.Position = UDim2.new(0, 4, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "◤ " .. string.upper(target.DisplayName)
    nameLbl.TextColor3 = WH
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3 = BG
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, -8, 0, 12)
    distLbl.Position = UDim2.new(0, 4, 0, 22)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "DIST: 0m"
    distLbl.TextColor3 = CY
    distLbl.TextSize = 10
    distLbl.Font = Enum.Font.Code
    distLbl.TextStrokeTransparency = 0
    distLbl.TextStrokeColor3 = BG
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = frame

    -- HPバー
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, -8, 0, 4)
    hpBg.Position = UDim2.new(0, 4, 1, -8)
    hpBg.BackgroundColor3 = BG
    hpBg.BorderSizePixel = 0
    hpBg.Parent = frame
    cnr(hpBg, 2)
    strk(hpBg, CY3, 1, 0.4)

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = GN
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    cnr(hpFill, 2)

    local conn = RunService.Heartbeat:Connect(function()
        if not target.Parent then
            conn:Disconnect()
            return
        end
        if not F.esp then return end
        local tc = target.Character
        if not tc then return end
        local th = tc:FindFirstChild("HumanoidRootPart")
        if not th then return end
        local mc = plr.Character
        if not mc then return end
        local mh = mc:FindFirstChild("HumanoidRootPart")
        if not mh then return end

        local dist = (th.Position - mh.Position).Magnitude
        distLbl.Text = string.format("DIST: %dm", math.floor(dist))

        if dist < 30 then
            hl.FillColor = RD
            hl.OutlineColor = RD
            frameStroke.Color = RD
            distLbl.TextColor3 = RD
        elseif dist < 100 then
            hl.FillColor = YL
            hl.OutlineColor = YL
            frameStroke.Color = YL
            distLbl.TextColor3 = YL
        else
            hl.FillColor = CY
            hl.OutlineColor = WH
            frameStroke.Color = CY
            distLbl.TextColor3 = CY
        end

        local hum = tc:FindFirstChildOfClass("Humanoid")
        if hum then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            if ratio > 0.6 then
                hpFill.BackgroundColor3 = GN
            elseif ratio > 0.3 then
                hpFill.BackgroundColor3 = YL
            else
                hpFill.BackgroundColor3 = RD
            end
        end
    end)

    espData[target] = {hl = hl, bb = bb, conn = conn}
end

local function removeESP(target)
    if espData[target] then
        local d = espData[target]
        if d.hl and d.hl.Parent then d.hl:Destroy() end
        if d.bb and d.bb.Parent then d.bb:Destroy() end
        if d.conn then d.conn:Disconnect() end
        espData[target] = nil
    end
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            if F.esp then
                createESP(p)
            else
                removeESP(p)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    if F.esp and p ~= plr then createESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

-- ============================================================
-- リスポーン対応
-- ============================================================
plr.CharacterAdded:Connect(function()
    task.wait(1)
    if F.speed then applySpeed() end
    if F.jump then applyJump() end
    if F.fly then stopFly() F.fly = false end
    if F.noclip then startNoclip() end
    if F.esp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then
                task.wait(0.2)
                removeESP(p)
                createESP(p)
            end
        end
    end
end)

print("[JARVIS] 機能実装完了")

-- ============================================================
-- GUI ルート
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "JarvisFullHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

-- ============================================================
-- ★ 画面全体のJARVIS装飾
-- ============================================================
local decorGui = Instance.new("ScreenGui")
decorGui.Name = "JarvisDecor"
decorGui.ResetOnSpawn = false
decorGui.IgnoreGuiInset = true
decorGui.DisplayOrder = 400
decorGui.Parent = PlayerGui

-- 1. 走査線（薄い横線）
task.spawn(function()
    task.wait(0.2)
    for y = 0, 1080, 5 do
        local l = Instance.new("Frame")
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundColor3 = CY
        l.BackgroundTransparency = 0.96
        l.BorderSizePixel = 0
        l.ZIndex = 1
        l.Parent = decorGui
    end
end)

-- 2. 四隅のL字コーナーブラケット
local function cornerBracket(x, y, fx, fy, sz)
    sz = sz or 60
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, sz, 0, sz)
    b.Position = UDim2.new(x, 0, y, 0)
    b.BackgroundTransparency = 1
    b.ZIndex = 2
    b.Parent = decorGui

    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 2)
    h.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    h.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    h.BackgroundColor3 = CY
    h.BackgroundTransparency = 0.2
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = b

    local v = Instance.new("Frame")
    v.Size = UDim2.new(0, 2, 1, 0)
    v.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    v.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    v.BackgroundColor3 = CY
    v.BackgroundTransparency = 0.2
    v.BorderSizePixel = 0
    v.ZIndex = 2
    v.Parent = b

    -- 内側の小さいコーナー
    local b2 = Instance.new("Frame")
    b2.Size = UDim2.new(0, sz * 0.6, 0, sz * 0.6)
    b2.Position = UDim2.new(x, 0, y, 0)
    b2.BackgroundTransparency = 1
    b2.ZIndex = 2
    b2.Parent = decorGui

    local h2 = Instance.new("Frame")
    h2.Size = UDim2.new(1, 0, 0, 1)
    h2.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    h2.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    h2.BackgroundColor3 = CY
    h2.BackgroundTransparency = 0.5
    h2.BorderSizePixel = 0
    h2.ZIndex = 2
    h2.Parent = b2

    local v2 = Instance.new("Frame")
    v2.Size = UDim2.new(0, 1, 1, 0)
    v2.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    v2.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    v2.BackgroundColor3 = CY
    v2.BackgroundTransparency = 0.5
    v2.BorderSizePixel = 0
    v2.ZIndex = 2
    v2.Parent = b2
end
cornerBracket(0, 0, false, false)
cornerBracket(1, 0, true, false)
cornerBracket(0, 1, false, true)
cornerBracket(1, 1, true, true)

-- 3. 中央クロスヘア
local ch = Instance.new("Frame")
ch.Size = UDim2.new(0, 100, 0, 100)
ch.Position = UDim2.new(0.5, -50, 0.5, -50)
ch.BackgroundTransparency = 1
ch.ZIndex = 2
ch.Parent = decorGui

local chRing = Instance.new("Frame")
chRing.Size = UDim2.new(0, 34, 0, 34)
chRing.Position = UDim2.new(0.5, -17, 0.5, -17)
chRing.BackgroundTransparency = 1
chRing.ZIndex = 2
chRing.Parent = ch
cnr(chRing, 17)
strk(chRing, CY, 1, 0.4)

local chRing2 = Instance.new("Frame")
chRing2.Size = UDim2.new(0, 50, 0, 50)
chRing2.Position = UDim2.new(0.5, -25, 0.5, -25)
chRing2.BackgroundTransparency = 1
chRing2.ZIndex = 2
chRing2.Parent = ch
cnr(chRing2, 25)
local chRing2Stroke = strk(chRing2, CY3, 1, 0.6)

local chDot = Instance.new("Frame")
chDot.Size = UDim2.new(0, 4, 0, 4)
chDot.Position = UDim2.new(0.5, -2, 0.5, -2)
chDot.BackgroundColor3 = CY
chDot.BorderSizePixel = 0
chDot.ZIndex = 3
chDot.Parent = ch
cnr(chDot, 2)

local function chLine(sz, pos)
    local l = Instance.new("Frame")
    l.Size = sz
    l.Position = pos
    l.BackgroundColor3 = CY
    l.BackgroundTransparency = 0.4
    l.BorderSizePixel = 0
    l.ZIndex = 2
    l.Parent = ch
end
chLine(UDim2.new(0, 12, 0, 1), UDim2.new(0.5, -6, 0, 6))
chLine(UDim2.new(0, 12, 0, 1), UDim2.new(0.5, -6, 1, -7))
chLine(UDim2.new(0, 1, 0, 12), UDim2.new(0, 6, 0.5, -6))
chLine(UDim2.new(0, 1, 0, 12), UDim2.new(1, -7, 0.5, -6))

-- 4. 上下の装飾バー
local topBarBg = Instance.new("Frame")
topBarBg.Size = UDim2.new(0.35, 0, 0, 20)
topBarBg.Position = UDim2.new(0.325, 0, 0, 0)
topBarBg.BackgroundTransparency = 1
topBarBg.ZIndex = 2
topBarBg.Parent = decorGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 2)
topBar.Position = UDim2.new(0, 0, 0, 12)
topBar.BackgroundColor3 = CY
topBar.BackgroundTransparency = 0.4
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = topBarBg

local topBar2 = Instance.new("Frame")
topBar2.Size = UDim2.new(0.5, 0, 0, 1)
topBar2.Position = UDim2.new(0.25, 0, 0, 16)
topBar2.BackgroundColor3 = CY3
topBar2.BackgroundTransparency = 0.6
topBar2.BorderSizePixel = 0
topBar2.ZIndex = 2
topBar2.Parent = topBarBg

local botBarBg = Instance.new("Frame")
botBarBg.Size = UDim2.new(0.35, 0, 0, 20)
botBarBg.Position = UDim2.new(0.325, 0, 1, -20)
botBarBg.BackgroundTransparency = 1
botBarBg.ZIndex = 2
botBarBg.Parent = decorGui

local botBar = Instance.new("Frame")
botBar.Size = UDim2.new(1, 0, 0, 2)
botBar.Position = UDim2.new(0, 0, 1, -14)
botBar.BackgroundColor3 = CY
botBar.BackgroundTransparency = 0.4
botBar.BorderSizePixel = 0
botBar.ZIndex = 2
botBar.Parent = botBarBg

-- 5. 左右の細いバー
local leftBar = Instance.new("Frame")
leftBar.Size = UDim2.new(0, 2, 0.2, 0)
leftBar.Position = UDim2.new(0, 12, 0.4, 0)
leftBar.BackgroundColor3 = CY
leftBar.BackgroundTransparency = 0.5
leftBar.BorderSizePixel = 0
leftBar.ZIndex = 2
leftBar.Parent = decorGui

local leftBar2 = Instance.new("Frame")
leftBar2.Size = UDim2.new(0, 1, 0.1, 0)
leftBar2.Position = UDim2.new(0, 16, 0.45, 0)
leftBar2.BackgroundColor3 = CY3
leftBar2.BackgroundTransparency = 0.6
leftBar2.BorderSizePixel = 0
leftBar2.ZIndex = 2
leftBar2.Parent = decorGui

local rightBar = Instance.new("Frame")
rightBar.Size = UDim2.new(0, 2, 0.2, 0)
rightBar.Position = UDim2.new(1, -14, 0.4, 0)
rightBar.BackgroundColor3 = CY
rightBar.BackgroundTransparency = 0.5
rightBar.BorderSizePixel = 0
rightBar.ZIndex = 2
rightBar.Parent = decorGui

local rightBar2 = Instance.new("Frame")
rightBar2.Size = UDim2.new(0, 1, 0.1, 0)
rightBar2.Position = UDim2.new(1, -17, 0.45, 0)
rightBar2.BackgroundColor3 = CY3
rightBar2.BackgroundTransparency = 0.6
rightBar2.BorderSizePixel = 0
rightBar2.ZIndex = 2
rightBar2.Parent = decorGui

-- 6. 上部左右のテキスト
local decoText1 = Instance.new("TextLabel")
decoText1.Size = UDim2.new(0, 400, 0, 14)
decoText1.Position = UDim2.new(0, 62, 0, 5)
decoText1.BackgroundTransparency = 1
decoText1.Text = "J.A.R.V.I.S. // ONLINE"
decoText1.TextColor3 = CY
decoText1.TextSize = 9
decoText1.Font = Enum.Font.Code
decoText1.TextTransparency = 0.3
decoText1.TextXAlignment = Enum.TextXAlignment.Left
decoText1.ZIndex = 3
decoText1.Parent = decorGui

local decoText2 = Instance.new("TextLabel")
decoText2.Size = UDim2.new(0, 400, 0, 14)
decoText2.Position = UDim2.new(1, -462, 0, 5)
decoText2.BackgroundTransparency = 1
decoText2.Text = "STARK INDUSTRIES // MARK VII"
decoText2.TextColor3 = CY
decoText2.TextSize = 9
decoText2.Font = Enum.Font.Code
decoText2.TextTransparency = 0.3
decoText2.TextXAlignment = Enum.TextXAlignment.Right
decoText2.ZIndex = 3
decoText2.Parent = decorGui

-- 7. 下部テキスト
local decoText3 = Instance.new("TextLabel")
decoText3.Size = UDim2.new(0, 400, 0, 14)
decoText3.Position = UDim2.new(0, 62, 1, -22)
decoText3.BackgroundTransparency = 1
decoText3.Text = "PWR: 98%  //  SYS: OK"
decoText3.TextColor3 = CY
decoText3.TextSize = 9
decoText3.Font = Enum.Font.Code
decoText3.TextTransparency = 0.3
decoText3.TextXAlignment = Enum.TextXAlignment.Left
decoText3.ZIndex = 3
decoText3.Parent = decorGui

local decoText4 = Instance.new("TextLabel")
decoText4.Size = UDim2.new(0, 400, 0, 14)
decoText4.Position = UDim2.new(1, -462, 1, -22)
decoText4.BackgroundTransparency = 1
decoText4.Text = "© 2026 STARK INDUSTRIES"
decoText4.TextColor3 = CY
decoText4.TextSize = 9
decoText4.Font = Enum.Font.Code
decoText4.TextTransparency = 0.3
decoText4.TextXAlignment = Enum.TextXAlignment.Right
decoText4.ZIndex = 3
decoText4.Parent = decorGui

-- 8. 点滅するインジケータ（左下）
local indicators = {}
for i = 1, 8 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 62 + (i-1) * 12, 1, -36)
    dot.BackgroundColor3 = CY
    dot.BackgroundTransparency = 0.3
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = decorGui
    cnr(dot, 2)
    table.insert(indicators, dot)
end

task.spawn(function()
    while decorGui.Parent do
        for i, dot in ipairs(indicators) do
            dot.BackgroundTransparency = 0
            task.wait(0.08)
            dot.BackgroundTransparency = 0.85
        end
        task.wait(0.6)
    end
end)

-- 9. 点滅する大インジケータ（左上）
local blinkBig = Instance.new("Frame")
blinkBig.Size = UDim2.new(0, 8, 0, 8)
blinkBig.Position = UDim2.new(0, 48, 0, 8)
blinkBig.BackgroundColor3 = GN
blinkBig.BorderSizePixel = 0
blinkBig.ZIndex = 3
blinkBig.Parent = decorGui
cnr(blinkBig, 4)

task.spawn(function()
    while decorGui.Parent do
        blinkBig.BackgroundTransparency = 0
        task.wait(0.6)
        blinkBig.BackgroundTransparency = 0.85
        task.wait(0.6)
    end
end)

-- 10. 走査線が動くエフェクト
local movingLine = Instance.new("Frame")
movingLine.Size = UDim2.new(1, 0, 0, 2)
movingLine.Position = UDim2.new(0, 0, 0, 0)
movingLine.BackgroundColor3 = CY
movingLine.BackgroundTransparency = 0.7
movingLine.BorderSizePixel = 0
movingLine.ZIndex = 3
movingLine.Parent = decorGui

task.spawn(function()
    while decorGui.Parent do
        local t = 0
        while t < 1 do
            t = t + 0.01
            movingLine.Position = UDim2.new(0, 0, t, 0)
            task.wait(0.02)
        end
    end
end)

-- 11. 中央下の追加装飾（扇形風）
local fanBg = Instance.new("Frame")
fanBg.Size = UDim2.new(0, 200, 0, 40)
fanBg.Position = UDim2.new(0.5, -100, 1, -70)
fanBg.BackgroundTransparency = 1
fanBg.ZIndex = 2
fanBg.Parent = decorGui

for i = 1, 7 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 1, 0)
    line.Position = UDim2.new((i-1) / 6, 0, 0, 0)
    line.BackgroundColor3 = CY
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0
    line.ZIndex = 2
    line.Parent = fanBg
end

local fanArc = Instance.new("Frame")
fanArc.Size = UDim2.new(1, 0, 0, 1)
fanArc.Position = UDim2.new(0, 0, 0, 0)
fanArc.BackgroundColor3 = CY
fanArc.BackgroundTransparency = 0.4
fanArc.BorderSizePixel = 0
fanArc.ZIndex = 2
fanArc.Parent = fanBg

-- 中央のテキスト
local centerLabel = Instance.new("TextLabel")
centerLabel.Size = UDim2.new(1, 0, 0, 16)
centerLabel.Position = UDim2.new(0, 0, 0.5, -8)
centerLabel.BackgroundTransparency = 1
centerLabel.Text = "J A R V I S"
centerLabel.TextColor3 = CY
centerLabel.TextSize = 10
centerLabel.Font = Enum.Font.Code
centerLabel.TextTransparency = 0.4
centerLabel.ZIndex = 3
centerLabel.Parent = fanBg

print("[JARVIS] 装飾完了")

-- ============================================================
-- 上部 FPS/ms パネル
-- ============================================================
local fpsPanel = Instance.new("Frame")
fpsPanel.Size = UDim2.new(0, 220, 0, 28)
fpsPanel.Position = UDim2.new(0.5, -110, 0, 22)
fpsPanel.BackgroundColor3 = BG
fpsPanel.BackgroundTransparency = 0.2
fpsPanel.BorderSizePixel = 0
fpsPanel.ZIndex = 10
fpsPanel.Parent = gui
cnr(fpsPanel, 6)
strk(fpsPanel, CY, 1.5, 0.3)
grad(fpsPanel, BG2, BG, 90)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, -10, 1, 0)
fpsLabel.Position = UDim2.new(0, 5, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = CY
fpsLabel.TextSize = 11
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.ZIndex = 11
fpsLabel.Parent = fpsPanel

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(0.5, -10, 1, 0)
msLabel.Position = UDim2.new(0.5, 5, 0, 0)
msLabel.BackgroundTransparency = 1
msLabel.Text = "MS: 16.7"
msLabel.TextColor3 = WH
msLabel.TextSize = 11
msLabel.Font = Enum.Font.Code
msLabel.TextXAlignment = Enum.TextXAlignment.Center
msLabel.ZIndex = 11
msLabel.Parent = fpsPanel

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -8)
divider.Position = UDim2.new(0.5, 0, 0, 4)
divider.BackgroundColor3 = CY3
divider.BorderSizePixel = 0
divider.ZIndex = 11
divider.Parent = fpsPanel

local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fpsValue = math.floor(frameCount / fpsTimer)
        msValue = (fpsTimer / frameCount) * 1000
        frameCount = 0
        fpsTimer = 0

        fpsLabel.Text = "FPS: " .. fpsValue
        msLabel.Text = string.format("MS: %.1f", msValue)

        if fpsValue < 30 then
            fpsLabel.TextColor3 = RD
        elseif fpsValue < 50 then
            fpsLabel.TextColor3 = YL
        else
            fpsLabel.TextColor3 = CY
        end

        if msValue > 30 then
            msLabel.TextColor3 = RD
        elseif msValue > 20 then
            msLabel.TextColor3 = YL
        else
            msLabel.TextColor3 = WH
        end
    end
end)

-- ============================================================
-- 左上 HUB
-- ============================================================
local hub = Instance.new("Frame")
hub.Size = UDim2.new(0, 220, 0, 360)
hub.Position = UDim2.new(0, 12, 0, 60)
hub.BackgroundColor3 = BG
hub.BackgroundTransparency = 0.1
hub.BorderSizePixel = 0
hub.ZIndex = 10
hub.Parent = gui
cnr(hub, 6)
strk(hub, CY, 1.5, 0.3)
grad(hub, BG2, BG, 90)

local hubHeader = Instance.new("Frame")
hubHeader.Size = UDim2.new(1, 0, 0, 26)
hubHeader.BackgroundColor3 = BG3
hubHeader.BackgroundTransparency = 0.2
hubHeader.BorderSizePixel = 0
hubHeader.ZIndex = 11
hubHeader.Parent = hub
cnr(hubHeader, 6)

local hubLine = Instance.new("Frame")
hubLine.Size = UDim2.new(1, 0, 0, 1)
hubLine.Position = UDim2.new(0, 0, 1, -1)
hubLine.BackgroundColor3 = CY
hubLine.BorderSizePixel = 0
hubLine.ZIndex = 12
hubLine.Parent = hubHeader

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -50, 1, 0)
hubTitle.Position = UDim2.new(0, 10, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "◈ J.A.R.V.I.S. HUB"
hubTitle.TextColor3 = CY
hubTitle.TextSize = 11
hubTitle.Font = Enum.Font.Code
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.ZIndex = 12
hubTitle.Parent = hubHeader

-- 状態インジケータ（ヘッダー内）
local hubStatus = Instance.new("Frame")
hubStatus.Size = UDim2.new(0, 5, 0, 5)
hubStatus.Position = UDim2.new(1, -46, 0.5, -2.5)
hubStatus.BackgroundColor3 = GN
hubStatus.BorderSizePixel = 0
hubStatus.ZIndex = 12
hubStatus.Parent = hubHeader
cnr(hubStatus, 2.5)

task.spawn(function()
    while gui.Parent do
        hubStatus.BackgroundTransparency = 0
        task.wait(0.6)
        hubStatus.BackgroundTransparency = 0.7
        task.wait(0.6)
    end
end)

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 20, 0, 20)
collapseBtn.Position = UDim2.new(1, -24, 0.5, -10)
collapseBtn.BackgroundColor3 = CY
collapseBtn.BackgroundTransparency = 0.5
collapseBtn.Text = "−"
collapseBtn.TextColor3 = WH
collapseBtn.TextSize = 12
collapseBtn.Font = Enum.Font.Code
collapseBtn.BorderSizePixel = 0
collapseBtn.AutoButtonColor = false
collapseBtn.ZIndex = 12
collapseBtn.Parent = hubHeader
cnr(collapseBtn, 10)

local hubBody = Instance.new("Frame")
hubBody.Size = UDim2.new(1, -16, 1, -36)
hubBody.Position = UDim2.new(0, 8, 0, 30)
hubBody.BackgroundTransparency = 1
hubBody.ZIndex = 11
hubBody.Parent = hub

local hubScroll = Instance.new("ScrollingFrame")
hubScroll.Size = UDim2.new(1, 0, 1, 0)
hubScroll.BackgroundTransparency = 1
hubScroll.BorderSizePixel = 0
hubScroll.ScrollBarThickness = 2
hubScroll.ScrollBarImageColor3 = CY
hubScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
hubScroll.ZIndex = 11
hubScroll.Parent = hubBody

local hubLayout = Instance.new("UIListLayout")
hubLayout.Padding = UDim.new(0, 4)
hubLayout.Parent = hubScroll
hubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    hubScroll.CanvasSize = UDim2.new(0, 0, 0, hubLayout.AbsoluteContentSize.Y + 5)
end)

-- トグルボタン生成
local function mkToggle(text, yPos, key, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 26)
    b.Position = UDim2.new(0, 2, 0, yPos)
    b.BackgroundColor3 = BG2
    b.BackgroundTransparency = 0.3
    b.Text = "  ◈ " .. text
    b.TextColor3 = CY
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 0
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 12
    b.Parent = hubScroll
    cnr(b, 3)
    local st = strk(b, CY3, 1, 0.5)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 34, 1, 0)
    status.Position = UDim2.new(1, -38, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = RD
    status.TextSize = 9
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.ZIndex = 13
    status.Parent = b

    local function upd()
        if F[key] then
            b.BackgroundColor3 = CY2
            b.BackgroundTransparency = 0.6
            b.TextColor3 = WH
            st.Color = CY
            status.Text = "ON"
            status.TextColor3 = GN
        else
            b.BackgroundColor3 = BG2
            b.BackgroundTransparency = 0.3
            b.TextColor3 = CY
            st.Color = CY3
            status.Text = "OFF"
            status.TextColor3 = RD
        end
    end

    clk(b, function()
        cb()
        upd()
    end)
    upd()
end

-- スライダー付きトグル
local function mkSliderToggle(text, yPos, key, cb, getVal, setVal)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 46)
    container.Position = UDim2.new(0, 2, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 12
    container.Parent = hubScroll

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 26)
    toggle.BackgroundColor3 = BG2
    toggle.BackgroundTransparency = 0.3
    toggle.Text = "  ◈ " .. text
    toggle.TextColor3 = CY
    toggle.TextSize = 10
    toggle.Font = Enum.Font.Code
    toggle.BorderSizePixel = 0
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.AutoButtonColor = false
    toggle.ZIndex = 12
    toggle.Parent = container
    cnr(toggle, 3)
    local st = strk(toggle, CY3, 1, 0.5)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 34, 1, 0)
    status.Position = UDim2.new(1, -38, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = RD
    status.TextSize = 9
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.ZIndex = 13
    status.Parent = toggle

    -- 値ラベル
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 45, 0, 16)
    valLabel.Position = UDim2.new(0.4, 0, 0, 28)
    valLabel.BackgroundColor3 = BG2
    valLabel.BackgroundTransparency = 0.3
    valLabel.Text = tostring(getVal())
    valLabel.TextColor3 = CY
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.Code
    valLabel.BorderSizePixel = 0
    valLabel.ZIndex = 12
    valLabel.Parent = container
    cnr(valLabel, 3)
    strk(valLabel, CY3, 1, 0.5)

    -- -ボタン
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 26, 0, 16)
    minus.Position = UDim2.new(0.4, -30, 0, 28)
    minus.BackgroundColor3 = BG2
    minus.BackgroundTransparency = 0.3
    minus.Text = "−"
    minus.TextColor3 = RD
    minus.TextSize = 12
    minus.Font = Enum.Font.Code
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.ZIndex = 12
    minus.Parent = container
    cnr(minus, 3)
    strk(minus, CY3, 1, 0.5)

    -- +ボタン
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 26, 0, 16)
    plus.Position = UDim2.new(0.4, 50, 0, 28)
    plus.BackgroundColor3 = BG2
    plus.BackgroundTransparency = 0.3
    plus.Text = "+"
    plus.TextColor3 = GN
    plus.TextSize = 12
    plus.Font = Enum.Font.Code
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.ZIndex = 12
    plus.Parent = container
    cnr(plus, 3)
    strk(plus, CY3, 1, 0.5)

    -- ラベル
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -5, 0, 14)
    label.Position = UDim2.new(1, -80, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "VALUE"
    label.TextColor3 = CY3
    label.TextSize = 8
    label.Font = Enum.Font.Code
    label.ZIndex = 12
    label.Parent = container

    local function upd()
        if F[key] then
            toggle.BackgroundColor3 = CY2
            toggle.BackgroundTransparency = 0.6
            toggle.TextColor3 = WH
            st.Color = CY
            status.Text = "ON"
            status.TextColor3 = GN
        else
            toggle.BackgroundColor3 = BG2
            toggle.BackgroundTransparency = 0.3
            toggle.TextColor3 = CY
            st.Color = CY3
            status.Text = "OFF"
            status.TextColor3 = RD
        end
        valLabel.Text = tostring(getVal())
    end

    clk(toggle, function()
        cb()
        upd()
    end)

    clk(minus, function()
        setVal(-10)
        upd()
    end)

    clk(plus, function()
        setVal(10)
        upd()
    end)

    upd()
end

-- ボタン配置
mkToggle("FLIGHT", 0, "fly", function()
    F.fly = not F.fly
    if F.fly then startFly() else stopFly() end
end)

mkSliderToggle("SPEED", 32, "speed",
    function()
        F.speed = not F.speed
        applySpeed()
    end,
    function() return speedValue end,
    function(delta)
        speedValue = math.clamp(speedValue + delta, 16, 500)
        if F.speed then applySpeed() end
    end
)

mkSliderToggle("JUMP", 82, "jump",
    function()
        F.jump = not F.jump
        applyJump()
    end,
    function() return jumpValue end,
    function(delta)
        jumpValue = math.clamp(jumpValue + delta, 50, 500)
        if F.jump then applyJump() end
    end
)

mkToggle("BRIGHT", 132, "bright", function()
    F.bright = not F.bright
    applyBright()
end)

mkToggle("NOCLIP", 160, "noclip", function()
    F.noclip = not F.noclip
    if F.noclip then startNoclip() end
end)

mkToggle("INF JUMP", 188, "infjump", function()
    F.infjump = not F.infjump
end)

mkToggle("NO FOG", 216, "nofog", function()
    F.nofog = not F.nofog
    applyNoFog()
end)

mkToggle("ESP", 244, "esp", function()
    F.esp = not F.esp
    updateESP()
end)

-- RESET
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -4, 0, 26)
resetBtn.Position = UDim2.new(0, 2, 0, 272)
resetBtn.BackgroundColor3 = BG2
resetBtn.BackgroundTransparency            = 0.3
resetBtn.Text = remove "  ↺ RESET ALL"
resetBtnESP.TextColor3 = RD
resetBtn.TextSize(target = 10
resetBtn.Font = Enum.Font.Code
resetBtn.BorderSizePixel = 0
resetBtn.TextXAlignment = Enum.TextXAlignment.Left
resetBtn.AutoButtonColor = false
resetBtn.ZIndex = 12
resetBtn.Parent = hubScroll
cnr(resetBtn, 3)
strk(resetBtn, CY3, 1, 0.5)

clk(resetBtn, function()
    F.fly = false; stopFly()
    F.speed = false; applySpeed()
    F.jump = false; applyJump()
    F.bright = false; applyBright()
    F.noclip = false
    F.esp = false; updateESP()
    F.infjump = false
    F.nofog = false; applyNoFog()
    speedValue = 50
    jumpValue = 100
    print("[JARVIS] RESET")
end)

-- 折りたたみ
local collapsed = false
local function toggleCollapse()
    collapsed = not collapsed
    if collapsed then
        hub.Size = UDim2.new(0, 220, 0, 26)
        collapseBtn.Text = "+"
        hubBody.Visible = false
    else
        hub.Size = UDim2.new(0, 220, 0, 360)
        collapseBtn.Text = "−"
        hubBody.Visible = true
    end
end
clk(collapseBtn, toggleCollapse)

mkDrag(hubHeader, hub)

-- ============================================================
-- プレイヤーリスト
-- ============================================================
local playerPanel = Instance.new("Frame")
playerPanel.Size = UDim2.new(0, 210, 0, 280)
playerPanel.Position = UDim2.new(1, -222, 0, 220)
playerPanel.BackgroundColor3 = BG
playerPanel.BackgroundTransparency = 0.1
playerPanel.BorderSizePixel = 0
playerPanel.ZIndex = 10
playerPanel.Parent = gui
cnr(playerPanel, 6)
strk(playerPanel, CY, 1.5, 0.3)
grad(playerPanel, BG2, BG, 90)

local plHeader = Instance.new("Frame")
plHeader.Size = UDim2.new(1, 0, 0, 26)
plHeader.BackgroundColor3 = BG3
plHeader.BackgroundTransparency = 0.2
plHeader.BorderSizePixel = 0
plHeader.ZIndex = 11
plHeader.Parent = playerPanel
cnr(plHeader, 6)

local plLine = Instance.new("Frame")
plLine.Size = UDim2.new(1, 0, 0, 1)
plLine.Position = UDim2.new(0, 0, 1, -1)
plLine.BackgroundColor3 = CY
plLine.BorderSizePixel = 0
plLine.ZIndex = 12
plLine.Parent = plHeader

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, -10, 1, 0)
plTitle.Position = UDim2.new(0, 10, 0, 0)
plTitle.BackgroundTransparency = 1
plTitle.Text = "◈ TARGETS"
plTitle.TextColor3 = CY
plTitle.TextSize = 11
plTitle.Font = Enum.Font.Code
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.ZIndex = 12
plTitle.Parent = plHeader

local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(1, -12, 1, -36)
plScroll.Position = UDim2.new(0, 6, 0, 30)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 2
plScroll.ScrollBarImageColor3 = CY
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.ZIndex = 11
plScroll.Parent = playerPanel

local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 3)
plLayout.Parent = plScroll
plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plScroll.CanvasSize = UDim2.new(0, 0, 0, plLayout.AbsoluteContentSize.Y + 5)
end)

local rowData = {}

local function makeRow(target)
    if target == plr then return end
    if rowData[target] then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -2, 0, 26)
    row.BackgroundColor3 = BG2
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = plScroll
    cnr(row, 3)
    local rowStroke = strk(row, CY3, 1, 0.5)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -90, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = target.DisplayName
    nameLbl.TextColor3 = CY
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 13
    nameLbl.Parent = row

    -- ESPボタン
    local espB = Instance.new("TextButton")
    espB.Size = UDim2.new(0, 26, 0, 20)
    espB.Position = UDim2.new(1, -58, 0.5, -10)
    espB.BackgroundColor3 = BG2
    espB.BackgroundTransparency = 0.3
    espB.Text = "◉"
    espB.TextColor3 = CY
    espB.TextSize = 11
    espB.Font = Enum.Font.Code
    espB.BorderSizePixel = 0
    espB.AutoButtonColor = false
    espB.ZIndex = 13
    espB.Parent = row
    cnr(espB, 3)
    local espBS = strk(espB, CY3, 1, 0.5)

    -- TPボタン
    local tpB = Instance.new("TextButton")
    tpB.Size = UDim2.new(0, 26, 0, 20)
    tpB.Position = UDim2.new(1, -30, 0.5, -10)
    tpB.BackgroundColor3 = BG2
    tpB.BackgroundTransparency = 0.3
    tpB.Text = "→"
    tpB.TextColor3 = GN
    tpB.TextSize = 11
    tpB.Font = Enum.Font.Code
    tpB.BorderSizePixel = 0
    tpB.AutoButtonColor = false
    tpB.ZIndex = 13
    tpB.Parent = row
    cnr(tpB, 3)
    local tpBS = strk(tpB, CY3, 1, 0.5)

    clk(espB, function()
        if espData[target] then
)
            espB.BackgroundColor3 = BG2
            espB.TextColor3 = CY
            nameLbl.TextColor3 = CY
            row.BackgroundColor3 = BG2
        else
            createESP(target)
            espB.BackgroundColor3 = CY2
            espB.TextColor3 = WH
            nameLbl.TextColor3 = WH
            row.BackgroundColor3 = CY4
        end
    end)

    clk(tpB, function()
        local mc = plr.Character
        if not mc then return end
        local mh = mc:FindFirstChild("HumanoidRootPart")
        if not mh then return end
        local tc = target.Character
        if not tc then return end
        local th = tc:FindFirstChild("HumanoidRootPart")
        if not th then return end
        mh.CFrame = th.CFrame * CFrame.new(0, 0, 3)
        tpB.BackgroundColor3 = GN
        tpB.TextColor3 = BG
        task.wait(0.3)
        tpB.BackgroundColor3 = BG2
        tpB.TextColor3 = GN
    end)

    rowData[target] = {row = row}
end

local function removeRow(target)
    if rowData[target] then
        rowData[target].row:Destroy()
        rowData[target] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do makeRow(p) end
Players.PlayerAdded:Connect(function(p) task.wait(0.5) makeRow(p) end)
Players.PlayerRemoving:Connect(function(p) removeRow(p) end)

mkDrag(plHeader, playerPanel)

-- ============================================================
-- 右上 ミニマップ（JARVIS風）
-- ============================================================
local mapSize = 150
local mapPanel = Instance.new("Frame")
mapPanel.Size = UDim2.new(0, mapSize, 0, mapSize)
mapPanel.Position = UDim2.new(1, -mapSize - 12, 0, 60)
mapPanel.BackgroundColor3 = BG
mapPanel.BackgroundTransparency = 0.2
mapPanel.BorderSizePixel = 0
mapPanel.ZIndex = 10
mapPanel.Parent = gui
cnr(mapPanel, mapSize/2)
strk(mapPanel, CY, 2, 0.2)

-- 内側の薄いリング
local innerRing = Instance.new("Frame")
innerRing.Size = UDim2.new(0, mapSize - 20, 0, mapSize - 20)
innerRing.Position = UDim2.new(0.5, -(mapSize-20)/2, 0.5, -(mapSize-20)/2)
innerRing.BackgroundTransparency = 1
innerRing.ZIndex = 11
innerRing.Parent = mapPanel
cnr(innerRing, (mapSize-20)/2)
local innerRingStroke = strk(innerRing, CY3, 1, 0.5)

local innerRing2 = Instance.new("Frame")
innerRing2.Size = UDim2.new(0, mapSize - 50, 0, mapSize - 50)
innerRing2.Position = UDim2.new(0.5, -(mapSize-50)/2, 0.5, -(mapSize-50)/2)
innerRing2.BackgroundTransparency = 1
innerRing2.ZIndex = 11
innerRing2.Parent = mapPanel
cnr(innerRing2, (mapSize-50)/2)
local innerRing2Stroke = strk(innerRing2, CY3, 1, 0.7)

-- 十字線
local crossH = Instance.new("Frame")
crossH.Size = UDim2.new(1, -30, 0, 1)
crossH.Position = UDim2.new(0, 15, 0.5, 0)
crossH.BackgroundColor3 = CY3
crossH.BackgroundTransparency = 0.5
crossH.BorderSizePixel = 0
crossH.ZIndex = 11
crossH.Parent = mapPanel

local crossV = Instance.new("Frame")
crossV.Size = UDim2.new(0, 1, 1, -30)
crossV.Position = UDim2.new(0.5, 0, 0, 15)
crossV.BackgroundColor3 = CY3
crossV.BackgroundTransparency = 0.5
crossV.BorderSizePixel = 0
crossV.ZIndex = 11
crossV.Parent = mapPanel

-- 中央（自分）
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 8, 0, 8)
centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
centerDot.BackgroundColor3 = CY
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 13
centerDot.Parent = mapPanel
cnr(centerDot, 4)

local centerDotGlow = Instance.new("Frame")
centerDotGlow.Size = UDim2.new(0, 16, 0, 16)
centerDotGlow.Position = UDim2.new(0.5, -8, 0.5, -8)
centerDotGlow.BackgroundColor3 = CY
centerDotGlow.BackgroundTransparency = 0.6
centerDotGlow.BorderSizePixel = 0
centerDotGlow.ZIndex = 12
centerDotGlow.Parent = mapPanel
cnr(centerDotGlow, 8)

task.spawn(function()
    while mapPanel.Parent do
        centerDotGlow.BackgroundTransparency = 0.6
        task.wait(0.5)
        centerDotGlow.BackgroundTransparency = 0.9
        task.wait(0.5)
    end
end)

-- 向き矢印
local dirArrow = Instance.new("Frame")
dirArrow.Size = UDim2.new(0, 2, 0, 16)
dirArrow.Position = UDim2.new(0.5, -1, 0.5, -16)
dirArrow.BackgroundColor3 = CY
dirArrow.BorderSizePixel = 0
dirArrow.ZIndex = 13
dirArrow.Parent = mapPanel

-- 走査線（レーダー）
local radarScan = Instance.new("Frame")
radarScan.Size = UDim2.new(0, 2, 0, mapSize/2 - 10)
radarScan.Position = UDim2.new(0.5, -1, 0.5, -(mapSize/2 - 10))
radarScan.BackgroundColor3 = CY
radarScan.BackgroundTransparency = 0.3
radarScan.BorderSizePixel = 0
radarScan.ZIndex = 11
radarScan.Parent = mapPanel

task.spawn(function()
    while mapPanel.Parent do
        local rot = 0
        while rot < 360 do
            rot = rot + 4
            radarScan.Rotation = rot
            task.wait(0.02)
        end
    end
end)

-- 方角表示
local compass = {"N", "E", "S", "W"}
local compassLabels = {}
for i, dir in ipairs(compass) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 20, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = dir
    lbl.TextColor3 = CY2
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Code
    lbl.ZIndex = 13
    lbl.Parent = mapPanel

    local angle = (i - 1) * 90
    local rad = math.rad(angle - 90)
    local r = mapSize/2 - 10
    local x = math.cos(rad) * r
    local y = math.sin(rad) * r
    lbl.Position = UDim2.new(0.5, x - 10, 0.5, y - 6)
    table.insert(compassLabels, lbl)
end

-- プレイヤードット
local dotContainer = Instance.new("Frame")
dotContainer.Size = UDim2.new(1, 0, 1, 0)
dotContainer.BackgroundTransparency = 1
dotContainer.ZIndex = 11
dotContainer.Parent = mapPanel

local playerDots = {}
local mapRange = 200

local function mkDot(target)
    if target == plr then return end
    if playerDots[target] then return end
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 7, 0, 7)
    d.BackgroundColor3 = RD
    d.BorderSizePixel = 0
    d.ZIndex = 12
    d.Parent = dotContainer
    cnr(d, 3.5)
    local ds = strk(d, WH, 1, 0.5)
    playerDots[target] = {frame = d, stroke = ds}
end

for _, p in ipairs(Players:GetPlayers()) do mkDot(p) end
Players.PlayerAdded:Connect(function(p) task.wait(0.5) mkDot(p) end)
Players.PlayerRemoving:Connect(function(p)
    if playerDots[p] then playerDots[p].frame:Destroy() playerDots[p] = nil end
end)

task.spawn(function()
    while gui.Parent do
        task.wait(0.05)
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local myPos = hrp.Position
        local myLook = hrp.CFrame.LookVector
        local yaw = math.atan2(-myLook.X, -myLook.Z)
        dirArrow.Rotation = math.deg(yaw)

        for target, data in pairs(playerDots) do
            local tChar = target.Character
            if tChar then
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local offset = tHrp.Position - myPos
                    local mapX = offset.X / mapRange
                    local mapZ = offset.Z / mapRange
                    local dist = math.sqrt(mapX * mapX + mapZ * mapZ)
                    if dist > 0.42 then
                        mapX = mapX / dist * 0.42
                        mapZ = mapZ / dist * 0.42
                    end
                    local px = (0.5 + mapX) * mapSize - 3.5
                    local pz = (0.5 + mapZ) * mapSize - 3.5
                    data.frame.Position = UDim2.new(0, px, 0, pz)

                    local d = (tHrp.Position - myPos).Magnitude
                    if d < 30 then
                        data.frame.BackgroundColor3 = RD
                        data.stroke.Color = RD
                    elseif d < 100 then
                        data.frame.BackgroundColor3 = YL
                        data.stroke.Color = YL
                    else
                        data.frame.BackgroundColor3 = GN
                        data.stroke.Color = GN
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- 開閉ボタン（HUB閉じた時用）
-- ============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 46, 0, 46)
toggleBtn.Position = UDim2.new(0, 12, 0, 60)
toggleBtn.BackgroundColor3 = BG
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.Text = "◉"
toggleBtn.TextColor3 = CY
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.Code
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Visible = false
toggleBtn.ZIndex = 10
toggleBtn.Parent = gui
cnr(toggleBtn, 23)
strk(toggleBtn, CY, 2, 0.2)
grad(toggleBtn, CY2, CY3, 45)

local function setVisible(v)
    hub.Visible = v
    playerPanel.Visible = v
    toggleBtn.Visible = not v
end

clk(toggleBtn, function()
    setVisible(true)
end)

-- ============================================================
-- キーボード
-- ============================================================
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not hub.Visible)
    end
end)

-- 初期化
print("[JARVIS] 完全起動完了")
print("機能: FLY / SPEED / JUMP / NOCLIP / INF JUMP / BRIGHT / NO FOG / ESP / TP")
print("キー: 右Shift で開閉")
