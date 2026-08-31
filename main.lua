getgenv().MM2Hub = getgenv().MM2Hub or {}
local S = getgenv().MM2Hub

-- ══════════ SERVICES ══════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ══════════ DEFAULTS ══════════
S.Aimbot        = S.Aimbot or false
S.FOV           = S.FOV or 120
S.Smoothness    = S.Smoothness or 0.6
S.ShowFOVCircle = S.ShowFOVCircle or false
S.AimPart       = S.AimPart or "Head"
S.AutoShoot     = S.AutoShoot or false
S.ShootDelay    = S.ShootDelay or 0.4
S.AutoKnife     = S.AutoKnife or false
S.KillOnSight   = S.KillOnSight or false
S.ESP_M         = S.ESP_M or false
S.ESP_S         = S.ESP_S or false
S.ESP_I         = S.ESP_I or false
S.ESP_Box       = S.ESP_Box or false
S.ESP_Name      = S.ESP_Name or false
S.ESP_Tracer    = S.ESP_Tracer or false
S.ESP_Coin      = S.ESP_Coin or false
S.ESP_Gun       = S.ESP_Gun or false
S.ESP_Spanner   = S.ESP_Spanner or false
S.ESP_Crossbow  = S.ESP_Crossbow or false
S.WalkSpeed     = S.WalkSpeed or 16
S.JumpPower     = S.JumpPower or 50
S.NoClip        = S.NoClip or false
S.Fly           = S.Fly or false
S.FlySpeed      = S.FlySpeed or 50
S.InfiniteJump  = S.InfiniteJump or false
S.AutoCollect   = S.AutoCollect or false
S.CoinMagnet    = S.CoinMagnet or false
S.MagnetRadius  = S.MagnetRadius or 50
S.AutoGrabGun   = S.AutoGrabGun or false
S.AutoEquipGun  = S.AutoEquipGun or false
S.AutoGrabSpanner = S.AutoGrabSpanner or false
S.AutoGrabKnife = S.AutoGrabKnife or false
S.CrossbowMode  = S.CrossbowMode or false
S.Fullbright    = S.Fullbright or false
S.NoFog         = S.NoFog or false
S.CameraFOV     = S.CameraFOV or 70
S.Crosshair     = S.Crosshair or false
S.RainbowLight  = S.RainbowLight or false
S.AntiAfk       = S.AntiAfk or false
S.AntiFall      = S.AntiFall or false
S.AutoRespawn   = S.AutoRespawn or false
S.AutoKill      = S.AutoKill or false
S.KillRange     = S.KillRange or 25
S.TeleportKill  = S.TeleportKill or false
S.KillAura      = S.KillAura or false
S.AutoWin       = S.AutoWin or false
S.SmartMode     = S.SmartMode or false
S.LoopDelay     = S.LoopDelay or 0.5
S.RainbowUI     = S.RainbowUI or false
S.Accent        = S.Accent or Color3.fromRGB(255, 45, 85)
S.DebugLogs     = S.DebugLogs or false

-- ══════════ HELPERS ══════════
local function Char(p) return p and p.Character end
local function HRP(p) local c = Char(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function Human(p) local c = Char(p); return c and c:FindFirstChildOfClass("Humanoid") end

local function Log(...) if S.DebugLogs then print("[MM2HUB]", ...) end end

local function GetRole(p)
    local c = Char(p)
    if not c then return "Unknown" end
    local hasKnife, hasGun = false, false
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:find("gun") or n:find("pistol") or n:find("luger") then
                hasGun = true
            elseif n ~= "spanner" and n ~= "coin" and n ~= "map" then
                hasKnife = true
            end
        end
    end
    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetRole(p) == "Murderer" then return p end
    end
    return nil
end

local function GetSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetRole(p) == "Sheriff" then return p end
    end
    return nil
end

local function FindItems(pattern)
    local list = {}
    for _, v in pairs(Workspace:GetChildren()) do
        local n = v.Name:lower()
        if v:IsA("Tool") and n:find(pattern) then
            table.insert(list, v)
        elseif v:IsA("Model") and n:find(pattern) then
            table.insert(list, v)
        elseif v:IsA("Model") then
            local t = v:FindFirstChildOfClass("Tool")
            if t and t.Name:lower():find(pattern) then table.insert(list, v) end
        end
    end
    return list
end

local function ItemPos(v)
    if v:IsA("Tool") then
        local h = v:FindFirstChild("Handle")
        return h and h.Position or v:GetPivot().Position
    end
    return v:GetPivot().Position
end

local function TpTo(pos)
    local hrp = HRP(LP)
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    end
end

local function AimAt(target)
    local c = Char(target)
    if not c then return end
    local part = S.AimPart == "Head" and c:FindFirstChild("Head") or HRP(target)
    if part and Camera then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, part.Position), S.Smoothness)
    end
end

local function GetGunTool()
    local c = Char(LP)
    local g = c and (c:FindFirstChild("Gun") or c:FindFirstChild("Crossbow"))
    if not g then g = LP.Backpack:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Crossbow") end
    return g
end

local function GetKnifeTool()
    local c = Char(LP)
    for _, v in pairs(c and c:GetChildren() or {}) do
        if v:IsA("Tool") and v.Name:lower() ~= "gun" and v.Name:lower() ~= "spanner" then return v end
    end
    for _, v in pairs(LP.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower() ~= "gun" and v.Name:lower() ~= "spanner" then return v end
    end
    return nil
end

local function Equip(tool)
    if not tool then return end
    local hum = Human(LP)
    if hum then pcall(function() hum:EquipTool(tool) end) end
end

local function ShootGun()
    local gun = GetGunTool()
    if gun then
        Equip(gun)
        pcall(function() gun:Activate() end)
        for _, c in pairs(gun:GetChildren()) do
            if c:IsA("RemoteEvent") then pcall(function() c:FireServer() end) end
        end
    end
end

local function GrabGun()
    local items = FindItems("gun")
    if #items > 0 then
        TpTo(ItemPos(items[1]))
        task.wait(0.25)
        for _, v in pairs(items) do
            local t = v:IsA("Tool") and v or v:FindFirstChildOfClass("Tool")
            if t then pcall(function() t.Parent = LP.Backpack end) end
        end
    end
end

local function GrabSpanner()
    local items = FindItems("spanner")
    if #items > 0 then
        TpTo(ItemPos(items[1]))
        task.wait(0.25)
        for _, v in pairs(items) do
            local t = v:IsA("Tool") and v or v:FindFirstChildOfClass("Tool")
            if t then pcall(function() t.Parent = LP.Backpack end) end
        end
    end
end

local function KillMurderer()
    local m = GetMurderer()
    if not m then return end
    AimAt(m)
    if S.TeleportKill or S.KillRange > 999 then TpTo(HRP(m).Position) end
    local gun = GetGunTool()
    if gun then
        ShootGun()
    else
        local knife = GetKnifeTool()
        if knife then
            Equip(knife)
            task.wait(0.15)
            pcall(function() knife:Activate() end)
        else
            GrabGun()
        end
    end
end

-- ══════════ FLY ══════════
local flyActive = false
local flyBV, flyBG
local function ToggleFly(on)
    flyActive = on
    S.Fly = on
    local hrp = HRP(LP)
    if on and hrp then
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9); flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); flyBG.Parent = hrp
    elseif flyBV then
        pcall(function() flyBV:Destroy() end); flyBV = nil
        pcall(function() flyBG:Destroy() end); flyBG = nil
    end
end

RunService.RenderStepped:Connect(function()
    if flyActive and HRP(LP) and Camera then
        local hrp = HRP(LP)
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        dir = dir.Unit * S.FlySpeed
        flyBV.Velocity = dir
        flyBG.CFrame = Camera.CFrame
    end
end)

-- ══════════ LOOP: AIMBOT ══════════
RunService.RenderStepped:Connect(function()
    if S.Aimbot then
        local m = GetMurderer()
        if m then
            local c = Char(m)
            local part = S.AimPart == "Head" and c and c:FindFirstChild("Head") or HRP(m)
            if part then
                local sp, on = Camera:WorldToScreenPoint(part.Position)
                if on then
                    local center = Camera.ViewportSize / 2
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist <= S.FOV then AimAt(m) end
                end
            end
        end
    end
end)

-- ══════════ LOOP: AUTO SHOOT / KILL ══════════
task.spawn(function()
    while task.wait(S.ShootDelay) do
        local m = GetMurderer()
        if m and Human(m) and Human(m).Health > 0 then
            if S.AutoShoot and GetGunTool() then ShootGun() end
            if S.KillOnSight and GetGunTool() then ShootGun() end
            if S.AutoKill then KillMurderer() end
            if S.KillAura and HRP(m) and HRP(LP) then
                if (HRP(m).Position - HRP(LP).Position).Magnitude <= S.KillRange then KillMurderer() end
            end
            if S.AutoWin then
                local gun = GetGunTool()
                if gun then AimAt(m); ShootGun() else GrabGun() end
            end
        end
    end
end)

-- ══════════ LOOP: FARM / ITEMS ══════════
task.spawn(function()
    while task.wait(S.LoopDelay) do
        if S.AutoGrabGun and not GetGunTool() then GrabGun() end
        if S.AutoGrabSpanner then GrabSpanner() end
        if S.AutoEquipGun and GetGunTool() then Equip(GetGunTool()) end
        if S.CrossbowMode then
            local cb = LP.Backpack:FindFirstChild("Crossbow") or (Char(LP) and Char(LP):FindFirstChild("Crossbow"))
            if cb then Equip(cb) end
        end
        if S.AutoCollect then
            local coins = FindItems("coin")
            if #coins > 0 then
                TpTo(ItemPos(coins[1]))
                task.wait(0.2)
            end
        end
        if S.SmartMode and GetRole(LP) == "Innocent" and S.AutoCollect then
            local coins = FindItems("coin")
            if #coins > 0 then TpTo(ItemPos(coins[1])) end
        end
    end
end)

-- ══════════ LOOP: COIN MAGNET ══════════
task.spawn(function()
    while task.wait(0.1) do
        if S.CoinMagnet and HRP(LP) then
            local hrp = HRP(LP)
            for _, coin in pairs(FindItems("coin")) do
                if (ItemPos(coin) - hrp.Position).Magnitude <= S.MagnetRadius then
                    pcall(function() coin:PivotTo(CFrame.new(hrp.Position + Vector3.new(0, 2, 0))) end)
                end
            end
        end
    end
end)

-- ══════════ LOOP: MOVEMENT / MISC ══════════
RunService.Stepped:Connect(function()
    local hum = Human(LP)
    if hum then
        if hum.WalkSpeed ~= S.WalkSpeed then hum.WalkSpeed = S.WalkSpeed end
        if hum.JumpPower ~= S.JumpPower then hum.JumpPower = S.JumpPower end
    end
    if S.NoClip and Char(LP) then
        for _, v in pairs(Char(LP):GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    if S.CameraFOV and Camera and Camera.FieldOfView ~= S.CameraFOV then Camera.FieldOfView = S.CameraFOV end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump and Human(LP) then
        pcall(function() Human(LP):ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- ══════════ LOOP: ANTI AFK / RESPAWN ══════════
task.spawn(function()
    while task.wait(30) do
        if S.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(0, 0))
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0))
            end)
        end
        if S.AutoRespawn and Human(LP) and Human(LP).Health <= 0 then
            pcall(function() LP:LoadCharacter() end)
        end
    end
end)

-- ══════════ VISUALS: FULLBRIGHT / FOG / RAINBOW ══════════
task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        if S.Fullbright then
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        end
        if S.NoFog then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        end
        if S.RainbowLight then
            hue = (hue + 0.002) % 1
            Lighting.Ambient = Color3.fromHSV(hue, 0.4, 1)
            Lighting.OutdoorAmbient = Color3.fromHSV(hue, 0.4, 1)
        end
        if S.RainbowUI then
            pcall(function()
                if OrionLib and OrionLib.Theme then
                    OrionLib.Theme.Background = Color3.fromHSV(hue, 0.5, 0.15)
                    OrionLib.Theme.Main = Color3.fromHSV(hue, 0.7, 0.25)
                end
            end)
        end
    end
end)

-- ══════════ DRAWINGS: FOV CIRCLE + CROSSHAIR ══════════
local fovCircle = Drawing.new("Circle"); fovCircle.Thickness = 2; fovCircle.Radius = S.FOV; fovCircle.Color = S.Accent; fovCircle.Visible = false
local xhairH = Drawing.new("Line"); xhairH.Thickness = 2; xhairH.Color = Color3.new(1, 0, 0); xhairH.Visible = false
local xhairV = Drawing.new("Line"); xhairV.Thickness = 2; xhairV.Color = Color3.new(1, 0, 0); xhairV.Visible = false

RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2
    fovCircle.Visible = S.ShowFOVCircle and S.Aimbot
    fovCircle.Position = center
    fovCircle.Radius = S.FOV
    fovCircle.Color = S.Accent
    xhairH.Visible = S.Crosshair; xhairH.From = Vector2.new(center.X - 10, center.Y); xhairH.To = Vector2.new(center.X + 10, center.Y)
    xhairV.Visible = S.Crosshair; xhairV.From = Vector2.new(center.X, center.Y - 10); xhairV.To = Vector2.new(center.X, center.Y + 10)
end)

-- ══════════ ESP: PLAYERS ══════════
local espObjs = {}
local function GetESP(p)
    if not espObjs[p] then
        local e = {}
        e.box = Drawing.new("Square"); e.box.Thickness = 2; e.box.Filled = false
        e.name = Drawing.new("Text"); e.name.Center = true; e.name.Size = 14; e.name.Outline = true
        e.tracer = Drawing.new("Line"); e.tracer.Thickness = 1
        espObjs[p] = e
    end
    return espObjs[p]
end

local function UpdatePlayerESP(p, color, show)
    local e = GetESP(p)
    local hrp = HRP(p)
    local hum = Human(p)
    if not (hrp and hum and hum.Health > 0) then
        e.box.Visible = false; e.name.Visible = false; e.tracer.Visible = false
        return
    end
    local pos, on = Camera:WorldToScreenPoint(hrp.Position)
    if not on then
        e.box.Visible = false; e.name.Visible = false; e.tracer.Visible = false
        return
    end
    local scale = 500 / (Camera.CFrame.Position - hrp.Position).Magnitude
    local h = math.clamp(3.5 * scale, 10, 500)
    local w = h * 0.65
    e.box.Visible = S.ESP_Box and show
    e.box.Color = color
    e.box.Position = Vector2.new(pos.X - w / 2, pos.Y - h)
    e.box.Size = Vector2.new(w, h)
    e.name.Visible = S.ESP_Name and show
    e.name.Color = color
    e.name.Position = Vector2.new(pos.X, pos.Y - h - 14)
    e.name.Text = p.Name .. " [" .. GetRole(p) .. "]"
    e.tracer.Visible = S.ESP_Tracer and show
    e.tracer.Color = color
    e.tracer.From = Camera.ViewportSize / 2
    e.tracer.To = Vector2.new(pos.X, pos.Y)
end

task.spawn(function()
    while task.wait() do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local role = GetRole(p)
                local show = false
                local col = Color3.new(1, 1, 1)
                if role == "Murderer" and S.ESP_M then show = true; col = Color3.fromRGB(255, 30, 30) end
                if role == "Sheriff" and S.ESP_S then show = true; col = Color3.fromRGB(30, 150, 255) end
                if role == "Innocent" and S.ESP_I then show = true; col = Color3.fromRGB(120, 255, 120) end
                UpdatePlayerESP(p, col, show)
            end
        end
    end
end)

-- ══════════ ESP: ITEMS ══════════
local itemESP = {}
local function GetItemESP(i)
    if not itemESP[i] then
        itemESP[i] = Drawing.new("Text")
        itemESP[i].Center = true
        itemESP[i].Size = 13
        itemESP[i].Outline = true
    end
    return itemESP[i]
end

task.spawn(function()
    local idx = 0
    while task.wait(0.1) do
        local configs = {
            {enabled = S.ESP_Coin, pattern = "coin", label = "🪙 COIN", color = Color3.fromRGB(255, 215, 0)},
            {enabled = S.ESP_Gun, pattern = "gun", label = "🔫 GUN", color = Color3.fromRGB(255, 160, 0)},
            {enabled = S.ESP_Spanner, pattern = "spanner", label = "🔧 SPANNER", color = Color3.fromRGB(0, 200, 255)},
            {enabled = S.ESP_Crossbow, pattern = "crossbow", label = "🏹 CROSSBOW", color = Color3.fromRGB(200, 0, 255)},
        }
        idx = 0
        for _, cfg in pairs(configs) do
            if cfg.enabled then
                local items = FindItems(cfg.pattern)
                for i = 1, math.min(#items, 8) do
                    idx = idx + 1
                    local e = GetItemESP(idx)
                    local pos, on = Camera:WorldToScreenPoint(ItemPos(items[i]))
                    if on then
                        e.Visible = true
                        e.Position = Vector2.new(pos.X, pos.Y - 20)
                        e.Text = cfg.label
                        e.Color = cfg.color
                    else
                        e.Visible = false
                    end
                end
            end
        end
        for i = idx + 1, #itemESP do
            if itemESP[i] then itemESP[i].Visible = false end
        end
    end
end)

-- ══════════ UI ══════════
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "🔪 MM2 DELTA HUB 🔫 — KEYLESS",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MM2DeltaHub"
})

-- ─── TAB 1: MAIN ───
local T1 = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T1:AddParagraph("Welcome", "Keyless MM2 script for Delta. 22 tabs, no key system, no gated content. Load and go.")
T1:AddLabel("✅ STATUS: KEYLESS | LOADED")
T1:AddButton({Name = "Destroy UI", Callback = function() OrionLib:Destroy() end})
T1:AddButton({Name = "Rejoin Server", Callback = function()
    pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
end})

-- ─── TAB 2: AIMBOT ───
local T2 = Window:MakeTab({Name = "Aimbot", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T2:AddToggle({Name = "Aimbot", Default = S.Aimbot, Callback = function(v) S.Aimbot = v end})
T2:AddSlider({Name = "FOV (degrees)", Min = 10, Max = 180, Default = S.FOV, Increment = 1, Callback = function(v) S.FOV = v end})
T2:AddSlider({Name = "Smoothness", Min = 1, Max = 100, Default = S.Smoothness * 100, Increment = 1, Callback = function(v) S.Smoothness = v / 100 end})
T2:AddToggle({Name = "Show FOV Circle", Default = S.ShowFOVCircle, Callback = function(v) S.ShowFOVCircle = v end})
T2:AddDropdown({Name = "Aim Part", Default = S.AimPart, Options = {"Head", "HumanoidRootPart"}, Callback = function(v) S.AimPart = v end})
T2:AddToggle({Name = "Aim Only With Gun", Default = false, Callback = function(v) S.AimOnlyGun = v end})

-- ─── TAB 3: COMBAT ───
local T3 = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T3:AddToggle({Name = "Auto Shoot Murderer", Default = S.AutoShoot, Callback = function(v) S.AutoShoot = v end})
T3:AddSlider({Name = "Shoot Delay (s)", Min = 1, Max = 20, Default = S.ShootDelay * 10, Increment = 1, Callback = function(v) S.ShootDelay = v / 10 end})
T3:AddButton({Name = "🔫 SHOOT NOW", Callback = function()
    local m = GetMurderer()
    if m then AimAt(m) end
    ShootGun()
end})
T3:AddToggle({Name = "Auto Knife (when no gun)", Default = S.AutoKnife, Callback = function(v) S.AutoKnife = v end})
T3:AddToggle({Name = "Kill On Sight", Default = S.KillOnSight, Callback = function(v) S.KillOnSight = v end})

-- ─── TAB 4: ESP ───
local T4 = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T4:AddToggle({Name = "ESP — Murderer (red)", Default = S.ESP_M, Callback = function(v) S.ESP_M = v end})
T4:AddToggle({Name = "ESP — Sheriff (blue)", Default = S.ESP_S, Callback = function(v) S.ESP_S = v end})
T4:AddToggle({Name = "ESP — Innocents (green)", Default = S.ESP_I, Callback = function(v) S.ESP_I = v end})
T4:AddSection({Name = "ESP Style"})
T4:AddToggle({Name = "Boxes", Default = S.ESP_Box, Callback = function(v) S.ESP_Box = v end})
T4:AddToggle({Name = "Names + Role", Default = S.ESP_Name, Callback = function(v) S.ESP_Name = v end})
T4:AddToggle({Name = "Tracers", Default = S.ESP_Tracer, Callback = function(v) S.ESP_Tracer = v end})
T4:AddSection({Name = "Item ESP"})
T4:AddToggle({Name = "Coins", Default = S.ESP_Coin, Callback = function(v) S.ESP_Coin = v end})
T4:AddToggle({Name = "Gun", Default = S.ESP_Gun, Callback = function(v) S.ESP_Gun = v end})
T4:AddToggle({Name = "Spanner", Default = S.ESP_Spanner, Callback = function(v) S.ESP_Spanner = v end})
T4:AddToggle({Name = "Crossbow", Default = S.ESP_Crossbow, Callback = function(v) S.ESP_Crossbow = v end})

-- ─── TAB 5: MOVEMENT ───
local T5 = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T5:AddSlider({Name = "WalkSpeed", Min = 16, Max = 250, Default = S.WalkSpeed, Increment = 1, Callback = function(v) S.WalkSpeed = v end})
T5:AddSlider({Name = "JumpPower", Min = 50, Max = 500, Default = S.JumpPower, Increment = 10, Callback = function(v) S.JumpPower = v end})
T5:AddToggle({Name = "Noclip", Default = S.NoClip, Callback = function(v) S.NoClip = v end})
T5:AddToggle({Name = "Fly (WASD + Space/Ctrl)", Default = S.Fly, Callback = function(v) ToggleFly(v) end})
T5:AddSlider({Name = "Fly Speed", Min = 10, Max = 300, Default = S.FlySpeed, Increment = 5, Callback = function(v) S.FlySpeed = v end})
T5:AddToggle({Name = "Infinite Jump", Default = S.InfiniteJump, Callback = function(v) S.InfiniteJump = v end})

-- ─── TAB 6: FARM ───
local T6 = Window:MakeTab({Name = "Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T6:AddToggle({Name = "Auto Collect Coins", Default = S.AutoCollect, Callback = function(v) S.AutoCollect = v end})
T6:AddToggle({Name = "Coin Magnet", Default = S.CoinMagnet, Callback = function(v) S.CoinMagnet = v end})
T6:AddSlider({Name = "Magnet Radius", Min = 10, Max = 200, Default = S.MagnetRadius, Increment = 5, Callback = function(v) S.MagnetRadius = v end})
T6:AddButton({Name = "Collect All Coins Now", Callback = function()
    for _, coin in pairs(FindItems("coin")) do
        TpTo(ItemPos(coin))
        task.wait(0.15)
    end
end})
T6:AddToggle({Name = "Smart Farm (only as Innocent)", Default = S.SmartMode, Callback = function(v) S.SmartMode = v end})

-- ─── TAB 7: GUNS ───
local T7 = Window:MakeTab({Name = "Guns", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T7:AddToggle({Name = "Auto Grab Gun (teleport to drop)", Default = S.AutoGrabGun, Callback = function(v) S.AutoGrabGun = v end})
T7:AddToggle({Name = "Auto Equip Gun", Default = S.AutoEquipGun, Callback = function(v) S.AutoEquipGun = v end})
T7:AddButton({Name = "Grab Gun Now", Callback = GrabGun})
T7:AddButton({Name = "Equip Gun", Callback = function() Equip(GetGunTool()) end})
T7:AddToggle({Name = "Crossbow Mode (auto-equip crossbow)", Default = S.CrossbowMode, Callback = function(v) S.CrossbowMode = v end})
T7:AddToggle({Name = "Keep Gun Equipped", Default = false, Callback = function(v) S.KeepGun = v end})

-- ─── TAB 8: ITEMS ───
local T8 = Window:MakeTab({Name = "Items", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T8:AddToggle({Name = "Auto Grab Spanner", Default = S.AutoGrabSpanner, Callback = function(v) S.AutoGrabSpanner = v end})
T8:AddToggle({Name = "Auto Grab Knife", Default = S.AutoGrabKnife, Callback = function(v) S.AutoGrabKnife = v end})
T8:AddButton({Name = "Grab Spanner Now", Callback = GrabSpanner})
T8:AddButton({Name = "Drop Current Tool", Callback = function()
    local c = Char(LP)
    if c then
        for _, v in pairs(c:GetChildren()) do
            if v:IsA("Tool") then pcall(function() v.Parent = Workspace end) end
        end
    end
end})
T8:AddSlider({Name = "Item Loop Delay (s)", Min = 1, Max = 30, Default = S.LoopDelay * 10, Increment = 1, Callback = function(v) S.LoopDelay = v / 10 end})

-- ─── TAB 9: VISUALS ───
local T9 = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T9:AddToggle({Name = "Fullbright", Default = S.Fullbright, Callback = function(v) S.Fullbright = v end})
T9:AddToggle({Name = "No Fog", Default = S.NoFog, Callback = function(v) S.NoFog = v end})
T9:AddSlider({Name = "Camera FOV", Min = 70, Max = 120, Default = S.CameraFOV, Increment = 1, Callback = function(v) S.CameraFOV = v end})
T9:AddToggle({Name = "Crosshair", Default = S.Crosshair, Callback = function(v) S.Crosshair = v end})
T9:AddToggle({Name = "Rainbow Lighting", Default = S.RainbowLight, Callback = function(v) S.RainbowLight = v end})
T9:AddColorpicker({Name = "Accent Color", Default = S.Accent, Callback = function(v) S.Accent = v end})

-- ─── TAB 10: TELEPORTS ───
local T10 = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T10:AddButton({Name = "Teleport to Murderer", Callback = function() local m = GetMurderer(); if m and HRP(m) then TpTo(HRP(m).Position) end end})
T10:AddButton({Name = "Teleport to Coin", Callback = function() local c = FindItems("coin"); if #c > 0 then TpTo(ItemPos(c[1])) end end})
T10:AddButton({Name = "Teleport to Gun", Callback = function() local g = FindItems("gun"); if #g > 0 then TpTo(ItemPos(g[1])) end end})
T10:AddButton({Name = "Teleport to Spanner", Callback = function() local s = FindItems("spanner"); if #s > 0 then TpTo(ItemPos(s[1])) end end})
T10:AddButton({Name = "Teleport to Crossbow", Callback = function() local x = FindItems("crossbow"); if #x > 0 then TpTo(ItemPos(x[1])) end end})
T10:AddButton({Name = "Teleport to Random Player", Callback = function()
    local ps = Players:GetPlayers()
    local r = ps[math.random(1, #ps)]
    if r and HRP(r) then TpTo(HRP(r).Position) end
end})

-- ─── TAB 11: SAFETY ───
local T11 = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T11:AddToggle({Name = "Anti AFK", Default = S.AntiAfk, Callback = function(v) S.AntiAfk = v end})
T11:AddToggle({Name = "Auto Respawn", Default = S.AutoRespawn, Callback = function(v) S.AutoRespawn = v end})
T11:AddToggle({Name = "Anti Fall Damage", Default = S.AntiFall, Callback = function(v) S.AntiFall = v end})
T11:AddButton({Name = "🚨 PANIC — Disable Everything", Callback = function()
    for k, _ in pairs(S) do
        if type(S[k]) == "boolean" then S[k] = false end
    end
    ToggleFly(false)
    pcall(function()
        for _, e in pairs(espObjs) do e.box.Visible = false; e.name.Visible = false; e.tracer.Visible = false end
        for _, e in pairs(itemESP) do e.Visible = false end
    end)
    OrionLib:MakeNotification({Name = "Panic", Content = "All features disabled", Time = 3})
end})

-- ─── TAB 12: PLAYER ───
local roleLabel = T1
local T12 = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local myRole = T12:AddLabel({Name = "Role: ..."})
T12:AddButton({Name = "Refresh Role", Callback = function() myRole:Set("Role: " .. GetRole(LP)) end})
T12:AddToggle({Name = "Speed Boost After Kill", Default = false, Callback = function(v) S.SpeedBoost = v end})
T12:AddSlider({Name = "Boost Speed", Min = 16, Max = 250, Default = 50, Increment = 1, Callback = function(v) S.BoostSpeed = v end})
T12:AddToggle({Name = "Show Role Above My Head", Default = false, Callback = function(v) S.ShowMyRole = v end})

task.spawn(function()
    while task.wait(1) do
        pcall(function() myRole:Set("Role: " .. GetRole(LP)) end)
    end
end)

-- ─── TAB 13: WORLD ───
local T13 = Window:MakeTab({Name = "World", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T13:AddToggle({Name = "Disable Shadows", Default = false, Callback = function(v)
    if v then
        pcall(function()
            for _, s in pairs(Lighting:GetDescendants()) do
                if s:IsA("Shadow") then s.Enabled = false end
            end
        end)
    end
end})
T13:AddSlider({Name = "Ambient Brightness", Min = 0, Max = 3, Default = 1, Increment = 0.1, Callback = function(v) Lighting.Brightness = v end})
T13:AddButton({Name = "Set Time: Day", Callback = function() Lighting.ClockTime = 14 end})
T13:AddButton({Name = "Set Time: Night", Callback = function() Lighting.ClockTime = 0 end})
T13:AddButton({Name = "Set Time: Sunset", Callback = function() Lighting.ClockTime = 18 end})

-- ─── TAB 14: KILL ───
local T14 = Window:MakeTab({Name = "Kill", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T14:AddToggle({Name = "Auto Kill Murderer", Default = S.AutoKill, Callback = function(v) S.AutoKill = v end})
T14:AddButton({Name = "💀 Kill Murderer NOW", Callback = KillMurderer})
T14:AddSlider({Name = "Kill Range", Min = 5, Max = 200, Default = S.KillRange, Increment = 1, Callback = function(v) S.KillRange = v end})
T14:AddToggle({Name = "Teleport Kill (always teleport to target)", Default = S.TeleportKill, Callback = function(v) S.TeleportKill = v end})
T14:AddToggle({Name = "Kill Aura (teleport + hit in range)", Default = S.KillAura, Callback = function(v) S.KillAura = v end})

-- ─── TAB 15: MISC ───
local T15 = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T15:AddButton({Name = "Server Hop", Callback = function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end})
T15:AddToggle({Name = "Auto Rejoin on Death", Default = false, Callback = function(v) S.AutoRejoin = v end})
T15:AddToggle({Name = "Sprint with Shift (x2 speed)", Default = false, Callback = function(v) S.Sprint = v end})
T15:AddToggle({Name = "No Walk Animation Glitch Fix", Default = false, Callback = function(v) S.FixAnim = v end})

RunService.RenderStepped:Connect(function()
    if S.Sprint and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Human(LP) then
        Human(LP).WalkSpeed = S.WalkSpeed * 2
    end
end)

-- ─── TAB 16: SETTINGS ───
local T16 = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T16:AddParagraph("Config", "Orion auto-saves settings on leave. You can also save/load manually.")
T16:AddButton({Name = "💾 Save Config", Callback = function()
    pcall(function()
        writefile("MM2DeltaHub_Config.json", HttpService:JSONEncode(S))
        OrionLib:MakeNotification({Name = "Saved", Content = "Config saved to file", Time = 3})
    end)
end})
T16:AddButton({Name = "📂 Load Config", Callback = function()
    pcall(function()
        local data = HttpService:JSONDecode(readfile("MM2DeltaHub_Config.json"))
        for k, v in pairs(data) do S[k] = v end
        OrionLib:MakeNotification({Name = "Loaded", Content = "Config loaded — restart script for full effect", Time = 3})
    end)
end})
T16:AddButton({Name = "Reset Config", Callback = function()
    pcall(function() writefile("MM2DeltaHub_Config.json", "{}") end)
    OrionLib:MakeNotification({Name = "Reset", Content = "Config cleared", Time = 3})
end})
T16:AddToggle({Name = "Debug Logs", Default = S.DebugLogs, Callback = function(v) S.DebugLogs = v end})

-- ─── TAB 17: INFO ───
local T17 = Window:MakeTab({Name = "Info", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T17:AddParagraph("MM2 DELTA HUB", "Version 2.0 | Built with Orion Library")
T17:AddLabel("🔑 KEYLESS — no key, no linkvertise, no gates")
T17:AddLabel("⚡ Delta / Android / iOS compatible")
T17:AddLabel("🛠️ For educational/testing use only")
T17:AddButton({Name = "Copy Loadstring Line", Callback = function()
    pcall(function() setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()') end)
    OrionLib:MakeNotification({Name = "Copied", Content = "Orion loader line copied", Time = 3})
end})

-- ─── TAB 18: CONTROLS / KEYBINDS ───
local T18 = Window:MakeTab({Name = "Controls", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T18:AddKeybind({Name = "Toggle Aimbot", Default = Enum.KeyCode.Q, Callback = function()
    S.Aimbot = not S.Aimbot
    OrionLib:MakeNotification({Name = "Aimbot", Content = tostring(S.Aimbot), Time = 1.5})
end})
T18:AddKeybind({Name = "SHOOT", Default = Enum.KeyCode.F, Callback = function()
    local m = GetMurderer(); if m then AimAt(m) end
    ShootGun()
end})
T18:AddKeybind({Name = "Teleport to Murderer", Default = Enum.KeyCode.T, Callback = function()
    local m = GetMurderer(); if m and HRP(m) then TpTo(HRP(m).Position) end
end})
T18:AddKeybind({Name = "Toggle Fly", Default = Enum.KeyCode.X, Callback = function()
    ToggleFly(not flyActive)
end})

-- ─── TAB 19: WEAPONS ───
local T19 = Window:MakeTab({Name = "Weapons", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T19:AddDropdown({Name = "Weapon Mode", Default = "Auto", Options = {"Auto", "Gun", "Knife", "Crossbow"}, Callback = function(v)
    S.WeaponMode = v
    if v == "Gun" then Equip(GetGunTool()) end
    if v == "Crossbow" then
        local cb = LP.Backpack:FindFirstChild("Crossbow") or (Char(LP) and Char(LP):FindFirstChild("Crossbow"))
        if cb then Equip(cb) end
    end
    if v == "Knife" then Equip(GetKnifeTool()) end
end})
T19:AddButton({Name = "Equip Selected", Callback = function()
    if S.WeaponMode == "Gun" then Equip(GetGunTool()) end
    if S.WeaponMode == "Knife" then Equip(GetKnifeTool()) end
    if S.WeaponMode == "Crossbow" then
        local cb = LP.Backpack:FindFirstChild("Crossbow") or (Char(LP) and Char(LP):FindFirstChild("Crossbow"))
        if cb then Equip(cb) end
    end
end})
T19:AddToggle({Name = "Auto Switch to Gun on Grab", Default = false, Callback = function(v) S.AutoSwitchGun = v end})

-- ─── TAB 20: AUTO ───
local T20 = Window:MakeTab({Name = "Auto", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T20:AddToggle({Name = "Auto Win Round (aim + shoot murderer)", Default = S.AutoWin, Callback = function(v) S.AutoWin = v end})
T20:AddToggle({Name = "Auto Loot (gun + coins)", Default = false, Callback = function(v)
    S.AutoLoot = v
    if v then S.AutoGrabGun = true; S.AutoCollect = true end
end})
T20:AddToggle({Name = "Auto Grab Everything (gun + spanner + coins)", Default = false, Callback = function(v)
    if v then S.AutoGrabGun = true; S.AutoGrabSpanner = true; S.AutoCollect = true end
end})
T20:AddSlider({Name = "Master Loop Delay (s)", Min = 1, Max = 30, Default = S.LoopDelay * 10, Increment = 1, Callback = function(v) S.LoopDelay = v / 10 end})

-- ─── TAB 21: DEBUG ───
local T21 = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T21:AddButton({Name = "Print Murderer", Callback = function()
    local m = GetMurderer(); print("[MM2HUB] Murderer:", m and m.Name or "none found")
end})
T21:AddButton({Name = "Print My Role", Callback = function() print("[MM2HUB] Role:", GetRole(LP)) end})
T21:AddButton({Name = "Print Coin Count", Callback = function() print("[MM2HUB] Coins:", #FindItems("coin")) end})
T21:AddButton({Name = "Clear All ESP", Callback = function()
    pcall(function()
        for _, e in pairs(espObjs) do e.box.Visible = false; e.name.Visible = false; e.tracer.Visible = false end
        for _, e in pairs(itemESP) do e.Visible = false end
    end)
end})

-- ─── TAB 22: THEME ───
local T22 = Window:MakeTab({Name = "Theme", Icon = "rbxassetid://4483345998", PremiumOnly = false})
T22:AddToggle({Name = "Rainbow UI", Default = S.RainbowUI, Callback = function(v) S.RainbowUI = v end})
T22:AddColorpicker({Name = "UI Background", Default = Color3.fromRGB(25, 25, 35), Callback = function(v)
    pcall(function()
        if OrionLib and OrionLib.Theme then
            OrionLib.Theme.Background = v
            OrionLib.Theme.Main = v
            OrionLib.Theme.Title = v
        end
    end)
end})
T22:AddColorpicker({Name = "UI Accent", Default = S.Accent, Callback = function(v)
    S.Accent = v
    pcall(function()
        if OrionLib and OrionLib.Theme then OrionLib.Theme.Accent = v end
    end)
end})

-- ══════════ INIT ══════════
OrionLib:Init()
print("✅ [MM2HUB] Loaded — KEYLESS | 22 tabs active")
OrionLib:MakeNotification({Name = "MM2 DELTA HUB", Content = "Loaded keyless — enjoy 🔪🔫", Time = 5})
