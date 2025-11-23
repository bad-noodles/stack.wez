# stack.wez

A WezTerm plugin for **stacked pane mode** - work with multiple panes but see only one at a time. It uses WezTerm's panes and zoom under the hood.

## What it does

- Creates new terminal panes that stack on top of each other
- Only shows one pane at a time (no split screen clutter)
- Switch between panes with keyboard shortcuts

## Installation

```lua
local wezterm = require("wezterm")
local stack = wezterm.plugin.require("https://github.com/bad-noodles/stack.wez")

local config = wezterm.config_builder()
stack.apply_to_config(config)

-- stack.wez does not set up any keybindings by default, so you need to add your own

config.keys = {
  { key = "s", mods = "CMD|SHIFT", action = stack.action.SpawnPane },
  { key = "k", mods = "CMD|SHIFT", action = stack.action.ActivatePaneRelative(-1) },
  { key = "j", mods = "CMD|SHIFT", action = stack.action.ActivatePaneRelative(1) },
  -- For closing panes, use the built-in WezTerm action
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
}

-- or

config.keys = {
  { key = "s", mods = "CTRL|SHIFT", action = stack.action.SpawnPane },
  { key = "k", mods = "CTRL|SHIFT", action = stack.action.ActivatePaneRelative(-1) },
  { key = "j", mods = "CTRL|SHIFT", action = stack.action.ActivatePaneRelative(1) },
	{ key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
}

return config
```

## Options

You can customize the plugin behavior:

```lua
stack.apply_to_config(config, {
  spawn_direction = "Bottom",  -- "Top", "Bottom", "Left", or "Right"
  spawn_domain = "CurrentPaneDomain",
  enrich_tab_title = true  -- Show stack position in tab title
})
```

**spawn_direction** (default: `"Bottom"`)
- Where new panes are created relative to the current pane
- [Check all options here](https://wezterm.org/config/lua/pane/split.html?h=split#direction)

**spawn_domain** (default: `"CurrentPaneDomain"`)
- Which domain new panes use
- [Check all options here](https://wezterm.org/config/lua/pane/split.html?h=split#domain)

**enrich_tab_title** (default: `true`)
- Shows your position in the stack in the tab title (e.g., `zsh [1/3]`)
- Set to `false` to disable

## Custom Tab Title Formatter

You can create your own tab title formatter using `stack.stack_info(tab_id)`:

```lua
-- Disable the built-in tab title enrichment
stack.apply_to_config(config, {
  enrich_tab_title = false
})

-- Create your own custom formatter
wezterm.on("format-tab-title", function(tab_info)
  local stack_info = stack.stack_info(tab_info.tab_id)
  
  if stack_info then
    return string.format("%s 📚 %d/%d", 
      tab_info.tab_title, 
      stack_info.index, 
      stack_info.count
    )
  end
  
  return tab_info.tab_title
end)
```

The `stack.stack_info(tab_id)` function returns:
- A table with `index` and `count` fields when in stacked/zoomed mode
- `nil` otherwise

## Why use it?

Ideal for when you need multiple panes but want to focus on one at a time - like having your editor in one pane, tests in another, and logs in a third.

## Limitations

Wezterm does not provide an API for closing a pane, and the default behaviour when closing one via the keybindings will take you out of zoom mode. I am still to find a solution for closing a pane and keeping the zoomed in state.
