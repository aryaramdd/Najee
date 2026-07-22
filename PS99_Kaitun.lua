-- ==========================================
-- PS99 KAITUN-STYLE AUTO SCRIPT
-- Based on Akuma Hub core logic, UI stripped
-- ==========================================

if getgenv().Kaitun_IsRunning then return end
getgenv().Kaitun_IsRunning = true

local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local vim = game:GetService("VirtualInputManager")

-- Startup: try remote + save poke only (no getgc — avoid calling random functions from other scripts)
pcall(function()
    for _, rn in ipairs({"Pick Starter Pets", "PickStarterPets", "Pick_Starter_Pets"}) do
        local r = Network:FindFirstChild(rn)
        if r then
            if r:IsA("RemoteFunction") then pcall(function() r:InvokeServer() end); pcall(function() r:InvokeServer(1, 2) end); pcall(function() r:InvokeServer("1", "2") end)
            elseif r:IsA("RemoteEvent") then pcall(function() r:FireServer() end); pcall(function() r:FireServer(1, 2) end); pcall(function() r:FireServer("1", "2") end)
            end
        end
    end
    local N = pcall(require, ReplicatedStorage.Library.Client.Network) and require(ReplicatedStorage.Library.Client.Network) or nil
    if type(N) == "table" then
        for _, rn in ipairs({"Pick Starter Pets", "PickStarterPets", "Pick_Starter_Pets"}) do
            for _, fn in ipairs({"Fire", "Invoke", "Send", "Call"}) do
                local f = N[fn]
                if type(f) == "function" then pcall(f, N, rn); pcall(f, N, rn, 1, 2); pcall(f, N, rn, "1", "2") end
            end
        end
    end
    local Save = pcall(require, ReplicatedStorage.Library.Client.Save) and require(ReplicatedStorage.Library.Client.Save) or nil
    if Save then
        local d = Save.Get()
        if d then
            for _, k in ipairs({"StarterClaimed","StarterPicked","HasPickedStarter","StarterPetsChosen","PickedStarterPets","ClaimedStarterPets","StarterSelected"}) do
                pcall(function() d[k] = true end)
            end
        end
    end
end)

getgenv().IsMachineActionActive = false
getgenv().LastPrintedQuest = ""
getgenv().HasDoneInitialRankTeleport = false
getgenv().IsDoingSpecificQuest = false
getgenv().DoingLegendaryQuest = false

local Config = getgenv().Config or {}
getgenv().Config = Config

Config.AutoFarm = Config.AutoFarm ~= false
Config.FastFarm = Config.FastFarm ~= false
Config.InfPetSpeed = Config.InfPetSpeed ~= false
Config.CollectOrbs = Config.CollectOrbs ~= false
Config.AutoRank = Config.AutoRank ~= false
Config.AutoHatch = Config.AutoHatch ~= false
Config.HatchBest = Config.HatchBest ~= false
Config.HideEgg = Config.HideEgg ~= false
Config.AutoBuyZone = Config.AutoBuyZone ~= false
Config.AutoBuySlot = Config.AutoBuySlot ~= false
Config.AutoBuyEggSlot = Config.AutoBuyEggSlot ~= false
Config.AutoBundleEnchant = Config.AutoBundleEnchant == true
Config.AutoBundlePotion = Config.AutoBundlePotion == true
Config.AutoBundleFruit = Config.AutoBundleFruit == true
Config.AutoBundleFlag = Config.AutoBundleFlag == true
Config.AutoUltimate = Config.AutoUltimate == true
Config.AutoClaimMail = Config.AutoClaimMail == true
Config.AntiAFK = Config.AntiAFK ~= false
Config.KaitunClicker = Config.KaitunClicker ~= false

Config.RankComet = Config.RankComet ~= false
Config.RankJar = Config.RankJar ~= false
Config.RankPinata = Config.RankPinata ~= false
Config.RankLucky = Config.RankLucky ~= false
Config.RankFlag = Config.RankFlag ~= false
Config.RankFruit = Config.RankFruit ~= false
Config.RankPotion = Config.RankPotion ~= false
Config.RankArea = Config.RankArea ~= false
Config.RankUpPotion = Config.RankUpPotion ~= false
Config.RankUpEnchant = Config.RankUpEnchant ~= false
Config.RankHatch = Config.RankHatch ~= false
Config.RankGold = Config.RankGold ~= false
Config.RankRainbow = Config.RankRainbow ~= false
Config.RankLegendary = Config.RankLegendary ~= false
Config.MinRankArea = Config.MinRankArea or 5
Config.TargetEquipSlots = Config.TargetEquipSlots or 99
Config.TargetEggSlots = Config.TargetEggSlots or 99
Config.TargetUltimate = Config.TargetUltimate or "Ground Pound"
Config.AutoTapMode = Config.AutoTapMode or "Closest"
Config.LegendaryEggOffset = Config.LegendaryEggOffset or 1
Config.FastFarmSpeedMs = Config.FastFarmSpeedMs or 300
Config.FastFarmTargets = Config.FastFarmTargets or 10
Config.FarmRadius = Config.FarmRadius or 150
Config.WebhookURL = Config.WebhookURL or ""
Config.WebhookInterval = Config.WebhookInterval or 120
Config.AutoPotion = Config.AutoPotion ~= false
Config.PotionInterval = Config.PotionInterval or 30

local RankConfig = {
    Comet = Config.RankComet, Jar = Config.RankJar, Pinata = Config.RankPinata,
    Lucky = Config.RankLucky, Flag = Config.RankFlag, Fruit = Config.RankFruit,
    Potion = Config.RankPotion, Area = Config.RankArea, UpPotion = Config.RankUpPotion,
    UpEnchant = Config.RankUpEnchant, Hatch = Config.RankHatch, Gold = Config.RankGold,
    Rainbow = Config.RankRainbow, Legendary = Config.RankLegendary
}

local SaveModule
pcall(function() SaveModule = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")) end)

local FetchSaveEvent = Instance.new("BindableEvent")
local LiveSaveData = nil
FetchSaveEvent.Event:Connect(function()
    pcall(function() LiveSaveData = SaveModule.Get() end)
end)

if not getgenv().Kaitun_AntiAFK_Setup then
    getgenv().Kaitun_AntiAFK_Setup = true
    pcall(function()
        player.Idled:Connect(function()
            if Config.AntiAFK and getgenv().Kaitun_IsRunning then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                VirtualUser:Button2Down(Vector2.new(0,0))
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0))
            end
        end)
    end)
    task.spawn(function()
        while task.wait(60) do
            if not getgenv().Kaitun_IsRunning then break end
            if Config.AntiAFK then
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    local char = player.Character
                    if char then
                        local h = char:FindFirstChildOfClass("Humanoid")
                        if h then h.Jump = true end
                    end
                end)
            end
        end
    end)
end

local Library, RankCmds, PlayerPet
pcall(function() Library = require(ReplicatedStorage:WaitForChild("Library")) end)
pcall(function() RankCmds = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("RankCmds")) end)
pcall(function() PlayerPet = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("PlayerPet")) end)

if PlayerPet and type(PlayerPet.CalculateSpeedMultiplier) == "function" and not getgenv().PetSpeedHooked then
    getgenv().PetSpeedHooked = true
    local originalCalc = PlayerPet.CalculateSpeedMultiplier
    PlayerPet.CalculateSpeedMultiplier = function(self, ...)
        if Config.InfPetSpeed and getgenv().Kaitun_IsRunning then return 75 end
        return originalCalc(self, ...)
    end
end

local function checkSuperComputer()
    local hasSC = false
    if SaveModule then pcall(function() local sd = SaveModule.Get(); if sd and ((sd.Rebirths and sd.Rebirths >= 4) or (sd.UnlockedZones and (sd.UnlockedZones["74 | Tech City"] or sd.UnlockedZones["100 | Void"]))) then hasSC = true end end) end
    return hasSC
end
local HAS_SUPER_COMPUTER = checkSuperComputer()

local ZoneDict, ZoneNameByNum = {}, {}
pcall(function()
    local zDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Zones")
    if zDir then
        for _, mod in ipairs(zDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local numStr = string.match(mod.Name, "^(%d+)")
                local clean = string.match(mod.Name, "%d+%s*|%s*(.+)")
                if numStr and clean then local num = tonumber(numStr); ZoneDict[clean] = num; ZoneDict[mod.Name] = num; ZoneNameByNum[num] = clean end
            end
        end
    end
end)

local function getCurrentWorldBounds()
    local pId = game.PlaceId
    if pId == 8737899170 then return 1, 99 elseif pId == 16498369169 then return 100, 199 elseif pId == 17503543197 then return 200, 239 elseif pId == 140403681187145 or pId == 17720827393 then return 240, 999 end
    return 1, 999
end

local function parseZoneNumber(zName, pId)
    local num = tonumber(string.match(zName, "^(%d+)"))
    if num then return num end
    local ln = string.lower(zName)
    if string.find(ln, "shop") or string.find(ln, "spawn") then
        if pId == 16498369169 then return 100 elseif pId == 17503543197 then return 200 elseif pId == 140403681187145 or pId == 17720827393 then return 240 else return 1 end
    end
    return ZoneDict[zName]
end

local CachedZones = nil
local function getAllZoneInstances()
    if CachedZones then return CachedZones end
    local zones = {}
    for _, mn in ipairs({"Map", "Map2", "Map3", "Map4"}) do
        local m = workspace:FindFirstChild(mn)
        if m then for _, z in ipairs(m:GetChildren()) do if not string.find(string.lower(z.Name), "vip") then table.insert(zones, z) end end end
    end
    CachedZones = zones; return zones
end

local function getZoneInstanceByNumber(zNum)
    local fallback = nil
    for _, z in ipairs(getAllZoneInstances()) do
        if parseZoneNumber(z.Name, game.PlaceId) == zNum then
            if string.match(z.Name, "^(%d+)") then return z else fallback = z end
        end
    end
    return fallback
end

local function getZoneName(num)
    local pId = game.PlaceId
    if pId == 8737899170 and num == 1 then return "Spawn" elseif pId == 16498369169 and num == 100 then return "Tech Spawn" elseif pId == 17503543197 and num == 200 then return "Void Spawn" elseif (pId == 140403681187145 or pId == 17720827393) and num == 240 then return "Fantasy Spawn" end
    return ZoneNameByNum[num]
end

local function getHighestUnlockedZoneNumAndInst()
    local maxNum = -1
    local minZ, maxZ = getCurrentWorldBounds()
    local tm = player.PlayerGui:FindFirstChild("TeleportMap")
    if tm then
        for _, d in ipairs(tm:GetDescendants()) do
            if d.Name == "textHolder" then
                local tl, nl = d:FindFirstChild("Title"), d:FindFirstChild("Number")
                if tl and nl and tl:IsA("TextLabel") and nl:IsA("TextLabel") and tl.Text ~= "???" and tl.Text ~= "Locked" then
                    local nm = string.match(nl.Text, "%d+")
                    if nm then local n = tonumber(nm); if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end end
                end
            end
        end
    end
    if maxNum == -1 and SaveModule then
        pcall(function() local d = SaveModule.Get() if d and d.UnlockedZones then for zn, _ in pairs(d.UnlockedZones) do local n = parseZoneNumber(zn, game.PlaceId) if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end end end end)
    end
    return maxNum, getZoneInstanceByNumber(maxNum)
end

local function isAreaUnlocked(req) if HAS_SUPER_COMPUTER then return true end local m, _ = getHighestUnlockedZoneNumAndInst() return m >= req end

getgenv().EggNameToNumber = {}
getgenv().EggNumberToName = {}
local function getEggDataList()
    local edl = {}
    local pId = game.PlaceId
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eDir then
        for _, mod in ipairs(eDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" and d.eggNumber then
                    local eNum = d.eggNumber; local iv = true
                    if pId == 8737899170 and eNum > 112 then iv = false elseif pId == 16498369169 and (eNum <= 112 or eNum >= 213) then iv = false elseif pId == 17503543197 and (eNum < 213 or eNum >= 240) then iv = false elseif (pId == 140403681187145 or pId == 17720827393) and eNum < 240 then iv = false end
                    if iv then
                        local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name
                        getgenv().EggNameToNumber[cn] = eNum; getgenv().EggNumberToName[eNum] = cn
                        table.insert(edl, { name = cn, num = eNum, zoneNum = d.zoneNumber or eNum })
                    end
                end
            end
        end
    end
    table.sort(edl, function(a, b) return a.num < b.num end); return edl
end
local GLOBAL_EGG_DATA = getEggDataList()

local function getEnchantDataList()
    local l, m = {}, {}
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Enchants")
    if eDir then for _, mod in ipairs(eDir:GetDescendants()) do if mod:IsA("ModuleScript") then local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name if not m[cn] then m[cn] = true; table.insert(l, cn) end end end end
    table.sort(l); return l
end
local GLOBAL_ENCHANT_LIST = getEnchantDataList()

local function getUltimateList()
    local l = {}
    local uDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Ultimates")
    if uDir then for _, mod in ipairs(uDir:GetChildren()) do if mod:IsA("ModuleScript") then table.insert(l, string.match(mod.Name, "|%s*(.+)") or mod.Name) end end end
    table.sort(l); if #l == 0 then l = {"Pet Surge", "Ground Pound", "Black Hole", "Tornado", "Tsunami", "Lightning Storm", "Hidden Treasure", "Nightmare", "TNT Shower", "UFO"} end; return l
end
local GLOBAL_ULTIMATE_LIST = getUltimateList()

local function getPetsFromEgg(eggName)
    local pets = {}
    local eggsDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eggsDir and eggName then
        for _, mod in ipairs(eggsDir:GetDescendants()) do
            local cleanName = string.match(mod.Name, "|%s*(.+)") or mod.Name
            if cleanName == eggName then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" then
                    local target = d.pets or d.Pets or d.drops or d.Drops or d.items or d.Items or d.rewards
                    if target and type(target) == "table" then
                        for _, p in pairs(target) do
                            if type(p) == "table" and (p[1] or p.id or p.name) then
                                pets[tostring(p[1] or p.id or p.name)] = true
                            elseif type(p) == "string" then
                                pets[p] = true
                            end
                        end
                    end
                end
                break
            end
        end
    end
    return pets
end

local function getOrderedConsumablePotionUID(targetTier)
    local orderList = {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}
    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory.Potion then
            for _, name in ipairs(orderList) do
                local fallbackUid, fallbackTier = nil, 999
                for uid, item in pairs(data.Inventory.Potion) do
                    if tostring(item.id) == name then
                        local tier, amount = tonumber(item.tn) or 1, tonumber(item._am) or 1
                        if targetTier then
                            if tier == tonumber(targetTier) and amount >= 1 then return uid, name end
                        else
                            if tier < fallbackTier and amount >= 1 then fallbackTier = tier; fallbackUid = uid end
                        end
                    end
                end
                if not targetTier and fallbackUid then return fallbackUid, name end
            end
        end
    end
    return nil, nil
end

local function getLiveUID(iName, tNum, cat, minAmt)
    if SaveModule then local s, d = pcall(SaveModule.Get); if s and d and d.Inventory and d.Inventory[cat] then for u, dt in pairs(d.Inventory[cat]) do if tostring(dt.id) == iName and (tonumber(dt.tn) or 1) == tonumber(tNum) and (tonumber(dt._am) or 1) >= (minAmt or 1) then return u end end end end
    return nil
end

local function getMiscItemUID(iName, avoidShiny)
    if SaveModule then local s, d = pcall(SaveModule.Get); if s and d and d.Inventory then for _, c in ipairs({"Misc", "Lootbox", "Consumable", "Fruit"}) do if d.Inventory[c] then for u, dt in pairs(d.Inventory[c]) do if tostring(dt.id) == iName then if not (avoidShiny and dt.sh) then return u end end end end end end end
    return nil
end

local function getValidBreakZone(zoneInstance)
    local interact = zoneInstance:FindFirstChild("INTERACT")
    if interact then
        local spawnFolder = interact:FindFirstChild("BREAKABLE_SPAWNS")
        if spawnFolder then
            local main = spawnFolder:FindFirstChild("Main")
            if main then return main end
        end
    end
    return nil
end

local function getZonePosition(zInst)
    if not zInst then return Vector3.new(0,0,0) end
    if zInst:IsA("Model") or zInst:IsA("BasePart") then return zInst:GetPivot().Position end
    local i = zInst:FindFirstChild("INTERACT")
    if i then local sf = i:FindFirstChild("BREAKABLE_SPAWNS") if sf and sf:FindFirstChild("Main") then return sf.Main:GetPivot().Position end end
    local p = zInst:FindFirstChild("PERSISTENT")
    if p then local fp = p:FindFirstChildWhichIsA("BasePart", true) if fp then return fp.Position end end
    local ap = zInst:FindFirstChildWhichIsA("BasePart", true); if ap then return ap.Position end
    return Vector3.new(0,0,0)
end

local function getCurrentAreaNumber()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -100, 0), (function() local p = RaycastParams.new(); p.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("__THINGS")}; p.FilterType = Enum.RaycastFilterType.Exclude; return p end)())
    if ray and ray.Instance then
        local c = ray.Instance
        while c and c ~= workspace do
            if c.Parent and string.match(string.lower(c.Parent.Name), "map") then local n = parseZoneNumber(c.Name, game.PlaceId) if n then return n end end
            c = c.Parent
        end
    end
    local md, an = math.huge, 0
    for _, z in ipairs(getAllZoneInstances()) do local pos = getZonePosition(z); if pos ~= Vector3.new(0,0,0) then local dist = (hrp.Position - pos).Magnitude; if dist < md then md = dist; an = parseZoneNumber(z.Name, game.PlaceId) or 0 end end end
    return an
end

local function getPlayerRank()
    local r = 1; pcall(function() if SaveModule then local d = SaveModule.Get(); if d and d.Rank then r = d.Rank end end end); return r
end

local function getMaxHatchAmount()
    local a = 1
    pcall(function()
        if SaveModule then
            local d = SaveModule.Get();
            if d then
                a = d.EggHatchCount or (d.EggSlotsPurchased or 0) + 1
            end
        end
    end)
    return a
end

local function getBestEggNameForPlayer()
    local mZ, _ = getHighestUnlockedZoneNumAndInst()
    if mZ == 100 then for i = #GLOBAL_EGG_DATA, 1, -1 do if GLOBAL_EGG_DATA[i].num == 113 then return GLOBAL_EGG_DATA[i].name end end end
    local bN, mE = nil, 0; for _, e in ipairs(GLOBAL_EGG_DATA) do if e.zoneNum <= mZ and e.num > mE then mE = e.num; bN = e.name end end; return bN
end

local function walkToPosition(targetPos)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:MoveTo(targetPos) end
end

local function teleportToZoneOfficial(zNum)
    local zN = getZoneName(zNum)
    if zN then
        pcall(function() Network.Teleports_RequestTeleport:InvokeServer(zN) end)
        task.wait(1.5)
        return true
    end
    return false
end

local lastCFrameTeleport = 0
local function forceTeleportToBestZone()
    if not getgenv().Kaitun_Ready then return false end
    local mN, bI = getHighestUnlockedZoneNumAndInst()
    if not mN then return false end
    if teleportToZoneOfficial(mN) then return true end
    if bI and tick() - lastCFrameTeleport > 60 then
        lastCFrameTeleport = tick()
        local p = bI:FindFirstChild("PERSISTENT")
        if p then
            local tp = p:FindFirstChild("Teleport") or p:FindFirstChildWhichIsA("BasePart", true)
            if tp then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = (tp:IsA("Model") and tp:GetPivot() or tp.CFrame) * CFrame.new(0, 15, 0)
                end
            end
        end
    end
    return true
end

local function teleportToZoneNum(zNum)
    return teleportToZoneOfficial(zNum)
end

local function teleportToEgg(eName)
    local n = getgenv().EggNameToNumber[eName]; if not n then return end
    local cN = tostring(n) .. " - Egg Capsule"; local t = workspace:FindFirstChild("__THINGS"); if not t then return end
    local pId, cap = game.PlaceId, nil
    if pId == 17503543197 then local ef = t:FindFirstChild("Eggs") if ef then cap = ef:FindFirstChild(cN, true) end end
    if not cap then local ze = t:FindFirstChild("ZoneEggs") if ze then cap = ze:FindFirstChild(cN, true) end end
    if not cap then local ef = t:FindFirstChild("Eggs") if ef then cap = ef:FindFirstChild(cN, true) end end
    if cap then
        teleportToZoneOfficial(n)
        task.wait(0.8)
        local target = cap:GetPivot().Position + Vector3.new(0, 4, 6)
        walkToPosition(target)
        task.wait(1)
    end
end



local function safeMachineFire(mTab, rName, uid, amt)
    local r = Network:FindFirstChild(rName); if not r then return end
    local el = Network:FindFirstChild("EventLog_Once")
    local pId = game.PlaceId
    local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if el then pcall(function() el:FireServer("OpenTab", uSC and "SuperMachine" or mTab) end) task.wait(0.1) end
    pcall(function() r:InvokeServer(uid, amt) end)
    if el then task.wait(0.1) pcall(function() el:FireServer("CloseTab", uSC and "SuperMachine" or mTab) end) end
end

local function performMachineAction(act, zNum, mName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local pId = game.PlaceId; local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if uSC then if pId == 16498369169 then zNum = 100 elseif pId == 17503543197 then zNum = 200 elseif pId == 140403681187145 or pId == 17720827393 then zNum = 240 end; mName = "SuperMachine" end
    getgenv().IsMachineActionActive = true; teleportToZoneNum(zNum); task.wait(0.5) 
    local appr = Network:FindFirstChild("Machines: Mark Approached"); if appr and mName then pcall(function() appr:FireServer(mName) end) end
    pcall(act); task.wait(0.3); getgenv().IsMachineActionActive = false
end

local function getBulkUpgradableItems(category, requiredCrafts, targetTierNum)
    local results = {}
    local orderList = category == "Potion" and {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter", "Speed"} or {"Treasure Hunter", "Tap Power", "Strong Pets", "Speed", "Magnet", "Lucky Eggs", "Diamonds", "Criticals", "Coins"}
    local craftsRemaining = requiredCrafts
    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory[category] then
            if targetTierNum then
                local targetInputTier = targetTierNum - 1
                for _, name in ipairs(orderList) do
                    for uid, item in pairs(data.Inventory[category]) do
                        if tostring(item.id) == name and (tonumber(item.tn) or 1) == targetInputTier then
                            local amount = tonumber(item._am) or 1
                            local possibleCrafts = math.floor(amount / 5)
                            if possibleCrafts > 0 then
                                local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                table.insert(results, {uid = uid, name = name, crafts = craftsToTake})
                                craftsRemaining = craftsRemaining - craftsToTake
                                if craftsRemaining <= 0 then return results end
                            end
                        end
                    end
                end
            else
                for currentSearchTier = 1, 7 do
                    for _, name in ipairs(orderList) do
                        for uid, item in pairs(data.Inventory[category]) do
                            if tostring(item.id) == name and (tonumber(item.tn) or 1) == currentSearchTier then
                                local isMax = false
                                if category == "Potion" and name == "Speed" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Magnet" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Speed" and currentSearchTier >= 5 then isMax = true end
                                if currentSearchTier >= 8 then isMax = true end
                                if not isMax then
                                    local amount = tonumber(item._am) or 1
                                    local possibleCrafts = math.floor(amount / 5)
                                    if possibleCrafts > 0 then
                                        local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                        table.insert(results, {uid = uid, name = name, crafts = craftsToTake})
                                        craftsRemaining = craftsRemaining - craftsToTake
                                        if craftsRemaining <= 0 then return results end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

-- Startup delay — let game settle after pet picker before any teleports
getgenv().Kaitun_Ready = false
task.delay(30, function() getgenv().Kaitun_Ready = true end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, g in ipairs(player.PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Enabled then
                    local n = string.lower(g.Name)
                    if string.find(n, "rankup") or string.find(n, "masteryperk") or string.find(n, "levelup") or string.find(n, "newperk") then
                        local cam = workspace.CurrentCamera
                        if cam then
                            local cx = cam.ViewportSize.X * 0.5
                            local cy = cam.ViewportSize.Y * 0.5
                            for i = 1, 3 do
                                pcall(function() VirtualUser:ClickButton1(Vector2.new(cx, cy)) end)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1) end)
                                task.wait(0.1)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1) end)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local function GetActiveRankQuests()
    local quests = {}
    local goalsSide = player.PlayerGui:FindFirstChild("GoalsSide")
    local holder = goalsSide and goalsSide:FindFirstChild("QuestsHolder", true)
    if holder then
        for _, item in pairs(holder:GetChildren()) do
            local titleLbl = item:FindFirstChild("Title", true) or item:FindFirstChild("Desc", true)
            if titleLbl and titleLbl.Text ~= "" then
                local text = string.lower(titleLbl.Text)
                if not string.find(text, "rankup ready") then
                    local questFullText = ""
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                            questFullText = questFullText .. " " .. string.lower(desc.Text)
                        end
                    end
                    local prog = 0; local maxNum = 1
                    local slash = string.char(47)
                    local pattern = "(%d+)%s*" .. slash .. "%s*(%d+)"
                    local pMatch, mMatch = string.match(questFullText, pattern)
                    if pMatch and mMatch then
                        prog = tonumber(pMatch); maxNum = tonumber(mMatch)
                    else
                        local n = string.match(text, "(%d+)")
                        maxNum = n and tonumber(n) or 1
                    end
                    local remaining = math.max(1, maxNum - prog)
                    table.insert(quests, {txt = text, remaining = remaining, raw = titleLbl.Text, ignored = false})
                end
            end
        end
    end
    return quests
end

local function getEquippedEnchants()
    local equipped = {}
    pcall(function()
        local data = SaveModule.Get()
        if data and data.EquippedEnchants then
            for slotStr, uid in pairs(data.EquippedEnchants) do
                local slotNum = tonumber(string.match(slotStr, "%d+"))
                if slotNum then
                    local eName, eTier, isTls = "Unknown", 1, false
                    if data.Inventory and data.Inventory.Enchant and data.Inventory.Enchant[uid] then
                        eName = tostring(data.Inventory.Enchant[uid].id)
                        local tierRaw = tonumber(data.Inventory.Enchant[uid].tn)
                        if tierRaw then eTier = tierRaw else eTier = 99; isTls = true end
                    end
                    equipped[slotNum] = {name = eName, tier = eTier, uid = uid, isTierless = isTls}
                end
            end
        end
    end)
    return equipped
end

local targetEggName = nil
local lastRankClaim, lastItemUse = 0, 0
local globalIgnoredQuests = {}
local rankFruitList = {"Rainbow Fruit", "Watermelon", "Pineapple", "Orange", "Banana", "Apple"}
local currentRankFruitIndex = 1
local lastRankFruitProgress = -1
local ROMAN_MAP = {["i"] = 1, ["ii"] = 2, ["iii"] = 3, ["iv"] = 4, ["v"] = 5, ["vi"] = 6, ["vii"] = 7, ["viii"] = 8, ["ix"] = 9, ["x"] = 10}

task.spawn(function()
    local kaitunDone = false
    while task.wait(0.3) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.KaitunClicker and not kaitunDone then
            local found = false
            for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    local isS = false
                    for _, d in ipairs(gui:GetDescendants()) do if d:IsA("TextLabel") and string.find(string.lower(d.Text), "pick 2 pets") then isS = true; break end end
                    if isS then
                        found = true
                        local petB, okB = {}, nil
                        for _, d in ipairs(gui:GetDescendants()) do
                            if d:IsA("GuiButton") and d.Visible and d.AbsoluteSize.X > 30 then
                                local lower = ""
                                pcall(function() if d:IsA("TextButton") then lower = string.lower(d.Text) else for _, c in ipairs(d:GetDescendants()) do if c:IsA("TextLabel") then lower = lower .. " " .. string.lower(c.Text) end end end end)
                                if string.find(lower, "ok") then okB = d else table.insert(petB, d) end
                            end
                        end
                        table.sort(petB, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)

                        for i = 1, math.min(2, #petB) do
                            local b = petB[i]
                            for _, eventName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}) do
                                local cons = getconnections and getconnections(b[eventName]) or {}
                                for _, con in ipairs(cons) do pcall(con.Fire, con) end
                            end
                            task.wait(0.15)
                        end

                        if okB then
                            task.wait(0.3)
                            for _, eventName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}) do
                                local cons = getconnections and getconnections(okB[eventName]) or {}
                                for _, con in ipairs(cons) do pcall(con.Fire, con) end
                            end
                        end

                        local remoteNames = {"Pick Starter Pets", "PickStarterPets", "Pick_Starter_Pets", "Pets: Pick Starter", "Pets_StarterPick", "Pets_PickStarter", "StarterPets_Pick", "StarterPets_Choose", "Starter_SelectPets"}
                        for _, rn in ipairs(remoteNames) do
                            local r = Network:FindFirstChild(rn)
                            if r then
                                if r:IsA("RemoteFunction") then
                                    pcall(function() r:InvokeServer() end); pcall(function() r:InvokeServer(1, 2) end); pcall(function() r:InvokeServer("1", "2") end); pcall(function() r:InvokeServer(true) end)
                                elseif r:IsA("RemoteEvent") then
                                    pcall(function() r:FireServer() end); pcall(function() r:FireServer(1, 2) end); pcall(function() r:FireServer("1", "2") end); pcall(function() r:FireServer(true) end)
                                end
                            end
                        end
                        local N = pcall(require, ReplicatedStorage.Library.Client.Network) and require(ReplicatedStorage.Library.Client.Network) or nil
                        if type(N) == "table" then
                            for _, rn in ipairs(remoteNames) do
                                for _, fn in ipairs({"Fire", "Invoke", "Send", "Call", "Request"}) do
                                    local f = N[fn]
                                    if type(f) == "function" then pcall(f, N, rn); pcall(f, N, rn, 1, 2); pcall(f, N, rn, "1", "2") end
                                end
                            end
                            if N.Invoke and type(N.Invoke) == "function" then pcall(N.Invoke, N, "Pick Starter Pets", 1, 2); pcall(N.Invoke, N, "Pick Starter Pets") end
                        end

                        pcall(function()
                            local s = require(ReplicatedStorage.Library.Client.Save)
                            local d = s.Get()
                            if d then
                                d.StarterClaimed = true; d.StarterPicked = true
                                for _, k in ipairs({"StarterClaimed","StarterPicked","HasPickedStarter","StarterPetsChosen","PickedStarterPets","ClaimedStarterPets","StarterSelected","_starterPicked","starterDone","hasChosenStarter"}) do pcall(function() d[k] = true end) end
                            end
                        end)

                        pcall(function() gui:Destroy() end)
                        kaitunDone = true
                        break
                    end
                end
            end
            if found then Config.KaitunClicker = false end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoBuyZone and not getgenv().IsMachineActionActive and not targetEggName and not getgenv().IsDoingSpecificQuest then
            local cM, _ = getHighestUnlockedZoneNumAndInst()
            if cM then
                for _, z in ipairs(getAllZoneInstances()) do
                    local n = tonumber(string.match(z.Name, "^(%d+)"))
                    if n == cM + 1 then
                        local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name
                        if cl then pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end); task.wait(0.5); local nM, _ = getHighestUnlockedZoneNumAndInst() if nM > cM then forceTeleportToBestZone() end end
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoUltimate and isAreaUnlocked(120) then
            pcall(function() Network:FindFirstChild("Ultimates: Activate"):InvokeServer(Config.TargetUltimate) end)
        end
        if Config.AutoBundleEnchant then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Enchant Bundle", 100) end) end
        if Config.AutoBundlePotion then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Potion Bundle", 100) end) end
        if Config.AutoBundleFruit then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Fruit Bundle", 100) end) end
        if Config.AutoBundleFlag then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Flag Bundle", 100) end) end
    end
end)

task.spawn(function()
    while task.wait(Config.PotionInterval) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoPotion then
            pcall(function()
                local orderList = {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}
                local s, d = pcall(SaveModule.Get)
                if s and d and d.Inventory and d.Inventory.Potion then
                    for _, name in ipairs(orderList) do
                        local bestUid, bestTier = nil, 0
                        for uid, item in pairs(d.Inventory.Potion) do
                            if tostring(item.id) == name then
                                local tier = tonumber(item.tn) or 1
                                local amt = tonumber(item._am) or 1
                                if amt >= 1 and tier > bestTier then
                                    bestTier = tier; bestUid = uid
                                end
                            end
                        end
                        if bestUid then
                            pcall(function() Network:FindFirstChild("Potions: Consume"):FireServer(bestUid, 1) end)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if not getgenv().Kaitun_IsRunning then break end
        if not Config.AutoRank then break end
        pcall(function()
            local saved = {}
            for n, _ in pairs(getgenv().Config) do
                if string.find(tostring(n), "EnchantSlot_") then
                    saved[tonumber(string.match(tostring(n), "%d+"))] = getgenv().Config[n]
                end
            end
            if next(saved) then
                local equipped = getEquippedEnchants()
                for slot, eName in pairs(saved) do
                    local cur = equipped[slot]
                    if not cur or cur.name ~= eName then
                        if cur then pcall(function() Network.Enchants_ClearSlot:FireServer(slot) end); task.wait(0.1) end
                        local evt = Network:FindFirstChild("Enchants_Equip")
                        if evt then
                            if SaveModule then
                                local s, d = pcall(SaveModule.Get)
                                if s and d and d.Inventory and d.Inventory.Enchant then
                                    for uid, dt in pairs(d.Inventory.Enchant) do
                                        if tostring(dt.id) == eName then
                                            pcall(function() evt:FireServer(uid) end); task.wait(0.1)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local cachedBreakables = {}
task.spawn(function()
    while task.wait(1) do
        if not getgenv().Kaitun_IsRunning then break end
        pcall(function()
            local zones = getAllZoneInstances()
            local cb = {}
            for _, z in ipairs(zones) do
                local bz = getValidBreakZone(z)
                if bz then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local dist = hrp and (hrp.Position - getZonePosition(z)).Magnitude or 9999
                    table.insert(cb, {n = bz, z = z, d = dist})
                end
            end
            cachedBreakables = cb
        end)
    end
end)

local lastFarmTime = tick()
task.spawn(function()
    while task.wait(0.15) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoFarm then
            pcall(function()
                if not getgenv().IsMachineActionActive and not getgenv().IsDoingSpecificQuest then
                    local vt = {}
                    for _, i in ipairs(cachedBreakables) do if i.n and i.n.Parent then table.insert(vt, i) end end
                    if #vt > 0 then
                        lastFarmTime = tick()
                        if Config.FastFarm then
                            local euids = {}
                            pcall(function() if PlayerPet and type(PlayerPet.GetAll) == "function" then for u, dt in pairs(PlayerPet.GetAll()) do if dt.owner == player then table.insert(euids, tostring(u)) end end end end)
                            if #euids > 0 then
                                local pl = {}; local bI = 1
                                for _, u in ipairs(euids) do pl[u] = vt[bI].n.Name; bI = bI + 1; if bI > #vt then bI = 1 end end
                                pcall(function() Network:FindFirstChild("Breakables_JoinPetBulk"):FireServer(pl) end)
                            end
                            local mT = Config.FastFarmTargets or 10; local tH = 0
                            local dr = Network:FindFirstChild("Breakables_PlayerDealDamage")
                            if dr then for _, bD in ipairs(vt) do if tH >= mT then break end tH = tH + 1 task.spawn(function() pcall(function() dr:FireServer(bD.n.Name) end) end) end end
                        else
                            local tN = (Config.AutoTapMode == "Random") and vt[math.random(1, #vt)].n or (table.sort(vt, function(a, b) return a.d < b.d end) and vt[1].n or vt[1].n)
                            if tN and tN.Name then pcall(function() Network:FindFirstChild("Breakables_PlayerDealDamage"):FireServer(tN.Name) end) end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoFarm and tick() - lastFarmTime > 10 then
            local mN, _ = getHighestUnlockedZoneNumAndInst()
            if mN and mN > 1 then
                pcall(function() forceTeleportToBestZone() end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not getgenv().Kaitun_IsRunning then break end
        if (Config.CollectOrbs or Config.AutoFarm) and not getgenv().IsMachineActionActive then
            pcall(function()
                local orbs = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Orbs")
                if orbs and #orbs:GetChildren() > 0 then
                    local ids = {}
                    for _, o in ipairs(orbs:GetChildren()) do table.insert(ids, tonumber(o.Name)) end
                    pcall(function() Network:FindFirstChild("Orbs: Collect"):FireServer(ids) end)
                    for _, o in ipairs(orbs:GetChildren()) do pcall(function() o:Destroy() end) end
                end
            end)
        end
    end
end)

task.spawn(function()
    getgenv().SlotFailCounts = getgenv().SlotFailCounts or { Pet = 0, Egg = 0 }
    getgenv().SlotLastFailTime = getgenv().SlotLastFailTime or { Pet = 0, Egg = 0 }
    getgenv().LastRank_Slot = getgenv().LastRank_Slot or getPlayerRank()
    while task.wait(3) do
        if not getgenv().Kaitun_IsRunning then break end
        local cR = getPlayerRank()
        if cR > getgenv().LastRank_Slot then getgenv().SlotFailCounts.Pet = 0; getgenv().SlotFailCounts.Egg = 0; getgenv().LastRank_Slot = cR end
        if Config.AutoBuySlot then
            pcall(function()
                if getgenv().SlotFailCounts.Pet >= 3 and tick() - getgenv().SlotLastFailTime.Pet < 300 then return end
                local cP, pP = 4, 0
                if SaveModule then local d = SaveModule.Get() if d then cP = d.MaxPetsEquipped or 4; pP = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or d.EquipSlotsPurchased or 0 end end
                if pP == 0 and cP > 4 then pP = cP - 4 end
                if cP < Config.TargetEquipSlots then
                    local tU = pP + 1; local preP = pP
                    pcall(function() Network:FindFirstChild("EquipSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetsSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function() local d = SaveModule.Get() pPo = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or preP end)
                    if pPo == preP then getgenv().SlotFailCounts.Pet = getgenv().SlotFailCounts.Pet + 1; getgenv().SlotLastFailTime.Pet = tick() else getgenv().SlotFailCounts.Pet = 0 end
                end
            end)
        end
        if Config.AutoBuyEggSlot then
            pcall(function()
                if getgenv().SlotFailCounts.Egg >= 3 and tick() - getgenv().SlotLastFailTime.Egg < 300 then return end
                local cE, pE = 1, 0
                if SaveModule then local d = SaveModule.Get() if d then cE = d.EggHatchCount or 1; pE = d.EggSlotsPurchased or d.HatchSlotsPurchased or 0 end end
                if pE == 0 and cE > 1 then pE = cE - 1 end
                if cE < Config.TargetEggSlots then
                    local allowed = 0
                    pcall(function() allowed = RankCmds.GetEggSlotsBeforeRank(cR); local rD = require(ReplicatedStorage.Library.Directory.Ranks)[cR] if rD and rD.UnlockableEggSlots then allowed = allowed + rD.UnlockableEggSlots end end)
                    if not (allowed > 0 and pE < allowed or true) then return end
                    local tU = pE + 1; local preP = pE
                    local eReq = Network:FindFirstChild("EggHatchSlotsMachine_RequestPurchase")
                    if eReq then
                        if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then pcall(function() eReq:InvokeServer(tU) end) else performMachineAction(function() pcall(function() eReq:InvokeServer(tU) end) end, 8, "EggHatchSlotsMachine") end
                    end
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function() local d = SaveModule.Get() pPo = d.EggSlotsPurchased or d.HatchSlotsPurchased or preP end)
                    if pPo == preP then getgenv().SlotFailCounts.Egg = getgenv().SlotFailCounts.Egg + 1; getgenv().SlotLastFailTime.Egg = tick() else getgenv().SlotFailCounts.Egg = 0 end
                end
            end)
        end
    end
end)

local isHatching = false
task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().Kaitun_IsRunning then break end
        if not isHatching then
            local tEgg = (Config.HatchBest and getBestEggNameForPlayer()) or targetEggName
            if tEgg then
                isHatching = true
                if Config.HatchBest then
                    local cZ, bZ = getCurrentAreaNumber(), getHighestUnlockedZoneNumAndInst()
                    if cZ ~= bZ then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end
                else
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local n = getgenv().EggNameToNumber[tEgg]
                    local cN = n and (tostring(n) .. " - Egg Capsule") or ""
                    local cap = nil
                    local t = workspace:FindFirstChild("__THINGS")
                    if t then
                        local pId = game.PlaceId
                        if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                    end
                    if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then getgenv().IsMachineActionActive = true; teleportToEgg(tEgg); task.wait(0.5); getgenv().IsMachineActionActive = false end
                end
                task.spawn(function()
                    local bm = getMaxHatchAmount()
                    pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tEgg, bm) end)
                end)
                isHatching = false
            end
        end
    end
end)

task.spawn(function()
    local function SnipeMail()
        pcall(function() Network:FindFirstChild("Machines: Mark Approached"):FireServer("MailboxMachine") end)
        task.wait(0.2)
        local cAll = Network:FindFirstChild("Mailbox: Claim All")
        if cAll then
            local s, err = pcall(function() return cAll:InvokeServer() end)
            if err == "You must wait 30 seconds before using the mailbox!" then task.wait(31); if Config.AutoClaimMail and getgenv().Kaitun_IsRunning then return SnipeMail() end end
        end
    end
    while task.wait(2) do if not getgenv().Kaitun_IsRunning then break end if Config.AutoClaimMail then SnipeMail(); task.wait(60) end end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.AutoRank and isAreaUnlocked(41) then
            pcall(function()
                if tick() - lastRankClaim >= 15 then
                    lastRankClaim = tick()
                    task.spawn(function() local e = Network:FindFirstChild("Ranks_ClaimReward") if e then for i=1, 99 do pcall(function() e:FireServer(i) end) task.wait(0.02) end end end)
                end
                local qs = GetActiveRankQuests()
                local tq = nil
                local function skip(raw) if raw then globalIgnoredQuests[raw] = tick() + 60 end end
                for _, q in ipairs(qs) do
                    if not (globalIgnoredQuests[q.raw] and tick() < globalIgnoredQuests[q.raw]) then
                        local text = q.txt; local matched = false

                        if RankConfig.Legendary and string.find(text, "legendary") then
                            getgenv().DoingLegendaryQuest = true; local be = getBestEggNameForPlayer()
                            if be then
                                local tE = be; local bI = 0
                                for i, e in ipairs(GLOBAL_EGG_DATA) do if e.name == be then bI = i; break end end
                                local off = Config.LegendaryEggOffset or 1
                                tE = (bI > off) and GLOBAL_EGG_DATA[bI - off].name or GLOBAL_EGG_DATA[1].name
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                local n = getgenv().EggNameToNumber[tE]; local cN = n and (tostring(n) .. " - Egg Capsule") or ""; local cap = nil
                                local t = workspace:FindFirstChild("__THINGS")
                                if t then local pId = game.PlaceId if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end end
                                if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then getgenv().IsMachineActionActive = true; teleportToEgg(tE); task.wait(0.5); getgenv().IsMachineActionActive = false end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tE, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else skip(q.raw) end
                            matched = true

                        elseif RankConfig.Hatch and string.find(text, "hatch") and not string.find(text, "legendary") then
                            local be = getBestEggNameForPlayer()
                            if be then
                                if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() and not getgenv().DoingLegendaryQuest then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else skip(q.raw) end
                            matched = true

                        elseif RankConfig.Potion and (string.find(text, "drink") or string.find(text, "use")) and string.find(text, "potion") then
                            if tick() - lastItemUse >= 1.25 then
                                local tNum = tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")] or 0
                                local u = getOrderedConsumablePotionUID(tNum)
                                if not u and tNum > 0 then u = getOrderedConsumablePotionUID(0) end
                                if not u then
                                    local orderList = {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}
                                    local s, d = pcall(SaveModule.Get)
                                    if s and d and d.Inventory and d.Inventory.Potion then
                                        for _, name in ipairs(orderList) do
                                            for uid, item in pairs(d.Inventory.Potion) do
                                                if tostring(item.id) == name and (tonumber(item._am) or 1) >= 1 then u = uid; break end
                                            end
                                            if u then break end
                                        end
                                    end
                                end
                                if u then for i = 1, q.remaining do pcall(function() Network:FindFirstChild("Potions: Consume"):FireServer(u, 1) end); task.wait(0.1) end lastItemUse = tick(); skip(q.raw) else skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Area and (string.find(text, "unlock") or string.find(text, "reach")) and string.find(text, "area") then
                            local ca = getCurrentAreaNumber()
                            for _, z in ipairs(getAllZoneInstances()) do if tonumber(string.match(z.Name, "^(%d+)")) == ca + 1 then local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name if cl then pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end); task.wait(0.5); forceTeleportToBestZone() end break end end
                            matched = true

                        elseif RankConfig.UpPotion and ((string.find(text, "potion") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "potion"))) and isAreaUnlocked(13) then
                            local r = getBulkUpgradableItems("Potion", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end end, 13, "UpgradePotionsMachine") end getgenv().IsDoingSpecificQuest = false; skip(q.raw) else skip(q.raw) end
                            matched = true

                        elseif RankConfig.UpEnchant and ((string.find(text, "enchant") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "enchant"))) and isAreaUnlocked(16) then
                            local r = getBulkUpgradableItems("Enchant", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end end, 16, "UpgradeEnchantsMachine") end getgenv().IsDoingSpecificQuest = false; skip(q.raw) else skip(q.raw) end
                            matched = true

                        elseif RankConfig.Gold and string.find(text, "golden") and isAreaUnlocked(31) then
                            local be = getBestEggNameForPlayer(); local vP = be and getPetsFromEgg(be) or {}; local nP, tC = {}, 0
                            if SaveModule then pcall(function() for u, d in pairs(SaveModule.Get().Inventory.Pet) do if not d.l and not d.locked and not d.lk and (tonumber(d.pt) or 0) == 0 then local id = tostring(d.id); local iM = false; for vp, _ in pairs(vP) do if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end end if iM then local cr = math.floor((tonumber(d._am) or 1) / 10); if cr > 0 then table.insert(nP, {uid = u, crafts = cr}); tC = tC + cr end end end end end) end
                            if tC > 0 then
                                local cQ, cR = {}, q.remaining; table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(nP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 31, "GoldMachine") end getgenv().IsDoingSpecificQuest = false end
                            end
                            if tC < q.remaining and be then if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end); task.wait(0.1) end
                            matched = true

                        elseif RankConfig.Rainbow and string.find(text, "rainbow") and isAreaUnlocked(41) then
                            local be = getBestEggNameForPlayer(); local vP = be and getPetsFromEgg(be) or {}; local nP, gP, tC, tR = {}, {}, 0, 0
                            if SaveModule then pcall(function() for u, d in pairs(SaveModule.Get().Inventory.Pet) do if not d.l and not d.locked and not d.lk then local pt = tonumber(d.pt) or 0 if pt == 0 or pt == 1 then local id = tostring(d.id); local iM = false; for vp, _ in pairs(vP) do if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end end if iM then local cr = math.floor((tonumber(d._am) or 1) / 10); if cr > 0 then if pt == 0 then table.insert(nP, {uid = u, crafts = cr}); tC = tC + cr elseif pt == 1 then table.insert(gP, {uid = u, crafts = cr}); tR = tR + cr end end end end end end end) end
                            local pId, uSC = game.PlaceId, HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393)
                            if tR > 0 then
                                local cQ, cR = {}, q.remaining; table.sort(gP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(gP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if uSC then for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 41, "RainbowMachine") end getgenv().IsDoingSpecificQuest = false end
                            end
                            if tR < q.remaining then
                                if tC > 0 then
                                    local mG = (q.remaining - tR) * 10; local cQ, cR = {}, mG; table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                    for _, it in ipairs(nP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                    if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if uSC then for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 31, "GoldMachine") end getgenv().IsDoingSpecificQuest = false end
                                end
                                if (tR * 10 + tC) < (q.remaining * 10) and be then if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end); task.wait(0.1) end
                            end
                            matched = true

                        elseif RankConfig.Flag and string.find(text, "flag") then
                            if tick() - lastItemUse >= 1.25 then
                                local fL = {"Fortune Flag", "Strength Flag", "Magnet Flag", "Coins Flag", "Hasty Flag", "Diamonds Flag", "Rainbow Flag", "Shiny Flag"}
                                local fn = false; for _, f in ipairs(fL) do local u = getMiscItemUID(f, false); if u then pcall(function() Network:FindFirstChild("FlexibleFlags_Consume"):InvokeServer(f, u) end); lastItemUse = tick(); fn = true; break end end
                                if not fn then skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Fruit and string.find(text, "fruit") then
                            if tick() - lastItemUse >= 1.25 then
                                if lastRankFruitProgress ~= -1 and q.prog == lastRankFruitProgress then currentRankFruitIndex = currentRankFruitIndex + 1; if currentRankFruitIndex > #rankFruitList then currentRankFruitIndex = 1 end end
                                local fU = rankFruitList[currentRankFruitIndex]; local u = getMiscItemUID(fU, false) or getMiscItemUID(fU=="Rainbow Fruit" and "Rainbow" or fU:gsub(" ",""), false)
                                if u then pcall(function() Network:FindFirstChild("Fruits: Consume"):FireServer(u, 1) end); lastItemUse = tick(); lastRankFruitProgress = q.prog else skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Comet and string.find(text, "comet") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = getMiscItemUID("Comet", false)
                                if u then for i = 1, q.remaining do pcall(function() Network:FindFirstChild("Comet_Spawn"):InvokeServer(u) end); task.wait(0.1) end lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Jar and string.find(text, "coin") and string.find(text, "jar") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Basic Coin Jar", "CoinJar", "Coin Jar", "Jar"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("CoinJar_Spawn"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Pinata and string.find(text, "pinata") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Mini Pinata", "MiniPinata"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("MiniPinata_Consume"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        elseif RankConfig.Lucky and string.find(text, "lucky") and string.find(text, "block") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Mini Lucky Block", "MiniLuckyBlock"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("MiniLuckyBlock_Consume"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true
                        end
                        if matched then tq = q; break end
                    end
                end
                if not tq and getgenv().DoingLegendaryQuest then
                    getgenv().DoingLegendaryQuest = false
                    getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false
                end
            end)
        end
    end
end)

if Config.HideEgg then
    local originalEggFuncs = {}
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "PlayEggAnimation") or rawget(v, "OpenEgg") or rawget(v, "PlayHatch") or rawget(v, "ShowEgg") then
                    originalEggFuncs.PlayEggAnimation = originalEggFuncs.PlayEggAnimation or rawget(v, "PlayEggAnimation")
                    originalEggFuncs.OpenEgg = originalEggFuncs.OpenEgg or rawget(v, "OpenEgg")
                    originalEggFuncs.PlayHatch = originalEggFuncs.PlayHatch or rawget(v, "PlayHatch")
                    originalEggFuncs.ShowEgg = originalEggFuncs.ShowEgg or rawget(v, "ShowEgg")
                    if type(rawget(v, "PlayEggAnimation")) == "function" then rawset(v, "PlayEggAnimation", function(...) end) end
                    if type(rawget(v, "OpenEgg")) == "function" then rawset(v, "OpenEgg", function(...) end) end
                    if type(rawget(v, "PlayHatch")) == "function" then rawset(v, "PlayHatch", function(...) end) end
                    if type(rawget(v, "ShowEgg")) == "function" then rawset(v, "ShowEgg", function(...) end) end
                end
            end
        end
    end)
    task.spawn(function()
        while task.wait(2) do
            if not getgenv().Kaitun_IsRunning then break end
            pcall(function()
                for _, n in ipairs({"EggOpenAnimation", "EggHatch", "HatchUI"}) do
                    local g = player.PlayerGui:FindFirstChild(n)
                    if g then
                        if g:IsA("ScreenGui") then g.Enabled = false end
                        for _, c in ipairs(g:GetChildren()) do if c:IsA("GuiObject") then c.Position = UDim2.new(9999, 0, 9999, 0); c.Visible = false end end
                    end
                end
            end)
        end
    end)
end

getgenv().Kaitun_StartTime = tick()

task.spawn(function()
    while task.wait(5) do
        if not getgenv().Kaitun_IsRunning then break end
        if Config.WebhookURL and Config.WebhookURL ~= "" and Config.TargetRank and Config.TargetRank > 0 and not Config.HasSentRank then
            pcall(function()
                local r = getPlayerRank()
                if r >= Config.TargetRank then
                    local msg = {}
                    if Config.PingEnabled and Config.PingID and Config.PingID ~= "" then table.insert(msg, "<@" .. Config.PingID .. ">") end
                    table.insert(msg, " Player " .. player.Name .. " reached rank " .. r .. "!")
                    local s, _ = pcall(function() HttpService:PostAsync(Config.WebhookURL, HttpService:JSONEncode({ content = table.concat(msg, " ") }), Enum.HttpContentType.ApplicationJson) end)
                    if s then Config.HasSentRank = true end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(30) do
        if not getgenv().Kaitun_IsRunning then break end
        pcall(function()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity end
            end
        end)
    end
end)

if Config.WebhookURL ~= "" then
    task.spawn(function()
        while task.wait(Config.WebhookInterval) do
            if not getgenv().Kaitun_IsRunning then break end
            pcall(function()
                local d = SaveModule and SaveModule.Get()
                if not d then return end
                local rank = getPlayerRank()
                local coins = d.Coins or 0; local gems = d.Diamonds or 0
                local area = getCurrentAreaNumber()
                local pId = game.PlaceId
                local wName = "World 1"
                if pId == 16498369169 then wName = "World 2 (Tech)"
                elseif pId == 17503543197 then wName = "World 3 (Void)"
                elseif pId == 140403681187145 or pId == 17720827393 then wName = "World 4 (Fantasy)" end
                local elapsed = tick() - getgenv().Kaitun_StartTime
                local function fmt(n)
                    if not n then return "0" end
                    if n >= 1e12 then return ("%.2fT"):format(n/1e12)
                    elseif n >= 1e9 then return ("%.2fB"):format(n/1e9)
                    elseif n >= 1e6 then return ("%.2fM"):format(n/1e6)
                    elseif n >= 1e3 then return ("%.1fK"):format(n/1e3)
                    else return ("%.0f"):format(n) end
                end
                HttpService:PostAsync(Config.WebhookURL, HttpService:JSONEncode({
                    embeds = {{
                        title = "PS99 Kaitun",
                        color = 44759,
                        fields = {
                            { name = "Account", value = player.Name },
                            { name = "MainTask", value = "Auto Farm " .. wName },
                            { name = "SubTask | Zone | Mode", value = "Auto Rank Quest | " .. tostring(area) .. " | Auto" },
                            { name = "Coins | Gems", value = fmt(coins) .. " | " .. fmt(gems), inline = true },
                            { name = "Rebirths | Rank", value = (d.Rebirths or 0) .. " | " .. rank, inline = true },
                            { name = "Runtime", value = ("%02d:%02d:%02d"):format(math.floor(elapsed/3600), math.floor((elapsed%3600)/60), math.floor(elapsed%60)) }
                        },
                        footer = { text = "PS99 Kaitun | Normal World" },
                        timestamp = DateTime.now():ToIsoDate()
                    }}
                }), Enum.HttpContentType.ApplicationJson)
            end)
        end
    end)
end
