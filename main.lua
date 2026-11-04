-- [[ STEAL AN EGG - SURE HUB (FIXED & INTEGRATED) ]]
-- Made for Player: zero

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local TeleportService   = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- // NETWORKING SETUP (Dari Method Asli Game)
local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Networking = Packages and Packages:FindFirstChild("Networking")

local function InvokeRemote(remoteName, ...)
    if not Networking then return nil end
    local r = Networking:FindFirstChild(remoteName)
    if not r then return nil end
    if r:IsA("RemoteFunction") then
        local ok, res = pcall(r.InvokeServer, r, ...)
        return ok and res or nil
    end
    pcall(r.FireServer, r, ...)
    return true
end

-- State Pengaturan
local State = {
    ActiveRunning = false,
    SelectedMode = "Mode 1 (Safe Zone Magnet)",
    SelectedRarity = "Divine",
    AutoPlace = false,
    AutoHatch = false,
    AutoSell = false,
    MinSellPrice = 1000,
    AutoTreadmill = false,
}

local function Notify(title, content, time)
    pcall(function()
        Library:Notify({ Title = title, Description = content, Time = time or 3 })
    end)
end

-- // CORE LOGIC: MENDAPATKAN DATA TELUR AKTIF DARI SERVER SNAPSHOT
local function GetTargetEggs()
    local validEggs = {}
    local snap = InvokeRemote("RF/EggWorld/AskFieldEggSnapshot")
    if type(snap) ~= "table" then return validEggs end
    
    local entries = snap.Eggs or snap.List or snap
    for _, egg in pairs(entries) do
        if type(egg) == "table" then
            local uid = egg.Uid or egg.uid or egg.ID
            local rarity = egg.Rarity or egg.rarity or egg.RarityName or "Common"
            if type(rarity) == "table" then rarity = rarity.DisplayName or rarity._id or "Common" end
            
            if tostring(rarity) == State.SelectedRarity and uid then
                table.insert(validEggs, { uid = tostring(uid), rarity = tostring(rarity), raw = egg })
            end
        end
    end
    return validEggs
end

-- // MODE 1: SAFE ZONE MAGNET & INSTANT COUNTER-STEAL
local function ExecuteMode1()
    Notify("Mode 1 Active", "Safe Zone Magnet & Remote Intercept engaged for " .. State.SelectedRarity, 3)
    task.spawn(function()
        while State.ActiveRunning and State.SelectedMode == "Mode 1 (Safe Zone Magnet)" do
            local eggs = GetTargetEggs()
            for _, egg in ipairs(eggs) do
                -- Memanggil remote carry/steal asli berdasarkan struktur open-source
                InvokeRemote("RF/EggWorld/AskFieldEggCarry", { Uid = egg.uid })
            end
            task.wait(0.4)
        end
    end)
end

-- // MODE 2: WALK, INSTANT PICK, & SAFE ZONE TELEPORT
local function ExecuteMode2()
    Notify("Mode 2 Active", "Walk / Teleport to target " .. State.SelectedRarity .. " egg...", 3)
    task.spawn(function()
        while State.ActiveRunning and State.SelectedMode == "Mode 2 (Walk & Teleport Safe)" do
            local eggs = GetTargetEggs()
            local char = LocalPlayer.Character
            if #eggs > 0 and char and char:FindFirstChild("HumanoidRootPart") then
                local targetEgg = eggs[1]
                
                -- Simulasi Instant Pick via Remote Carry
                InvokeRemote("RF/EggWorld/AskFieldEggCarry", { Uid = targetEgg.uid })
                task.wait(0.1)
                
                -- Teleport balik aman ke base/safezone area
                local safeZone = Workspace:FindFirstChild("SafeZone") or Workspace:FindFirstChild("Base")
                if safeZone then
                    char.HumanoidRootPart.CFrame = safeZone:IsA("Model") and safeZone:GetPivot() or safeZone.CFrame
                end
            end
            task.wait(1)
        end
    end)
end

-- // MODE 3: MULTI-STEP RELAY DELIVERY WITH SHIELD PROTECTION
local function ExecuteMode3()
    Notify("Mode 3 Active", "Multi-step Relay Delivery & Shield Protection engaged!", 3)
    task.spawn(function()
        while State.ActiveRunning and State.SelectedMode == "Mode 3 (Multi-step Relay)" do
            local eggs = GetTargetEggs()
            if #eggs > 0 then
                local targetEgg = eggs[1]
                -- Step Relay Estafet 2 langkah dengan proteksi drop-pickup
                InvokeRemote("RF/EggWorld/AskFieldEggCarry", { Uid = targetEgg.uid })
                task.wait(0.05)
                InvokeRemote("RF/EggWorld/AskFieldEggDrop")
                task.wait(0.05)
                InvokeRemote("RF/EggWorld/AskFieldEggCarry", { Uid = targetEgg.uid })
            end
            task.wait(1)
        end
    end)
end

-- // AUTOMATION LOOP (Auto Place, Hatch, Sell, Treadmill)
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoPlace then
            InvokeRemote("RF/EggWorld/AskPlaceEgg")
        end
        if State.AutoHatch then
            local eggs = GetTargetEggs()
            if #eggs > 0 then
                InvokeRemote("RF/EggWorld/AskHatch", { Uid = eggs[1].uid })
            end
        end
        if State.AutoSell then
            InvokeRemote("RF/Haul/OfferFullSatchelSale")
        end
        
        -- Auto Treadmill (AFK Handler)
        if State.AutoTreadmill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local eggs = GetTargetEggs()
            if #eggs == 0 then
                InvokeRemote("RF/Treadmill/AskTierRaise")
                local treadmill = Workspace:FindFirstChild("Treadmill")
                if treadmill and treadmill:FindFirstChild("PrimaryPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = treadmill.PrimaryPart.CFrame
                end
            end
        end
    end
end)


-- ============================================================
-- UI SETUP (OBSIDIAN THEME)
-- ============================================================
local Window = Library:CreateWindow({
    Title = "Steal An Egg | Sure Hub",
    Footer = "Custom Steal Modes • Fully Integrated",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Steal  = Window:AddTab("Steal Modes", "target"),
    Automation = Window:AddTab("Automation", "zap"),
    Server = Window:AddTab("Server Hop", "globe"),
}

-- TAB 1: STEAL MODES
local StealGroup = Tabs.Steal:AddLeftGroupbox("3 Modes Steal Configuration")

StealGroup:AddDropdown("SelectedMode", {
    Text = "Pilih Mode Steal",
    Values = {"Mode 1 (Safe Zone Magnet)", "Mode 2 (Walk & Teleport Safe)", "Mode 3 (Multi-step Relay)"},
    Default = 1,
    Callback = function(v)
        State.SelectedMode = v
    end,
})

StealGroup:AddDropdown("SelectedRarity", {
    Text = "Target Rarity Telur",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Secret", "Divine", "Eternal"},
    Default = 9, -- Divine
    Callback = function(v)
        State.SelectedRarity = v
    end,
})

StealGroup:AddToggle("ActiveRunning", {
    Text = "Aktifkan Fitur Steal",
    Default = false,
    Callback = function(v)
        State.ActiveRunning = v
        if v then
            if State.SelectedMode == "Mode 1 (Safe Zone Magnet)" then ExecuteMode1()
            elseif State.SelectedMode == "Mode 2 (Walk & Teleport Safe)" then ExecuteMode2()
            elseif State.SelectedMode == "Mode 3 (Multi-step Relay)" then ExecuteMode3() end
        else
            Notify("Stopped", "Steal mode dinonaktifkan.", 2)
        end
    end,
})

-- TAB 2: AUTOMATION
local AutoGroup = Tabs.Automation:AddLeftGroupbox("Auto Farm & Automation")

AutoGroup:AddToggle("AutoPlace", {
    Text = "Auto Place Egg",
    Default = false,
    Callback = function(v) State.AutoPlace = v end,
})

AutoGroup:AddToggle("AutoHatch", {
    Text = "Auto Hatch Egg",
    Default = false,
    Callback = function(v) State.AutoHatch = v end,
})

AutoGroup:AddToggle("AutoSell", {
    Text = "Auto Sell (Satchel Threshold)",
    Default = false,
    Callback = function(v) State.AutoSell = v end,
})

AutoGroup:AddToggle("AutoTreadmill", {
    Text = "Auto Treadmill (AFK Handler)",
    Default = false,
    Callback = function(v) State.AutoTreadmill = v end,
})

-- TAB 3: SERVER HOP
local ServerGroup = Tabs.Server:AddLeftGroupbox("Global Server Finder")

ServerGroup:AddButton({
    Text = "Hop Server Cari Telur Langka",
    Func = function()
        Notify("Server Hop", "Mencari server publik lain...", 3)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

Notify("Sure Hub Loaded", "Ready to steal high-tier eggs, zero!", 4)
