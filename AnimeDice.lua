local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Anime Dice",
    105369821130198,
    2,
    "grey"
)

Library:SendNotification("Lymn", "Script loaded", 2, 105369821130198, 2, "grey")

LymnWindow:SetFooter(
    "https://discord.gg/6B36mdd6cJ",
    16584754883,
    2
)

local MainSection = LymnWindow:NewSection("Main")

local CreditsSection = LymnWindow:NewSection("Credits")

CreditsSection:CreateButton("Copy TikTok", function()
    setclipboard("https://www.tiktok.com/@michel.ljw")
    Library:SendNotification(
        "Copied!",
        "TikTok link copied to clipboard!",
        3,
        17757765730,
        2
    )
end)

CreditsSection:CreateButton("Copy Discord", function()
    setclipboard("https://discord.gg/6B36mdd6cJ")
    Library:SendNotification(
        "Copied!",
        "Discord invite copied to clipboard!",
        3,
        16584754883,
        2
    )
end)

-- Adapter: API lama (Hub:CreateXxx) dipetakan ke element native library Lymn
local function __run(cb, ...)
    if not cb then return end
    local ok, err = pcall(cb, ...)
    if not ok then warn("[Lymn] " .. tostring(err)) end
end

local __Hub = {}

function __Hub:CreateButton(name, cb)
    MainSection:CreateButton(tostring(name), function()
        __run(cb)
    end)
end

function __Hub:CreateToggle(name, default, cb)
    MainSection:CreateToggle(tostring(name), default and true or false, function(state)
        __run(cb, state)
    end)
end

function __Hub:CreateSlider(name, min, max, default, cb)
    MainSection:CreateSlider(tostring(name), min, max, default or min, function(value)
        __run(cb, value)
    end)
end

function __Hub:CreateDropdown(name, options, default, cb)
    options = options or {}
    local index = 1
    if type(default) == "number" and options[default] ~= nil and tostring(options[default]) == tostring(default) then
        index = default
    end
    for i, v in ipairs(options) do
        if tostring(v) == tostring(default) then index = i break end
    end
    MainSection:CreateDropdown(tostring(name), options, index, function(selected)
        __run(cb, selected)
    end)
end

function __Hub:CreateInput(name, placeholder, cb)
    MainSection:CreateTextbox(tostring(name), function(text)
        __run(cb, text, true)
    end)
end

function __Hub:Clear() end
function __Hub:SetTitle() end
function __Hub:Destroy() end

local Hub = __Hub
-- 核心服務
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---------------------------------------------------------
-- 1. Auto Equip Best 功能
---------------------------------------------------------
local autoEquipEnabled = false

Hub:CreateToggle("Auto Equip Best", false, function(isOn)
    autoEquipEnabled = isOn

    if autoEquipEnabled then
        task.spawn(function()
            local network = ReplicatedStorage:WaitForChild("Network", 5)
            local plotService = network and network:WaitForChild("PlotService", 5)
            local reFolder = plotService and plotService:WaitForChild("RE", 5)
            local equipBestEvent = reFolder and reFolder:WaitForChild("EquipBest", 5)

            if equipBestEvent then
                while autoEquipEnabled do
                    pcall(function()
                        equipBestEvent:FireServer()
                    end)
                    task.wait(1)
                end
            else
                warn("[Auto Equip Best]: 未找到 EquipBest RemoteEvent！")
            end
        end)
    end
end)

---------------------------------------------------------
-- 2. Auto Collect Money 功能 (1~8 並列即時發送)
---------------------------------------------------------
local autoCollectEnabled = false

Hub:CreateToggle("Auto Collect Money", false, function(isOn)
    autoCollectEnabled = isOn

    if autoCollectEnabled then
        local network = ReplicatedStorage:WaitForChild("Network", 5)
        local plotService = network and network:WaitForChild("PlotService", 5)
        local reFolder = plotService and plotService:WaitForChild("RE", 5)
        local collectEvent = reFolder and reFolder:WaitForChild("CollectBalance", 5)

        if collectEvent then
            for i = 1, 100 do
                task.spawn(function()
                    while autoCollectEnabled do
                        pcall(function()
                            collectEvent:FireServer(i)
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        else
            warn("[Auto Collect Money]: 未找到 CollectBalance RemoteEvent！")
        end
    end
end)

---------------------------------------------------------
-- 3. Auto Rebirth 功能
---------------------------------------------------------
local autoRebirthEnabled = false

Hub:CreateToggle("Auto Rebirth", false, function(isOn)
    autoRebirthEnabled = isOn

    if autoRebirthEnabled then
        task.spawn(function()
            local network = ReplicatedStorage:WaitForChild("Network", 5)
            local rebirthService = network and network:WaitForChild("RebirthService", 5)
            local reFolder = rebirthService and rebirthService:WaitForChild("RE", 5)
            local rebirthEvent = reFolder and reFolder:WaitForChild("Rebirth", 5)

            if rebirthEvent then
                while autoRebirthEnabled do
                    pcall(function()
                        rebirthEvent:FireServer()
                    end)
                    task.wait(1)
                end
            else
                warn("[Auto Rebirth]: 未找到 Rebirth RemoteEvent！")
            end
        end)
    end
end)
