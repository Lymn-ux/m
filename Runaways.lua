local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Runaways",
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
--------------------------------------------------
-- 變數設定
--------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoNPCEnabled = false
local NoclipEnabled = false
local SpeedValue = 16 -- 預設速度 (Roblox 預設為 16)

-- Remote 服務
local FlowClient = ReplicatedStorage:WaitForChild("FlowClient"):WaitForChild("ClientRunner")
local RemoteEvent = FlowClient:WaitForChild("Event")
local RemoteFunction = FlowClient:WaitForChild("Function")

--------------------------------------------------
-- 核心功能邏輯
--------------------------------------------------

-- 1. 速度保護邏輯 (每幀強制維持速度，防止被遊戲改回)
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= SpeedValue then
            humanoid.WalkSpeed = SpeedValue
        end
    end
end)

-- 2. Noclip 穿牆邏輯 (每幀將角色部位設為 CanCollide = false)
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 一鍵撿取所有掉落物 (Loot All)
local function LootAll()
    local lootFolder = Workspace:FindFirstChild("Loot")
    if not lootFolder then return end

    task.spawn(function()
        for _, item in ipairs(lootFolder:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("Model") then
                pcall(function()
                    RemoteFunction:InvokeServer("Loot", "LootEquip", item)
                end)
                task.wait(0.02)
            end
        end
    end)
end

-- 一鍵丟棄背包與手上所有物品 (Drop All)
local function DropAllInventory()
    task.spawn(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                pcall(function()
                    RemoteEvent:FireServer("Loot", "LootUnequip", item, false)
                end)
                task.wait(0.05)
            end
        end
        
        local character = LocalPlayer.Character
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") then
                    pcall(function()
                        RemoteEvent:FireServer("Loot", "LootUnequip", item, false)
                    end)
                    task.wait(0.05)
                end
            end
        end
    end)
end

-- Auto NPC 核心邏輯
task.spawn(function()
    while true do
        if AutoNPCEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local npcsFolder = Workspace:FindFirstChild("NPCs")

                if hrp and npcsFolder then
                    for _, npc in ipairs(npcsFolder:GetChildren()) do
                        if not AutoNPCEnabled then break end

                        if npc:IsA("Model") then
                            local humanoid = npc:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                RemoteEvent:FireServer("Punches", "ReplicateSound", hrp, "Swoosh")
                                RemoteEvent:FireServer("NPCs", "Damage", humanoid, 1000000)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

--------------------------------------------------
-- UI 控制項
--------------------------------------------------

-- 1. 速度滑桿 (範圍: 16 ~ 300，預設: 16)
Hub:CreateSlider("Walk Speed", 16, 300, 16, function(val)
    SpeedValue = val
end)

-- 2. Noclip 穿牆開關
Hub:CreateToggle("Noclip", false, function(isOn)
    NoclipEnabled = isOn
end)

-- 3. Auto NPC 開關
Hub:CreateToggle("Kill NPC", false, function(isOn)
    AutoNPCEnabled = isOn
end)

-- 4. Loot All 按鈕
Hub:CreateButton("Loot All", function()
    LootAll()
end)

-- 5. Drop All 按鈕
Hub:CreateButton("Drop All", function()
    DropAllInventory()
end)
