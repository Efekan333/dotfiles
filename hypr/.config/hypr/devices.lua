
--Monitor, MnK


hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
            -- libinput turns tap → tap-hold → slide into a held LMB, so border-resize and
            -- SUPER+drag work from the touchpad like a real button
            tap_to_click = true,
            tap_and_drag = true,
            drag_lock    = 1, -- lift finger mid-drag briefly (timeout) without dropping the window
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


