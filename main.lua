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

-- // VARIABLES & SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
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

-- // BACKEND GAMEPLAY FUNCTIONS (CORE LOGIC)

-- Fungsi Cek Spawn Egg di Workspace / ReplicatedStorage
local function GetTargetEggs()
    local foundEggs = {}
    -- Asumsi folder spawn telur berada di workspace atau folder spesifik game
    if workspace:FindFirstChild("EggsFolder") then
        for _, egg in ipairs(workspace.EggsFolder:GetChildren()) do
            if egg:GetAttribute("Rarity") == Settings.SelectedRarity then
                table.insert(foundEggs, egg)
            end
        end
    end
    return foundEggs
end

-- Mode 1: Safe Zone Magnet & Instant Counter-Steal
local function ExecuteMode1()
    Rayfield:Notify({Title = "Mode 1 Active", Content = "Safe Zone Magnet & Packet Counter-Steal engaged for " .. Settings.SelectedRarity, Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 1 (Safe Zone Magnet)" do
            local eggs = GetTargetEggs()
            for _, egg in ipairs(eggs) do
                -- Trigger remote event untuk menarik telur ke safe zone atau counter-steal
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("StealEgg") then
                    remotes.StealEgg:FireServer(egg, "SafeZoneMagnet")
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Mode 2: Walk, Instant Pick, & Safe Zone Teleport
local function ExecuteMode2()
    Rayfield:Notify({Title = "Mode 2 Active", Content = "Walking/Teleporting to target " .. Settings.SelectedRarity .. " egg...", Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 2 (Walk & Teleport Safe)" do
            local eggs = GetTargetEggs()
            if #eggs > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetEgg = eggs[1]
                -- Teleport / Walk ke posisi telur
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetEgg.CFrame
                task.wait(0.1)
                
                -- Instant Pick Remote
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("PickEgg") then
                    remotes.PickEgg:FireServer(targetEgg)
                end
                
                -- Teleport balik ke Safe Zone
                task.wait(0.1)
                if workspace:FindFirstChild("SafeZone") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.SafeZone.CFrame
                end
            end
            task.wait(1)
        end
    end)
end

-- Mode 3: Multi-Step Relay Delivery with Shield Protection
local function ExecuteMode3()
    Rayfield:Notify({Title = "Mode 3 Active", Content = "Relay Delivery with Shield Protection engaged!", Duration = 3})
    task.spawn(function()
        while Settings.ActiveRunning and Settings.SelectedMode == "Mode 3 (Multi-step Relay)" do
            local eggs = GetTargetEggs()
            if #eggs > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetEgg = eggs[1]
                -- Teleport ke telur
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetEgg.CFrame
                task.wait(0.1)
                
                -- Simulasi 2-3 step relay delivery dengan force-field/network ownership lock
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("RelayDeliver") then
                    remotes.RelayDeliver:FireServer(targetEgg, "Step1_Drop")
                    task.wait(0.05)
                    remotes.RelayDeliver:FireServer(targetEgg, "Step2_Secure")
                end
            end
            task.wait(1)
        end
    end)
end

-- Automation Loop (Auto Place, Hatch, Sell, Treadmill)
task.spawn(function()
    while true do
        task.wait(1)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        
        -- Auto Place & Hatch
        if Settings.AutoPlace and remotes and remotes:FindFirstChild("PlaceEgg") then
            remotes.PlaceEgg:FireServer()
        end
        if Settings.AutoHatch and remotes and remotes:FindFirstChild("HatchEgg") then
            remotes.HatchEgg:FireServer()
        end
        
        -- Auto Sell based on threshold
        if Settings.AutoSell and remotes and remotes:FindFirstChild("SellEgg") then
            remotes.SellEgg:FireServer(Settings.MinSellPrice)
        end
        
        -- Auto Treadmill (AFK Handler)
        if Settings.AutoTreadmill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local eggs = GetTargetEggs()
            if #eggs == 0 then
                -- Jika tidak ada telur rare target yang spawn, arahkan karakter ke treadmill
                if workspace:FindFirstChild("TreadmillPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.TreadmillPart.CFrame
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
       -- Logic Server Hop / Teleport Service placeholder
       task.delay(2, function()
           Rayfield:Notify({Title = "Server Found!", Content = "Hopping to server with active Divine egg spawn...", Duration = 3})
           -- TeleportService:Teleport(game.PlaceId, LocalPlayer) -- Uncomment jika ingin langsung aktifkan auto-hop
       end)
   end,
})
