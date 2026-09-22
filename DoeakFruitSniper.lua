-- =========================================================
-- DOEAK FRUIT SNIPER v4
-- Scan Workspace.Fruit + GetFruitData remote
-- =========================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer

-- ===== CONFIG =====
local SCRIPT_URL = "https://raw.githubusercontent.com/idkshdcs/DoeakHub_UILib/main/DoeakFruitSniper.lua"
local FLY_SPEED  = 170

-- ===== PARENT =====
local function getSafeParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return CoreGui
end
local UIParent = getSafeParent()

local old = UIParent:FindFirstChild("DoeakFruitUI")
if old then old:Destroy() end

-- ===== COLORS =====
local C = {
    Surface = Color3.fromRGB(22, 22, 26),
    Card    = Color3.fromRGB(40, 40, 46),
    CardHi  = Color3.fromRGB(52, 52, 60),
    Bg      = Color3.fromRGB(30, 30, 34),
    Stroke  = Color3.fromRGB(240, 240, 240),
    Gold    = Color3.fromRGB(255, 200, 60),
    Green   = Color3.fromRGB(105, 200, 145),
    Red     = Color3.fromRGB(225, 95, 105),
    Text    = Color3.fromRGB(240, 242, 246),
    Sub     = Color3.fromRGB(160, 165, 175),
    Muted   = Color3.fromRGB(100, 105, 115),
}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = type(r) == "number" and UDim.new(0, r) or r
    c.Parent = p; return c
end
local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Stroke
    s.Thickness = th or 1.5
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end
local function tween(o, t, props)
    TweenService:Create(o, TweenInfo.new(t), props):Play()
end

-- ===== REMOTES =====
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local CommF_ = Remotes and Remotes:FindFirstChild("CommF_")
local GetFruitData = Remotes and Remotes:FindFirstChild("GetFruitData")

print("[SNIPER] Remotes:", CommF_ and "OK" or "NIL", GetFruitData and "OK" or "NIL")

-- ===== STATE =====
local autoSnipe = true
local hopCount = 0
local fruitFound = 0
local isHopping = false

-- ===== TEAM =====
local function isInPirates()
    if not LP.Team then return false end
    local n = LP.Team.Name:lower()
    return n == "pirates" or n == "pirate"
end

task.spawn(function()
    while true do
        if not isInPirates() and CommF_ then
            pcall(function() CommF_:InvokeServer("SetTeam", "Pirates") end)
        end
        task.wait(5)
    end
end)

-- ===== NOCLIP =====
task.spawn(function()
    while true do
        if LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
        task.wait(0.2)
    end
end)

-- ===== UI =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "DoeakFruitUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 100
pcall(function() Gui.Parent = UIParent end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 320)
Main.Position = UDim2.new(0.5, -230, 0.5, -160)
Main.BackgroundColor3 = C.Surface
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
corner(Main, 16)
stroke(Main, C.Stroke, 2, 0)

-- Header
local MH = Instance.new("Frame")
MH.Size = UDim2.new(1, -24, 0, 56)
MH.Position = UDim2.new(0, 12, 0, 12)
MH.BackgroundColor3 = C.Bg
MH.BorderSizePixel = 0
MH.Parent = Main
corner(MH, 12)
stroke(MH, C.Stroke, 1, 0.5)

local MHTitle = Instance.new("TextLabel")
MHTitle.Size = UDim2.new(1, -20, 0, 22)
MHTitle.Position = UDim2.new(0, 12, 0, 8)
MHTitle.BackgroundTransparency = 1
MHTitle.Text = "🍎 DOEAK FRUIT SNIPER v4"
MHTitle.TextColor3 = C.Text
MHTitle.Font = Enum.Font.GothamBold
MHTitle.TextSize = 15
MHTitle.TextXAlignment = Enum.TextXAlignment.Left
MHTitle.Parent = MH

local MHSub = Instance.new("TextLabel")
MHSub.Size = UDim2.new(1, -20, 0, 14)
MHSub.Position = UDim2.new(0, 12, 0, 32)
MHSub.BackgroundTransparency = 1
MHSub.Text = "Scan Workspace.Fruit • Auto hop sau khi nhặt"
MHSub.TextColor3 = C.Sub
MHSub.Font = Enum.Font.Gotham
MHSub.TextSize = 10
MHSub.TextXAlignment = Enum.TextXAlignment.Left
MHSub.Parent = MH

-- Fruit info
local FruitInfo = Instance.new("Frame")
FruitInfo.Size = UDim2.new(1, -24, 0, 80)
FruitInfo.Position = UDim2.new(0, 12, 0, 80)
FruitInfo.BackgroundColor3 = C.Card
FruitInfo.BorderSizePixel = 0
FruitInfo.Parent = Main
corner(FruitInfo, 12)
stroke(FruitInfo, C.Stroke, 1.5, 0.3)

local FILabel = Instance.new("TextLabel")
FILabel.Size = UDim2.new(1, -20, 0, 18)
FILabel.Position = UDim2.new(0, 12, 0, 8)
FILabel.BackgroundTransparency = 1
FILabel.Text = "FRUIT GẦN NHẤT"
FILabel.TextColor3 = C.Sub
FILabel.Font = Enum.Font.GothamBold
FILabel.TextSize = 10
FILabel.TextXAlignment = Enum.TextXAlignment.Left
FILabel.Parent = FruitInfo

local FIName = Instance.new("TextLabel")
FIName.Size = UDim2.new(1, -20, 0, 22)
FIName.Position = UDim2.new(0, 12, 0, 28)
FIName.BackgroundTransparency = 1
FIName.Text = "Đang scan..."
FIName.TextColor3 = C.Gold
FIName.Font = Enum.Font.GothamBold
FIName.TextSize = 16
FIName.TextXAlignment = Enum.TextXAlignment.Left
FIName.Parent = FruitInfo

local FIDist = Instance.new("TextLabel")
FIDist.Size = UDim2.new(1, -20, 0, 18)
FIDist.Position = UDim2.new(0, 12, 0, 52)
FIDist.BackgroundTransparency = 1
FIDist.Text = "Distance: ---"
FIDist.TextColor3 = C.Text
FIDist.Font = Enum.Font.Gotham
FIDist.TextSize = 11
FIDist.TextXAlignment = Enum.TextXAlignment.Left
FIDist.Parent = FruitInfo

-- Toggle
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -24, 0, 46)
ToggleBtn.Position = UDim2.new(0, 12, 0, 176)
ToggleBtn.BackgroundColor3 = C.Green
ToggleBtn.Text = ""
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main
corner(ToggleBtn, 10)
stroke(ToggleBtn, C.Green, 1.5, 0.2)

local TogLbl = Instance.new("TextLabel")
TogLbl.Size = UDim2.new(1, -80, 1, 0)
TogLbl.Position = UDim2.new(0, 14, 0, 0)
TogLbl.BackgroundTransparency = 1
TogLbl.Text = "🍎  AUTO SNIPE FRUIT"
TogLbl.TextColor3 = Color3.fromRGB(20, 40, 28)
TogLbl.Font = Enum.Font.GothamBold
TogLbl.TextSize = 12
TogLbl.TextXAlignment = Enum.TextXAlignment.Left
TogLbl.Parent = ToggleBtn

local TogStat = Instance.new("TextLabel")
TogStat.Size = UDim2.new(0, 60, 1, 0)
TogStat.Position = UDim2.new(1, -70, 0, 0)
TogStat.BackgroundTransparency = 1
TogStat.Text = "● ON"
TogStat.TextColor3 = Color3.fromRGB(20, 40, 28)
TogStat.Font = Enum.Font.GothamBold
TogStat.TextSize = 11
TogStat.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    autoSnipe = not autoSnipe
    ToggleBtn.BackgroundColor3 = autoSnipe and C.Green or C.Card
    TogLbl.TextColor3 = autoSnipe and Color3.fromRGB(20, 40, 28) or C.Text
    TogStat.TextColor3 = autoSnipe and Color3.fromRGB(20, 40, 28) or C.Muted
    TogStat.Text = autoSnipe and "● ON" or "○ OFF"
end)

-- Stats
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -24, 0, 48)
StatsFrame.Position = UDim2.new(0, 12, 0, 232)
StatsFrame.BackgroundColor3 = C.Card
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = Main
corner(StatsFrame, 10)
stroke(StatsFrame, C.Stroke, 1, 0.5)

local StatsLbl = Instance.new("TextLabel")
StatsLbl.Size = UDim2.new(1, -20, 1, 0)
StatsLbl.Position = UDim2.new(0, 12, 0, 0)
StatsLbl.BackgroundTransparency = 1
StatsLbl.Text = "Hops: 0 | Fruits: 0 | Team: ---"
StatsLbl.TextColor3 = C.Text
StatsLbl.Font = Enum.Font.GothamBold
StatsLbl.TextSize = 11
StatsLbl.TextXAlignment = Enum.TextXAlignment.Left
StatsLbl.Parent = StatsFrame

-- ===== FRUIT DETECTION =====
local FRUIT_NAMES = {
    "Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike","Flame","Falcon",
    "Ice","Sand","Dark","Diamond","Light","Rubber","Barrier","Ghost","Magma",
    "Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble",
    "Pain","Blizzard","Gravity","Mammoth","T-Rex","Dough","Shadow","Venom",
    "Control","Spirit","Dragon","Leopard","Kitsune","Yeti","Gas","Snow","Create"
}

local function isFruitName(n)
    n = n:lower()
    for _, fn in ipairs(FRUIT_NAMES) do
        if n == fn:lower() or n:find(fn:lower(), 1, true) then return true end
    end
    return false
end

local function isFruit(obj)
    -- Fruit có thể là Tool, Model, MeshPart, hoặc Part
    if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
        return isFruitName(obj.Name)
    end
    if obj:IsA("Model") then
        -- Check tên model hoặc con của nó
        if isFruitName(obj.Name) then return true end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("MeshPart") or child:IsA("Part") then
                if isFruitName(child.Name) then return true end
            end
        end
    end
    if obj:IsA("MeshPart") or obj:IsA("Part") then
        return isFruitName(obj.Name)
    end
    return false
end

local function getFruitPosition(obj)
    if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
        return obj.Handle, obj.Handle.Position
    end
    if obj:IsA("Model") then
        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if primary then return primary, primary.Position end
    end
    if obj:IsA("BasePart") then
        return obj, obj.Position
    end
    return nil, nil
end

local function getFruits()
    local result = {}
    if not LP.Character then return result end
    local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return result end

    -- Scan Workspace.Fruit (quan trọng - từ log của bạn)
    local fruitFolder = Workspace:FindFirstChild("Fruit")
    if fruitFolder then
        for _, obj in ipairs(fruitFolder:GetChildren()) do
            if isFruit(obj) then
                local part, pos = getFruitPosition(obj)
                if pos then
                    local dist = (myHRP.Position - pos).Magnitude
                    table.insert(result, {
                        Obj = obj, Name = obj.Name, Distance = dist,
                        Position = pos, Part = part
                    })
                end
            end
        end
    end

    -- Scan Workspace trực tiếp (fallback)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isFruit(obj) and obj.Parent ~= fruitFolder then
            local part, pos = getFruitPosition(obj)
            if pos then
                local dist = (myHRP.Position - pos).Magnitude
                table.insert(result, {
                    Obj = obj, Name = obj.Name, Distance = dist,
                    Position = pos, Part = part
                })
            end
        end
    end

    table.sort(result, function(a,b) return a.Distance < b.Distance end)
    return result
end

-- ===== FLY =====
local function flyTo(targetPos, dt)
    if not LP.Character then return false end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dir = targetPos - hrp.Position
    local dist = dir.Magnitude
    if dist < 4 then
        hrp.Velocity = Vector3.zero
        return true
    end
    local step = math.min(FLY_SPEED * dt, dist)
    hrp.CFrame = CFrame.new(hrp.Position + dir.Unit * step)
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    return false
end

-- ===== HOP =====
local function hopServer()
    if isHopping then return end
    isHopping = true

    print("[SNIPER] Hop server...")

    -- Queue load lại script
    local queueFunc = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    if queueFunc then
        pcall(function()
            queueFunc('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
        end)
        print("[SNIPER] Đã queue script reload")
    end

    -- Tìm server
    local servers
    local ok = pcall(function()
        servers = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId ..
            "/servers/Public?sortOrder=Desc&limit=100"
        ))
    end)

    if ok and servers and servers.data then
        local list = {}
        for _, s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(list, s.id)
            end
        end
        if #list > 0 then
            local pick = list[math.random(1, #list)]
            print("[SNIPER] Teleport tới:", pick)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, pick, LP)
            end)
            return
        end
    end

    -- Fallback
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end

-- ===== MAIN LOOP =====
local lastLog = 0

RunService.Heartbeat:Connect(function(dt)
    local teamName = LP.Team and LP.Team.Name or "---"
    StatsLbl.Text = string.format("Hops: %d | Fruits: %d | Team: %s",
        hopCount, fruitFound, teamName)

    if not autoSnipe or isHopping then return end

    local fruits = getFruits()

    -- Log mỗi 2s
    local now = tick()
    if now - lastLog >= 2 then
        lastLog = now
        local folder = Workspace:FindFirstChild("Fruit")
        print(string.format("[SNIPER] Fruit folder: %s | Fruits found: %d",
            folder and (#folder:GetChildren() .. " children") or "NIL",
            #fruits))
    end

    if #fruits == 0 then
        FIName.Text = "Không có fruit"
        FIDist.Text = "Distance: ---"
        return
    end

    local target = fruits[1]
    FIName.Text = target.Name
    FIDist.Text = string.format("Distance: %.0f studs", target.Distance)

    local reached = flyTo(target.Position, dt)

    if reached then
        pcall(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp and target.Part and target.Part.Parent then
                target.Part.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                firetouchinterest(hrp, target.Part, 0)
                task.wait(0.05)
                firetouchinterest(hrp, target.Part, 1)
            end
        end)

        task.wait(0.3)

        if not target.Obj.Parent or (target.Part and not target.Part.Parent) then
            fruitFound = fruitFound + 1
            print("[SNIPER] ✅ Nhặt được:", target.Name, "| Total:", fruitFound)
            task.wait(0.5)
            hopCount = hopCount + 1
            hopServer()
        end
    end
end)

-- Notify
local note = Instance.new("TextLabel")
note.Size = UDim2.new(0, 320, 0, 40)
note.Position = UDim2.new(0.5, -160, 0, 40)
note.BackgroundColor3 = C.Card
note.Text = "  ✅ Fruit Sniper v4 loaded"
note.TextColor3 = C.Green
note.Font = Enum.Font.GothamBold
note.TextSize = 12
note.BorderSizePixel = 0
note.Parent = Gui
corner(note, 10)
stroke(note, C.Green, 1.5, 0.2)
task.delay(3, function()
    tween(note, 0.4, {BackgroundTransparency = 1, TextTransparency = 1})
    task.wait(0.5); note:Destroy()
end)

print("[SNIPER] Loaded | Sea PlaceId:", game.PlaceId)