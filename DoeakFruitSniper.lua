-- =========================================================
-- DOEAK - KAITUN FRUIT v8
-- Fix LocalPlayer nil • Full workspace scan • Smart hop
-- =========================================================

-- ⭐ CHỜ PLAYER LOAD XONG (fix lỗi Character nil)
local Players = game:GetService("Players")
local LP
repeat
    LP = Players.LocalPlayer
    task.wait(0.1)
until LP ~= nil

local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

-- Chờ character load
repeat task.wait(0.1) until LP.Character ~= nil

local SCRIPT_URL  = "https://raw.githubusercontent.com/idkshdcs/doeak_hub-kaitun/main/DoeakFruitSniper.lua"
local FLY_SPEED   = 170
local HOP_TIMEOUT = 20
local KEY_FILE    = "doeak_key.txt"
local SESSION     = 24 * 3600

local VALID_KEYS = {
    ["DOEAK-VIP-2026"]   = true,
    ["KAITUN-FREE-2026"] = true,
    ["DOEAK-KAITUN"]     = true,
    ["FREE-2026"]        = true,
}

-- =========================================================
-- KEY FILE
-- =========================================================
local function readKeyFile()
    local ok, data = pcall(readfile, KEY_FILE)
    if not ok or not data then return nil, 0 end
    local k, e = data:match("^([^|]+)|(%d+)$")
    if not k then return nil, 0 end
    return k, tonumber(e) or 0
end

local function writeKeyFile(k, e)
    pcall(writefile, KEY_FILE, k .. "|" .. tostring(e))
end

local savedKey, savedExpire = readKeyFile()
local hasValidKey = savedKey and VALID_KEYS[savedKey] and savedExpire > os.time()

-- =========================================================
-- PARENT
-- =========================================================
local function getSafeParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return CoreGui
end
local UIParent = getSafeParent()

for _, n in ipairs({"DoeakKeyUI", "DoeakMainUI"}) do
    local o = UIParent:FindFirstChild(n)
    if o then o:Destroy() end
end

local C = {
    Surface = Color3.fromRGB(45, 45, 52),
    Card    = Color3.fromRGB(58, 58, 65),
    Bg      = Color3.fromRGB(35, 35, 42),
    White   = Color3.fromRGB(245, 245, 245),
    Green   = Color3.fromRGB(105, 200, 145),
    Red     = Color3.fromRGB(225, 95, 105),
    Gold    = Color3.fromRGB(255, 200, 60),
    Text    = Color3.fromRGB(245, 245, 248),
    Sub     = Color3.fromRGB(165, 170, 180),
    Muted   = Color3.fromRGB(105, 110, 120),
}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = type(r) == "number" and UDim.new(0, r) or r
    c.Parent = p; return c
end
local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.White
    s.Thickness = th or 1.5
    s.Transparency = tr or 0
    s.Parent = p; return s
end
local function tween(o, t, props)
    TweenService:Create(o, TweenInfo.new(t), props):Play()
end

-- =========================================================
-- KEY UI
-- =========================================================
local function showKeyUI()
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "DoeakKeyUI"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 200
    pcall(function() Gui.Parent = UIParent end)

    local F = Instance.new("Frame")
    F.Size = UDim2.new(0, 340, 0, 250)
    F.Position = UDim2.new(0.5, -170, 0.5, -125)
    F.BackgroundColor3 = C.Surface
    F.BackgroundTransparency = 0.15
    F.BorderSizePixel = 0
    F.Active = true
    F.Draggable = true
    F.Parent = Gui
    corner(F, 16)
    stroke(F, C.White, 2, 0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = "DOEAK - KAITUN FRUIT"
    title.TextColor3 = C.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = F

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Position = UDim2.new(0, 10, 0, 48)
    sub.BackgroundTransparency = 1
    sub.Text = "Nhập key (24h)"
    sub.TextColor3 = C.Sub
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.Parent = F

    local IF = Instance.new("Frame")
    IF.Size = UDim2.new(1, -40, 0, 44)
    IF.Position = UDim2.new(0, 20, 0, 84)
    IF.BackgroundColor3 = C.Bg
    IF.BackgroundTransparency = 0.3
    IF.BorderSizePixel = 0
    IF.Parent = F
    corner(IF, 10)
    stroke(IF, C.White, 1, 0.3)

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Text = ""
    Box.PlaceholderText = "Nhập key..."
    Box.PlaceholderColor3 = C.Muted
    Box.TextColor3 = C.Text
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 13
    Box.ClearTextOnFocus = false
    Box.Parent = IF

    local SB = Instance.new("TextButton")
    SB.Size = UDim2.new(1, -40, 0, 44)
    SB.Position = UDim2.new(0, 20, 0, 140)
    SB.BackgroundColor3 = C.Card
    SB.BackgroundTransparency = 0.1
    SB.Text = "XÁC NHẬN"
    SB.TextColor3 = C.Text
    SB.Font = Enum.Font.GothamBold
    SB.TextSize = 14
    SB.AutoButtonColor = false
    SB.Parent = F
    corner(SB, 10)
    stroke(SB, C.White, 1.5, 0.3)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -40, 0, 20)
    Status.Position = UDim2.new(0, 20, 0, 196)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = C.Sub
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 11
    Status.Parent = F

    SB.MouseButton1Click:Connect(function()
        local entered = Box.Text
        if entered == "" then
            Status.Text = "Chưa nhập key"
            Status.TextColor3 = C.Red
            return
        end
        if VALID_KEYS[entered] then
            writeKeyFile(entered, os.time() + SESSION)
            Status.Text = "✅ OK — khởi động..."
            Status.TextColor3 = C.Green
            task.wait(0.8)
            Gui:Destroy()
            -- queue reload
            local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
            if q then
                pcall(function()
                    q('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
                end)
            end
            loadstring(game:HttpGet(SCRIPT_URL))()
        else
            Status.Text = "❌ Key sai"
            Status.TextColor3 = C.Red
        end
    end)
end

-- =========================================================
-- MAIN
-- =========================================================
local function startMain()
    savedKey, savedExpire = readKeyFile()

    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local CommF_ = Remotes and Remotes:FindFirstChild("CommF_")

    -- Stats persist qua các server
    local genv = getgenv and getgenv() or _G
    if not genv.DoeakStats then
        genv.DoeakStats = {hops = 0, fruits = 0}
    end
    local stats = genv.DoeakStats

    local function queueReload()
        local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
        if q then
            pcall(function()
                q('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
            end)
        end
    end
    queueReload()

    -- Team Pirates
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

    -- NoClip
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

    -- ================ UI ================
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "DoeakMainUI"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 100
    pcall(function() Gui.Parent = UIParent end)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 340, 0, 220)
    Main.Position = UDim2.new(0, 20, 0.3, 0)
    Main.BackgroundColor3 = C.Surface
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui
    corner(Main, 16)
    stroke(Main, C.White, 2, 0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 14)
    title.BackgroundTransparency = 1
    title.Text = "DOEAK - KAITUN FRUIT"
    title.TextColor3 = C.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = Main

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -28, 0, 1)
    div.Position = UDim2.new(0, 14, 0, 48)
    div.BackgroundColor3 = C.White
    div.BackgroundTransparency = 0.7
    div.BorderSizePixel = 0
    div.Parent = Main

    local function makeRow(y, label)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, -10, 0, 22)
        lbl.Position = UDim2.new(0, 18, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.Sub
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = Main

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.5, -10, 0, 22)
        val.Position = UDim2.new(0.5, 2, 0, y)
        val.BackgroundTransparency = 1
        val.Text = "---"
        val.TextColor3 = C.Text
        val.Font = Enum.Font.GothamBold
        val.TextSize = 12
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = Main
        return val
    end

    local vFruit = makeRow(58, "Fruit:")
    local vHop   = makeRow(84, "Hop:")
    local vTime  = makeRow(110, "Time:")
    local vKey   = makeRow(136, "Key:")

    -- Status
    local vStatus = Instance.new("TextLabel")
    vStatus.Size = UDim2.new(1, -28, 0, 18)
    vStatus.Position = UDim2.new(0, 14, 0, 162)
    vStatus.BackgroundTransparency = 1
    vStatus.Text = "Đang khởi động..."
    vStatus.TextColor3 = C.Sub
    vStatus.Font = Enum.Font.Gotham
    vStatus.TextSize = 11
    vStatus.TextXAlignment = Enum.TextXAlignment.Center
    vStatus.Parent = Main

    -- ================ FRUIT SCAN (FULL WORKSPACE) ================
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
            if n == fn:lower() then return true end
        end
        return false
    end

    local function isFruit(obj)
        local cls = obj.ClassName
        if cls == "Tool" and obj:FindFirstChild("Handle") then
            return isFruitName(obj.Name)
        end
        if cls == "Model" then
            if isFruitName(obj.Name) then return true end
        end
        if cls == "MeshPart" or cls == "Part" then
            if isFruitName(obj.Name) then return true end
        end
        return false
    end

    local function getPart(obj)
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            return obj.Handle, obj.Handle.Position
        end
        if obj:IsA("Model") then
            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if p then return p, p.Position end
        end
        if obj:IsA("BasePart") then
            return obj, obj.Position
        end
        return nil, nil
    end

    -- Cache fruits - scan mỗi 0.3s
    local fruitCache = {}
    task.spawn(function()
        while Gui.Parent do
            local list = {}
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                -- Scan toàn bộ workspace
                local ok, all = pcall(function()
                    return Workspace:GetDescendants()
                end)
                if ok and all then
                    for _, obj in ipairs(all) do
                        if isFruit(obj) then
                            local p, pos = getPart(obj)
                            if pos then
                                local d = (myHRP.Position - pos).Magnitude
                                table.insert(list, {
                                    Obj = obj, Name = obj.Name, Distance = d,
                                    Position = pos, Part = p
                                })
                            end
                        end
                    end
                end
                table.sort(list, function(a,b) return a.Distance < b.Distance end)
            end
            fruitCache = list
            task.wait(0.3)
        end
    end)

    -- ================ FLY ================
    local function flyTo(target, dt)
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local dir = target - hrp.Position
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

    -- ================ SMART HOP ================
    local isHopping = false

    local function hop()
        if isHopping then return false end
        isHopping = true
        vStatus.Text = "Đang tìm server..."

        queueReload()

        local pool = {}
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?sortOrder=Desc&limit=100"
            ))
        end)

        if ok and data and data.data then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId
                   and s.playing < s.maxPlayers
                   and s.playing >= 5 then  -- có ít nhất 5 người
                    table.insert(pool, {id = s.id, playing = s.playing})
                end
            end
        end

        -- Shuffle để random
        for i = #pool, 2, -1 do
            local j = math.random(i)
            pool[i], pool[j] = pool[j], pool[i]
        end

        -- Ưu tiên server đông
        table.sort(pool, function(a, b) return a.playing > b.playing end)

        vStatus.Text = string.format("Hop... (%d server)", #pool)

        for i = 1, math.min(3, #pool) do
            local ok2 = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, pool[i].id, LP)
            end)
            if ok2 then
                task.delay(5, function() isHopping = false end)
                return true
            end
        end

        -- Fallback: teleport ngẫu nhiên
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
        task.delay(5, function() isHopping = false end)
        return true
    end

    -- ================ KEY EXPIRY CHECK ================
    task.spawn(function()
        while true do
            task.wait(5)
            local k, e = readKeyFile()
            if not k or not VALID_KEYS[k] or e <= os.time() then
                pcall(delfile, KEY_FILE)
                Gui:Destroy()
                showKeyUI()
                break
            end
        end
    end)

    -- ================ MAIN LOOP ================
    local noFruitTimer = 0
    local lastHopAttempt = 0

    RunService.Heartbeat:Connect(function(dt)
        -- update stats
        local keyLeft = savedExpire - os.time()
        vHop.Text = tostring(stats.hops)
        vTime.Text = string.format("%dh %dm",
            math.floor(keyLeft / 3600),
            math.floor((keyLeft % 3600) / 60))
        vKey.Text = savedKey and savedKey:sub(1, 12) .. "..." or "---"

        if isHopping then return end

        local fruits = fruitCache

        -- Kaitun: 20s không có fruit → hop
        if #fruits == 0 then
            vFruit.Text = "None"
            noFruitTimer = noFruitTimer + dt
            vStatus.Text = string.format("Chờ fruit... %.0fs / 20s", noFruitTimer)

            if noFruitTimer >= HOP_TIMEOUT then
                noFruitTimer = 0
                stats.hops = stats.hops + 1
                hop()
            end
            return
        end

        noFruitTimer = 0
        local target = fruits[1]
        vFruit.Text = target.Name
        vStatus.Text = string.format("Farming %s (%.0f)", target.Name, target.Distance)

        local reached = flyTo(target.Position, dt)
        if reached then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp and target.Part and target.Part.Parent then
                pcall(function()
                    target.Part.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                    firetouchinterest(hrp, target.Part, 0)
                    task.wait(0.05)
                    firetouchinterest(hrp, target.Part, 1)
                end)
            end
            task.wait(0.3)
            if not target.Obj.Parent or (target.Part and not target.Part.Parent) then
                stats.fruits = stats.fruits + 1
                task.wait(0.5)
                stats.hops = stats.hops + 1
                hop()
            end
        end
    end)

    print("[DOEAK] ✅ Loaded — running on", game.PlaceId)
end

-- =========================================================
-- ENTRY
-- =========================================================
if hasValidKey then
    startMain()
else
    showKeyUI()
end
