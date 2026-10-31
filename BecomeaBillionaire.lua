local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Become a Billionaire",
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
local LocalPlayer = Players.LocalPlayer

local AutoFireTouchEnabled = false

--------------------------------------------------
-- 超低負載全圖 Fire Touch (極致分流)
--------------------------------------------------
task.spawn(function()
    while true do
        if AutoFireTouchEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")

                if hrp then
                    local count = 0
                    for _, descendant in ipairs(Workspace:GetDescendants()) do
                        if not AutoFireTouchEnabled then break end

                        if descendant:IsA("TouchTransmitter") then
                            local parentPart = descendant.Parent
                            if parentPart and parentPart:IsA("BasePart") then
                                firetouchinterest(hrp, parentPart, 0)
                                firetouchinterest(hrp, parentPart, 1)

                                count = count + 1
                                -- 關鍵：每觸發 1 個就暫停 1 幀，保證 100% 不卡頓
                                if count % 1 == 0 then
                                    task.wait()
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1) -- 一輪結束後休息 1 秒
    end
end)

--------------------------------------------------
-- UI 控制項
--------------------------------------------------

Hub:CreateToggle("Auto Collect Money", false, function(isOn)
    AutoFireTouchEnabled = isOn
end)
