local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X build and kill zombies",
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
-- 服務與玩家設定
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 變數設定
local autoGlideZombiesEnabled = false
local autoRollEnabled = false
local zombieEspEnabled = false

local glideSpeed = 40 -- 滑行速度
local hitDelay = 0.5 -- 撞擊停留時間
local flyHeightOffset = 2 -- 撞擊高度微調

-- UI 開關設定
Hub:CreateToggle("Auto Kill Zombies", false, function(isOn)
    autoGlideZombiesEnabled = isOn
    print("[Zombie Glide] 開關狀態: " .. tostring(isOn))
end)

Hub:CreateToggle("Auto Roll", false, function(isOn)
    autoRollEnabled = isOn
    print("[Auto Roll] 開關狀態: " .. tostring(isOn))
end)

Hub:CreateToggle("Zombies ESP", false, function(isOn)
    zombieEspEnabled = isOn
    print("[Zombie ESP] 開關狀態: " .. tostring(isOn))
    if not isOn then
        ClearAllZombieEsp()
    end
end)

------------------------------------------------------------------
-- [ Zombies ESP 自動配色邏輯 ]
------------------------------------------------------------------

-- 喪屍名稱關鍵字 ➔ 顏色對照表 (可自由新增/修改)
local colorRules = {
    { keywords = {"boss", "elite", "giant"}, color = Color3.fromRGB(255, 50, 50) },    -- 🔴 紅色
    { keywords = {"tank", "brute", "heavy"}, color = Color3.fromRGB(255, 140, 0) },    -- 🟠 橘色
    { keywords = {"runner", "fast", "scout"}, color = Color3.fromRGB(255, 235, 50) },   -- 🟡 黃色
    { keywords = {"poison", "toxic", "acid"}, color = Color3.fromRGB(170, 50, 255) },   -- 🟣 紫色
    { keywords = {"normal", "zombie", "walker"}, color = Color3.fromRGB(50, 255, 100) },-- 🟢 綠色
}

-- 預設顏色（若名稱不在上述關鍵字中）
local defaultColor = Color3.fromRGB(255, 255, 255) -- ⚪ 白色

-- 根據喪屍 Model 名稱判定顏色
local function GetZombieColorByName(zombieName)
    local lowerName = string.lower(zombieName)
    for _, rule in ipairs(colorRules) do
        for _, kw in ipairs(rule.keywords) do
            if string.find(lowerName, kw) then
                return rule.color
            end
        end
    end
    return defaultColor
end

-- 清除所有 ESP
function ClearAllZombieEsp()
    local zombiesFolder = workspace:FindFirstChild("ClientZombies")
    if zombiesFolder then
        for _, zombie in ipairs(zombiesFolder:GetChildren()) do
            local highlight = zombie:FindFirstChild("ZombieESP_Highlight")
            if highlight then highlight:Destroy() end

            local billboard = zombie:FindFirstChild("ZombieESP_Billboard")
            if billboard then billboard:Destroy() end
        end
    end
end

-- 為單一喪屍建立 ESP
local function ApplyEspToZombie(zombieModel)
    if not zombieModel or not zombieModel:IsA("Model") then return end
    if zombieModel:FindFirstChild("ZombieESP_Highlight") then return end -- 避免重複建立

    local color = GetZombieColorByName(zombieModel.Name)

    -- 1. 建立 Highlight 外框發光
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZombieESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Adornee = zombieModel
    highlight.Parent = zombieModel

    -- 2. 建立名字與顏色標籤
    local primaryPart = zombieModel.PrimaryPart or zombieModel:FindFirstChildWhichIsA("BasePart", true)
    if primaryPart then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ZombieESP_Billboard"
        billboard.Adornee = primaryPart
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = zombieModel.Name
        textLabel.TextColor3 = color
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboard

        billboard.Parent = zombieModel
    end
end

-- Zombies ESP 監控線程
task.spawn(function()
    while true do
        task.wait(0.5)
        if zombieEspEnabled then
            local zombiesFolder = workspace:FindFirstChild("ClientZombies")
            if zombiesFolder then
                for _, zombie in ipairs(zombiesFolder:GetChildren()) do
                    if zombie:IsA("Model") then
                        ApplyEspToZombie(zombie)
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- [ Auto Roll 邏輯：直接觸發 Roll 內的 ProximityPrompt ]
------------------------------------------------------------------

local function FirePromptStandard(prompt)
    if prompt and prompt.Enabled and type(fireproximityprompt) == "function" then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end

local function FireAllRollPrompts()
    local gameFolder = workspace:FindFirstChild("Game")
    local searchScope = gameFolder or workspace

    for _, descendant in ipairs(searchScope:GetDescendants()) do
        if descendant.Name == "Roll" then
            local prompt = descendant:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                FirePromptStandard(prompt)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if autoRollEnabled then
            FireAllRollPrompts()
        end
    end
end)

------------------------------------------------------------------
-- [ Auto Glide Zombies 邏輯 ]
------------------------------------------------------------------

local function GetVehicleInfo()
    local character = LocalPlayer.Character
    if not character then return nil, nil end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local seatPart = humanoid and humanoid.SeatPart

    if seatPart then
        local vehicleModel = seatPart:FindFirstAncestorWhichIsA("Model") or seatPart.Parent
        local rootPart = seatPart.AssemblyRootPart or seatPart
        return vehicleModel, rootPart
    end

    return nil, nil
end

local function GlideToTarget(targetCFrame)
    local vehicleModel, rootPart = GetVehicleInfo()
    
    if not rootPart or not vehicleModel then return end

    local currentCF = rootPart.CFrame
    local finalCF = targetCFrame + Vector3.new(0, flyHeightOffset, 0)
    
    local distance = (finalCF.Position - currentCF.Position).Magnitude
    local glideDuration = math.clamp(distance / glideSpeed, 0.3, 5)

    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    local tweenInfo = TweenInfo.new(
        glideDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    local tweenGoal = { CFrame = finalCF }
    local tweenTarget = (vehicleModel:IsA("Model") and vehicleModel.PrimaryPart) or rootPart
    local tween = TweenService:Create(tweenTarget, tweenInfo, tweenGoal)
    
    tween:Play()
    
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        task.wait(0.05)
        local currentVehicle, _ = GetVehicleInfo()
        if not currentVehicle then
            tween:Cancel()
            break
        end
    end
end

local function GetClientZombieModels()
    local zombiesFolder = workspace:FindFirstChild("ClientZombies")
    local zombieModels = {}

    if zombiesFolder then
        for _, child in ipairs(zombiesFolder:GetChildren()) do
            if child:IsA("Model") then
                table.insert(zombieModels, child)
            end
        end
    end

    return zombieModels
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if autoGlideZombiesEnabled then
            local vehicleModel, _ = GetVehicleInfo()

            if vehicleModel then
                local zombieList = GetClientZombieModels()

                if #zombieList > 0 then
                    for _, zombieModel in ipairs(zombieList) do
                        if not autoGlideZombiesEnabled then break end

                        local currentVehicle, _ = GetVehicleInfo()
                        if not currentVehicle then
                            warn("[Zombie Glide] 玩家已離開車輛，暫停執行！")
                            break
                        end

                        if zombieModel and zombieModel.Parent then
                            local mainPart = zombieModel.PrimaryPart 
                                or zombieModel:FindFirstChild("HumanoidRootPart") 
                                or zombieModel:FindFirstChildWhichIsA("BasePart", true)

                            if mainPart then
                                print("[Zombie Glide] 滑行撞擊: " .. zombieModel.Name)
                                GlideToTarget(mainPart.CFrame)
                                task.wait(hitDelay)
                            end
                        end
                    end
                else
                    task.wait(0.5)
                end
            else
                print("[Zombie Glide] 角色不在車上，等待玩家上車...")
                task.wait(1)
            end
        end
    end
end)
