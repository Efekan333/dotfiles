// Screen frame (Caelestia architecture, squared strips + rounded inner corners).
// Draw: ONE fullscreen layer surface, exclusionMode Ignore → geometry is fixed (0,0,W,H), independent of the order
//   Hyprland arranges other layers in (separate strip surfaces moved around on reload).
// Input: mask = the strips only → everything else (incl. the corner pieces) is click-through to windows.
// Space: 3 invisible 1×1 surfaces whose only job is exclusiveZone → Hyprland tiles windows inside the frame.
// Left side = the bar (Theme.bar px). Top layer → fullscreen windows cover the frame.
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    required property ShellScreen modelData

    component Exclusion: PanelWindow {
        screen: root.modelData
        implicitWidth: 1; implicitHeight: 1
        color: "transparent"
        exclusiveZone: Theme.border
        mask: Region {}                      // empty input region → never catches the mouse
        WlrLayershell.namespace: "frame-exclusion"
    }
    Exclusion { anchors.top: true }
    Exclusion { anchors.right: true }
    Exclusion { anchors.bottom: true }

    PanelWindow {
        id: win
        screen: root.modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.namespace: "frame"
        mask: Region {
            Region { item: top }
            Region { item: right }
            Region { item: bottom }
        }

        readonly property int b: Theme.border
        readonly property int l: Theme.bar

        Rectangle { id: top;    x: win.l; width: win.width - win.l; height: win.b; color: Theme.frame }
        Rectangle { id: right;  x: win.width - win.b; width: win.b; height: win.height; color: Theme.frame }
        Rectangle {
            id: bottom
            x: win.l; y: win.height - win.b
            width: win.width - win.l; height: win.b
            color: Theme.frame
            // launcher hot zone: dwell 250 ms → wofi rises out of the strip
            MouseArea { id: area; anchors.fill: parent; hoverEnabled: true }
        }
        Timer {
            interval: 250                    // passing mouse (scrolling, aiming at a window) doesn't trigger
            running: area.containsMouse
            onTriggered: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/wofi/launch.sh", "--open"])
        }

        // inner corners (drawn for top-left, rotated for the rest)
        Fillet { x: win.l;                       y: win.b }
        Fillet { x: win.width - win.b - width;   y: win.b;                         rotation: 90 }
        Fillet { x: win.width - win.b - width;   y: win.height - win.b - height;   rotation: 180 }
        Fillet { x: win.l;                       y: win.height - win.b - height;   rotation: 270 }
    }
}
