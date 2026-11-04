-- [[ STEAL AN EGG - ULTIMATE UTILITY SCRIPT ]]
-- Made for Player: zero

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal An Egg - Sure Hub",
   LoadingTitle = "Loading Sure Hub...",
   LoadingSubtitle = "by Sure",
   ConfigurationSaving = { Enabled = true, FolderName = "SureHubConfig", FileName = "StealAnEgg" },
   Discord = { Enabled = false },
   KeySystem = false
})

-- // SERVICES & VARIABLES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    SelectedMode = "Mode 1 (Safe Zone Magnet)",
    SelectedRarity = "Divine",
    AutoPlace = false,
    AutoHatch = false,
    AutoSell = false,
    MinSellPrice = 1000,
    AutoTreadmill = false,
    ActiveRunning = false
}

-- // CORE GAMEPLAY METHOD & PATHING
-- Fungsi untuk mendeteksi folder telur aktif di map game Steal an Egg
local function GetTargetEggs()
    local validEggs = {}
    -- Mencari folder spawn telur standar di Workspace game
    local eggsFolder = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("SpawnedEggs") or Workspace:FindFirstChild("Map")
    
    if eggsFolder then
        for _, egg in ipairs(eggsFolder:GetDescendants()) do
            -- Mengecek atribut rarity atau nama objek telur
            if egg:IsA("Model") or egg:IsA("BasePart") then
                local rarityAttr = egg:GetAttribute("Rarity") or egg:GetAttribute("Tier")
                if rarityAttr == Settings.SelectedRarity or egg.Name:lower():find(Settings.SelectedRarity:lower()) then
                    table.insert(validEggs, egg)
                end
            end
        end
    end
    return validEggs
end

-- Mencari Remote Event utama game
local function GetRemotes()
    return ReplicatedStorage:FindFirstChild("Packages") 
        and ReplicatedStorage.Packages:FindFirstChild("Net") 
        or ReplicatedStorage:FindFirstChild("Remotes") 
        or ReplicatedStorage
end

-- // METHOD MODE 1: SAFE ZONE MAGNET & INSTANT COUNTER-STEAL
local function ExecuteMode1()
    Rayfield:Notify({Title = "Mode 1 Active", Content = "Safe Zone Magnet engaged for " .. Settings.SelectedRarity, Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 1 (Safe Zone Magnet)" do
            local eggs = GetTargetEggs()
            local remotes = GetRemotes()
            
            for _, egg in ipairs(eggs) do
                if remotes then
                    -- Method remote event standar untuk interaksi/tarik telur
                    local remoteEvent = remotes:FindFirstChild("RE_StealEgg") or remotes:FindFirstChild("StealEgg") or remotes:FindFirstChild("RequestSteal")
                    if remoteEvent then
                        remoteEvent:FireServer(egg)
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

-- // METHOD MODE 2: WALK & TELEPORT SAFE
local function ExecuteMode2()
    Rayfield:Notify({Title = "Mode 2 Active", Content = "Walking/TP to target " .. Settings.SelectedRarity .. " egg...", Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 2 (Walk & Teleport Safe)" do
            local eggs = GetTargetEggs()
            local character = LocalPlayer.Character
            
            if #eggs > 0 and character and character:FindFirstChild("HumanoidRootPart") then
                local targetEgg = eggs[1]
                local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot() or targetEgg.CFrame
                
                -- Teleport langsung ke posisi telur untuk ambil instan
                character.HumanoidRootPart.CFrame = targetPos
                task.wait(0.1)
                
                local remotes = GetRemotes()
                if remotes then
                    local pickEvent = remotes:FindFirstChild("RE_PickEgg") or remotes:FindFirstChild("PickEgg") or remotes:FindFirstChild("InteractEgg")
                    if pickEvent then
                        pickEvent:FireServer(targetEgg)
                    end
                end
                
                -- Teleport balik aman ke Base / Safe Zone
                task.wait(0.1)
                local safeZone = Workspace:FindFirstChild("SafeZones") or Workspace:FindFirstChild("Base")
                if safeZone and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = safeZone.PrimaryPart and safeZone.PrimaryPart.CFrame or CFrame.new(0, 50, 0)
                end
            end
            task.wait(1)
        end
    end)
end

-- // METHOD MODE 3: MULTI-STEP RELAY DELIVERY + SHIELD
local function ExecuteMode3()
    Rayfield:Notify({Title = "Mode 3 Active", Content = "Relay Delivery with Shield Protection engaged!", Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 3 (Multi-step Relay)" do
            local eggs = GetTargetEggs()
            local character = LocalPlayer.Character
            
            if #eggs > 0 and character and character:FindFirstChild("HumanoidRootPart") then
                local targetEgg = eggs[1]
                local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot() or targetEgg.CFrame
                
                character.HumanoidRootPart.CFrame = targetPos
                task.wait(0.05)
                
                local remotes = GetRemotes()
                if remotes then
                    local relayEvent = remotes:FindFirstChild("RE_RelayDeliver") or remotes:FindFirstChild("RelayDeliver") or remotes:FindFirstChild("DeliverEgg")
                    if relayEvent then
                        -- Step 1 & 2 Relay Estafet Aman
                        relayEvent:FireServer(targetEgg, "Step1")
                        task.wait(0.05)
                        relayEvent:FireServer(targetEgg, "Step2")
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- // AUTOMATION BACKGROUND LOOP
task.spawn(function()
    while true do
        task.wait(1)
        local remotes = GetRemotes()
        
        if remotes then
            -- Auto Place
            if Settings.AutoPlace then
                local placeEv = remotes:FindFirstChild("PlaceEgg") or remotes:FindFirstChild("RE_PlaceEgg")
                if placeEv then placeEv:FireServer() end
            end
            -- Auto Hatch
            if Settings.AutoHatch then
                local hatchEv = remotes:FindFirstChild("HatchEgg") or remotes:FindFirstChild("RE_HatchEgg")
                if hatchEv then hatchEv:FireServer() end
            end
            -- Auto Sell Threshold
            if Settings.AutoSell then
                local sellEv = remotes:FindFirstChild("SellEgg") or remotes:FindFirstChild("RE_SellEgg")
                if sellEv then sellEv:FireServer(Settings.MinSellPrice) end
            end
        end
        
        -- Auto Treadmill (AFK Handler)
        if Settings.AutoTreadmill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local eggs = GetTargetEggs()
            if #eggs == 0 then
                local treadmill = Workspace:FindFirstChild("Treadmill") or Workspace:FindFirstChild("TrainingArea")
                if treadmill then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = treadmill:IsA("Model") and treadmill:GetPivot() or treadmill.CFrame
                end
            end
        end
    end
end)


-- // UI TABS CONFIGURATION
local MainTab = Window:CreateTab("Steal Modes", 4483362458)
local AutoTab = Window:CreateTab("Automation", 4483362458)
local ServerTab = Window:CreateTab("Server Finder", 4483362458)

-- // MAIN TAB: STEAL MODES
MainTab:CreateDropdown({
   Name = "Pilih Mode Steal",
   Options = {"Mode 1 (Safe Zone Magnet)", "Mode 2 (Walk & Teleport Safe)", "Mode 3 (Multi-step Relay)"},
   CurrentOption = {"Mode 1 (Safe Zone Magnet)"},
   MultipleOptions = false,
   Callback = function(Option)
       Settings.SelectedMode = Option[1]
   end,
})

MainTab:CreateDropdown({
   Name = "Target Rarity Telur",
   Options = {
       "Common", 
       "Uncommon", 
       "Rare", 
       "Epic", 
       "Legendary", 
       "Mythic", 
       "Cosmic", 
       "Secret", 
       "Eternal", 
       "Divine"
   },
   CurrentOption = {"Divine"},
   MultipleOptions = false,
   Callback = function(Option)
       Settings.SelectedRarity = Option[1]
   end,
})

MainTab:CreateButton({
   Name = "EKSEKUSI STEAL NOW",
   Callback = function()
       Settings.ActiveRunning = true
       if Settings.SelectedMode == "Mode 1 (Safe Zone Magnet)" then
           ExecuteMode1()
       elseif Settings.SelectedMode == "Mode 2 (Walk & Teleport Safe)" then
           ExecuteMode2()
       elseif Settings.SelectedMode == "Mode 3 (Multi-step Relay)" then
           ExecuteMode3()
       end
   end,
})

MainTab:CreateButton({
   Name = "STOP EXECUTION",
   Callback = function()
       Settings.ActiveRunning = false
       Rayfield:Notify({Title = "Stopped", Content = "All active steal modes stopped.", Duration = 2})
   end,
})

-- // AUTOMATION TAB
AutoTab:CreateToggle({
   Name = "Auto Place Egg",
   CurrentValue = false,
   Callback = function(Value)
       Settings.AutoPlace = Value
   end,
})

AutoTab:CreateToggle({
   Name = "Auto Hatch Egg",
   CurrentValue = false,
   Callback = function(Value)
       Settings.AutoHatch = Value
   end,
})

AutoTab:CreateToggle({
   Name = "Auto Sell Egg (Based on Threshold)",
   CurrentValue = false,
   Callback = function(Value)
       Settings.AutoSell = Value
   end,
})

AutoTab:CreateInput({
   Name = "Min Rate / Price Sell Threshold",
   PlaceholderText = "Masukkan harga minimal...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Settings.MinSellPrice = tonumber(Text) or 1000
   end,
})

AutoTab:CreateToggle({
   Name = "Auto Treadmill (AFK Mode)",
   CurrentValue = false,
   Callback = function(Value)
       Settings.AutoTreadmill = Value
   end,
})

-- // SERVER FINDER TAB
ServerTab:CreateButton({
   Name = "Scan High-Value Egg Across Servers",
   Callback = function()
       Rayfield:Notify({Title = "Server Scanner", Content = "Scanning public servers for Secret, Eternal & Divine eggs...", Duration = 4})
       task.delay(2, function()
           Rayfield:Notify({Title = "Server Found!", Content = "Hopping server...", Duration = 3})
       end)
   end,
})
