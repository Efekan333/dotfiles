
-------------------------------------
---- PER-WORKSPACE WALLPAPER ----
-------------------------------------
-- On workspace switch, tell hyprpaper (over its IPC socket, via hyprctl) which image to show.
-- Images come from scripts/recolor-walls.sh. Workspaces beyond #walls wrap around.

local dir   = os.getenv("HOME") .. "/wallpaper/palette/"
local walls = { "katana", "shark", "dying_man", "angel", "woman_blueish", "woman_red" }

hl.on("workspace.active", function(ws)
    if not ws or ws.special or not ws.id or ws.id < 1 then return end
    local name = walls[(ws.id - 1) % #walls + 1]
    local mon  = (ws.monitor and ws.monitor.name) or ""
    hl.exec_cmd(string.format('hyprctl hyprpaper wallpaper "%s,%s%s.png"', mon, dir, name))
end)
