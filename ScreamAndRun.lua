local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherXOfficial/x/refs/heads/main/UiLibary"))()

local LymnWindow = Library:NewWindow(
    "Lymn X Scream And Run",
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
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Hub = __Hub
local Config = {
	Auto = {
		Fullbright = false,
	},
	Player = {
		WalkSpeed = 24,
	},
	ESP = {
		MonsterESP = false,
	},
	MonsterNames = {
		"CatInTheHat",
		"CatInTheHat2",
	},
}

local function GetCharacter()
	return Player.Character
end

local function GetRoot()
	local character = GetCharacter()
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
	local character = GetCharacter()
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function StopVelocity()
	local root = GetRoot()
	if not root then return end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function IsMonsterName(name)
	for _, wanted in ipairs(Config.MonsterNames) do
		if name == wanted then return true end
	end
	return false
end

local function GetMonsterPart(monster)
	if not monster then return nil end
	return monster:FindFirstChild("HumanoidRootPart")
		or monster.PrimaryPart
		or monster:FindFirstChildWhichIsA("BasePart", true)
end

local function GetMonsters()
	local result = {}
	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("Model") and IsMonsterName(object.Name) then
			table.insert(result, object)
		end
	end
	return result
end

local MonsterESP = {}

local function CreateMonsterESP(monster)
	if MonsterESP[monster] then return end
	local rootPart = GetMonsterPart(monster)
	if not rootPart then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "_MonsterHighlight"
	highlight.Adornee = monster
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.Parent = monster

	local gui = Instance.new("BillboardGui")
	gui.Name = "_MonsterDistance"
	gui.Adornee = rootPart
	gui.Size = UDim2.fromOffset(220, 38)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = false
	gui.Parent = rootPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 50, 50)
	label.Parent = gui

	MonsterESP[monster] = {Highlight = highlight, Gui = gui, Label = label}
end

local function UpdateMonsterESP()
	local root = GetRoot()
	for monster, data in pairs(MonsterESP) do
		if not monster.Parent then
			MonsterESP[monster] = nil
			continue
		end
		data.Highlight.Enabled = Config.ESP.MonsterESP
		data.Gui.Enabled = Config.ESP.MonsterESP

		if Config.ESP.MonsterESP and root then
			local monsterPart = GetMonsterPart(monster)
			if monsterPart then
				local distance = (root.Position - monsterPart.Position).Magnitude
				data.Label.Text = string.format("%s [%.0f studs]", monster.Name, distance)
			end
		end
	end
end

local function GetExitTouchPart()
	local exit = Workspace:FindFirstChild("Exit")
	if not exit then return nil end
	if exit:IsA("BasePart") then return exit end

	for _, object in ipairs(exit:GetDescendants()) do
		if object:IsA("BasePart") and object:FindFirstChildWhichIsA("TouchTransmitter") then
			return object
		end
	end
	for _, object in ipairs(exit:GetDescendants()) do
		if object:IsA("BasePart") and object:FindFirstChild("TouchInterest") then
			return object
		end
	end
	return exit:FindFirstChildWhichIsA("BasePart", true)
end

local function InstaWin()
	local root = GetRoot()
	local character = GetCharacter()
	local exitPart = GetExitTouchPart()

	if not root or not character or not exitPart then return end
	local oldCFrame = root.CFrame
	StopVelocity()

	if type(firetouchinterest) == "function" then
		for _ = 1, 5 do
			pcall(firetouchinterest, root, exitPart, 0)
			task.wait(0.03)
			pcall(firetouchinterest, root, exitPart, 1)
			task.wait(0.03)
		end
	end

	local exitCF = exitPart.CFrame
	local positions = {
		exitCF * CFrame.new(0, 2, 5),
		exitCF * CFrame.new(0, 2, 1),
		exitCF * CFrame.new(0, 2, 0),
		exitCF * CFrame.new(0, 2, -1),
		exitCF * CFrame.new(0, 2, -5),
	}

	for pass = 1, 3 do
		for _, cframe in ipairs(positions) do
			if not character.Parent then return end
			StopVelocity()
			character:PivotTo(cframe)
			StopVelocity()
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()
		end
	end

	character:PivotTo(exitPart.CFrame)
	StopVelocity()
	task.wait(0.35)

	if character.Parent and root.Parent then
		local distanceFromExit = (root.Position - exitPart.Position).Magnitude
		if distanceFromExit < 20 then
			character:PivotTo(oldCFrame)
			StopVelocity()
		end
	end
end

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows,
}
local EffectStates = {}
local AtmosphereStates = {}

local function SetFullbright(enabled)
	Config.Auto.Fullbright = enabled
	if enabled then
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(185, 185, 185)
		Lighting.OutdoorAmbient = Color3.fromRGB(185, 185, 185)
		Lighting.GlobalShadows = false

		for _, object in ipairs(Lighting:GetChildren()) do
			if object:IsA("BloomEffect") or object:IsA("DepthOfFieldEffect") or object:IsA("ColorCorrectionEffect") or object:IsA("SunRaysEffect") or object:IsA("BlurEffect") then
				if EffectStates[object] == nil then EffectStates[object] = object.Enabled end
				object.Enabled = false
			elseif object:IsA("Atmosphere") then
				if AtmosphereStates[object] == nil then
					AtmosphereStates[object] = {Density = object.Density, Haze = object.Haze, Glare = object.Glare}
				end
				object.Density = 0
				object.Haze = 0
				object.Glare = 0
			end
		end
	else
		Lighting.Brightness = OriginalLighting.Brightness
		Lighting.ClockTime = OriginalLighting.ClockTime
		Lighting.Ambient = OriginalLighting.Ambient
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
		Lighting.GlobalShadows = OriginalLighting.GlobalShadows

		for object, state in pairs(EffectStates) do
			if object.Parent then object.Enabled = state end
		end
		for object, state in pairs(AtmosphereStates) do
			if object.Parent then
				object.Density = state.Density
				object.Haze = state.Haze
				object.Glare = state.Glare
			end
		end
		table.clear(EffectStates)
		table.clear(AtmosphereStates)
	end
end

local function EnableThirdPerson()
	Player.CameraMinZoomDistance = 10
	Player.CameraMaxZoomDistance = 100
	Player.CameraMode = Enum.CameraMode.Classic
	
	local character = GetCharacter()
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end

local function ApplyPlayerMods()
	local humanoid = GetHumanoid()
	if not humanoid then return end
	humanoid.WalkSpeed = Config.Player.WalkSpeed
end

Hub:CreateSlider("WalkSpeed", 8, 100, Config.Player.WalkSpeed, function(val)
	Config.Player.WalkSpeed = val
end)

Hub:CreateButton("Insta Win", function()
	task.spawn(InstaWin)
end)

Hub:CreateButton("Enable Third Person", function()
	EnableThirdPerson()
end)

Hub:CreateToggle("Monster ESP", false, function(isOn)
	Config.ESP.MonsterESP = isOn
end)

Hub:CreateToggle("Fullbright / Clear Darkness", false, function(isOn)
	SetFullbright(isOn)
end)

for _, monster in ipairs(GetMonsters()) do
	CreateMonsterESP(monster)
end

local LastScan = 0
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	if now - LastScan >= 0.5 then
		LastScan = now
		for _, monster in ipairs(GetMonsters()) do
			CreateMonsterESP(monster)
		end
	end

	UpdateMonsterESP()
	ApplyPlayerMods()
end)
