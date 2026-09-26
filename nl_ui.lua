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

local ICONS = {
	crosshair = "\u{2316}", mouse = "\u{1F5B1}", camera = "\u{1F4F7}",
	inventory = "\u{1F4E6}", gear = "\u{2699}", eye = "\u{1F441}",
	sword = "\u{2694}", bolt = "\u{26A1}", shield = "\u{1F6E1}",
}

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

local function makeDrag(target, handle)
	local dragging, startInput, startPos
	handle.InputBegan:Connect(function(ip)
		if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = ip.Position
			startPos = target.Position
		end
	end)
	UIS.InputChanged:Connect(function(ip)
		if dragging and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
			local d = ip.Position - startInput
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
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
		Size = UDim2.fromOffset(860, 520),
		Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(430, 260),
		BackgroundColor3 = COL_BG, BorderSizePixel = 0, ClipsDescendants = true, Parent = gui,
	})
	corner(root, 12); stroke(root, COL_LINE, 1)

	local side = inst("Frame", {
		Size = UDim2.fromOffset(200, 1), BackgroundColor3 = COL_BG, BorderSizePixel = 0, Parent = root,
	})
	pad(side, 12, 12, 12, 12)
	inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = side })

	local body = inst("ScrollingFrame", {
		Size = UDim2.new(1, -200, 1, 0), Position = UDim2.fromOffset(200, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = root,
	})
	pad(body, 16, 16, 12, 16)
	inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = body })

	local headerSlot = inst("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = body })
	inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = headerSlot })
	local configBtn = inst("TextButton", {
		Size = UDim2.fromOffset(180, 34), BackgroundColor3 = COL_CARD, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = headerSlot,
	})
	corner(configBtn, 8); stroke(configBtn, COL_LINE, 1)
	inst("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = "My Config", Parent = configBtn,
	})
	inst("TextLabel", {
		Size = UDim2.fromOffset(20, 34), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = COL_MUTED, Text = ">", Parent = configBtn,
	})
	inst("TextButton", {
		Size = UDim2.fromOffset(34, 34), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 3),
		BackgroundTransparency = 1, Text = "\u{1F50D}", Font = Enum.Font.GothamBold, TextSize = 16,
		TextColor3 = COL_TEXT, AutoButtonColor = false, BorderSizePixel = 0, Parent = headerSlot,
	})

	local userCard = inst("Frame", {
		Size = UDim2.new(1, -24, 0, 56), Position = UDim2.new(0, 12, 1, -68), BackgroundColor3 = COL_CARD,
		BorderSizePixel = 0, Parent = side, ZIndex = 5,
	})
	corner(userCard, 10); stroke(userCard, COL_LINE, 1); userCard.LayoutOrder = 999
	local avatar = inst("ImageLabel", {
		Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = COL_PILL,
		BorderSizePixel = 0, Image = opts.Avatar or "", ScaleType = Enum.ScaleType.Crop, Parent = userCard, ZIndex = 6,
	})
	corner(avatar, 20)
	inst("TextLabel", {
		Size = UDim2.new(1, -70, 0, 20), Position = UDim2.fromOffset(56, 10), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Nick or "user", Parent = userCard, ZIndex = 6,
	})
	inst("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(56, 30), BackgroundTransparency = 1,
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COL_BLUE, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Subtext or "INF Days Left", Parent = userCard, ZIndex = 6,
	})
	inst("TextLabel", {
		Size = UDim2.fromOffset(16, 56), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = COL_MUTED,
		Text = ">", Parent = userCard, ZIndex = 6,
	})

	makeDrag(gui, root)

	local float = inst("TextButton", {
		Size = UDim2.fromOffset(50, 50), Position = UDim2.fromScale(0.04, 0.5), BackgroundColor3 = COL_BLUE,
		Text = "\u{2699}", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.new(1, 1, 1),
		Visible = false, BorderSizePixel = 0, Parent = gui,
	})
	corner(float, 25); stroke(float, Color3.new(1, 1, 1), 1.5)
	makeDrag(gui, float)

	local minimized = false
	local function setMin(v)
		minimized = v; root.Visible = not v; float.Visible = v
	end
	float.MouseButton1Click:Connect(function() setMin(false) end)

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
		return inst("Frame", { Size = UDim2.new(1, 0, 0, h or 40), BackgroundTransparency = 1, Parent = parent })
	end

	function W.toggle(parent, label, def, cb)
		local r = rowBase(parent)
		inst("TextLabel", {
			Size = UDim2.new(1, -70, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local sw = inst("Frame", {
			Size = UDim2.fromOffset(44, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = def and COL_BLUE or COL_PILL, BorderSizePixel = 0, Parent = r,
		})
		corner(sw, 12)
		local knob = inst("Frame", {
			Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(def and 23 or 3, 3), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0, Parent = sw,
		})
		corner(knob, 9)
		local state = def and true or false
		local function paint()
			sw.BackgroundColor3 = state and COL_BLUE or COL_PILL
			knob.Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
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
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local track = inst("Frame", {
			Size = UDim2.new(0, 150, 0, 6), Position = UDim2.new(0.5, 0, 0.5, -3),
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
			Size = UDim2.fromOffset(58, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
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
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(150, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
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
		local list = inst("Frame", { Size = UDim2.fromOffset(150, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 4), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = r })
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
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(150, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
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
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(150, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
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
		local list = inst("Frame", { Size = UDim2.fromOffset(150, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 4), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, BackgroundColor3 = COL_CARD, BorderSizePixel = 0, Parent = r })
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
			TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
		})
		local cur = key or Enum.KeyCode.Unknown
		local box = inst("TextButton", {
			Size = UDim2.fromOffset(150, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
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
		corner(c, 10); stroke(c, COL_LINE, 1); pad(c, 12, 12, 10, 12)
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
			Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = COL_BG, Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order + 1, Parent = side,
		})
		corner(tabBtn, 8)
		local activeBg = inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = COL_ROW, BorderSizePixel = 0, Visible = false, Parent = tabBtn })
		corner(activeBg, 8)
		inst("TextLabel", {
			Size = UDim2.fromOffset(24, 42), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 17, TextColor3 = COL_TEXT, Text = (icon and ICONS[icon]) or "\u{2022}", Parent = tabBtn,
		})
		inst("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(40, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = COL_TEXT, TextXAlignment = Enum.TextXAlignment.Left, Text = name, Parent = tabBtn,
		})

		local page = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, Parent = body })
		page.LayoutOrder = order + 2
		local cols = inst("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page })
		inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = cols })

		local tabObj = { _page = page, _cols = {}, _colCount = 0 }
		function tabObj:column()
			tabObj._colCount = tabObj._colCount + 1
			local colFrame = inst("Frame", { Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = tabObj._colCount, Parent = cols })
			inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = colFrame })
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

	self.Minimize = function() setMin(true) end
	self.Restore = function() setMin(false) end
	self.gui = gui
	self.root = root
	return self
end

return NLUI
