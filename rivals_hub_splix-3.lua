local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local UIS        = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local env    = getgenv()

task.spawn(function()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Splix"))()

local _updateRot = RS.Remotes.Replication.Fighter.UpdateCameraRotation

local window = library:new({name = "Rivals Hub", color = Color3.fromRGB(103, 93, 190)})

local _rivReady = false

local function _Notify(msg) pcall(function() window:notify(msg) end) end

-- 값 저장 테이블 (Splix는 Toggles/Options 글로벌 없음)
local Toggles = {}
local Options  = {}

local function _toggle(id, section, cfg)
    local val = cfg.def or false
    Toggles[id] = {Value = val}
    section:toggle({
        name = cfg.name,
        def  = val,
        callback = function(v)
            Toggles[id].Value = v
            if cfg.callback then cfg.callback(v) end
        end,
    })
end

local function _slider(id, section, cfg)
    local val = cfg.def or cfg.min or 0
    Options[id] = {Value = val}
    section:slider({
        name     = cfg.name,
        def      = val,
        min      = cfg.min,
        max      = cfg.max,
        rounding = cfg.rounding ~= nil and cfg.rounding or 0,
        measuring = cfg.suffix or "",
        ticking  = false,
        callback = function(v)
            Options[id].Value = v
            if cfg.callback then cfg.callback(v) end
        end,
    })
end

local function _dropdown(id, section, cfg)
    local val = cfg.options and cfg.options[cfg.def or 1] or ""
    Options[id] = {Value = val}
    section:dropdown({
        name    = cfg.name,
        def     = val,
        max     = #cfg.options,
        options = cfg.options,
        callback = function(v)
            Options[id].Value = v
            if cfg.callback then cfg.callback(v) end
        end,
    })
end

local function _textbox(id, section, cfg)
    local val = cfg.def or ""
    Options[id] = {Value = val}
    section:textbox({
        name        = cfg.name,
        def         = val,
        placeholder = cfg.placeholder or "",
        callback    = function(v)
            Options[id].Value = v
        end,
    })
end

local function _button(section, name, cb)
    section:button({name = name, callback = cb})
end

local function _label(section, text)
    pcall(function() section:label({name = text}) end)
end

-- ===== COMBAT =====
local CombatTab = window:page({name = "Combat"})
local AimbotBox     = CombatTab:section({name = "Aimbot",    side = "left",  size = 250})
local TriggerbotBox = CombatTab:section({name = "Triggerbot",side = "left",  size = 250})
local WeaponBox     = CombatTab:section({name = "Weapon",    side = "left",  size = 250})
local SilentAimBox  = CombatTab:section({name = "Silent Aim",side = "right", size = 250})
local RagebotBox    = CombatTab:section({name = "Ragebot",   side = "right", size = 250})
local ChecksBox     = CombatTab:section({name = "Checks",    side = "right", size = 250})

_toggle("AimbotEnabled", AimbotBox, {name="Aimbot", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startAimbot(v)
end})
_dropdown("AimbotTargetPart",    AimbotBox, {name="Target Part",    options={"Head","Torso","HumanoidRootPart"}, def=1})
_dropdown("AimbotBlacklistPart", AimbotBox, {name="Blacklist Part", options={"None","Head","Torso"},            def=1})
_slider("AimbotSmooth",  AimbotBox, {name="Smoothing", def=10,  min=1,   max=50,  rounding=0})
_slider("AimbotFOV",     AimbotBox, {name="FOV",       def=150, min=10,  max=800, rounding=0, suffix="px"})
_toggle("AimbotShowFOV", AimbotBox, {name="Show FOV",  def=false})

_toggle("TriggerEnabled", TriggerbotBox, {name="Triggerbot", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startTriggerbot(v)
end})
_slider("TriggerDelay",   TriggerbotBox, {name="Delay",    def=0,  min=0, max=500, rounding=0, suffix="ms"})
_slider("TriggerFOV",     TriggerbotBox, {name="Set FOV",  def=10, min=1, max=200, rounding=0, suffix="px"})
_slider("TriggerScanFOV", TriggerbotBox, {name="Scan FOV", def=30, min=1, max=400, rounding=0, suffix="px"})
_dropdown("TriggerBlacklistPart", TriggerbotBox, {name="Blacklist Part", options={"None","Head","Torso"}, def=1})
_toggle("TriggerShowFOV", TriggerbotBox, {name="Show FOV", def=false})

_toggle("Wallbang", WeaponBox, {name="Wallbang", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startWallbang(v)
end})
_toggle("NoRecoil",  WeaponBox, {name="No Recoil / No Spread", def=false, callback=function(v)
    if _rivReady then env._rivNoRecoil = v end
end})
_toggle("RapidFire", WeaponBox, {name="Rapid Fire", def=false, callback=function(v)
    if _rivReady then env._rivRapidFire = v end
end})
_toggle("FastADS", WeaponBox, {name="Fast ADS", def=false, callback=function(v)
    if _rivReady then env._riv_startFastADS(v) end
end})
_toggle("NoEquipAnim", WeaponBox, {name="No Equip Animation", def=false, callback=function(v)
    if _rivReady then env._riv_startNoEquipAnim(v) end
end})
_toggle("HitsoundEnabled", WeaponBox, {name="Hitsound", def=false, callback=function(v)
    if _rivReady then env._riv_startHitsound(v) end
end})
_textbox("HitsoundID", WeaponBox, {name="Sound ID", def="rbxassetid://4764109000"})
_toggle("BigGun", WeaponBox, {name="Big Gun", def=false, callback=function(v)
    if _rivReady then env._riv_startBigGun(v) end
end})
_slider("BigGunSize", WeaponBox, {name="Size Multiplier", def=2, min=0.1, max=10, rounding=1})

_toggle("SilentAim", SilentAimBox, {name="Silent Aim", def=false, callback=function(v)
    if _rivReady then
        env._silentRageActive = v
        if v then env._tcAddConsumer() else env._tcRemoveConsumer() end
    end
end})
_dropdown("RageAimPart", SilentAimBox, {name="Aim Part", options={"Head","Torso"}, def=1})
_slider("RageFOV",       SilentAimBox, {name="FOV", def=250, min=10, max=800, rounding=0, suffix="px"})
_toggle("SilentShowFOV", SilentAimBox, {name="Show FOV", def=false})

_toggle("RageEnabled", RagebotBox, {name="Ragebot", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startRagebot(v)
end})
_toggle("VoidSpam", RagebotBox, {name="Void Spam", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startVoidSpam(v)
end})
_dropdown("PreferredWeapon", RagebotBox, {name="Preferred Weapon", options={"Primary","Secondary","Melee"}, def=1, callback=function(v)
    env._rivPreferredWeapon = v:lower()
end})
_toggle("VoidHide", RagebotBox, {name="Void Hide", def=false, callback=function(v)
    env._rivVoidHide = v
end})
_slider("VoidHideTime",   RagebotBox, {name="Hide Time",   def=2, min=0.1, max=5, rounding=2, suffix="s"})
_slider("VoidAttackTime", RagebotBox, {name="Attack Time", def=1, min=0.1, max=5, rounding=2, suffix="s"})

_toggle("TeamCheck",   ChecksBox, {name="Team Check",         def=true})
_toggle("VisualCheck", ChecksBox, {name="Visual Check",       def=false})
_toggle("AntiKatana",  ChecksBox, {name="Anti-Katana/Shield", def=false})

-- ===== PLAYER =====
local PlayerTab  = window:page({name = "Player"})
local FovBox     = PlayerTab:section({name = "FOV Changer",  side = "left",  size = 250})
local MovBox     = PlayerTab:section({name = "Movement",     side = "left",  size = 250})
local AntiEffBox = PlayerTab:section({name = "Anti Effects", side = "left",  size = 250})
local FinishBox  = PlayerTab:section({name = "Finisher",     side = "left",  size = 250})
local TPBox      = PlayerTab:section({name = "Third Person", side = "left",  size = 250})
local RespBox    = PlayerTab:section({name = "Auto Respawn", side = "left",  size = 250})
local NoclipBox  = PlayerTab:section({name = "Noclip",       side = "left",  size = 250})
local AABox      = PlayerTab:section({name = "Anti-Aim",     side = "right", size = 250})
local FlyBox     = PlayerTab:section({name = "Fly",          side = "right", size = 250})
local DevBox     = PlayerTab:section({name = "Device Spoof", side = "right", size = 250})

_slider("FOVValue", FovBox, {name="Field of View", def=70, min=40, max=120, rounding=0, suffix="deg", callback=function(v)
    Camera.FieldOfView = v
end})
_button(FovBox, "Reset FOV", function()
    Camera.FieldOfView = 70
    Options.FOVValue.Value = 70
end)

_slider("WalkSpeed", MovBox, {name="Walk Speed", def=16, min=16, max=200, rounding=0, callback=function(v)
    local char = LP.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.WalkSpeed = v end
end})
_slider("JumpPower", MovBox, {name="Jump Power", def=50, min=50, max=300, rounding=0, callback=function(v)
    local char = LP.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end})

_toggle("AntiFlash", AntiEffBox, {name="Anti Flash", def=false, callback=function(v)
    if _rivReady then env._riv_startAntiFlash(v) end
end})
_toggle("NoSmoke", AntiEffBox, {name="No Smoke", def=false, callback=function(v)
    if _rivReady then env._riv_startNoSmoke(v) end
end})

_toggle("FinisherChanger", FinishBox, {name="Finisher Changer", def=false, callback=function(v)
    if _rivReady then env._riv_startFinisherChanger(v) end
end})
_textbox("FinisherName", FinishBox, {name="Finisher Name", def="Chark Attack"})

_toggle("ThirdPerson", TPBox, {name="Third Person", def=false, callback=function(v)
    if not _rivReady then return end
    if v then Toggles.UnlockMouse.Value = false end
    env._riv_startTP(v)
end})
_toggle("UnlockMouse", TPBox, {name="Unlock Mouse", def=false, callback=function(v)
    if not _rivReady then return end
    if v then Toggles.ThirdPerson.Value = false end
    env._riv_startUnlockMouse(v)
end})

_toggle("AutoRespawn", RespBox, {name="Auto Respawn", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startAutoRespawn(v)
end})
_slider("RespawnDelay", RespBox, {name="Delay", def=0, min=0, max=5, rounding=1, suffix="s"})

_toggle("NoclipEnabled", NoclipBox, {name="Noclip", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startNoclip(v)
end})

_toggle("AntiAim", AABox, {name="Anti-Aim", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startAA(v)
end})
_dropdown("AAMethod",    AABox, {name="Method",       options={"Spinbot","Backwards","Right","Left"}, def=2})
_slider("AASpinSpeed",   AABox, {name="Spin Speed",   def=15, min=1,   max=30,  rounding=0, suffix="x"})
_slider("AACustomAngle", AABox, {name="Custom Angle", def=0,  min=-90, max=90,  rounding=0, suffix="deg"})
_toggle("AAJitter",      AABox, {name="Jitter",       def=false})
_slider("AAJitterRange", AABox, {name="Jitter Range", def=35, min=0,   max=180, rounding=0, suffix="deg"})
_toggle("AAPitchEnabled",AABox, {name="Pitch",        def=false})
_slider("AAPitchAngle",  AABox, {name="Pitch Angle",  def=0,  min=-90, max=90,  rounding=0, suffix="deg"})

_toggle("FlyEnabled", FlyBox, {name="Fly", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startFly(v)
end})
_slider("FlySpeed", FlyBox, {name="Speed", def=50, min=10, max=300, rounding=0, suffix="st/s"})

_dropdown("DeviceSpoof", DevBox, {name="Device", options={"None","Computer","Mobile","Console"}, def=1})
_button(DevBox, "Apply Spoof", function()
    local map = {Computer="MouseKeyboard", Mobile="Touch", Console="Gamepad"}
    local val = Options.DeviceSpoof and Options.DeviceSpoof.Value
    if not val or val == "None" then return end
    pcall(function()
        RS.Remotes.Replication.Fighter.SetControls:FireServer(map[val])
    end)
end)

-- ===== MISC =====
env._targetList     = {}
env._targetListMode = "blacklist"

local MiscTab    = window:page({name = "Misc"})
local TLBox      = MiscTab:section({name = "Target List",   side = "left",  size = 250})
local CollectBox = MiscTab:section({name = "Collect",       side = "left",  size = 250})
local ProjTPBox  = MiscTab:section({name = "Projectile TP", side = "left",  size = 250})
local SoundBox   = MiscTab:section({name = "Sound Spammer", side = "right", size = 250})
local DuelBanBox = MiscTab:section({name = "Duel Ban",      side = "right", size = 250})

_dropdown("TargetListMode", TLBox, {name="Mode", options={"Blacklist","Whitelist"}, def=1, callback=function(v)
    env._targetListMode = v:lower()
end})

local function _tlGetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then names[#names+1] = p.Name end
    end
    table.sort(names)
    if #names == 0 then names = {"(없음)"} end
    return names
end

Options.TargetListPlayers = {Value = ""}
local _tlDropRef = nil
pcall(function()
    _tlDropRef = TLBox:dropdown({
        name = "Player", def = "", max = 20, options = _tlGetPlayerNames(),
        callback = function(v) Options.TargetListPlayers.Value = v end,
    })
end)

_button(TLBox, "Add Selected", function()
    local name = Options.TargetListPlayers.Value
    if not name or name == "(없음)" or name == "" then return end
    env._targetList[name] = true
    _Notify("추가: "..name)
end)
_button(TLBox, "Remove Selected", function()
    local name = Options.TargetListPlayers.Value
    if not name or name == "(없음)" or name == "" then return end
    env._targetList[name] = nil
    _Notify("제거: "..name)
end)
_button(TLBox, "Refresh / Add All", function()
    local names = _tlGetPlayerNames()
    if #names > 0 and names[1] ~= "(없음)" then
        for _, n in ipairs(names) do env._targetList[n] = true end
        _Notify("전체 추가 ("..#names.."명)")
    end
end)
_button(TLBox, "Clear", function()
    env._targetList = {}
    _Notify("목록 초기화")
end)

_toggle("CollectHP", CollectBox, {name="Collect Health", def=false, callback=function(v)
    env._rivCollectHP = v
    if _rivReady then env._riv_startDrop(v or env._rivCollectAmmo) end
end})
_toggle("CollectAmmo", CollectBox, {name="Collect Ammo", def=false, callback=function(v)
    env._rivCollectAmmo = v
    if _rivReady then env._riv_startDrop(v or env._rivCollectHP) end
end})

_toggle("ProjTPEnabled", ProjTPBox, {name="Projectile TP", def=false, callback=function(v)
    if not _rivReady then return end
    env._riv_startProjTP(v)
end})
_dropdown("ProjTPTarget", ProjTPBox, {name="Target", options={"Closest","Aimbot Target"}, def=1})

_toggle("SoundSpammer", SoundBox, {name="Sound Spammer", def=false, callback=function(v)
    if _rivReady then env._riv_startSoundSpammer(v) end
end})
_slider("SoundSpamInterval", SoundBox, {name="Interval", def=0.2, min=0.05, max=1.0, rounding=2, suffix="s"})

_toggle("AutoBanEnabled", DuelBanBox, {name="Auto Ban", def=false, callback=function(v)
    env._riv_startAutoBan(v)
end})
_dropdown("AutoBanTarget", DuelBanBox, {name="Ban Target", options={"Riot Shield + Katana","Riot Shield","Katana"}, def=1})

-- ===== VISUALS =====
local VisualsTab = window:page({name = "Visuals"})
local ESPBox     = VisualsTab:section({name = "ESP",            side = "left",  size = 250})
local TargetBox  = VisualsTab:section({name = "Target",         side = "left",  size = 250})
local TracerBox  = VisualsTab:section({name = "Bullet Tracers", side = "right", size = 250})

local function _espAnyOn()
    return Toggles.ESPBox.Value or Toggles.ESPTracer.Value or Toggles.ESPName.Value
        or Toggles.ESPHealth.Value or Toggles.ESPDist.Value or Toggles.ESPSkeleton.Value
end
_toggle("ESPBox",      ESPBox, {name="Box",         def=false, callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPTracer",   ESPBox, {name="Tracers",     def=false, callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPName",     ESPBox, {name="Names",       def=true,  callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPHealth",   ESPBox, {name="Health Bar",  def=true,  callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPDist",     ESPBox, {name="Distance",    def=false, callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPSkeleton", ESPBox, {name="Skeleton",    def=false, callback=function(v) if _rivReady then env._riv_startESP(v or _espAnyOn()) end end})
_toggle("ESPChams",    ESPBox, {name="Chams",       def=false, callback=function(v) if _rivReady then env._riv_startChams(v) end end})
_toggle("LandmineESP", ESPBox, {name="Landmine ESP",def=false, callback=function(v) if _rivReady then env._riv_startLandmineESP(v) end end})

-- Chams 컬러는 고정값 사용 (Splix colorpicker 없음)
Options.ESPChamsColor   = {Value = Color3.new(1,0,0)}
Options.ESPChamsOutline = {Value = Color3.new(1,1,1)}
Options.LandmineESPColor = {Value = Color3.fromRGB(255,80,80)}

_toggle("TargetDot",       TargetBox, {name="Red Dot on Target", def=false, callback=function(v) if _rivReady then env._riv_startTargetDot(v) end end})
_toggle("TargetFOVCircle", TargetBox, {name="FOV Circle",        def=false, callback=function(v) if _rivReady then env._riv_startFOVCircle(v) end end})
_slider("TargetFOVRadius", TargetBox, {name="FOV Radius", def=120, min=10, max=400, rounding=0})

_toggle("BulletTracerEnemy", TracerBox, {name="Enemy Tracers", def=false})
_toggle("BulletTracerLocal", TracerBox, {name="Local Tracers", def=false, callback=function(v)
    if _rivReady then env._riv_startBulletTracer(v) end
end})
_slider("BulletTracerDuration", TracerBox, {name="Duration", def=0.3, min=0.05, max=2.0, rounding=2, suffix="s"})
Options.BulletTracerEnemyCol = {Value = Color3.new(1,0.2,0.2)}
Options.BulletTracerLocalCol = {Value = Color3.new(0.2,0.8,1)}

-- ===== SETTINGS =====
local SettingsTab = window:page({name = "Settings"})
local UnloadBox   = SettingsTab:section({name = "Unload",   side = "left",  size = 250})
local AutoBox     = SettingsTab:section({name = "Autoload", side = "left",  size = 250})
local CfgBox      = SettingsTab:section({name = "Config",   side = "right", size = 250})

_button(UnloadBox, "Unload Hub", function()
    local _toggleKeys = {
        "RageEnabled","SilentAim","Wallbang","NoRecoil","RapidFire",
        "FastADS","NoEquipAnim","HitsoundEnabled",
        "TeamCheck","VisualCheck","AntiKatana",
        "AntiFlash","NoSmoke","VoidSpam","ThirdPerson","FlyEnabled","AutoRespawn",
        "AntiAim","ESPBox","ESPTracer","ESPName","ESPHealth","ESPDist",
        "ESPSkeleton","ESPChams","TargetDot","TargetFOVCircle",
        "BulletTracerEnemy","BulletTracerLocal","LandmineESP",
        "SoundSpammer","AutoBanEnabled","ProjTPEnabled","CollectHP","CollectAmmo",
    }
    for _, k in ipairs(_toggleKeys) do
        if Toggles[k] then pcall(function() Toggles[k].Value = false end) end
    end
    local _stopFns = {
        "_riv_startAimbot","_riv_startTriggerbot",
        "_riv_startRagebot","_riv_startWallbang",
        "_riv_startPulse","_riv_startAntiFlash","_riv_startVoidSpam",
        "_riv_startTP","_riv_startFly","_riv_startAutoRespawn",
        "_riv_startAA","_riv_startESP","_riv_startChams",
        "_riv_startTargetDot","_riv_startFOVCircle",
    }
    for _, fn in ipairs(_stopFns) do
        if type(env[fn]) == "function" then pcall(env[fn], false) end
    end
    env._silentRageActive = false
    env._rivNoRecoil      = false
    env._rivRapidFire     = false
    _Notify("Rivals Hub 언로드 완료")
end)

_button(AutoBox, "Set as Autoload", function()
    local loaderScript = [[
if not game:IsLoaded() then game.Loaded:Wait() end
local rivals = {4922741943, 2791838005, 129604661913557, 71874690745115}
local ok = false
for _, id in ipairs(rivals) do
    if game.PlaceId == id then ok = true break end
end
if not ok then
    local name = (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)).Name or ""
    if name:lower():find("rivals") then ok = true end
end
if not ok then return end
task.wait(2)
local ok2, src = pcall(readfile, "Scripts/Rivals_Hub.lua")
if ok2 and src then loadstring(src)()
else warn("[RivalsHub Autoload] Scripts/Rivals_Hub.lua 를 찾을 수 없음") end
]]
    local ok, err = pcall(function()
        makefolder("autoexec")
        writefile("autoexec/RivalsHub_autoload.lua", loaderScript)
    end)
    if ok then _Notify("Autoload 설정 완료")
    else      _Notify("실패: "..tostring(err)) end
end)
_button(AutoBox, "Remove Autoload", function()
    pcall(function() delfile("autoexec/RivalsHub_autoload.lua") end)
    _Notify("Autoload 제거됨")
end)

local function _getCfgList()
    pcall(function() makefolder("RivalsHub") makefolder("RivalsHub/configs") end)
    local ok, files = pcall(listfiles, "RivalsHub/configs")
    if not ok or not files then return {"(없음)"} end
    local names = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n then names[#names+1] = n end
    end
    return #names > 0 and names or {"(없음)"}
end

local function _saveConfig(name)
    if not name or name == "" or name == "(없음)" then return false, "이름 없음" end
    local ok, err = pcall(function()
        makefolder("RivalsHub"); makefolder("RivalsHub/configs")
        local data = {}
        for k, v in pairs(Toggles) do data["T_"..k] = v.Value end
        for k, v in pairs(Options) do
            if k ~= "CfgNewName" and k ~= "CfgSelect" then
                local ok2, val = pcall(function() return v.Value end)
                if ok2 and type(val) ~= "userdata" then data["O_"..k] = val end
            end
        end
        writefile("RivalsHub/configs/"..name..".json", game:GetService("HttpService"):JSONEncode(data))
    end)
    return ok, err
end

local function _loadConfig(name)
    if not name or name == "" or name == "(없음)" then return false, "이름 없음" end
    local ok, err = pcall(function()
        local raw  = readfile("RivalsHub/configs/"..name..".json")
        local data = game:GetService("HttpService"):JSONDecode(raw)
        for k, v in pairs(data) do
            if k:sub(1,2) == "T_" then
                local key = k:sub(3)
                if Toggles[key] then Toggles[key].Value = v end
            elseif k:sub(1,2) == "O_" then
                local key = k:sub(3)
                if Options[key] then Options[key].Value = v end
            end
        end
    end)
    return ok, err
end

Options.CfgSelect  = {Value = "(없음)"}
Options.CfgNewName = {Value = "default"}

pcall(function()
    CfgBox:dropdown({
        name = "Config", def = "(없음)", max = 20, options = _getCfgList(),
        callback = function(v) Options.CfgSelect.Value = v end,
    })
end)
_button(CfgBox, "Refresh", function()
    _Notify("목록 새로고침됨")
end)
_button(CfgBox, "Load Selected", function()
    local ok, err = _loadConfig(Options.CfgSelect.Value)
    if ok then _Notify("로드됨: "..Options.CfgSelect.Value)
    else      _Notify("로드 실패: "..tostring(err)) end
end)
_button(CfgBox, "Delete Selected", function()
    local name = Options.CfgSelect.Value
    if not name or name == "(없음)" then return end
    pcall(function() delfile("RivalsHub/configs/"..name..".json") end)
    _Notify("삭제됨: "..name)
end)
_textbox("CfgNewName", CfgBox, {name="새 Config 이름", def="default"})
_button(CfgBox, "Save As", function()
    local name = Options.CfgNewName.Value or "default"
    if name == "" then name = "default" end
    local ok, err = _saveConfig(name)
    if ok then _Notify("저장됨: "..name)
    else      _Notify("저장 실패: "..tostring(err)) end
end)

-- 로직에서 참조하는 Keypickers 더미 (AA/Fly 등 keybind 없음)
Keypickers = {}

task.spawn(function()
    local ok, err = xpcall(function()
    local PS        = LP.PlayerScripts
    local updateRot = _updateRot

    local _tcTarget    = nil
    local _tcActive    = false
    local _tcConsumers = 0

    local function _tcIsEnemy(p)
        local inList = env._targetList[p.Name] == true
        local mode   = env._targetListMode or 'blacklist'
        if mode == 'blacklist' and inList then return false end
        if mode == 'whitelist' and not inList and next(env._targetList) ~= nil then return false end
        if not Toggles.TeamCheck.Value then return true end
        local myTeam = LP:GetAttribute("TeamID")
        local theirTeam = p:GetAttribute("TeamID")
        if myTeam == nil or theirTeam == nil then return true end
        return theirTeam ~= myTeam
    end

    local function _getEnemyWeapon(p)
        local vms = workspace:FindFirstChild("ViewModels")
        if not vms then return "" end
        local pName = p.Name
        for _, model in ipairs(vms:GetChildren()) do
            if model:IsA("Model") then
                local sep = model.Name:find(" - ", 1, true)
                if sep and model.Name:sub(1, sep-1) == pName then
                    return model.Name:sub(sep+3):lower()
                end
            end
        end
        return ""
    end

    local function _tcGetClosest()
        local best, minD = nil, math.huge
        local mpos = UIS:GetMouseLocation()
        for _, p in next, Players:GetPlayers() do
            if p == LP or not _tcIsEnemy(p) then continue end
            if Toggles.AntiKatana and Toggles.AntiKatana.Value then
                local wpn = _getEnemyWeapon(p)
                if wpn:find("katana",1,true) or wpn:find("riot",1,true) or wpn:find("shield",1,true) then continue end
            end
            local char = p.Character; if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then continue end
            local s, vis = Camera:WorldToViewportPoint(hrp.Position)
            if not vis then continue end
            local d = (mpos - Vector2.new(s.X, s.Y)).Magnitude
            if d < minD then minD = d; best = p end
        end
        return best
    end
    local function _tcAddConsumer()
        _tcConsumers += 1
        if _tcConsumers == 1 then
            _tcActive = true
            task.spawn(function()
                while _tcActive do _tcTarget = _tcGetClosest(); task.wait(0.1) end
                _tcTarget = nil
            end)
        end
    end
    local function _tcRemoveConsumer()
        _tcConsumers = math.max(0, _tcConsumers - 1)
        if _tcConsumers == 0 then _tcActive = false end
    end
    env._tcIsEnemy       = _tcIsEnemy
    env._tcAddConsumer   = _tcAddConsumer
    env._tcRemoveConsumer = _tcRemoveConsumer

    env._silentRageActive = false
    local _okC,  ClientItem  = pcall(require, PS.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
    local _okG,  GunItem     = pcall(require, PS.Modules.ItemTypes.Gun)
    local _okU,  Utility     = pcall(require, RS.Modules.Utility)
    local _okF,  FighterCtrl  = pcall(require, PS.Controllers.FighterController)
    local _okEC, EnemyCtrl   = pcall(require, PS.Controllers.EnemyController)
    local _okE,  EnumLib      = pcall(require, RS.Modules.EnumLibrary)
    local _useItemRemote     = RS.Remotes.Replication.Fighter.UseItem
    local _ssEnum; pcall(function() _ssEnum = EnumLib:ToEnum("StartShooting") end)
    print("[Rivals Hub] ClientItem:", _okC, "GunItem:", _okG, "Utility:", _okU, "FighterCtrl:", _okF, "EnumLib:", _okE)

    local function _getEquippedObjId()
        if not (_okF and FighterCtrl) then return nil end
        local lf = FighterCtrl.LocalFighter; if not lf then return nil end
        local item = lf.EquippedItem; if not item then return nil end
        local ok, id = pcall(function() return item:Get("ObjectID") end)
        if ok and id then return id end
        ok, id = pcall(function() return item.Data and item.Data.ObjectID end)
        return ok and id or nil
    end

    local _lastShootFire = 0

    local function _buildShotData(originPos, targetPart)
        local targetPos = targetPart.Position
        local lookCF = CFrame.lookAt(originPos, targetPos)
        local lX, lY, lZ = lookCF:ToOrientation()
        local originStruct = {
            [utf8.char(0)] = originPos.X, [utf8.char(1)] = originPos.Y, [utf8.char(2)] = originPos.Z,
            [utf8.char(3)] = lX, [utf8.char(4)] = lY, [utf8.char(5)] = lZ,
        }
        local relCF = targetPart.CFrame:ToObjectSpace(CFrame.new(targetPos))
        local rX, rY, rZ = relCF:ToOrientation()
        return {
            [utf8.char(1)] = {
                [utf8.char(0)] = originStruct,
                [utf8.char(1)] = originStruct,
                [utf8.char(2)] = targetPart,
                [utf8.char(3)] = {
                    [utf8.char(0)] = relCF.X, [utf8.char(1)] = relCF.Y, [utf8.char(2)] = relCF.Z,
                    [utf8.char(3)] = rX, [utf8.char(4)] = rY, [utf8.char(5)] = rZ,
                },
            },
        }
    end

    local function _fireShootFrom(originPos, targetHead)
        if not (_okU and Utility and _ssEnum and _useItemRemote) then return end
        local now = tick()
        if now - _lastShootFire < 0.45 then return end
        _lastShootFire = now
        local objId = _getEquippedObjId(); if not objId then return end
        local tPos = targetHead.Position

        if Toggles.RageEnabled and Toggles.RageEnabled.Value then
            local myHRP    = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
            local shootPos = myHRP and myHRP.Position or Camera.CFrame.Position
            local shotData = _buildShotData(shootPos, targetHead)
            pcall(function() _useItemRemote:FireServer(objId, _ssEnum, shotData, nil) end)
            return
        end

        local _dir = originPos - tPos
        if _dir.Magnitude > 45 then originPos = tPos + _dir.Unit * 45 end
        local shotData = _buildShotData(originPos, targetHead)
        pcall(function() _useItemRemote:FireServer(objId, _ssEnum, shotData, nil) end)
    end

    local function _fireShoot(targetHead)
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        _fireShootFrom(myHRP and myHRP.Position or Camera.CFrame.Position, targetHead)
    end

    local _wbOrigFn     = nil
    local _wbDsyncConn  = nil
    local _wbDsyncTgt   = nil
    local _wbDsyncClean = nil

    local function _wbGetTarget()
        local mpos = UIS:GetMouseLocation()
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP or not _tcIsEnemy(p) then continue end
            local char = p.Character
            local hrp  = char and char:FindFirstChild('HumanoidRootPart')
            if not hrp then continue end
            local sp, vis = Camera:WorldToViewportPoint(hrp.Position)
            if not vis then continue end
            local d = (mpos - Vector2.new(sp.X, sp.Y)).Magnitude
            if d < bestD then bestD = d; best = p end
        end
        return best
    end

    local function _wbDsyncStop()
        _wbDsyncTgt = nil
        if _wbDsyncConn then _wbDsyncConn:Disconnect(); _wbDsyncConn = nil end
        RunService:UnbindFromRenderStep('_wbDs')
    end

    local function _wbDsyncStart(target)
        if _wbDsyncConn then _wbDsyncConn:Disconnect(); _wbDsyncConn = nil end
        _wbDsyncTgt = target
        _wbDsyncConn = RunService.Heartbeat:Connect(function()
            local hrp = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
            if not hrp then return end
            local tRoot = target and target.Character and target.Character:FindFirstChild('HumanoidRootPart')
            if not tRoot then _wbDsyncStop(); return end
            local desyncCF  = tRoot.CFrame * CFrame.new(0, -5, 0)
            local backupCF  = hrp.CFrame
            local backupVel = hrp.Velocity
            local backupRot = hrp.RotVelocity
            hrp.CFrame = desyncCF
            RunService:BindToRenderStep('_wbDs', 101, function()
                hrp.CFrame      = backupCF
                hrp.Velocity    = backupVel
                hrp.RotVelocity = backupRot
                RunService:UnbindFromRenderStep('_wbDs')
            end)
        end)
    end

    env._riv_startWallbang = function(on)
        if _wbOrigFn then
            GunItem.StartShooting = _wbOrigFn
            _wbOrigFn = nil
        end
        _wbDsyncStop()
        if _wbDsyncClean then task.cancel(_wbDsyncClean); _wbDsyncClean = nil end
        if not on then return end

        _wbOrigFn = GunItem.StartShooting

        GunItem.StartShooting = function(controller, ...)
            local res = { _wbOrigFn(controller, ...) }

            local cf = controller.ClientFighter
            if not (cf and cf.IsLocalPlayer) then return unpack(res) end

            local cameraData = res[3]
            if not cameraData or type(cameraData) ~= 'table' then return unpack(res) end

            res[4] = true

            local targetPlayer = _wbGetTarget()
            if not targetPlayer or not targetPlayer.Character then return unpack(res) end

            if _wbDsyncTgt ~= targetPlayer then
                _wbDsyncStart(targetPlayer)
                task.wait(0.1)
            end

            if _wbDsyncClean then task.cancel(_wbDsyncClean); _wbDsyncClean = nil end

            local targetHead = targetPlayer.Character:FindFirstChild('Head')
            if not targetHead then return unpack(res) end

            local targetPos   = targetHead.Position
            local shootPos    = targetPos - Vector3.new(0, 5, 0)
            local shootingOffset = targetHead.CFrame:ToObjectSpace(
                CFrame.new(targetPos + Vector3.new(math.random(), math.random(), math.random()))
            )

            cameraData[utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(shootPos, targetPos) * CFrame.Angles(CFrame.lookAt(shootPos, targetPos):ToOrientation()))
            cameraData[utf8.char(1)] = Utility:EncodeCFrame(CFrame.new(targetPos) * CFrame.Angles(CFrame.lookAt(shootPos, targetPos):ToOrientation()))
            cameraData[utf8.char(2)] = targetHead
            cameraData[utf8.char(3)] = Utility:EncodeCFrame(shootingOffset)

            _wbDsyncClean = task.delay(0.15, _wbDsyncStop)

            return unpack(res)
        end
    end

    if _okC and ClientItem then
        local origInput = rawget(ClientItem, "Input") or ClientItem.Input
        rawset(ClientItem, "Input", function(self, ...)
            if self and type(self) == "table" and self.Info then
                if env._rivNoRecoil then
                    rawset(self.Info, "ShootRecoil",     0)
                    rawset(self.Info, "ShootSpread",     0)
                    rawset(self.Info, "ProjectileSpeed", 99999999)
                end
                if env._rivRapidFire then
                    rawset(self.Info, "ShootCooldown",     0)
                    rawset(self.Info, "QuickShotCooldown", 0)
                end
            end
            return origInput(self, ...)
        end)
    end

    if _okG and GunItem and _okU and Utility then
        local _gunIdx   = rawget(GunItem, "__index")
        local origShoot = (_gunIdx and rawget(_gunIdx, "StartShooting")) or rawget(GunItem, "StartShooting")

        local function _shootPatch(ctrl, ...)
            local res = { origShoot(ctrl, ...) }
            if not env._silentRageActive then return unpack(res) end
            local cf = ctrl and rawget(ctrl, "ClientFighter") or (ctrl and ctrl.ClientFighter)
            if not (cf and cf.IsLocalPlayer) then return unpack(res) end
            local cameraData
            for i = 1, #res do
                if type(res[i]) == "table" then cameraData = res[i]; break end
            end
            if not cameraData then return unpack(res) end
            local tp = _tcTarget
            if not tp or not tp.Character then return unpack(res) end
            local aimPartName = Options.RageAimPart and Options.RageAimPart.Value or 'Head'
            local aimPart = tp.Character:FindFirstChild(aimPartName)
                         or tp.Character:FindFirstChild("HitboxHead")
                         or tp.Character:FindFirstChild("HitboxHeadSmall")
                         or tp.Character:FindFirstChild("Head")
                         or tp.Character:FindFirstChild("HumanoidRootPart")
            if not aimPart then return unpack(res) end
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local sPos  = myHRP and myHRP.Position or Camera.CFrame.Position
            local tPos  = aimPart.Position
            local lookCF = CFrame.new(sPos, tPos)
            local lX, lY, lZ = lookCF:ToOrientation()
            local originStruct = {
                [utf8.char(0)] = sPos.X, [utf8.char(1)] = sPos.Y, [utf8.char(2)] = sPos.Z,
                [utf8.char(3)] = lX, [utf8.char(4)] = lY, [utf8.char(5)] = lZ,
            }
            local relCF = aimPart.CFrame:ToObjectSpace(CFrame.new(tPos))
            local rX, rY, rZ = relCF:ToOrientation()
            rawset(cameraData, utf8.char(0), originStruct)
            rawset(cameraData, utf8.char(1), originStruct)
            rawset(cameraData, utf8.char(2), aimPart)
            rawset(cameraData, utf8.char(3), {
                [utf8.char(0)] = relCF.X, [utf8.char(1)] = relCF.Y, [utf8.char(2)] = relCF.Z,
                [utf8.char(3)] = rX, [utf8.char(4)] = rY, [utf8.char(5)] = rZ,
            })
            res[4] = true
            res[5] = nil
            return unpack(res)
        end

        if _gunIdx then
            rawset(_gunIdx, "StartShooting", _shootPatch)
        end
        rawset(GunItem, "StartShooting", _shootPatch)
    end

    env._riv_startNoRecoil = function(v) env._rivNoRecoil = v end

    local _fcOrigFinisher = nil
    local _fcPatched      = false

    env._riv_startFinisherChanger = function(on)
        local ok, CE = pcall(require, PS.Modules.ClientReplicatedClasses.ClientEntity)
        if not ok or not CE then
            warn("[FinisherChanger] ClientEntity 로드 실패"); return
        end
        if on then
            if not _fcPatched then
                _fcOrigFinisher = CE._PlayFinisher
                _fcPatched = true
            end
            CE._PlayFinisher = function(self, _, ...)
                local name = Options.FinisherName and Options.FinisherName.Value or 'Chark Attack'
                _fcOrigFinisher(self, name, ...)
            end
        else
            if _fcPatched and _fcOrigFinisher then
                CE._PlayFinisher = _fcOrigFinisher
            end
            _fcPatched = false
        end
    end

    local _adsOrigStart = nil
    local _adsOrigSpeed = nil
    local _adsPatched   = false

    env._riv_startFastADS = function(on)
        local ok, Gun = pcall(require, PS.Modules.ItemTypes.Gun)
        if not ok or not Gun then return end
        if on then
            if not _adsPatched then
                _adsOrigStart = Gun.StartAiming
                _adsOrigSpeed = Gun.GetAimSpeed
                _adsPatched = true
            end
            Gun.StartAiming = function(self, ...)
                self:SetReplicate('IsAiming', true)
                self.StopSprinting:Fire()
                self.ViewModel:SetAiming(true)
                self:SetReplicate('FOVOffset', self.Info.AimFOVOffset)
                if self.ViewModel.CurrentAimValue then
                    self.ViewModel.CurrentAimValue = 1
                end
                return true, 'StartAiming'
            end
            Gun.GetAimSpeed = function() return 999 end
        else
            if _adsPatched then
                if _adsOrigStart then Gun.StartAiming = _adsOrigStart end
                if _adsOrigSpeed then Gun.GetAimSpeed = _adsOrigSpeed end
                _adsPatched = false
            end
        end
    end

    local _neaOrig    = nil
    local _neaPatched = false

    env._riv_startNoEquipAnim = function(on)
        local ok, Gun = pcall(require, PS.Modules.ItemTypes.Gun)
        if not ok or not Gun then return end
        if on then
            if not _neaPatched then
                _neaOrig = Gun.Equip
                _neaPatched = true
            end
            Gun.Equip = function(self, ...)
                local res = { _neaOrig(self, ...) }
                if self.ViewModel then
                    pcall(function() self.ViewModel:StopAnimation('Equip') end)
                    pcall(function() self.ViewModel:StopAnimation('EquipEmpty') end)
                end
                return unpack(res)
            end
        else
            if _neaPatched and _neaOrig then
                Gun.Equip = _neaOrig
                _neaPatched = false
            end
        end
    end

    local _bgConn      = nil
    local _bgChildConn = nil
    local _bgScaled    = {}

    local function _bgScaleModel(model)
        if not (model and model:IsA("Model")) then return end
        if not model.Name:match("^" .. LP.Name .. " %- ") and
           not model.Name:match("^" .. LP.Name .. " %-%% ") and
           not model.Name:find(LP.Name, 1, true) then return end
        if _bgScaled[model] then return end
        _bgScaled[model] = true

        local mult = Options.BigGunSize and Options.BigGunSize.Value or 2
        local pivot = model:GetPivot()

        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local origSize = part:GetAttribute("OrigSize") or part.Size
                local origCF   = part:GetAttribute("OrigCF")   or part.CFrame
                part:SetAttribute("OrigSize", origSize)
                part:SetAttribute("OrigCF",   origCF)
                local rel = pivot:ToObjectSpace(origCF)
                part.Size   = origSize * mult
                part.CFrame = pivot * CFrame.new(rel.Position * mult) * (rel - rel.Position)
            end
        end
    end

    local function _bgUnscaleModel(model)
        if not (model and model:IsA("Model")) then return end
        if not _bgScaled[model] then return end
        _bgScaled[model] = nil
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local origSize = part:GetAttribute("OrigSize")
                local origCF   = part:GetAttribute("OrigCF")
                if origSize then part.Size   = origSize end
                if origCF   then part.CFrame = origCF   end
            end
        end
    end

    local function _bgHookVM(vm)
        for _, v in ipairs(vm:GetDescendants()) do _bgScaleModel(v) end
        local c = vm.DescendantAdded:Connect(function(v) _bgScaleModel(v) end)
        if _bgChildConn then _bgChildConn:Disconnect() end
        _bgChildConn = c
    end

    env._riv_startBigGun = function(on)
        if _bgConn then _bgConn:Disconnect(); _bgConn = nil end
        if _bgChildConn then _bgChildConn:Disconnect(); _bgChildConn = nil end
        if not on then
            local vm = workspace:FindFirstChild("ViewModels")
            if vm then
                for _, v in ipairs(vm:GetDescendants()) do _bgUnscaleModel(v) end
            end
            _bgScaled = {}
            return
        end
        local vm = workspace:FindFirstChild("ViewModels")
        if vm then _bgHookVM(vm) end
        _bgConn = workspace.ChildAdded:Connect(function(c)
            if c.Name == "ViewModels" then _bgHookVM(c) end
        end)
    end

    local _hsConn    = nil
    local _hsVMPath  = nil

    local function _hsGetVM()
        local ok, CI = pcall(require, PS.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        if not ok or not CI then return nil end
        return CI and CI.ClientViewModel
    end

    env._riv_startHitsound = function(on)
        if _hsConn then _hsConn:Disconnect(); _hsConn = nil end
        if not on then return end
        local ok, CI = pcall(require, PS.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        if not ok or not CI then return end
        local vm = CI.ClientViewModel
        if not vm then return end
        _hsConn = vm.ChildAdded:Connect(function(v)
            if not (Toggles.HitsoundEnabled and Toggles.HitsoundEnabled.Value) then return end
            if v:IsA("Sound") and v.SoundId ~= "rbxassetid://16537449730" then
                local sid = Options.HitsoundID and Options.HitsoundID.Value or "rbxassetid://4764109000"
                if not sid:find("rbxassetid://") then sid = "rbxassetid://"..sid end
                v.SoundId = sid
                v.Pitch   = 1
                v.Volume  = 1
            end
        end)
    end

    local _afOrigFlash = nil
    local _afPatched   = false

    local function _afGetFlashed()
        local ok, m = pcall(require, PS.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.Flashed)
        if ok then return m end
    end

    env._riv_startAntiFlash = function(on)
        local Flashed = _afGetFlashed()
        if not Flashed then return end
        if on then
            if not _afPatched then
                _afOrigFlash = Flashed.Flash
                _afPatched   = true
            end
            Flashed.Flash = function() return end
        else
            if _afPatched and _afOrigFlash then
                Flashed.Flash = _afOrigFlash
            end
            _afPatched = false
        end
    end

    local _nsOrigScrUpdate  = nil
    local _nsOrigCloudUpdate = nil
    local _nsPatched = false

    env._riv_startNoSmoke = function(on)
        if on then
            if not _nsPatched then
                pcall(function()
                    local SS = require(PS.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.SmokeScreen)
                    if SS and SS.Update then
                        _nsOrigScrUpdate = SS.Update
                        SS.Update = function(self)
                            self._smoke_cloud_spring.Target = 0
                            self._smoke_cloud_cover.Transparency = 1
                            if self._smoke_cloud_dof then self._smoke_cloud_dof.Parent = nil end
                        end
                    end
                end)
                pcall(function()
                    local SC = require(PS.Modules.SmokeCloud)
                    if SC and SC.Update then
                        _nsOrigCloudUpdate = SC.Update
                        SC.Update = function(self)
                            if self.Model then self.Model:Destroy() end
                            return true
                        end
                    end
                end)
                _nsPatched = true
            end
        else
            if _nsPatched then
                pcall(function()
                    local SS = require(PS.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.SmokeScreen)
                    if SS and _nsOrigScrUpdate then SS.Update = _nsOrigScrUpdate end
                end)
                pcall(function()
                    local SC = require(PS.Modules.SmokeCloud)
                    if SC and _nsOrigCloudUpdate then SC.Update = _nsOrigCloudUpdate end
                end)
                _nsPatched = false
            end
        end
    end

    local _saFovCircle = Drawing.new("Circle")
    _saFovCircle.Thickness = 1; _saFovCircle.Color = Color3.fromRGB(0,200,255)
    _saFovCircle.Filled = false; _saFovCircle.Visible = false; _saFovCircle.Transparency = 0.6

    RunService.Heartbeat:Connect(function()
        local show = Toggles.SilentShowFOV and Toggles.SilentShowFOV.Value or false
        if not show then _saFovCircle.Visible = false; return end
        local vp = Camera.ViewportSize
        _saFovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        _saFovCircle.Radius   = Options.RageFOV and Options.RageFOV.Value or 250
        _saFovCircle.Visible  = true
    end)

    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false; fovCircle.Color = Color3.new(1,1,1)
    fovCircle.Thickness = 1.5; fovCircle.Transparency = 0.5; fovCircle.Filled = false

    local _rageShooting  = false
    local _rageConn

    local _isSpecialPlace = (game.PlaceId == 129604661913557 or game.PlaceId == 71874690745115)
    local function _chidToId(c) return string.byte(c or string.char(0)) end

    local function _getPTPHitbox()
        local p = _tcTarget
        if not p or p == LP then return nil end
        local char = p.Character; if not char then return nil end
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        local myEnv = _chidToId(LP:GetAttribute("EnvironmentID"))
        local hEnv  = _chidToId(p:GetAttribute("EnvironmentID"))
        if myEnv == 0 or hEnv ~= myEnv then return nil end
        return char:FindFirstChild("HitboxHeadSmall")
            or char:FindFirstChild("HitboxHead")
            or char:FindFirstChild("Head")
            or char:FindFirstChild("HumanoidRootPart")
    end

    local _PROJ_NAMES = {CoreProjectile=true, Slingshot=true, Daggers=true, Bow=true, ["Paintball Gun"]=true}

    local function _startPTP(on)
        if _ptpConn then _ptpConn:Disconnect(); _ptpConn = nil end
        _ptpActive = on
        if not on then return end
        _ptpConn = workspace.ChildAdded:Connect(function(v)
            if not _ptpActive then return end
            if not _PROJ_NAMES[v.Name] then return end
            task.spawn(function()
                local deadline = tick() + 2
                while v and v.Parent and tick() < deadline do
                    local hb = _getPTPHitbox()
                    if hb then
                        v.CFrame = hb.CFrame
                        v.AssemblyLinearVelocity = Vector3.zero
                        pcall(firetouchinterest, hb, v, 0)
                        pcall(firetouchinterest, hb, v, 1)
                    end
                    task.wait()
                end
            end)
        end)
    end

    local function _getRageTarget()
        local p = _tcTarget
        if not p or p == LP then return nil end
        local char = p.Character; if not char then return nil end
        local hum  = char:FindFirstChildWhichIsA("Humanoid")
        local head = char:FindFirstChild("Head")
        if not hum or hum.Health <= 0 or not head then return nil end
        local fov = Options.RageFOV and Options.RageFOV.Value or 250
        local vp  = Camera.ViewportSize
        local s   = Camera:WorldToViewportPoint(head.Position)
        local dx, dy = s.X - vp.X/2, s.Y - vp.Y/2
        if dx*dx + dy*dy > fov*fov then return nil end
        return { head=head, char=char }
    end

    local _abConn   = nil
    local _abFovCircle = Drawing.new("Circle")
    _abFovCircle.Thickness = 1; _abFovCircle.Color = Color3.fromRGB(255,255,255)
    _abFovCircle.Filled = false; _abFovCircle.Visible = false; _abFovCircle.Transparency = 0.6

    env._riv_startAimbot = function(on)
        if _abConn then _abConn:Disconnect(); _abConn = nil end
        _abFovCircle.Visible = false
        if not on then return end
        _abConn = RunService.RenderStepped:Connect(function()
            if not (Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value) then return end

            local fov    = Options.AimbotFOV    and Options.AimbotFOV.Value    or 150
            local smooth = Options.AimbotSmooth and Options.AimbotSmooth.Value or 10
            local tPart  = Options.AimbotTargetPart    and Options.AimbotTargetPart.Value    or 'Head'
            local blPart = Options.AimbotBlacklistPart and Options.AimbotBlacklistPart.Value or 'None'
            local showFov = Toggles.AimbotShowFOV and Toggles.AimbotShowFOV.Value or false

            local vp = Camera.ViewportSize
            _abFovCircle.Position    = Vector2.new(vp.X/2, vp.Y/2)
            _abFovCircle.Radius      = fov
            _abFovCircle.Visible     = showFov

            local best, bestDist = nil, math.huge
            local mPos = UIS:GetMouseLocation()
            for _, p in Players:GetPlayers() do
                if p == LP or not _tcIsEnemy(p) then continue end
                local char = p.Character; if not char then continue end
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local part = char:FindFirstChild(tPart) or char:FindFirstChild("HumanoidRootPart")
                if not part then continue end
                if blPart ~= 'None' then
                    local bl = char:FindFirstChild(blPart)
                    if bl then
                        local bs, bv = Camera:WorldToViewportPoint(bl.Position)
                        if bv and (mPos - Vector2.new(bs.X, bs.Y)).Magnitude < fov then continue end
                    end
                end
                local s, vis = Camera:WorldToViewportPoint(part.Position)
                if not vis then continue end
                local d = (mPos - Vector2.new(s.X, s.Y)).Magnitude
                if d < fov and d < bestDist then bestDist = d; best = part end
            end
            if not best then return end

            local targetPos = best.Position
            local camPos    = Camera.CFrame.Position
            local targetDir = (targetPos - camPos).Unit
            local targetCF  = CFrame.new(camPos, camPos + targetDir)
            Camera.CFrame   = Camera.CFrame:Lerp(targetCF, 1 / math.max(smooth, 1))
        end)
    end

    local _tbConn     = nil
    local _tbShooting = false
    local _tbFovCircle = Drawing.new("Circle")
    _tbFovCircle.Thickness = 1; _tbFovCircle.Color = Color3.fromRGB(255,200,0)
    _tbFovCircle.Filled = false; _tbFovCircle.Visible = false; _tbFovCircle.Transparency = 0.6

    env._riv_startTriggerbot = function(on)
        if _tbConn then _tbConn:Disconnect(); _tbConn = nil end
        _tbShooting = false; _tbFovCircle.Visible = false
        if not on then return end
        _tbConn = RunService.Heartbeat:Connect(function()
            if not (Toggles.TriggerEnabled and Toggles.TriggerEnabled.Value) then return end

            local scanFov = Options.TriggerScanFOV       and Options.TriggerScanFOV.Value       or 30
            local setFov  = Options.TriggerFOV           and Options.TriggerFOV.Value           or 10
            local delay   = Options.TriggerDelay         and Options.TriggerDelay.Value         or 0
            local blPart  = Options.TriggerBlacklistPart and Options.TriggerBlacklistPart.Value or 'None'
            local showFov = Toggles.TriggerShowFOV       and Toggles.TriggerShowFOV.Value       or false

            local vp = Camera.ViewportSize
            _tbFovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
            _tbFovCircle.Radius   = scanFov
            _tbFovCircle.Visible  = showFov

            if _tbShooting then return end
            local mPos = UIS:GetMouseLocation()
            local ray  = Camera:ScreenPointToRay(mPos.X, mPos.Y)
            local res  = workspace:Raycast(ray.Origin, ray.Direction * 2000, RaycastParams.new())
            if not res then return end
            local hit  = res.Instance; if not hit then return end
            local char = hit:FindFirstAncestorOfClass("Model"); if not char then return end
            local player = Players:GetPlayerFromCharacter(char)
            if not player or player == LP or not _tcIsEnemy(player) then return end
            if blPart ~= 'None' and hit.Name == blPart then return end
            local s, vis = Camera:WorldToViewportPoint(res.Position)
            if not vis then return end
            local d = (mPos - Vector2.new(s.X, s.Y)).Magnitude
            if d > scanFov or d > setFov then return end

            _tbShooting = true
            task.spawn(function()
                if delay > 0 then task.wait(delay / 1000) end
                mouse1press(); task.wait(0.05); mouse1release()
                _tbShooting = false
            end)
        end)
    end

    env._riv_startRagebot = function(on)
        if _rageConn then _rageConn:Disconnect(); _rageConn = nil end
        fovCircle.Visible = false; _rageShooting = false
        env._silentRageActive = on and (Toggles.SilentAim and Toggles.SilentAim.Value or false)
        _startPTP(on)
        if not on then
            _tcRemoveConsumer()
            return
        end
        _tcAddConsumer()
        local vp = Camera.ViewportSize
        fovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        fovCircle.Radius   = Options.RageFOV and Options.RageFOV.Value or 250
        fovCircle.Visible  = true
        local _cachedObjId = nil
        _rageConn = RunService.Heartbeat:Connect(function()
            env._silentRageActive = Toggles.SilentAim and Toggles.SilentAim.Value or false
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local objId = _getEquippedObjId()
            if objId then _cachedObjId = objId else objId = _cachedObjId end
            if not objId then return end
            local shootPos = myHRP.Position
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP or not _tcIsEnemy(p) then continue end
                local char = p.Character; if not char then continue end
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local targetHead = char:FindFirstChild("Head"); if not targetHead then continue end
                local wbOrigin = targetHead.Position - Vector3.new(0, 5, 0)
                local shotData = _buildShotData(wbOrigin, targetHead)
                pcall(function() _useItemRemote:FireServer(objId, _ssEnum, shotData, nil) end)
            end
        end)
    end

    local _aaThread    = 0
    local _aaSpinYaw   = 0
    local _aaFakeYaw   = 0
    local _aaFakePitch = 0

    local function _aaGetRealYaw()
        local _, y, _ = Camera.CFrame:ToOrientation()
        return y
    end

    local function _aaCalcPitch()
        if not (Toggles.AAPitchEnabled and Toggles.AAPitchEnabled.Value) then return 0 end
        return math.rad(Options.AAPitchAngle and Options.AAPitchAngle.Value or 0)
    end

    local function _aaCalcYaw(baseYaw, dt)
        local method = Options.AAMethod and Options.AAMethod.Value or 'Backwards'
        local speed  = Options.AASpinSpeed and Options.AASpinSpeed.Value or 15
        local custom = math.rad(Options.AACustomAngle and Options.AACustomAngle.Value or 0)

        local yaw
        if method == 'Spinbot' then
            _aaSpinYaw = (_aaSpinYaw + speed * 4 * dt) % (math.pi * 2)
            yaw = baseYaw + _aaSpinYaw
        elseif method == 'Backwards' then
            yaw = baseYaw + math.pi
        elseif method == 'Right' then
            yaw = baseYaw + math.pi / 2
        elseif method == 'Left' then
            yaw = baseYaw - math.pi / 2
        else
            yaw = baseYaw
        end

        yaw = yaw + custom

        if Toggles.AAJitter and Toggles.AAJitter.Value then
            local jitter = math.rad(Options.AAJitterRange and Options.AAJitterRange.Value or 35)
            yaw = yaw + (math.random() * 2 - 1) * jitter
        end

        return yaw
    end

    env._riv_startAA = function(on)
        _aaThread += 1
        RunService:UnbindFromRenderStep("_riv_aa_visual")
        if not on then return end
        local t = _aaThread
        local updateRot = RS.Remotes.Replication.Fighter.UpdateCameraRotation
        local lastT = tick()
        task.spawn(function()
            while t == _aaThread do
                if _okU and Utility then
                    pcall(function()
                        local now = tick()
                        local dt  = now - lastT; lastT = now
                        local baseYaw = _aaGetRealYaw()
                        local fakeYaw = _aaCalcYaw(baseYaw, dt)
                        local fakePitch = _aaCalcPitch()
                        _aaFakeYaw   = fakeYaw
                        _aaFakePitch = fakePitch

                        updateRot:FireServer(Utility:EncodeCameraRotation(Vector2.new(fakePitch, fakeYaw)), nil)

                    end)
                end
                task.wait()
            end
        end)

        RunService:BindToRenderStep("_riv_aa_visual", Enum.RenderPriority.Character.Value + 1, function()
            local char = LP.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

            local pos = hrp.Position
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, _aaFakeYaw, 0)

            local neck = char:FindFirstChild("Neck", true)
            if neck and neck:IsA("Motor6D") then
                local baseC0 = CFrame.new(0, 1, 0) * CFrame.Angles(-math.pi/2, 0, math.pi)
                neck.C0 = baseC0 * CFrame.Angles(_aaFakePitch, 0, 0)
            end
        end)
    end

    local _pulseThread = 0
    env._riv_startPulse = function(on)
        _pulseThread += 1
        if not on then return end
        local t = _pulseThread
        task.spawn(function()
            while t == _pulseThread do
                local interval = Options.PulseInterval and Options.PulseInterval.Value or 0.4
                local scatter  = Options.PulseScatter  and Options.PulseScatter.Value  or 60
                local baseCF   = Camera.CFrame
                if Toggles.PulseAimEnemy and Toggles.PulseAimEnemy.Value then
                    local tp = _tcTarget
                    if tp and tp.Character then
                        local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then baseCF = CFrame.new(Camera.CFrame.Position, hrp.Position) end
                    end
                end
                local rx = math.rad((math.random() * 2 - 1) * scatter)
                local ry = math.rad((math.random() * 2 - 1) * scatter)
                local mpos   = UIS:GetMouseLocation()
                local guiHit = LP.PlayerGui:GetGuiObjectsAtPosition(mpos.X, mpos.Y)
                if #guiHit == 0 then
                    local origCF   = Camera.CFrame
                    local origType = Camera.CameraType
                    Camera.CameraType = Enum.CameraType.Scriptable
                    Camera.CFrame = baseCF * CFrame.Angles(rx, ry, 0)
                    mouse1press(); task.wait(0.06); mouse1release()
                    Camera.CFrame     = origCF
                    Camera.CameraType = origType
                end
                task.wait(interval + math.random() * 0.15)
            end
        end)
    end

    local _tpCamCtrl     = nil
    local _tpOrigState   = nil
    local _tpLoaded      = false

    local function _tpEnsureCtrl()
        if _tpLoaded then return _tpCamCtrl end
        local ok, ctrl = pcall(require, PS.Controllers.CameraController)
        if ok and ctrl then _tpCamCtrl = ctrl end
        _tpLoaded = true
        return _tpCamCtrl
    end

    env._riv_startTP = function(on)
        local ctrl = _tpEnsureCtrl()
        if not ctrl or not ctrl.CameraState then
            warn("[ThirdPerson] CameraController 로드 실패"); return
        end
        local cs = ctrl.CameraState
        if on then
            if type(cs.GetCurrentState) == 'function' then _tpOrigState = cs:GetCurrentState() end
            pcall(function() cs:_SetPOVState(cs.States.ThirdPersonMirrored) end)
        else
            if _tpOrigState then
                pcall(function() cs:_SetPOVState(_tpOrigState) end)
            else
                pcall(function() cs:_SetPOVState(cs.States.FirstPerson) end)
            end
        end
    end

    env._riv_startUnlockMouse = function(on)
        local ctrl = _tpEnsureCtrl()
        if not ctrl or not ctrl.CameraState then
            warn("[UnlockMouse] CameraController 로드 실패"); return
        end
        local cs = ctrl.CameraState
        if on then
            if type(cs.GetCurrentState) == 'function' then _tpOrigState = cs:GetCurrentState() end
            pcall(function() cs:_SetPOVState(cs.States.ThirdPersonUnlockedMouse) end)
        else
            if _tpOrigState then
                pcall(function() cs:_SetPOVState(_tpOrigState) end)
            else
                pcall(function() cs:_SetPOVState(cs.States.FirstPerson) end)
            end
        end
    end

    local _voidConn
    local VOID_Y   = -100
    local VOID_XZ  = 30

    env._riv_startVoidSpam = function(on)
        if _voidConn then _voidConn:Disconnect(); _voidConn = nil end
        RunService:UnbindFromRenderStep("_riv_vs_cam")
        if not on then return end

        local savedCam = nil

        RunService:BindToRenderStep("_riv_vs_cam", Enum.RenderPriority.Camera.Value + 1, function()
            if savedCam then Camera.CFrame = savedCam end
        end)

        local baseX, baseZ = nil, nil

        _voidConn = RunService.Heartbeat:Connect(function()
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if not baseX then
                baseX = hrp.Position.X
                baseZ = hrp.Position.Z
            end

            savedCam   = Camera.CFrame
            local randX = baseX + math.random(-VOID_XZ, VOID_XZ)
            local randZ = baseZ + math.random(-VOID_XZ, VOID_XZ)
            hrp.CFrame = CFrame.new(randX, VOID_Y, randZ)
        end)
    end

    local _espObjects = {}
    local _espActive  = false

    local function _removeESP(p)
        local o = _espObjects[p]; if not o then return end
        for k, d in pairs(o) do
            if k == "skel" then
                for _, l in ipairs(d) do pcall(function() l:Remove() end) end
            else
                pcall(function() d:Remove() end)
            end
        end
        _espObjects[p] = nil
    end
    local _SKEL_CONNECTIONS = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }

    local function _createESP(p)
        if p == LP then return end
        _removeESP(p)
        local box  = Drawing.new("Square"); box.Thickness=1;  box.Filled=false;  box.Visible=false
        local trac = Drawing.new("Line");   trac.Thickness=1; trac.Visible=false
        local name = Drawing.new("Text");   name.Size=13; name.Center=true; name.Outline=true; name.Visible=false
        local hpBg = Drawing.new("Square"); hpBg.Filled=true; hpBg.Color=Color3.new(0,0,0); hpBg.Transparency=0.5; hpBg.Visible=false
        local hpBr = Drawing.new("Square"); hpBr.Filled=true; hpBr.Visible=false
        local dist = Drawing.new("Text");   dist.Size=11; dist.Center=true; dist.Outline=true; dist.Color=Color3.new(0.9,0.9,0.9); dist.Visible=false
        local skelLines = {}
        for i = 1, #_SKEL_CONNECTIONS do
            local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false
            skelLines[i] = l
        end
        _espObjects[p] = {box=box, trac=trac, name=name, hpBg=hpBg, hpBr=hpBr, dist=dist, skel=skelLines}
    end
    local function _updateESP()
        local vp = Camera.ViewportSize; local cx,cy = vp.X/2, vp.Y/2
        local showBox  = Toggles.ESPBox.Value
        local showTrac = Toggles.ESPTracer.Value
        local showName = Toggles.ESPName.Value
        local showHP   = Toggles.ESPHealth.Value
        local showDist = Toggles.ESPDist.Value
        local myHRP    = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, p in next, Players:GetPlayers() do
            if p == LP then continue end
            if not _espObjects[p] then _createESP(p) end
            local o = _espObjects[p]; if not o then continue end
            local char = p.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
            if not hrp or not head or not hum or hum.Health <= 0 then
                for _, d in pairs(o) do d.Visible = false end; continue
            end
            local isEnemy = env._tcIsEnemy and env._tcIsEnemy(p)
            local col = isEnemy and Color3.new(1,0.2,0.2) or Color3.new(0.2,0.8,1)
            local sTop, vT = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.7,0))
            local sBot, vB = Camera:WorldToViewportPoint(hrp.Position  - Vector3.new(0,3,0))
            if not vT and not vB then
                for _, d in pairs(o) do d.Visible = false end; continue
            end
            local h = math.abs(sTop.Y - sBot.Y); local w = h * 0.55
            local x = sTop.X - w/2;              local y = math.min(sTop.Y, sBot.Y)
            o.box.Visible=showBox; o.box.Color=col; o.box.Position=Vector2.new(x,y); o.box.Size=Vector2.new(w,h)
            o.trac.Visible=showTrac; o.trac.Color=col; o.trac.From=Vector2.new(cx,vp.Y); o.trac.To=Vector2.new(sBot.X,sBot.Y)
            o.name.Visible=showName; o.name.Color=Color3.new(1,1,1); o.name.Text=p.DisplayName; o.name.Position=Vector2.new(sTop.X,y-16)
            local hpR = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
            local bx  = x - 6
            o.hpBg.Visible=showHP; o.hpBg.Position=Vector2.new(bx,y); o.hpBg.Size=Vector2.new(4,h)
            o.hpBr.Visible=showHP; o.hpBr.Color=Color3.new(1-hpR,hpR,0)
            o.hpBr.Position=Vector2.new(bx, y+h*(1-hpR)); o.hpBr.Size=Vector2.new(4, h*hpR)
            local studs = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
            o.dist.Visible=showDist; o.dist.Text=studs.."m"; o.dist.Position=Vector2.new(sTop.X, y+h+2)
            local showSkel = Toggles.ESPSkeleton.Value
            for i, conn in ipairs(_SKEL_CONNECTIONS) do
                local l = o.skel[i]
                if not showSkel then l.Visible=false; continue end
                local pA = char:FindFirstChild(conn[1])
                local pB = char:FindFirstChild(conn[2])
                if pA and pB then
                    local sA, vA = Camera:WorldToViewportPoint(pA.Position)
                    local sB, vB2 = Camera:WorldToViewportPoint(pB.Position)
                    if vA or vB2 then
                        l.From=Vector2.new(sA.X,sA.Y); l.To=Vector2.new(sB.X,sB.Y)
                        l.Color=col; l.Visible=true
                    else l.Visible=false end
                else l.Visible=false end
            end
        end
    end

    Players.PlayerAdded:Connect(function(p) _createESP(p) end)
    Players.PlayerRemoving:Connect(function(p) _removeESP(p) end)
    for _, p in next, Players:GetPlayers() do _createESP(p) end

    env._riv_startESP = function(on)
        if on and not _espActive then
            _espActive = true
            task.spawn(function()
                while _espActive do _updateESP(); RunService.Heartbeat:Wait() end
                for _, o in pairs(_espObjects) do for _, d in pairs(o) do d.Visible=false end end
            end)
        elseif not on then
            _espActive = false
        end
    end

    local _dotDraw = Drawing.new("Circle")
    _dotDraw.Radius = 5; _dotDraw.Thickness = 2; _dotDraw.Color = Color3.new(1,0,0)
    _dotDraw.Filled = true; _dotDraw.Visible = false
    local _dotOutline = Drawing.new("Circle")
    _dotOutline.Radius = 6; _dotOutline.Thickness = 1.5; _dotOutline.Color = Color3.new(0,0,0)
    _dotOutline.Filled = false; _dotOutline.Visible = false
    local _dotActive = false

    env._riv_startTargetDot = function(on)
        _dotActive = on
        if not on then _dotDraw.Visible=false; _dotOutline.Visible=false; return end
        task.spawn(function()
            while _dotActive do
                local tp = _tcTarget
                local head = tp and tp.Character and (
                    tp.Character:FindFirstChild("HitboxHeadSmall") or
                    tp.Character:FindFirstChild("Head"))
                if head then
                    local sp, vis = Camera:WorldToViewportPoint(head.Position)
                    if vis then
                        local p2 = Vector2.new(sp.X, sp.Y)
                        _dotDraw.Position=p2; _dotDraw.Visible=true
                        _dotOutline.Position=p2; _dotOutline.Visible=true
                    else
                        _dotDraw.Visible=false; _dotOutline.Visible=false
                    end
                else
                    _dotDraw.Visible=false; _dotOutline.Visible=false
                end
                RunService.Heartbeat:Wait()
            end
            _dotDraw.Visible=false; _dotOutline.Visible=false
        end)
    end

    local _chamsObjects = {}

    local function _removeChams(p)
        local h = _chamsObjects[p]
        if h then pcall(function() h:Destroy() end); _chamsObjects[p] = nil end
    end

    local function _applyChams(p)
        if p == LP then return end
        _removeChams(p)
        local char = p.Character; if not char then return end
        local h = Instance.new("Highlight")
        h.FillColor       = Options.ESPChamsColor   and Options.ESPChamsColor.Value   or Color3.new(1,0,0)
        h.OutlineColor    = Options.ESPChamsOutline and Options.ESPChamsOutline.Value or Color3.new(1,1,1)
        h.FillTransparency    = 0.5
        h.OutlineTransparency = 0
        h.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee         = char
        h.Parent          = char
        _chamsObjects[p]  = h
    end

    local _chamsActive = false
    local _chamsCharConns = {}

    env._riv_startChams = function(on)
        _chamsActive = on
        for p in pairs(_chamsObjects) do _removeChams(p) end
        for _, c in pairs(_chamsCharConns) do pcall(function() c:Disconnect() end) end
        _chamsCharConns = {}
        if not on then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                if p.Character then _applyChams(p) end
                local c1 = p.CharacterAdded:Connect(function(char)
                    task.wait(0.1)
                    if _chamsActive then _applyChams(p) end
                end)
                local c2 = p.CharacterRemoving:Connect(function() _removeChams(p) end)
                _chamsCharConns[p] = {c1, c2}
            end
        end
        task.spawn(function()
            local lastFill = Options.ESPChamsColor and Options.ESPChamsColor.Value
            local lastOut  = Options.ESPChamsOutline and Options.ESPChamsOutline.Value
            while _chamsActive do
                local newFill = Options.ESPChamsColor and Options.ESPChamsColor.Value
                local newOut  = Options.ESPChamsOutline and Options.ESPChamsOutline.Value
                if newFill ~= lastFill or newOut ~= lastOut then
                    lastFill = newFill; lastOut = newOut
                    for p, h in pairs(_chamsObjects) do
                        if h and h.Parent then
                            h.FillColor = newFill or Color3.new(1,0,0)
                            h.OutlineColor = newOut or Color3.new(1,1,1)
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end

    local _fovCircle = Drawing.new("Circle")
    _fovCircle.Thickness = 1; _fovCircle.Color = Color3.new(1,1,1)
    _fovCircle.Filled = false; _fovCircle.Visible = false; _fovCircle.Transparency = 0.6
    local _fovActive = false

    env._riv_startFOVCircle = function(on)
        _fovActive = on
        if not on then _fovCircle.Visible=false; return end
        task.spawn(function()
            while _fovActive do
                local vp = Camera.ViewportSize
                _fovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
                _fovCircle.Radius   = Options.TargetFOVRadius and Options.TargetFOVRadius.Value or 120
                _fovCircle.Visible  = true
                RunService.Heartbeat:Wait()
            end
            _fovCircle.Visible = false
        end)
    end

    local _flyConn, _flyBV, _flyBG
    env._riv_startFly = function(on)
        if _flyConn then _flyConn:Disconnect(); _flyConn = nil end
        if _flyBV then pcall(function() _flyBV:Destroy() end); _flyBV = nil end
        if _flyBG then pcall(function() _flyBG:Destroy() end); _flyBG = nil end
        local char = LP.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum  = char:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        if not on then
            hum.PlatformStand = false
            return
        end
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.zero; bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9); bg.D = 100; bg.P = 1e5; bg.Parent = hrp
        _flyBV = bv; _flyBG = bg
        _flyConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character; if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
            local speed = Options.FlySpeed and Options.FlySpeed.Value or 50
            local cf    = Camera.CFrame
            local vel   = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W)          then vel += cf.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.S)          then vel -= cf.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.A)          then vel -= cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D)          then vel += cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)      then vel += Vector3.yAxis  end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift)  then vel -= Vector3.yAxis  end
            bv.Velocity = vel.Magnitude > 0 and vel.Unit * speed or Vector3.zero
            bg.CFrame   = cf
        end)
        LP.CharacterRemoving:Once(function()
            env._riv_startFly(false)
            pcall(function() Toggles.FlyEnabled:SetValue(false) end)
        end)
    end

    local _arConn
    env._riv_startAutoRespawn = function(on)
        if _arConn then _arConn:Disconnect(); _arConn = nil end
        if not on then return end
        local function _hookChar(char)
            local hum = char:FindFirstChildWhichIsA("Humanoid")
                     or char:WaitForChild("Humanoid", 5)
            if not hum then return end
            hum.Died:Connect(function()
                if not (Toggles.AutoRespawn and Toggles.AutoRespawn.Value) then return end
                local delay = Options.RespawnDelay and Options.RespawnDelay.Value or 0
                if delay > 0 then task.wait(delay) end
                pcall(function()
                    RS.Remotes.Duels.RespawnNow:FireServer()
                end)
            end)
        end
        if LP.Character then task.spawn(_hookChar, LP.Character) end
        _arConn = LP.CharacterAdded:Connect(function(char)
            task.spawn(_hookChar, char)
        end)
    end

    local _spawnTime = {}
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() _spawnTime[p] = tick() end)
    end)
    Players.PlayerRemoving:Connect(function(p) _spawnTime[p] = nil end)
    for _, p in Players:GetPlayers() do
        if p.Character then _spawnTime[p] = tick() end
        p.CharacterAdded:Connect(function() _spawnTime[p] = tick() end)
    end

    local function _farmSpawnOk(p)
        local age = Options.FarmSpawnAge and Options.FarmSpawnAge.Value or 5
        return _spawnTime[p] and (tick() - _spawnTime[p]) >= age
    end

    local function _behindNeckCF(tHRP, dist)
        local neckPos = tHRP.Position + Vector3.new(0, 1.5, 0)
        local behind  = tHRP.CFrame * CFrame.new(0, 0, dist)
        return CFrame.new(behind.Position, neckPos)
    end

    local function _lockCamToNeck(tHRP)
        if not tHRP then return end
        local neckPos = tHRP.Position + Vector3.new(0, 1.5, 0)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, neckPos)
    end

    local function _inSameEnv(p)
        local myEnv = _chidToId(LP:GetAttribute("EnvironmentID"))
        if myEnv == 0 then return false end
        return _chidToId(p:GetAttribute("EnvironmentID")) == myEnv
    end

    local function _getFarmEnemies()
        local list = {}
        for _, p in Players:GetPlayers() do
            if p ~= LP and _tcIsEnemy(p) and _farmSpawnOk(p) and _inSameEnv(p) and p.Character then
                local hum = p.Character:FindFirstChildWhichIsA("Humanoid")
                if hum and hum.Health > 0 then table.insert(list, p) end
            end
        end
        return list
    end

    local function _strictBehind(tHRP, dist)
        local neckPos = tHRP.Position + Vector3.new(0, 1.5, 0)
        local behindPos = tHRP.Position + tHRP.CFrame.LookVector * (-dist)
        return CFrame.new(behindPos, neckPos)
    end

    local _btShotConn  = nil
    local _btItemConn  = nil
    local _btCharConn  = nil

    local function _btCreateBeam(startPos, endPos, color, duration)
        local dir = endPos - startPos
        local dist = dir.Magnitude
        if dist <= 0 then return end
        local part = Instance.new("Part")
        part.Anchored      = true
        part.CanCollide    = false
        part.CanQuery      = false
        part.CanTouch      = false
        part.Transparency  = 0
        part.Material      = Enum.Material.Neon
        part.Color         = color
        part.Size          = Vector3.new(0.07, 0.07, dist)
        part.CFrame        = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -dist * 0.5)
        part.Parent        = workspace
        task.delay(0.02, function()
            local life  = duration
            local start = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local t = (tick() - start) / life
                if t >= 1 then conn:Disconnect(); part:Destroy(); return end
                part.Transparency = t
            end)
        end)
    end

    local function _btTryFire()
        if not (Toggles.BulletTracerLocal and Toggles.BulletTracerLocal.Value) then return end
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local dur   = Options.BulletTracerDuration and Options.BulletTracerDuration.Value or 0.3
        local col   = Options.BulletTracerLocalCol and Options.BulletTracerLocalCol.Value or Color3.new(0.2,0.8,1)
        local origin = Camera.CFrame.Position
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.IgnoreWater = true
        local result = workspace:Raycast(origin, Camera.CFrame.LookVector * 2000, rp)
        if result then
            _btCreateBeam(origin, result.Position, col, dur)
        end
    end

    local function _btSetItem(item)
        if _btShotConn then _btShotConn:Disconnect(); _btShotConn = nil end
        if item and item.Shot then
            _btShotConn = item.Shot:Connect(_btTryFire)
        end
    end

    env._riv_startBulletTracer = function(on)
        if _btItemConn then _btItemConn:Disconnect(); _btItemConn = nil end
        if _btShotConn then _btShotConn:Disconnect(); _btShotConn = nil end
        if not on then return end
        if not (_okF and FighterCtrl) then return end
        local function hook(lf)
            if not lf then return end
            _btSetItem(lf.EquippedItem)
            if _btItemConn then _btItemConn:Disconnect() end
            _btItemConn = lf.EquippedItemChanged:Connect(function(newItem) _btSetItem(newItem) end)
        end
        local lf = FighterCtrl.LocalFighter
        if lf then hook(lf)
        else
            task.spawn(function()
                if FighterCtrl.WaitForLocalFighter then
                    hook(FighterCtrl:WaitForLocalFighter())
                end
            end)
        end
    end

    local _ssSpamActive = false
    local _ssSpamThread = nil

    env._riv_startSoundSpammer = function(on)
        _ssSpamActive = false
        if not on then return end
        local ok, MC = pcall(require, PS.Controllers.MechanicsController)
        if not ok or not MC then
            warn("[SoundSpammer] MechanicsController 로드 실패"); return
        end
        _ssSpamActive = true
        _ssSpamThread = task.spawn(function()
            while _ssSpamActive do
                if Toggles.SoundSpammer and Toggles.SoundSpammer.Value then
                    local char = LP.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.AssemblyLinearVelocity
                        pcall(function() MC:DoubleJump() end)
                        task.defer(function()
                            if hrp and hrp.Parent then
                                hrp.AssemblyLinearVelocity = vel
                            end
                        end)
                    end
                end
                local interval = Options.SoundSpamInterval and Options.SoundSpamInterval.Value or 0.2
                task.wait(interval)
            end
        end)
    end

    local _lmConn      = nil
    local _lmDrawings  = {}
    local _LANDMINE_NAMES = { Landmine=true, Mine=true, ProximityMine=true }

    local function _lmRemove(part)
        local d = _lmDrawings[part]
        if d then
            if d.circle then d.circle:Remove() end
            if d.label  then d.label:Remove()  end
            _lmDrawings[part] = nil
        end
    end

    local function _lmScan()
        local col = Options.LandmineESPColor and Options.LandmineESPColor.Value or Color3.fromRGB(255,80,80)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and _LANDMINE_NAMES[obj.Name] and not _lmDrawings[obj] then
                local circ = Drawing.new("Circle")
                circ.Radius = 8; circ.Thickness = 2; circ.Color = col
                circ.Filled = false; circ.Transparency = 0.8; circ.Visible = false
                local lbl = Drawing.new("Text")
                lbl.Size = 14; lbl.Color = col; lbl.Outline = true
                lbl.Text = "Mine"; lbl.Visible = false
                _lmDrawings[obj] = { circle=circ, label=lbl }
            end
        end
        for part, d in pairs(_lmDrawings) do
            if not (part and part.Parent) then
                _lmRemove(part)
            else
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    d.circle.Position = Vector2.new(sp.X, sp.Y)
                    d.label.Position  = Vector2.new(sp.X + 10, sp.Y - 7)
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    d.label.Text = string.format("Mine [%dm]", math.floor(dist))
                    d.circle.Color = col; d.label.Color = col
                    d.circle.Visible = true; d.label.Visible = true
                else
                    d.circle.Visible = false; d.label.Visible = false
                end
            end
        end
    end

    env._riv_startLandmineESP = function(on)
        if _lmConn then _lmConn:Disconnect(); _lmConn = nil end
        for part in pairs(_lmDrawings) do _lmRemove(part) end
        _lmDrawings = {}
        if not on then return end
        _lmConn = RunService.RenderStepped:Connect(_lmScan)
    end

    local _banConn = nil
    local _voteRemote = nil
    pcall(function()
        _voteRemote = RS.Remotes.Duels.Vote
    end)

    env._riv_startAutoBan = function(on)
        if _banConn then _banConn:Disconnect(); _banConn = nil end
        if not on then return end
        if not _voteRemote then
            warn("[AutoBan] Vote 리모트를 찾지 못했습니다")
            return
        end
        local _banIdx = 1
        local _banLast = 0
        _banConn = RunService.Heartbeat:Connect(function()
            if not (Toggles.AutoBanEnabled and Toggles.AutoBanEnabled.Value) then return end
            local now = tick()
            if now - _banLast < 1 then return end
            _banLast = now
            local target = Options.AutoBanTarget and Options.AutoBanTarget.Value or 'Riot Shield + Katana'
            local votes
            if target == 'Riot Shield + Katana' then
                votes = { 'Riot Shield', 'Katana' }
            elseif target == 'Riot Shield' then
                votes = { 'Riot Shield' }
            else
                votes = { 'Katana' }
            end
            pcall(_voteRemote.FireServer, _voteRemote, votes[_banIdx])
            _banIdx = _banIdx % #votes + 1
        end)
    end

    local _dropConn
    local _dropAddedConn
    local _dropCooldown = {}

    local function _collectDrop(obj)
        if not (obj.Name == "_drop" and obj:IsA("BasePart")) then return end
        if _dropCooldown[obj] then return end
        local isHP   = obj:FindFirstChild("Health") ~= nil
        local isAmmo = false
        for _, c in obj:GetChildren() do
            if c:IsA("Model") and c.Name:lower():sub(1,4) == "ammo" then isAmmo = true; break end
        end
        if not ((env._rivCollectHP and isHP) or (env._rivCollectAmmo and isAmmo)) then return end
        local char = LP.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        _dropCooldown[obj] = true
        pcall(firetouchinterest, hrp, obj, 0)
        pcall(firetouchinterest, hrp, obj, 1)
        task.delay(1, function() _dropCooldown[obj] = nil end)
    end

    env._riv_startDrop = function(on)
        if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
        if _dropAddedConn then _dropAddedConn:Disconnect(); _dropAddedConn = nil end
        _dropCooldown = {}
        if not on then return end
        _dropAddedConn = workspace.ChildAdded:Connect(_collectDrop)
        local lastScan = 0
        _dropConn = RunService.Heartbeat:Connect(function()
            local now = tick()
            if now - lastScan < 0.05 then return end
            lastScan = now
            for _, obj in workspace:GetChildren() do
                _collectDrop(obj)
            end
        end)
    end

    local _ptpActive  = false
    local _ptpHooks   = {}
    local _ptpAttached = setmetatable({}, { __mode = "k" })

    local _PTP_FOLDERS = { Daggers=true, Bow=true, Slingshot=true }

    local function _ptpGetTarget()
        local mode = Options.ProjTPTarget and Options.ProjTPTarget.Value or 'Closest'
        if mode == 'Aimbot Target' and _tcTarget and _tcTarget.Character then
            return _tcTarget.Character:FindFirstChild('Head')
                or _tcTarget.Character:FindFirstChild('HumanoidRootPart')
        end
        local myHRP = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
        if not myHRP then return nil end
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character
            local head = char and char:FindFirstChild('Head')
            if head then
                local d = (myHRP.Position - head.Position).Magnitude
                if d < bestD then bestD = d; best = head end
            end
        end
        return best
    end

    local function _ptpAttach(part)
        if not (part and part:IsA('BasePart')) then return end
        if _ptpAttached[part] then return end
        _ptpAttached[part] = true
        part.CanCollide = false
        part.Massless   = true
        pcall(function() part:SetNetworkOwner(LP) end)
        task.spawn(function()
            while _ptpActive and part and part.Parent do
                local head = _ptpGetTarget()
                if head and head.Parent then
                    part.AssemblyLinearVelocity  = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                    part.CFrame = head.CFrame
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end

    local function _ptpHandleInst(inst)
        if not (inst and inst.Parent) then return end
        if inst:IsA('BasePart') then
            _ptpAttach(inst)
        elseif inst:IsA('Model') or inst:IsA('Folder') then
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA('BasePart') then _ptpAttach(d) end
            end
        end
    end

    local function _ptpHookFolder(folder)
        for _, d in ipairs(folder:GetDescendants()) do _ptpHandleInst(d) end
        local c = folder.DescendantAdded:Connect(function(desc) _ptpHandleInst(desc) end)
        _ptpHooks[#_ptpHooks+1] = c
    end

    env._riv_startProjTP = function(on)
        _ptpActive = false
        for _, c in ipairs(_ptpHooks) do pcall(function() c:Disconnect() end) end
        _ptpHooks = {}
        _ptpAttached = setmetatable({}, { __mode = "k" })
        if not on then return end
        _ptpActive = true
        for _, child in ipairs(workspace:GetChildren()) do
            if _PTP_FOLDERS[child.Name] then _ptpHookFolder(child) end
        end
        local wc = workspace.ChildAdded:Connect(function(child)
            if _ptpActive and _PTP_FOLDERS[child.Name] then _ptpHookFolder(child) end
        end)
        _ptpHooks[#_ptpHooks+1] = wc
    end

    local _ncConn = nil

    env._riv_startNoclip = function(on)
        if _ncConn then _ncConn:Disconnect(); _ncConn = nil end
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA('BasePart') then
                    p.CanCollide = not on and (p.Name ~= 'HumanoidRootPart') or false
                end
            end
        end
        if not on then return end
        _ncConn = RunService.Stepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA('BasePart') then
                    p.CanCollide = false
                end
            end
        end)
    end

    end, function(e) warn("[Rivals Hub] ERROR: " .. tostring(e) .. "\n" .. debug.traceback()) end)
    if not ok then return end
    _rivReady = true

    if Toggles.ESPBox.Value or Toggles.ESPTracer.Value or Toggles.ESPName.Value or Toggles.ESPHealth.Value or Toggles.ESPDist.Value then
        env._riv_startESP(true)
    end
    if Toggles.TargetDot.Value       then env._riv_startTargetDot(true) end
    if Toggles.TargetFOVCircle.Value then env._riv_startFOVCircle(true) end
    if Toggles.ESPChams.Value        then env._riv_startChams(true) end
    if Toggles.AimbotEnabled  and Toggles.AimbotEnabled.Value  then env._riv_startAimbot(true) end
    if Toggles.TriggerEnabled and Toggles.TriggerEnabled.Value then env._riv_startTriggerbot(true) end
    if Toggles.ShowKeybinds and Toggles.ShowKeybinds.Value then
        pcall(_buildKeybindGui)
    end
    print("[Rivals Hub] Loaded")
end)

task.delay(10, function()
    if not _rivReady then
        _rivReady = true
        print("[Rivals Hub] Fallback ready")
    end
end)

end)
