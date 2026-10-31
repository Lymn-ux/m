local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Illegal Soccer",
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

local Players = game:GetService("Players")

local Hub = __Hub
local Config = {
	InfStamina = false
}

-- ==================== Inf Stamina 模組 ====================
local StaminaUtility = {
	hookhistory = {},
	Players = Players,
	Initialized = false
}

function StaminaUtility:safeFilterGc(t, d, i)
	local s, r = pcall(function(...)
		return filtergc(t, d, i)
	end)
	if s and r then return r end
	return warn('failed to filtergc reason: '..tostring(r))
end

function StaminaUtility:gupv(f, i)
	local s, r = pcall(function()
		return debug.getupvalue(f, i)
	end)
	if s and r then return r end
	return warn('failed to getupvalue err: '..tostring(r))
end

function StaminaUtility:safehook(o, n)
	local s, r = pcall(function(...)
		local h = hookfunction(o, n)
		self.hookhistory[h] = o
		return h
	end)
	if s and r then return r end
	return warn('failed to hookfunction err: '..tostring(r))
end

function StaminaUtility:init()
	if self.Initialized then return end
	
	if not hookfunction or not filtergc or not debug.getupvalue then
		return warn("Executor missing required functions for Inf Stamina")
	end

	self.updateSprint = self:safeFilterGc("function", {Name = "updateSprint"}, true)
	if not self.updateSprint then return end

	self.module = self:gupv(self.updateSprint, 14)
	if not self.module then return end

	self.Update = self.module.Update
	if not self.Update then return warn("failed to get Update func") end

	self.hook = self:safehook(self.Update, function(...)
		if Config.InfStamina then
			local data = select(2, ...)
			if data and rawget(data, "HasUnlimitedStamina") ~= nil then
				rawset(data, "HasUnlimitedStamina", true)
			end
		end 
		return self.hook(...)
	end)

	if self.hook then
		self.Initialized = true
		warn("Inf Stamina Hook Loaded Successfully")
	end
end

-- 預先初始化 Stamina Hook
StaminaUtility:init()

-- ==================== UI 控制開關 ====================
Hub:CreateToggle("Inf Stamina", false, function(isOn)
	Config.InfStamina = isOn
end)
