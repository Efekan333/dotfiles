// Left bar, layout after soramane's caelestia bar (squared to fit the rice):
//   top: workspaces · bottom (upwards): power, [wifi bt] group, clock, calendar button.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick

PanelWindow {
    id: bar
    required property ShellScreen modelData   // injected by Variants
    screen: modelData

    // top+bottom+left anchored → compositor sets the height; we only choose the width.
    anchors { top: true; bottom: true; left: true }
    implicitWidth: 40
    color: "#0c0c0c"                          // bg

    readonly property string textFont: "Courier Prime"
    readonly property string iconFont: "ProggyClean CE Nerd Font Mono"
    function glyph(cp) { return String.fromCodePoint(cp) }   // Nerd Font MD icons live in the PUA

    // Clock in-process: wakes once per minute instead of fork+exec `date` every second.
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // 1px right edge in `line`: hard rectangular edge like the window borders.
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 1; color: "#3a3a3a"
    }

    // Reusable square icon button: dim when off, fg when on, inverted on hover.
    component IconButton: Rectangle {
        id: btn
        property string icon
        property bool on: true
        property bool active: false               // forced inversion (popup open, power armed)
        readonly property bool lit: area.containsMouse || active
        signal clicked()
        width: 28; height: 28
        color: lit ? "#f0f0f0" : "transparent"
        Text {
            anchors.centerIn: parent
            text: btn.icon
            font { family: bar.iconFont; pixelSize: 26 }
            color: btn.lit ? "#0c0c0c" : (btn.on ? "#d6d6d6" : "#808080")
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // ---- top: workspaces (event-driven via Hyprland socket2, no polling) ----
    Column {
        anchors { top: parent.top; topMargin: 12; horizontalCenter: parent.horizontalCenter }
        spacing: 4
        Repeater {
            model: Hyprland.workspaces
            Rectangle {
                id: ws
                required property HyprlandWorkspace modelData
                visible: modelData.id > 0                 // hide special (scratchpad) workspaces
                width: 26; height: 26
                color: modelData.focused ? "#f0f0f0" : "transparent"   // highlight = inversion
                Text {
                    anchors.centerIn: parent
                    text: ws.modelData.id
                    font { family: bar.textFont; pixelSize: 15; bold: true }
                    color: ws.modelData.focused ? "#0c0c0c" : "#808080"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ws.modelData.activate()
                }
            }
        }
    }

    // ---- bottom stack ----
    Column {
        anchors { bottom: parent.bottom; bottomMargin: 10; horizontalCenter: parent.horizontalCenter }
        spacing: 10

        IconButton {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: bar.glyph(0xF00ED)                      // calendar
            active: calendar.visible
            onClicked: calendar.visible = !calendar.visible
        }

        // clock: HH over MM
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: [Qt.formatDateTime(clock.date, "hh"), Qt.formatDateTime(clock.date, "mm")]
                Text {
                    required property string modelData
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData
                    font { family: bar.textFont; pixelSize: 15; bold: true }
                    color: "#d6d6d6"
                }
            }
        }

        // status group on a grey plate so it stands out from the bar
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32; height: toggles.height + 8
            color: "#161616"                              // surface
            border { width: 1; color: "#3a3a3a" }         // line
            Column {
                id: toggles
                anchors.centerIn: parent
                spacing: 2
                // State comes straight from NetworkManager / BlueZ over D-Bus; writing toggles the radio.
                IconButton {
                    icon: bar.glyph(Networking.wifiEnabled ? 0xF05A9 : 0xF05AA)
                    on: Networking.wifiEnabled
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                IconButton {
                    readonly property var adapter: Bluetooth.defaultAdapter
                    icon: bar.glyph(adapter && adapter.enabled ? 0xF00AF : 0xF00B2)
                    on: !!adapter && adapter.enabled
                    onClicked: if (adapter) adapter.enabled = !adapter.enabled
                }
            }
        }

        // power off: two clicks within 3 s (first click arms) → no accidental shutdowns
        IconButton {
            id: power
            property bool armed: false
            anchors.horizontalCenter: parent.horizontalCenter
            icon: bar.glyph(0xF0425)
            active: armed
            onClicked: {
                if (armed) Quickshell.execDetached(["systemctl", "poweroff"]);
                else { armed = true; disarm.restart(); }
            }
            Timer { id: disarm; interval: 3000; onTriggered: power.armed = false }
        }
    }

    // ---- calendar popup (xdg_popup: drawn above all windows, anchored to the bar) ----
    PopupWindow {
        id: calendar
        visible: false
        anchor { window: bar; rect.x: bar.width + 8; rect.y: bar.height - implicitHeight - 10 }
        implicitWidth: cal.implicitWidth + 32
        implicitHeight: cal.implicitHeight + 24
        color: "#0c0c0c"

        // click outside → close (compositor tells us when the grab is cleared)
        HyprlandFocusGrab {
            windows: [calendar]
            active: calendar.visible
            onCleared: calendar.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border { width: 1; color: "#d6d6d6" }
        }

        Calendar { id: cal; anchors.centerIn: parent; date: clock.date; font: bar.textFont }
    }
}
