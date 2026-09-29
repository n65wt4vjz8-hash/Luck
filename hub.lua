--[[ 
    J.A.R.V.I.S. FULL HUB
    - FLY / NOCLIP / SPEED / JUMP / ESP
    - Player TP List
    - Mini-map (top right)
    - FPS/MS (top center)
]]

print("[HUB] 起動中...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

-- ============================================================
-- カラー
-- ============================================================
local CY = Color3.fromRGB(0, 220, 255)
local CY2 = Color3.fromRGB(0, 150, 220)
local CY3 = Color3.fromRGB(0, 80, 140)
local BG = Color3.fromRGB(0, 10, 25)
local BG2 = Color3.fromRGB(0, 20, 40)
local WH = Color3.fromRGB(220, 245, 255)
local RD = Color3.fromRGB(255, 80, 80)
local GN = Color3.fromRGB(80, 255, 150)
local YL = Color3.fromRGB(255, 200, 0)
local PR = Color3.fromRGB(180, 80, 255)

-- ============================================================
-- 状態
-- ============================================================
local F = {
    fly = false,
    speed = false,
    jump = false,
    bright = false,
    noclip = false,
    esp = false,
    infjump = false,
}

local speedValue = 50
local jumpValue = 100
local flySpeed = 80

local origLight = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
}

print("[HUB] 状態OK")

-- ============================================================
-- ヘルパー
-- ============================================================
local function cnr(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end

local function strk(o, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = t or 1
    s.Transparency = tr or 0.3
    s.Parent = o
end

local function clk(b, cb)
    local last = 0
    b.MouseButton1Click:Connect(function()
        local n = tick()
        if n - last < 0.2 then return end
        last = n
        cb()
    end)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            local n = tick()
            if n - last < 0.2 then return end
            last = n
            cb()
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
-- BRIGHT
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
    bb.Size = UDim2.new(0, 160, 0, 50)
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

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = CY
    frameStroke.Thickness = 1
    frameStroke.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 18)
    nameLbl.Position = UDim2.new(0, 4, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(target.DisplayName)
    nameLbl.TextColor3 = WH
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3 = BG
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, -8, 0, 14)
    distLbl.Position = UDim2.new(0, 4, 0, 24)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "DIST: 0m"
    distLbl.TextColor3 = CY
    distLbl.TextSize = 11
    distLbl.Font = Enum.Font.Code
    distLbl.TextStrokeTransparency = 0
    distLbl.TextStrokeColor3 = BG
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = frame

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

print("[HUB] 機能実装OK")

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "JarvisHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

-- ============================================================
-- 画面装飾（JARVIS風）
-- ============================================================
local decorGui = Instance.new("ScreenGui")
decorGui.Name = "JarvisDecor"
decorGui.ResetOnSpawn = false
decorGui.IgnoreGuiInset = true
decorGui.DisplayOrder = 500
decorGui.Parent = PlayerGui

-- 走査線
task.spawn(function()
    task.wait(0.2)
    for y = 0, 1080, 6 do
        local l = Instance.new("Frame")
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundColor3 = CY
        l.BackgroundTransparency = 0.95
        l.BorderSizePixel = 0
        l.Parent = decorGui
    end
end)

-- 四隅
local function cornerBracket(x, y, fx, fy)
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 50, 0, 50)
    b.Position = UDim2.new(x, 0, y, 0)
    b.BackgroundTransparency = 1
    b.Parent = decorGui
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 2)
    h.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    h.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    h.BackgroundColor3 = CY
    h.BackgroundTransparency = 0.2
    h.BorderSizePixel = 0
    h.Parent = b
    local v = Instance.new("Frame")
    v.Size = UDim2.new(0, 2, 1, 0)
    v.Position = UDim2.new(fx and 1 or 0, 0, fy and 1 or 0, 0)
    v.AnchorPoint = Vector2.new(fx and 1 or 0, fy and 1 or 0)
    v.BackgroundColor3 = CY
    v.BackgroundTransparency = 0.2
    v.BorderSizePixel = 0
    v.Parent = b
end
cornerBracket(0, 0, false, false)
cornerBracket(1, 0, true, false)
cornerBracket(0, 1, false, true)
cornerBracket(1, 1, true, true)

-- テキスト
local dt1 = Instance.new("TextLabel")
dt1.Size = UDim2.new(0, 400, 0, 14)
dt1.Position = UDim2.new(0, 62, 0, 12)
dt1.BackgroundTransparency = 1
dt1.Text = "J.A.R.V.I.S. // ONLINE"
dt1.TextColor3 = CY
dt1.TextSize = 9
dt1.Font = Enum.Font.Code
dt1.TextTransparency = 0.3
dt1.TextXAlignment = Enum.TextXAlignment.Left
dt1.Parent = decorGui

local dt2 = Instance.new("TextLabel")
dt2.Size = UDim2.new(0, 400, 0, 14)
dt2.Position = UDim2.new(1, -462, 1, -26)
dt2.BackgroundTransparency = 1
dt2.Text = "STARK INDUSTRIES // MARK VII"
dt2.TextColor3 = CY
dt2.TextSize = 9
dt2.Font = Enum.Font.Code
dt2.TextTransparency = 0.3
dt2.TextXAlignment = Enum.TextXAlignment.Right
dt2.Parent = decorGui

-- 点滅
local blink = Instance.new("Frame")
blink.Size = UDim2.new(0, 6, 0, 6)
blink.Position = UDim2.new(0, 48, 0, 16)
blink.BackgroundColor3 = GN
blink.BorderSizePixel = 0
blink.Parent = decorGui
cnr(blink, 3)

task.spawn(function()
    while decorGui.Parent do
        blink.BackgroundTransparency = 0
        task.wait(0.6)
        blink.BackgroundTransparency = 0.85
        task.wait(0.6)
    end
end)

-- ============================================================
-- 上部 FPS/ms
-- ============================================================
local fpsPanel = Instance.new("Frame")
fpsPanel.Size = UDim2.new(0, 200, 0, 26)
fpsPanel.Position = UDim2.new(0.5, -100, 0, 16)
fpsPanel.BackgroundColor3 = BG
fpsPanel.BackgroundTransparency = 0.2
fpsPanel.BorderSizePixel = 0
fpsPanel.ZIndex = 10
fpsPanel.Parent = gui
cnr(fpsPanel, 6)
strk(fpsPanel, CY, 1.5, 0.3)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = CY
fpsLabel.TextSize = 11
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.ZIndex = 11
fpsLabel.Parent = fpsPanel

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(0.5, 0, 1, 0)
msLabel.Position = UDim2.new(0.5, 0, 0, 0)
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
hub.Size = UDim2.new(0, 210, 0, 320)
hub.Position = UDim2.new(0, 12, 0, 60)
hub.BackgroundColor3 = BG
hub.BackgroundTransparency = 0.15
hub.BorderSizePixel = 0
hub.ZIndex = 10
hub.Parent = gui
cnr(hub, 6)
strk(hub, CY, 1.5, 0.3)

local hubHeader = Instance.new("Frame")
hubHeader.Size = UDim2.new(1, 0, 0, 24)
hubHeader.BackgroundColor3 = BG2
hubHeader.BackgroundTransparency = 0.3
hubHeader.BorderSizePixel = 0
hubHeader.ZIndex = 11
hubHeader.Parent = hub
cnr(hubHeader, 6)

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -50, 1, 0)
hubTitle.Position = UDim2.new(0, 10, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "◈ J.A.R.V.I.S."
hubTitle.TextColor3 = CY
hubTitle.TextSize = 11
hubTitle.Font = Enum.Font.Code
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.ZIndex = 12
hubTitle.Parent = hubHeader

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 18, 0, 18)
collapseBtn.Position = UDim2.new(1, -22, 0.5, -9)
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
cnr(collapseBtn, 9)

local hubBody = Instance.new("Frame")
hubBody.Size = UDim2.new(1, -16, 1, -34)
hubBody.Position = UDim2.new(0, 8, 0, 28)
hubBody.BackgroundTransparency = 1
hubBody.ZIndex = 11
hubBody.Parent = hub

-- トグルボタン作成
local function mkToggle(text, yPos, key, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 24)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = BG
    b.BackgroundTransparency = 0.3
    b.Text = "  " .. text
    b.TextColor3 = CY
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 0
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 12
    b.Parent = hubBody
    cnr(b, 3)
    local st = strk(b, CY3, 1, 0.5)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 30, 1, 0)
    status.Position = UDim2.new(1, -34, 0, 0)
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
            b.BackgroundTransparency = 0.5
            b.TextColor3 = WH
            st.Color = CY
            status.Text = "ON"
            status.TextColor3 = GN
        else
            b.BackgroundColor3 = BG
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
    return upd
end

-- 速度調整付きトグル
local function mkSliderToggle(text, yPos, key, cb, getVal, setVal)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 12
    container.Parent = hubBody

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.55, 0, 0, 24)
    toggle.Position = UDim2.new(0, 0, 0, 0)
    toggle.BackgroundColor3 = BG
    toggle.BackgroundTransparency = 0.3
    toggle.Text = "  " .. text
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
    status.Size = UDim2.new(0, 26, 1, 0)
    status.Position = UDim2.new(1, -28, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = RD
    status.TextSize = 9
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.ZIndex = 13
    status.Parent = toggle

    -- 値表示
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 45, 1, 0)
    valLabel.Position = UDim2.new(0.56, 0, 0, 0)
    valLabel.BackgroundColor3 = BG
    valLabel.BackgroundTransparency = 0.3
    valLabel.Text = tostring(getVal())
    valLabel.TextColor3 = CY
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.Code
    valLabel.BorderSizePixel = 0
    valLabel.ZIndex = 12
    valLabel.Parent = container
    cnr(valLabel, 3)
    local vst = strk(valLabel, CY3, 1, 0.5)

    -- -ボタン
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 22, 0, 24)
    minus.Position = UDim2.new(0.56, 50, 0, 0)
    minus.BackgroundColor3 = BG
    minus.BackgroundTransparency = 0.3
    minus.Text = "−"
    minus.TextColor3 = RD
    minus.TextSize = 14
    minus.Font = Enum.Font.Code
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.ZIndex = 12
    minus.Parent = container
    cnr(minus, 3)
    strk(minus, CY3, 1, 0.5)

    -- +ボタン
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 22, 0, 24)
    plus.Position = UDim2.new(1, -22, 0, 0)
    plus.BackgroundColor3 = BG
    plus.BackgroundTransparency = 0.3
    plus.Text = "+"
    plus.TextColor3 = GN
    plus.TextSize = 14
    plus.Font = Enum.Font.Code
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.ZIndex = 12
    plus.Parent = container
    cnr(plus, 3)
    strk(plus, CY3, 1, 0.5)

    local function upd()
        if F[key] then
            toggle.BackgroundColor3 = CY2
            toggle.BackgroundTransparency = 0.5
            toggle.TextColor3 = WH
            st.Color = CY
            status.Text = "ON"
            status.TextColor3 = GN
        else
            toggle.BackgroundColor3 = BG
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

-- ============ ボタン配置 ============
mkToggle("FLIGHT", 0, "fly", function()
    F.fly = not F.fly
    if F.fly then startFly() else stopFly() end
end)

mkSliderToggle("SPEED", 30, "speed",
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

mkSliderToggle("JUMP", 76, "jump",
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

mkToggle("BRIGHT", 122, "bright", function()
    F.bright = not F.bright
    applyBright()
end)

mkToggle("NOCLIP", 150, "noclip", function()
    F.noclip = not F.noclip
    if F.noclip then startNoclip() end
end)

mkToggle("INF JUMP", 178, "infjump", function()
    F.infjump = not F.infjump
end)

mkToggle("ESP", 206, "esp", function()
    F.esp = not F.esp
    updateESP()
end)

-- RESET
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 24)
resetBtn.Position = UDim2.new(0, 0, 0, 234)
resetBtn.BackgroundColor3 = BG
resetBtn.BackgroundTransparency = 0.3
resetBtn.Text = "  RESET ALL"
resetBtn.TextColor3 = RD
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.Code
resetBtn.BorderSizePixel = 0
resetBtn.TextXAlignment = Enum.TextXAlignment.Left
resetBtn.AutoButtonColor = false
resetBtn.ZIndex = 12
resetBtn.Parent = hubBody
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
    speedValue = 50
    jumpValue = 100
    print("[HUB] RESET")
end)

-- 折りたたみ
local collapsed = false
local function toggleCollapse()
    collapsed = not collapsed
    if collapsed then
        hub.Size = UDim2.new(0, 210, 0, 24)
        collapseBtn.Text = "+"
        hubBody.Visible = false
    else
        hub.Size = UDim2.new(0, 210, 0, 320)
        collapseBtn.Text = "−"
        hubBody.Visible = true
    end
end
clk(collapseBtn, toggleCollapse)

-- ============================================================
-- プレイヤーリスト（中央右）
-- ============================================================
local playerPanel = Instance.new("Frame")
playerPanel.Size = UDim2.new(0, 200, 0, 260)
playerPanel.Position = UDim2.new(1, -212, 0, 210)
playerPanel.BackgroundColor3 = BG
playerPanel.BackgroundTransparency = 0.15
playerPanel.BorderSizePixel = 0
playerPanel.ZIndex = 10
playerPanel.Parent = gui
cnr(playerPanel, 6)
strk(playerPanel, CY, 1.5, 0.3)

local plHeader = Instance.new("Frame")
plHeader.Size = UDim2.new(1, 0, 0, 24)
plHeader.BackgroundColor3 = BG2
plHeader.BackgroundTransparency = 0.3
plHeader.BorderSizePixel = 0
plHeader.ZIndex = 11
plHeader.Parent = playerPanel
cnr(plHeader, 6)

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
plScroll.Size = UDim2.new(1, -12, 1, -34)
plScroll.Position = UDim2.new(0, 6, 0, 28)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 3
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
    row.Size = UDim2.new(1, -2, 0, 24)
    row.BackgroundColor3 = BG
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = plScroll
    cnr(row, 3)
    local rowStroke = strk(row, CY3, 1, 0.5)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -55, 1, 0)
    nameLbl.Position = UDim2.new(0, 6, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = target.DisplayName
    nameLbl.TextColor3 = CY
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 13
    nameLbl.Parent = row

    -- TPボタン
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 42, 0, 20)
    tpBtn.Position = UDim2.new(1, -46, 0.5, -10)
    tpBtn.BackgroundColor3 = BG
    tpBtn.BackgroundTransparency = 0.3
    tpBtn.Text = "TP"
    tpBtn.TextColor3 = GN
    tpBtn.TextSize = 10
    tpBtn.Font = Enum.Font.Code
    tpBtn.BorderSizePixel = 0
    tpBtn.AutoButtonColor = false
    tpBtn.ZIndex = 13
    tpBtn.Parent = row
    cnr(tpBtn, 3)
    strk(tpBtn, CY3, 1, 0.5)

    clk(tpBtn, function()
        local mc = plr.Character
        if not mc then return end
        local mh = mc:FindFirstChild("HumanoidRootPart")
        if not mh then return end
        local tc = target.Character
        if not tc then return end
        local th = tc:FindFirstChild("HumanoidRootPart")
        if not th then return end
        mh.CFrame = th.CFrame * CFrame.new(0, 0, 3)
        tpBtn.BackgroundColor3 = GN
        tpBtn.TextColor3 = BG
        task.wait(0.3)
        tpBtn.BackgroundColor3 = BG
        tpBtn.TextColor3 = GN
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

-- ============================================================
-- 右上 ミニマップ
-- ============================================================
local mapSize = 140
local mapPanel = Instance.new("Frame")
mapPanel.Size = UDim2.new(0, mapSize, 0, mapSize)
mapPanel.Position = UDim2.new(1, -mapSize - 12, 0, 60)
mapPanel.BackgroundColor3 = BG
mapPanel.BackgroundTransparency = 0.2
mapPanel.BorderSizePixel = 0
mapPanel.ZIndex = 10
mapPanel.Parent = gui
cnr(mapPanel, mapSize/2)
strk(mapPanel, CY, 1.5, 0.3)

-- 十字線
local crossH = Instance.new("Frame")
crossH.Size = UDim2.new(1, -20, 0, 1)
crossH.Position = UDim2.new(0, 10, 0.5, 0)
crossH.BackgroundColor3 = CY3
crossH.BackgroundTransparency = 0.4
crossH.BorderSizePixel = 0
crossH.ZIndex = 11
crossH.Parent = mapPanel

local crossV = Instance.new("Frame")
crossV.Size = UDim2.new(0, 1, 1, -20)
crossV.Position = UDim2.new(0.5, 0, 0, 10)
crossV.BackgroundColor3 = CY3
crossV.BackgroundTransparency = 0.4
crossV.BorderSizePixel = 0
crossV.ZIndex = 11
crossV.Parent = mapPanel

-- 中央（自分）
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 7, 0, 7)
centerDot.Position = UDim2.new(0.5, -3.5, 0.5, -3.5)
centerDot.BackgroundColor3 = CY
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 12
centerDot.Parent = mapPanel
cnr(centerDot, 3.5)

-- 向き矢印
local dirArrow = Instance.new("Frame")
dirArrow.Size = UDim2.new(0, 2, 0, 14)
dirArrow.Position = UDim2.new(0.5, -1, 0.5, -14)
dirArrow.BackgroundColor3 = CY
dirArrow.BorderSizePixel = 0
dirArrow.ZIndex = 12
dirArrow.Parent = mapPanel

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
    d.Size = UDim2.new(0, 6, 0, 6)
    d.BackgroundColor3 = RD
    d.BorderSizePixel = 0
    d.ZIndex = 12
    d.Parent = dotContainer
    cnr(d, 3)
    playerDots[target] = d
end

for _, p in ipairs(Players:GetPlayers()) do mkDot(p) end
Players.PlayerAdded:Connect(function(p) task.wait(0.5) mkDot(p) end)
Players.PlayerRemoving:Connect(function(p)
    if playerDots[p] then playerDots[p]:Destroy() playerDots[p] = nil end
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

        for target, dot in pairs(playerDots) do
            local tChar = target.Character
            if tChar then
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local offset = tHrp.Position - myPos
                    local mapX = offset.X / mapRange
                    local mapZ = offset.Z / mapRange
                    local dist = math.sqrt(mapX * mapX + mapZ * mapZ)
                    if dist > 0.45 then
                        mapX = mapX / dist * 0.45
                        mapZ = mapZ / dist * 0.45
                    end
                    local px = (0.5 + mapX) * mapSize - 3
                    local pz = (0.5 + mapZ) * mapSize - 3
                    dot.Position = UDim2.new(0, px, 0, pz)

                    local d = (tHrp.Position - myPos).Magnitude
                    if d < 30 then
                        dot.BackgroundColor3 = RD
                    elseif d < 100 then
                        dot.BackgroundColor3 = YL
                    else
                        dot.BackgroundColor3 = GN
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- 開閉ボタン
-- ============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 44, 0, 44)
toggleBtn.Position = UDim2.new(0, 12, 0, 60)
toggleBtn.BackgroundColor3 = BG
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Text = "◉"
toggleBtn.TextColor3 = CY
toggleBtn.TextSize = 20
toggleBtn.Font = Enum.Font.Code
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Visible = false
toggleBtn.ZIndex = 10
toggleBtn.Parent = gui
cnr(toggleBtn, 22)
strk(toggleBtn, CY, 2, 0.2)

clk(toggleBtn, function()
    hub.Visible = true
    playerPanel.Visible = true
    toggleBtn.Visible = false
end)

-- ============================================================
-- ハブのドラッグ
-- ============================================================
local dragging, dI, dS, sP = false, nil, nil, nil
hubHeader.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dS = i.Position
        sP = hub.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
hubHeader.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        dI = i
    end
end)
UIS.InputChanged:Connect(function(i)
    if i == dI and dragging then
        local d = i.Position - dS
        hub.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- プレイヤーパネルのドラッグ
-- ============================================================
local drag2, dI2, dS2, sP2 = false, nil, nil, nil
plHeader.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag2 = true
        dS2 = i.Position
        sP2 = playerPanel.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag2 = false end
        end)
    end
end)
plHeader.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        dI2 = i
    end
end)
UIS.InputChanged:Connect(function(i)
    if i == dI2 and drag2 then
        local d = i.Position - dS2
        playerPanel.Position = UDim2.new(sP2.X.Scale, sP2.X.Offset + d.X, sP2.Y.Scale, sP2.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- キーボード
-- ============================================================
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        hub.Visible = not hub.Visible
        playerPanel.Visible = hub.Visible
        toggleBtn.Visible = not hub.Visible
    end
end)

print("[HUB] 完全起動完了 - 右Shiftで開閉")
