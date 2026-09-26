--[[
	NLUI - Neverlose style UI for Roblox executors.

	Dark two column layout, sidebar with grouped tabs and icons, blue switches,
	sliders with a value pill, Select dropdowns, top config and search bar, bottom
	user card. Draggable, minimizes to a floating icon on mobile.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local NLUI = {}

-- Lucide icons rendered from a shared sprite sheet (rbxassetid + ImageRect).
-- Each entry: { assetId, x, y } with a fixed 48x48 cell. Names are the tab `icon` arg.
local ICON_SHEET_CELL = Vector2.new(48, 48)
local ICONS = {
	crosshair = {16898613044, 453, 869}, target = {16898613869, 514, 771},
	mouse = {16898613613, 563, 918}, pointer = {16898613777, 869, 661},
	camera = {16898612819, 967, 563}, image = {16898613509, 306, 918}, eye = {16898613353, 771, 563},
	inventory = {16898613613, 918, 196}, box = {16898612819, 771, 196}, layers = {16898613509, 98, 967},
	gear = {16898613777, 771, 257}, sliders = {16898613777, 404, 771}, cog = {16898613777, 771, 257},
	sword = {16898613777, 967, 759}, bolt = {16898613869, 918, 906}, shield = {16898613777, 869, 0},
	user = {16898613869, 661, 869}, list = {16898613509, 869, 808}, search = {16898613699, 918, 857},
	monitor = {16898613613, 404, 820}, cpu = {16898613044, 196, 869}, radar = {16898613699, 820, 404},
	sparkles = {16898613777, 918, 49}, bell = {16898612819, 820, 257}, lock = {16898613509, 918, 857},
	key = {16898613509, 869, 404}, wifi = {16898613869, 869, 808}, flag = {16898613353, 98, 918},
	gamepad = {16898613353, 710, 967}, bot = {16898612819, 869, 98}, bug = {16898612819, 257, 967},
	pencil = {16898613699, 820, 257}, palette = {16898613613, 453, 918}, focus = {16898613353, 771, 759},
}

local function setIcon(label, name, size)
	local ic = ICONS[name]
	if not ic then label.Image = ""; return end
	size = size or 18
	label.Image = "rbxassetid://" .. ic[1]
	label.ImageRectSize = ICON_SHEET_CELL
	label.ImageRectOffset = Vector2.new(ic[2], ic[3])
	label.ScaleType = Enum.ScaleType.Slice
end

local function inst(class, props)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	return o
end

local function corner(o, r)
	inst("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = o })
end

local function stroke(o, col, t)
	inst("UIStroke", { Color = col, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end

local function pad(o, l, r, t, b)
	inst("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l),
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0), Parent = o,
	})
end

local function makeDrag(target, handle, isLocked)
	-- track press position from the handle, then move on global input so
	-- overlapping child frames don't swallow the drag
	local dragging, startInput, startPos = false, nil, nil
	handle.InputBegan:Connect(function(ip)
		if isLocked and isLocked() then return end
		if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = Vector2.new(ip.Position.X, ip.Position.Y)
			startPos = target.Position
		end
	end)
	UIS.InputChanged:Connect(function(ip)
		if dragging and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
			local dx = ip.Position.X - startInput.X
			local dy = ip.Position.Y - startInput.Y
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
		end
	end)
	UIS.InputEnded:Connect(function(ip)
		if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function NLUI.new(opts)
	opts = opts or {}

	local COL_BG    = Color3.fromRGB(18, 19, 24)
	local COL_CARD  = Color3.fromRGB(26, 28, 35)
	local COL_ROW   = Color3.fromRGB(31, 33, 41)
	local COL_LINE  = Color3.fromRGB(43, 46, 55)
	local COL_TEXT  = Color3.fromRGB(232, 233, 238)
	local COL_MUTED = Color3.fromRGB(120, 124, 135)
	local COL_BLUE  = Color3.fromRGB(37, 99, 235)
	local COL_PILL  = Color3.fromRGB(46, 49, 59)

	local gui = inst("ScreenGui", {
		Name = "NLUI", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	local root = inst("Frame", {
		Size = UDim2.fromOffset(430, 285),
		Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(215, 142),
		BackgroundColor3 = COL_BG, BorderSizePixel = 0, ClipsDescendants = false, Parent = gui,
	})
	corner(root, 10); stroke(root, COL_LINE, 1)

	-- top grab bar (drag handle for the whole window)
	local grabBar = inst("TextButton", {
		Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = COL_CARD, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = root, ZIndex = 3,
	})
	corner(grabBar, 10)
	inst("Frame", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = grabBar }) -- square off bottom of the bar
	inst("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = COL_MUTED, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Title or "NLUI", Parent = grabBar, ZIndex = 4,
	})

	local side = inst("Frame", {
		Size = UDim2.new(0, 110, 1, -26), Position = UDim2.fromOffset(0, 26), BackgroundColor3 = COL_BG, BorderSizePixel = 0, Parent = root,
	})
	pad(side, 6, 6, 6, 46)
	inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = side })

	local body = inst("Frame", {
		Size = UDim2.new(1, -110, 1, -26), Position = UDim2.fromOffset(110, 26),
		BackgroundTransparency = 1, BorderSizePixel = 0, Parent = root,
	})
	pad(body, 8, 8, 6, 8)
	inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = body })

	local headerSlot = inst("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = body })
	inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = headerSlot })
	local configBtn = inst("TextButton", {
		Size = UDim2.fromOffset(120, 22), BackgroundColor3 = COL_CARD, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = headerSlot,
	})
	corner(configBtn, 6); stroke(configBtn, COL_LINE, 1)
	inst("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = "My Config", Parent = configBtn,
	})
	inst("TextLabel", {
		Size = UDim2.fromOffset(14, 22), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = COL_MUTED, Text = ">", Parent = configBtn,
	})

	local userCard = inst("Frame", {
		Size = UDim2.new(1, -12, 0, 40), Position = UDim2.new(0, 6, 1, -46), BackgroundColor3 = COL_CARD,
		BorderSizePixel = 0, Parent = side, ZIndex = 5,
	})
	corner(userCard, 8); stroke(userCard, COL_LINE, 1); userCard.LayoutOrder = 999
	local avatar = inst("ImageLabel", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(5, 5), BackgroundColor3 = COL_PILL,
		BorderSizePixel = 0, Image = "", ScaleType = Enum.ScaleType.Crop, Parent = userCard, ZIndex = 6,
	})
	corner(avatar, 15)
	local avatarLetter = inst("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 7,
		Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = COL_MUTED, Text = "?", Parent = avatar,
	})
	local nickLbl = inst("TextLabel", {
		Size = UDim2.new(1, -44, 0, 16), Position = UDim2.fromOffset(40, 6), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Nick or "player", Parent = userCard, ZIndex = 6,
	})
	inst("TextLabel", {
		Size = UDim2.new(1, -44, 0, 14), Position = UDim2.fromOffset(40, 22), BackgroundTransparency = 1,
		Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COL_BLUE, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Subtext or "Freemium", Parent = userCard, ZIndex = 6,
	})

	-- load the local player's headshot (face + neck). Try the thumbnail API,
	-- fall back to GetUserThumbnail which works even when HttpGet is blocked.
	local lp = Players.LocalPlayer
	local nickName = opts.Nick or lp.DisplayName or lp.Name
	nickLbl.Text = nickName
	avatarLetter.Text = string.sub(nickName, 1, 1):upper()
	task.spawn(function()
		local url
		pcall(function()
			local hs = game:GetService("HttpService")
			local resp = hs:GetAsync(("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png"):format(lp.UserId))
			url = hs:JSONDecode(resp).data[1].imageUrl
		end)
		if type(url) ~= "string" then
			pcall(function() url = lp:GetUserThumbnail(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
		end
		if type(url) == "string" and url ~= "" then
			avatar.Image = url
			avatarLetter.Visible = false
		end
	end)

	local locked = false
	makeDrag(root, grabBar, function() return locked end)
	makeDrag(root, side, function() return locked end)

	local float = inst("TextButton", {
		Size = UDim2.fromOffset(70, 26), Position = UDim2.fromScale(0.04, 0.5), BackgroundColor3 = COL_BLUE,
		Text = "Toggle", Font = Enum.Font.Code, TextSize = 15, TextColor3 = Color3.new(1, 1, 1),
		Visible = true, BorderSizePixel = 0, Parent = gui, ZIndex = 100,
	})
	corner(float, 3); stroke(float, Color3.fromRGB(20, 20, 26), 2)
	makeDrag(float, float, function() return locked end)

	local minimized = false
	local function setMin(v)
		minimized = v; root.Visible = not v
	end
	float.MouseButton1Click:Connect(function() setMin(not minimized) end)

	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	UIS.InputBegan:Connect(function(ip)
		if ip.UserInputType == Enum.UserInputType.Keyboard and ip.KeyCode == toggleKey then
			setMin(not minimized)
		end
	end)

	local self = {}
	self.pages = {}

	local function sideGroup(text)
		inst("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
			TextSize = 12, TextColor3 = COL_MUTED, TextXAlignment = Enum.TextXAlignment.Left,
			Text = text, LayoutOrder = #self.pages * 100, Parent = side,
		})
	end

	local W = {}

	local function rowBase(parent, h)
		return inst("Frame", { Size = UDim2.new(1, 0, 0, h or 32), BackgroundTransparency = 1, Parent = parent })
	end

	function W.toggle(parent, label, def, cb)
		local r = rowBase(parent)
		inst("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local sw = inst("Frame", {
			Size = UDim2.fromOffset(38, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = def and COL_BLUE or COL_PILL, BorderSizePixel = 0, Parent = r,
		})
		corner(sw, 10)
		local knob = inst("Frame", {
			Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(def and 21 or 3, 3), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0, Parent = sw,
		})
		corner(knob, 9)
		local state = def and true or false
		local function paint()
			sw.BackgroundColor3 = state and COL_BLUE or COL_PILL
			knob.Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		end
		inst("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = r }).MouseButton1Click:Connect(function()
			state = not state; paint(); if cb then pcall(cb, state) end
		end)
		return { Set = function(_, v) state = v and true or false; paint(); if cb then pcall(cb, state) end end, Get = function() return state end }
	end

	function W.slider(parent, label, min, max, def, suffix, cb)
		suffix = suffix or ""
		local val = math.clamp(def or min, min, max)
		local r = rowBase(parent, 34)
		inst("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local track = inst("Frame", {
			Size = UDim2.new(0, 130, 0, 5), Position = UDim2.new(0.5, 0, 0.5, -3),
			BackgroundColor3 = COL_PILL, BorderSizePixel = 0, Parent = r,
		})
		corner(track, 3)
		local fill = inst("Frame", { Size = UDim2.fromScale((val - min) / (max - min), 1), BackgroundColor3 = COL_BLUE, BorderSizePixel = 0, Parent = track })
		corner(fill, 3)
		local grab = inst("Frame", {
			Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((val - min) / (max - min), 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = track,
		})
		corner(grab, 7)
		local pill = inst("TextLabel", {
			Size = UDim2.fromOffset(52, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = COL_PILL, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = COL_TEXT,
			Text = tostring(val)..suffix, BorderSizePixel = 0, Parent = r,
		})
		corner(pill, 6)
		local dragging = false
		local function update(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			val = math.floor(min + rel * (max - min) + 0.5)
			local f = (val - min) / (max - min)
			fill.Size = UDim2.fromScale(f, 1); grab.Position = UDim2.fromScale(f, 0.5)
			pill.Text = tostring(val)..suffix
			if cb then pcall(cb, val) end
		end
		r.InputBegan:Connect(function(ip)
			if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
				dragging = true; update(ip.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(ip)
			if dragging and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
				update(ip.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(ip)
			if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
		return { Set = function(_, v) val = math.clamp(v, min, max); local f = (val-min)/(max-min); fill.Size=UDim2.fromScale(f,1); grab.Position=UDim2.fromScale(f,0.5); pill.Text=tostring(val)..suffix; if cb then pcall(cb,val) end end, Get = function() return val end }
	end

	function W.dropdown(parent, label, options, startIdx, cb)
		local idx = startIdx or 1
		local open = false
		local holder = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = parent })
		inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = holder })
		local r = rowBase(holder, 36)
		inst("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(130, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = COL_PILL, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = r,
		})
		corner(box, 7)
		local boxLbl = inst("TextLabel", {
			Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
			Text = options[idx], Parent = box,
		})
		inst("TextLabel", {
			Size = UDim2.fromOffset(16, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0),
			BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COL_MUTED, Text = ">", Parent = box,
		})
		local list = inst("Frame", { Size = UDim2.fromOffset(130, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 4), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = r })
		corner(list, 7); stroke(list, COL_LINE, 1); list.ZIndex = 10; pad(list, 4, 4, 4, 4)
		inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = list })
		for i, opt in ipairs(options) do
			local it = inst("TextButton", {
				Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = opt, Font = Enum.Font.Gotham,
				TextSize = 13, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 11, Parent = list,
			})
			pad(it, 6, 6, 0, 0)
			it.MouseButton1Click:Connect(function()
				idx = i; boxLbl.Text = opt; open = false; list.Visible = false; if cb then pcall(cb, i, opt) end
			end)
		end
		box.MouseButton1Click:Connect(function() open = not open; list.Visible = open end)
		return { Get = function() return idx, options[idx] end }
	end

	function W.select(parent, label, cb)
		local r = rowBase(parent, 36)
		inst("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(130, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = COL_PILL, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = r,
		})
		corner(box, 7)
		inst("TextLabel", {
			Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Select", Parent = box,
		})
		inst("TextLabel", {
			Size = UDim2.fromOffset(16, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0),
			BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COL_MUTED, Text = ">", Parent = box,
		})
		box.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
		return box
	end

	function W.multiselect(parent, label, options, def, cb)
		local chosen = {}
		for _, v in ipairs(def or {}) do chosen[v] = true end
		local open = false
		local holder = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = parent })
		inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = holder })
		local r = rowBase(holder, 36)
		inst("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(130, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = COL_PILL, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = r,
		})
		corner(box, 7)
		local boxLbl = inst("TextLabel", {
			Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Select", Parent = box,
		})
		inst("TextLabel", {
			Size = UDim2.fromOffset(16, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0),
			BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COL_MUTED, Text = ">", Parent = box,
		})
		local list = inst("Frame", { Size = UDim2.fromOffset(130, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 4), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = r })
		corner(list, 7); stroke(list, COL_LINE, 1); list.ZIndex = 10; pad(list, 4, 4, 4, 4)
		inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = list })
		local function refresh()
			local n = 0
			for _ in pairs(chosen) do n = n + 1 end
			boxLbl.Text = n > 0 and (n.." selected") or "Select"
			local arr = {}
			for _, o in ipairs(options) do if chosen[o] then table.insert(arr, o) end end
			if cb then pcall(cb, arr) end
		end
		for _, opt in ipairs(options) do
			local it = inst("TextButton", {
				Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = (chosen[opt] and "\u{2611} " or "\u{2610} ")..opt, Font = Enum.Font.Gotham,
				TextSize = 13, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 11, Parent = list,
			})
			pad(it, 6, 6, 0, 0)
			it.MouseButton1Click:Connect(function()
				chosen[opt] = not chosen[opt]
				it.Text = (chosen[opt] and "\u{2611} " or "\u{2610} ")..opt
				refresh()
			end)
		end
		box.MouseButton1Click:Connect(function() open = not open; list.Visible = open end)
		return { Get = function() local a={} for _,o in ipairs(options) do if chosen[o] then table.insert(a,o) end end return a end }
	end

	function W.keybind(parent, label, key, cb)
		local r = rowBase(parent, 36)
		inst("TextLabel", {
			Size = UDim2.new(1, -160, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local cur = key or Enum.KeyCode.Unknown
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(130, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = COL_PILL, Text = cur.Name, Font = Enum.Font.GothamMedium, TextSize = 13,
			TextColor3 = COL_TEXT, AutoButtonColor = false, BorderSizePixel = 0, Parent = r,
		})
		corner(box, 7)
		local listening = false
		box.MouseButton1Click:Connect(function() listening = true; box.Text = "..." end)
		UIS.InputBegan:Connect(function(ip)
			if listening and ip.UserInputType == Enum.UserInputType.Keyboard then
				cur = ip.KeyCode; box.Text = cur.Name; listening = false
			elseif not listening and ip.UserInputType == Enum.UserInputType.Keyboard and ip.KeyCode == cur then
				if cb then pcall(cb) end
			end
		end)
		return { Get = function() return cur end }
	end

	function W.color(parent, label, def, cb)
		def = def or Color3.fromRGB(255, 255, 255)
		local col = Color3.new(def.R, def.G, def.B)
		local r = rowBase(parent, 36)
		inst("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local swatch = inst("TextButton", {
			Size = UDim2.fromOffset(34, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = col, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = r,
		})
		corner(swatch, 5); stroke(swatch, COL_LINE, 1)

		local pop = inst("Frame", {
			Size = UDim2.fromOffset(150, 150), Visible = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = gui,
		})
		corner(pop, 8); stroke(pop, COL_LINE, 1); pop.ZIndex = 50
		pad(pop, 8, 8, 8, 8)
		local area = inst("TextButton", {
			Size = UDim2.new(1, 0, 0, 90), BackgroundColor3 = Color3.fromHSV(col.H, 1, 1), Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = pop,
		})
		corner(area, 4); area.ZIndex = 51
		local satGrad = inst("UIGradient", { Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}), Rotation = 90, Parent = area })
		local valGrad = inst("UIGradient", { Color = ColorSequence.new(Color3.new(0,0,0)), Parent = area })
		local areaDot = inst("Frame", { Size = UDim2.fromOffset(6,6), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = area }); corner(areaDot,3); areaDot.ZIndex=52
		local hueBar = inst("TextButton", {
			Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -20), Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = pop,
		})
		corner(hueBar, 4); hueBar.ZIndex = 51
		inst("UIGradient", { Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
		}), Parent = hueBar })
		local hueDot = inst("Frame", { Size = UDim2.fromOffset(2,12), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = hueBar }); hueDot.ZIndex=52

		local function apply(h, s, v)
			col = Color3.fromHSV(h, s, v)
			swatch.BackgroundColor3 = col
			area.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			if cb then pcall(cb, col) end
		end
		local function placeArea(x, y)
			local sx = math.clamp((x - area.AbsolutePosition.X)/area.AbsoluteSize.X, 0, 1)
			local sy = math.clamp((y - area.AbsolutePosition.Y)/area.AbsoluteSize.Y, 0, 1)
			areaDot.Position = UDim2.fromScale(sx, sy)
			apply(col.H, sx, 1 - sy)
		end
		local function placeHue(x)
			local h = math.clamp((x - hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X, 0, 1)
			hueDot.Position = UDim2.new(h, -1, 0, 0)
			apply(h, (areaDot.AbsolutePosition.X-area.AbsolutePosition.X)/area.AbsoluteSize.X, 1-((areaDot.AbsolutePosition.Y-area.AbsolutePosition.Y)/area.AbsoluteSize.Y))
		end
		local dragA, dragH = false, false
		area.InputBegan:Connect(function(ip) if ip.UserInputType==Enum.UserInputType.MouseButton1 or ip.UserInputType==Enum.UserInputType.Touch then dragA=true; placeArea(ip.Position.X,ip.Position.Y) end end)
		hueBar.InputBegan:Connect(function(ip) if ip.UserInputType==Enum.UserInputType.MouseButton1 or ip.UserInputType==Enum.UserInputType.Touch then dragH=true; placeHue(ip.Position.X) end end)
		UIS.InputChanged:Connect(function(ip)
			if ip.UserInputType==Enum.UserInputType.MouseMovement or ip.UserInputType==Enum.UserInputType.Touch then
				if dragA then placeArea(ip.Position.X,ip.Position.Y) elseif dragH then placeHue(ip.Position.X) end
			end
		end)
		UIS.InputEnded:Connect(function(ip) if ip.UserInputType==Enum.UserInputType.MouseButton1 or ip.UserInputType==Enum.UserInputType.Touch then dragA=false; dragH=false end end)
		swatch.MouseButton1Click:Connect(function()
			pop.Visible = not pop.Visible
			if pop.Visible then
				local ap = swatch.AbsolutePosition
				pop.Position = UDim2.fromOffset(ap.x - 120, ap.y + 26)
			end
		end)
		return { Set = function(_, c) apply(c.H, c.S, c.V) end, Get = function() return col end }
	end

	local Column = {}
	Column.__index = Column

	function Column:card(title)
		if title then
			inst("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
				TextSize = 12, TextColor3 = COL_MUTED, TextXAlignment = Enum.TextXAlignment.Left,
				Text = string.upper(title), LayoutOrder = #self._cards * 2, Parent = self._frame,
			})
		end
		local c = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = COL_CARD, BorderSizePixel = 0, LayoutOrder = #self._cards * 2 + 1, Parent = self._frame })
		corner(c, 8); stroke(c, COL_LINE, 1); pad(c, 10, 10, 8, 10)
		inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = c })
		table.insert(self._cards, c)
		return setmetatable({ _parent = c }, { __index = function(_, k) return W[k] end })
	end

	function self:Tab(name, icon, group)
		local order = #self.pages
		if group and group ~= self._lastGroup then
			sideGroup(group)
			self._lastGroup = group
		end

		local tabBtn = inst("TextButton", {
			Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = COL_BG, Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order + 1, Parent = side,
		})
		corner(tabBtn, 6)
		local activeBg = inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = COL_ROW, BorderSizePixel = 0, Visible = false, Parent = tabBtn })
		corner(activeBg, 6)
		local iconImg = inst("ImageLabel", {
			Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(7, 6), BackgroundTransparency = 1,
			ImageColor3 = COL_TEXT, ScaleType = Enum.ScaleType.Fit, Parent = tabBtn,
		})
		setIcon(iconImg, icon, 14)
		inst("TextLabel", {
			Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(28, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = name, Parent = tabBtn,
		})

		local page = inst("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -46), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 3,
			BorderSizePixel = 0, Parent = body, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})
		page.LayoutOrder = order + 2
		local cols = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page })
		inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = cols })

		local tabObj = { _page = page, _cols = {}, _colCount = 0 }
		function tabObj:column()
			tabObj._colCount = tabObj._colCount + 1
			local colFrame = inst("Frame", { Size = UDim2.fromScale(0.5, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = tabObj._colCount, Parent = cols })
			inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = colFrame })
			local col = setmetatable({ _frame = colFrame, _cards = {} }, Column)
			table.insert(tabObj._cols, col)
			return col
		end

		local function select()
			for _, p in ipairs(self.pages) do p.page.Visible = false; p.active.Visible = false end
			page.Visible = true; activeBg.Visible = true
		end
		tabBtn.MouseButton1Click:Connect(select)

		table.insert(self.pages, { obj = tabObj, page = page, active = activeBg, btn = tabBtn })
		if order == 0 then select() end
		return tabObj
	end

	-- ===================== built-in Settings tab =====================
	local settings = self:Tab("Settings", "gear", "System")
	local scol = settings:column()
	local ssec = scol:card("Interface")

	-- watermark (text showing nick + status), placed below the top row of game buttons
	local wm = inst("TextLabel", {
		Size = UDim2.fromOffset(300, 18), Position = UDim2.new(0, 10, 0, 64), BackgroundTransparency = 1,
		Font = Enum.Font.Code, TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = nickName .. "   Freemium", Visible = true, Parent = gui, ZIndex = 99,
	})

	local uiScale = 1
	local function applyScale(s)
		uiScale = s
		root.Size = UDim2.fromOffset(math.floor(430*s), math.floor(285*s))
	end

	ssec:toggle("Lock movement", false, function(v) locked = v end)
	ssec:toggle("Watermark", true, function(v) wm.Visible = v end)
	ssec:dropdown("Language", { "English", "Русский" }, 1, function(i, v)
		local ru = (v == "Русский")
		wm.Text = nickName .. "   " .. (ru and "Фримиум" or "Freemium")
	end)
	ssec:slider("UI size", 70, 130, 100, "%", function(v) applyScale(v/100) end)
	ssec:keybind("Toggle key", opts.ToggleKey or Enum.KeyCode.RightShift, function() setMin(not minimized) end)

	self.Minimize = function() setMin(true) end
	self.Restore = function() setMin(false) end
	self.gui = gui
	self.root = root
	return self
end

return NLUI
