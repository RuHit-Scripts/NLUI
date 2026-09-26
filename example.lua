--[[
	Example script using NLUI. Shows the full widget set and two column layout.
]]

local nl = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NLUI/main/nl_ui.lua"))()

local win = nl.new({
	Nick = "player",
	Subtext = "INF Days Left",
	ToggleKey = Enum.KeyCode.RightShift,
})

local rage = win:Tab("Rage", "crosshair", "Aimbot")
local legit = win:Tab("Legit", "mouse", "Aimbot")
local visuals = win:Tab("Visuals", "camera", "Common")
local misc = win:Tab("Miscellaneous", "gear", "Common")

-- Rage: two columns
local left = rage:column()
local right = rage:column()

local main = left:card("Main")
main:toggle("Enabled", true)
main:toggle("Silent Aim", true)
main:toggle("Automatic Fire", true)
main:toggle("Aim Through Walls", true)
main:slider("Field of View", 1, 180, 75, "\u{00B0}")
main:color("Modulate", Color3.fromRGB(255, 60, 60))

local selection = left:card("Selection")
selection:select("Target")
selection:multiselect("Hitboxes", { "Head", "Chest", "Arms", "Legs" }, { "Head", "Chest" })
selection:multiselect("Multipoint", { "Head", "Body" }, {})
selection:slider("Hit Chance", 0, 100, 34, "%")
selection:slider("Min Damage", 0, 120, 15)
selection:toggle("Quick Stop", true)
selection:toggle("Quick Scope", true)

local other = right:card("Other")
other:select("History")
other:toggle("Delay Shot", true)
other:toggle("Remove Recoil", false)
other:toggle("Remove Spread", false)
other:toggle("Duck Peek Assist", false)
other:toggle("Quick Peek Assist", false)
other:toggle("Double Tap", false)

local antiAim = right:card("Anti-Aim")
antiAim:toggle("Enabled", true)
antiAim:select("Pitch")
antiAim:select("Yaw")
antiAim:select("Freestanding")
antiAim:select("Mouse Override")

-- Legit tab, single column
local leg = legit:column()
local legMain = leg:card("Main")
legMain:toggle("Enabled", false)
legMain:slider("FOV", 1, 500, 120)
legMain:dropdown("Mode", { "Classic", "Smooth" }, 1)
legMain:keybind("Trigger", Enum.KeyCode.T)

-- Visuals
local vc = visuals:column()
local vsec = vc:card("ESP")
vsec:toggle("Boxes", true)
vsec:toggle("Skeleton", false)
vsec:toggle("Names", true)
vsec:slider("Max Distance", 50, 2000, 1000)

-- Misc
local mc = misc:column()
local msec = mc:card("General")
msec:toggle("Auto Accept", false)
msec:toggle("Fast Reload", false)
msec:slider("Menu FPS", 30, 240, 60)
