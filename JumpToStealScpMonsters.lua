local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Jump to steal scp monster",
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
-- 核心服務與變數
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local isRunning = false

---------------------------------------------------------
-- 判斷 Model 是否為 Slime God
---------------------------------------------------------
local function isSlimeGod(model)
    if not model or not model:IsA("Model") then return false end

    if string.find(model.Name, "Slime God") then
        return true
    end

    local rarityObj = model:FindFirstChild("Rarity")
    if rarityObj then
        if rarityObj:IsA("StringValue") and rarityObj.Value == "Slime God" then
            return true
        end
    end

    local rarityAttr = model:GetAttribute("Rarity")
    if rarityAttr and tostring(rarityAttr) == "Slime God" then
        return true
    end

    return false
end

---------------------------------------------------------
-- 執行傳送、觸發與返回邏輯 (停留 1 秒)
---------------------------------------------------------
local function executeAutoBlock()
    if isRunning then return end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local slimesFolder = Workspace:FindFirstChild("Live") and Workspace.Live:FindFirstChild("Slimes")
    if not slimesFolder then return end

    local targetModel = nil
    for _, model in ipairs(slimesFolder:GetChildren()) do
        if isSlimeGod(model) then
            targetModel = model
            break
        end
    end

    if not targetModel then return end

    local rootPart = targetModel:FindFirstChild("RootPart")
    if not rootPart then return end

    local prompt = rootPart:FindFirstChildWhichIsA("ProximityPrompt", true) or rootPart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end

    isRunning = true
    local originalCFrame = hrp.CFrame

    hrp.CFrame = rootPart.CFrame * CFrame.new(0, 3, 0)

    local startTime = tick()
    while tick() - startTime < 1.0 do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
        LocalPlayer.Character.HumanoidRootPart.CFrame = rootPart.CFrame * CFrame.new(0, 3, 0)
        fireproximityprompt(prompt)
        task.wait(0.1)
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
    end
    isRunning = false
end

---------------------------------------------------------
-- UI 控制組件
---------------------------------------------------------

-- 1. 自動循環檢測 Slime God Toggle
local autoLoopEnabled = false
Hub:CreateToggle("Auto Best Block", false, function(isOn)
    autoLoopEnabled = isOn
    if autoLoopEnabled then
        task.spawn(function()
            while autoLoopEnabled do
                pcall(executeAutoBlock)
                task.wait(1)
            end
        end)
    end
end)

---------------------------------------------------------
-- 2. Auto Open & Collect (開箱與領取)
---------------------------------------------------------

local autoCollectEnabled = false

Hub:CreateToggle("Auto Open & Collect", false, function(isOn)
    autoCollectEnabled = isOn
    
    if autoCollectEnabled then
        task.spawn(function()
            while autoCollectEnabled do
                pcall(function()
                    local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
                    local network = sharedModules and sharedModules:FindFirstChild("Network")
                    local remotes = network and network:FindFirstChild("Remotes")
                    
                    if remotes then
                        local openEvent = remotes:FindFirstChild("Open Lucky Block")
                        local collectEvent = remotes:FindFirstChild("Collect Earnings")

                        for i = 1, 100 do
                            if not autoCollectEnabled then break end
                            local strIndex = tostring(i)

                            if openEvent then
                                openEvent:FireServer(strIndex)
                            end
                            if collectEvent then
                                collectEvent:FireServer(strIndex)
                            end
                            
                            task.wait(0.01)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

---------------------------------------------------------
-- 3. Auto Buy Speed +3
---------------------------------------------------------

local autoBuySpeedEnabled = false

Hub:CreateToggle("Auto Buy Speed +10", false, function(isOn)
    autoBuySpeedEnabled = isOn
    
    if autoBuySpeedEnabled then
        task.spawn(function()
            while autoBuySpeedEnabled do
                pcall(function()
                    local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
                    local network = sharedModules and sharedModules:FindFirstChild("Network")
                    local remotes = network and network:FindFirstChild("Remotes")
                    
                    if remotes then
                        local event = remotes:FindFirstChild("Buy Speed Upgrade")
                        if event then
                            event:FireServer(3)
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
