local wezterm = require("wezterm")

local M = {
	action = {},
}

local opts = {
	spawn_direction = "Bottom",
	spawn_domain = "CurrentPaneDomain",
	enrich_tab_title = true,
}

function M.apply_to_config(_, user_opts)
	if user_opts then
		for k, v in pairs(user_opts) do
			opts[k] = v
		end
	end

	if opts.enrich_tab_title then

    wezterm.on("format-tab-title", function(tab_info)
      local stack_info = M.stack_info(tab_info.tab_id)
      local title = M.tab_title(tab_info)

      if not stack_info then
        return title
      end

      return title .. " [" .. stack_info.index .. "/" .. stack_info.count .. "]"
    end)
	end
end

function M.stack_info(tab_id)
	local tab = wezterm.mux.get_tab(tab_id)
	local panes_info = tab:panes_with_info()
	local pane_count = #panes_info
	local active_pane_index

	for i, pane_info in ipairs(panes_info) do
		if pane_info.is_active then
			if not pane_info.is_zoomed then
				return nil
			end
			active_pane_index = i
			break
		end
	end

  return {
    index = active_pane_index,
    count = pane_count
  }
end

function M.tab_title(tab_info)
  local title = tab_info.tab_title
  local index = tab_info.tab_index + 1

  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return index .. ": " .. title
  end

  -- Otherwise, use the title from the active pane
  -- in that tab
  return index .. ": " .. tab_info.active_pane.title
end


M.action.SpawnPane = wezterm.action_callback(function(window, pane)
	pane:split({ domain = opts.spawn_domain, direction = opts.spawn_direction })
	window:active_tab():set_zoomed(true)
end)

function M.action.ActivatePaneRelative(direction)
	return wezterm.action_callback(function(window)
		local tab = window:active_tab()
		local panes = tab:panes_with_info()
		local activeIndex = -1

		for i, pane_info in ipairs(panes) do
			if pane_info.is_active then
				if not pane_info.is_zoomed then
					return
				end
				activeIndex = i
				break
			end
		end

		if activeIndex == -1 then
			return
		end

		local target = activeIndex + direction
		local pane_info = panes[1]

		if target < 1 then
			pane_info = panes[#panes]
		elseif target <= #panes then
			pane_info = panes[target]
		end

		tab:set_zoomed(false)
		pane_info.pane:activate()
		tab:set_zoomed(true)
	end)
end

return M
