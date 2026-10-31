local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Shuffle an egg",
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

-- 服務
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameHandShake = ReplicatedStorage.Remotes.GameHandShake
local EquipBestAnimals = ReplicatedStorage.Remotes.EquipBestAnimals
local SellAnimal = ReplicatedStorage.Remotes.SellAnimal

-- 變數
local autoPlayEnabled = false
local autoEquipBestEnabled = false
local autoSellEnabled = false

local Hub = __Hub
-- Auto Play Game 邏輯
local function startAutoPlay()
    task.spawn(function()
        while autoPlayEnabled do
            -- 開始洗牌
            GameHandShake:FireServer("StartShuffle")
            task.wait(1.2)

            -- 選擇杯子（固定選第 2 個）
            GameHandShake:FireServer("PickCup", 2)
            -- 想隨機選杯子可改成：
            -- GameHandShake:FireServer("PickCup", math.random(1, 3))

            task.wait(2.5)
        end
    end)
end

-- Auto Equip Best 邏輯
local function startAutoEquipBest()
    task.spawn(function()
        while autoEquipBestEnabled do
            EquipBestAnimals:FireServer()
            task.wait(3)  -- 每 3 秒自動裝備一次最佳動物
        end
    end)
end

-- Auto Sell 邏輯
local function startAutoSell()
    task.spawn(function()
        while autoSellEnabled do
            SellAnimal:FireServer("SellAllAnimals")
            task.wait(5)  -- 每 5 秒自動賣出所有動物（可自行調整）
        end
    end)
end

-- Auto Play Game 開關
Hub:CreateToggle("Auto Play Game", false, function(isOn)
    autoPlayEnabled = isOn
    if autoPlayEnabled then
        startAutoPlay()
    end
end)

-- Auto Equip Best 開關
Hub:CreateToggle("Auto Equip Best", false, function(isOn)
    autoEquipBestEnabled = isOn
    if autoEquipBestEnabled then
        startAutoEquipBest()
    end
end)

-- Auto Sell 開關
Hub:CreateToggle("Auto Sell", false, function(isOn)
    autoSellEnabled = isOn
    if autoSellEnabled then
        startAutoSell()
    end
end)
