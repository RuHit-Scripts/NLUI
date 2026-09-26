--[[
	Full NLUI demo. Every widget is exercised with a callback that prints to the
	output console, so you can confirm each control fires before wiring real logic.
]]

local nl = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NLUI/main/nl_ui.lua"))()

local win = nl.new({
	Title = "NLUI Demo",
	Nick = "player",
	Subtext = "Freemium",
	ToggleKey = Enum.KeyCode.RightShift,
})

local function log(...)
	local ok = select("#", ...) > 0
	print("[NLUI]", ...)
end

-- ===================== RAGE (two columns) =====================
local rage = win:Tab("Rage", "crosshair", "Aimbot")
local legit = win:Tab("Legit", "mouse", "Aimbot")
local visuals = win:Tab("Visuals", "camera", "Common")
local misc = win:Tab("Miscellaneous", "gear", "Common")

local left = rage:column()
local right = rage:column()

local main = left:card("Main")
main:toggle("Enabled", true, function(v) log("rage enabled", v) end)
main:toggle("Silent Aim", true, function(v) log("silent", v) end)
main:toggle("Automatic Fire", false, function(v) log("autofire", v) end)
main:toggle("Aim Through Walls", false, function(v) log("atw", v) end)
main:slider("Field of View", 1, 180, 75, "\u{00B0}", function(v) log("fov", v) end)
main:color("Modulate", Color3.fromRGB(255, 60, 60), function(c) log("modulate", c) end)

local selection = left:card("Selection")
selection:select("Target", function() log("open target list") end)
selection:multiselect("Hitboxes", { "Head", "Chest", "Arms", "Legs" }, { "Head", "Chest" }, function(list)
	log("hitboxes", table.concat(list, ","))
end)
selection:multiselect("Multipoint", { "Head", "Body" }, {}, function(list) log("multipoint", #list) end)
selection:slider("Hit Chance", 0, 100, 34, "%", function(v) log("hc", v) end)
selection:slider("Min Damage", 0, 120, 15, "", function(v) log("mindmg", v) end)
selection:dropdown("Prefer Body Aim", { "Never", "Distance", "Always" }, 1, function(i, v) log("bodyaim", v) end)
selection:toggle("Quick Stop", true, function(v) log("quickstop", v) end)
selection:toggle("Quick Scope", true, function(v) log("quickscope", v) end)

local other = right:card("Other")
other:select("History", function() log("history") end)
other:toggle("Delay Shot", true, function(v) log("delayshot", v) end)
other:toggle("Remove Recoil", false, function(v) log("norecoil", v) end)
other:toggle("Remove Spread", false, function(v) log("nospread", v) end)
other:toggle("Duck Peek Assist", false, function(v) log("duckpeek", v) end)
other:toggle("Quick Peek Assist", false, function(v) log("quickpeek", v) end)
other:toggle("Double Tap", false, function(v) log("doubletap", v) end)

local antiAim = right:card("Anti-Aim")
antiAim:toggle("Enabled", true, function(v) log("aa enabled", v) end)
antiAim:select("Pitch", function() log("pitch") end)
antiAim:select("Yaw", function() log("yaw") end)
antiAim:select("Freestanding", function() log("freestand") end)
antiAim:select("Mouse Override", function() log("mouseoverride") end)
antiAim:keybind("Anti-Aim Toggle", Enum.KeyCode.F, function() log("aa key fired") end)

-- ===================== LEGIT =====================
local leg = legit:column()
local legMain = leg:card("Main")
legMain:toggle("Enabled", false, function(v) log("legit", v) end)
legMain:slider("FOV", 1, 500, 120, "", function(v) log("legit fov", v) end)
legMain:slider("Smoothing", 1, 20, 5, "", function(v) log("smooth", v) end)
legMain:dropdown("Mode", { "Classic", "Smooth", "Hybrid" }, 1, function(i, v) log("mode", v) end)
legMain:keybind("Trigger", Enum.KeyCode.T, function() log("trigger held") end)
legMain:color("Team Color", Color3.fromRGB(80, 200, 120), function(c) log("teamcol", c) end)

-- ===================== VISUALS =====================
local vc = visuals:column()
local esp = vc:card("ESP")
esp:toggle("Boxes", true, function(v) log("boxes", v) end)
esp:toggle("Skeleton", false, function(v) log("skeleton", v) end)
esp:toggle("Names", true, function(v) log("names", v) end)
esp:toggle("Health Bar", true, function(v) log("healthbar", v) end)
esp:color("Box Color", Color3.fromRGB(255, 255, 255), function(c) log("boxcol", c) end)
esp:slider("Max Distance", 50, 2000, 1000, "m", function(v) log("maxdist", v) end)

-- ===================== MISC =====================
local mc = misc:column()
local msec = mc:card("General")
msec:toggle("Auto Accept", false, function(v) log("autoaccept", v) end)
msec:toggle("Fast Reload", false, function(v) log("fastreload", v) end)
msec:toggle("Unlock FPS", true, function(v) log("unlockfps", v) end)
msec:slider("Menu FPS", 30, 240, 60, "", function(v) log("menufps", v) end)
msec:keybind("Panic", Enum.KeyCode.P, function() log("panic") end)

print("[NLUI] demo loaded. RightShift or the Toggle button opens/closes the menu.")
