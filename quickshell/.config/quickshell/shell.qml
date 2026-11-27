// Entry point (`qs` loads ~/.config/quickshell/shell.qml).
// Variants = one LeftBar per screen; bars are created/destroyed on hotplug.
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        LeftBar {}
    }
    Variants {
        model: Quickshell.screens
        Frame {}            // top/right/bottom strips; bottom = launcher hot zone
    }
}
