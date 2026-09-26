# NLUI

Neverlose style UI library for Roblox. Dark two column layout, sidebar with grouped tabs and Lucide icons, blue switches, sliders with a value pill, Select dropdowns, keybinds. Draggable, minimizes to a floating icon so it works on mobile. Icons come from the Lucide sprite sheet (rbxassetid), no image files to ship.

## Load

```lua
local nl = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NLUI/main/nl_ui.lua"))()
```

## Quick start

```lua
local win = nl.new({ Nick = "you", Subtext = "INF Days Left" })

local rage = win:Tab("Rage", "crosshair", "Aimbot")
local left = rage:column()
local right = rage:column()

local main = left:card("Main")
main:toggle("Enabled", true)
main:slider("Field of View", 1, 180, 75, "\u{00B0}")

local sel = left:card("Selection")
sel:select("Target")
sel:multiselect("Hitboxes", { "Head", "Chest", "Arms", "Legs" }, { "Head", "Chest" })
sel:keybind("Trigger", Enum.KeyCode.T)
```

See `example.lua` for the full layout.

## API

### Window

```lua
nl.new(opts)
```

| opt | default | what |
|-----|---------|------|
| `Nick` | `"user"` | name in the bottom card |
| `Subtext` | `"INF Days Left"` | line under the name |
| `Avatar` | `""` | image id/url for the avatar circle |
| `ToggleKey` | `RightShift` | key that shows/hides the menu |

Methods: `win:Minimize()`, `win:Restore()`. On mobile the floating gear button restores it.

### Tabs

```lua
local tab = win:Tab(name, icon, group)
```

`icon` is a Lucide name, one of: `crosshair target mouse pointer camera image eye inventory box layers gear sliders sword bolt shield user list search monitor cpu radar sparkles bell lock key wifi flag gamepad bot bug pencil palette focus`. `group` is an optional sidebar header (e.g. `"Aimbot"`, `"Common"`); pass it on the first tab of each group.

Each tab splits into columns:

```lua
local col = tab:column()   -- call twice for two side by side columns
```

### Cards and widgets

```lua
local card = col:card("MAIN")
```

Every widget returns a handle with `:Get()` and most also `:Set(value)`. The last argument is the callback.

```lua
card:toggle(label, default, cb)                       -> :Get() :Set(v)
card:slider(label, min, max, default, suffix, cb)     -> :Get() :Set(v)
card:dropdown(label, options, startIndex, cb)         -> :Get()
card:select(label, cb)                                -- a "Select >" row
card:multiselect(label, options, defaults, cb)        -> :Get()
card:keybind(label, keyCode, cb)                      -> :Get()
```

## Notes

- Renders into `gethui()` when present, otherwise `PlayerGui`.
- Toggle the whole menu with RightShift or the floating icon.
- Colors are set at the top of `NLUI.new`; change `COL_BLUE` to retheme the accent.
