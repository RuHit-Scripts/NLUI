--[[
	Fly - speed fly on the NLUI menu. Works on Delta / Codex / Wave / Hydrogen.
	RightShift or the Toggle button opens the menu.
]]

local nl = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NLUI/main/nl_ui.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local settings = { enabled = false, speed = 60 }

-- pick a body mover depending on what the executor exposes
local function applyVelocity(vel)
	if typeof(setvelocity) == "function" then
		setvelocity(lp.Character and lp.Character.PrimaryPart, vel)
	elseif typeof(setreadonly) == "function" and getgenv().gethiddenproperty then
		local ok = pcall(function()
			local pv = Instance.new("BodyVelocity")
			pv.MaxForce = Vector3.new(1,1,1) * math.huge
			pv.Velocity = vel
			pv.Parent = lp.Character.PrimaryPart
			task.delay(0.1, function() pv:Destroy() end)
		end)
	else
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.AssemblyLinearVelocity = vel end
	end
end

local win = nl.new({ Title = "Fly", Nick = lp.Name, Subtext = "Freemium" })
local tab = win:Tab("Movement", "bolt", "Main")
local col = tab:column()
local card = col:card("Fly")

card:toggle("Enabled", false, function(v) settings.enabled = v end)
card:slider("Speed", 10, 500, 60, "", function(v) settings.speed = v end)
card:keybind("Toggle fly", Enum.KeyCode.Q, function()
	settings.enabled = not settings.enabled
end)

RunService.Heartbeat:Connect(function(dt)
	if not settings.enabled then return end
	local char = lp.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	local moveDir = hum.MoveDirection
	if moveDir.Magnitude < 0.1 then moveDir = Vector3.new(0,0,0) end

	local vel = moveDir * settings.speed
	-- keep it airborne, no gravity drop
	applyVelocity(Vector3.new(vel.X, settings.speed * 0.2, vel.Z))
end)

print("[Fly] loaded. Speed:", settings.speed)
