-- Migrated from tmux (~/.config/tmux/tmux.conf, ~/.config/grove/grove.tmux.conf)
-- and Ghostty (~/.config/ghostty/config).

-- tmux: prefix ctrl+a
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Splits
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("ctrl+a>h", "pane.split", { direction = "down" })

-- New tab
rex.bind("ctrl+a>c", "client.tab.new")

-- Pane navigation
rex.bind("ctrl+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+l", "pane.focus", { direction = "right" })

-- Resize panes
rex.bind("ctrl+a>shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+a>shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+a>shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+a>shift+l", "pane.resize", { amount = 5, direction = "right" })

-- Repeat mode for the repeatable (bind -r) resize bindings
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("repeat/shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("repeat/shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("repeat/shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("repeat/shift+l", "pane.resize", { amount = 5, direction = "right" })

-- Reload config
rex.bind("ctrl+a>r", "client.config.reload")

-- Ghostty
rex.bind("ctrl+shift+b", "pane.split", { direction = "right" })
rex.bind("ctrl+shift+n", "client.tab.new")
rex.bind("ctrl+shift+t", "client.window.new")

-- Worktree tasks (wt is in the dotfiles). Both run wt in a floating terminal in the
-- focused pane's folder, so wt can ask for a task title and show what it does.
local terminal = "com.superlogical.terminal"
local wt = os.getenv("HOME") .. "/.local/bin/wt"

-- Where the focused pane's program is running (shells here don't report it with OSC 7).
local function focused_dir(ctx)
  local r = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  return r and r.foreground and r.foreground.cwd
end

-- With `pause`, the output stays on screen until a key is pressed; without it, only
-- an error does.
local function run_wt(ctx, cmd, pause)
  local view, err = rex.session.view{}
  if view == nil then error(err, 0) end
  local wait = '{ echo; read -rsn1 -p "Press any key to close"; }'
  -- On the way out, give focus back to the pane that was focused before ($1, in
  -- session $2). It may be gone, e.g. after wt rm closed its session.
  local back = 'trap \'rex focus -s "$2" "$1" >/dev/null 2>&1\' EXIT; '
  local script = back .. '"$0" ' .. cmd .. (pause and '; ' or ' || ') .. wait
  local prev = ctx.block_id or view.windows[1].focused_block_id
  local _, err2 = rex.session.new_layer{
    window_id = view.active_window_id,
    bounds = { 0.2, 0.25, 0.6, 0.4 },
    focus = true,
    layout = rex.layout.block{
      flavor = terminal .. ".shell",
      options = {
        command = { "/bin/bash", "-c", script, wt, prev or "", view.session_id },
        cwd = focused_dir(ctx),
      },
    },
  }
  if err2 ~= nil then error(err2, 0) end
end

for _, a in ipairs{
  { "wt_new", "New Worktree Task", "new" },
  { "wt_rm", "Remove Worktree Task", "rm" },
  { "wt_gc", "Clean Up Merged Tasks", "gc", true },
  { "wt_ls", "List Worktree Tasks", "ls", true },
} do
  rex.action{
    name = a[1], title = a[2], category = "Worktrees", keywords = "worktree task wt",
    run = function(ctx) run_wt(ctx, a[3], a[4]) end,
  }
end
rex.bind("ctrl+a>n", "wt_new")
rex.bind("ctrl+a>x", "wt_rm")
