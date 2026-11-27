// Left bar: workspaces (top) + clock (bottom). Text-only, palette.md colors.
import Quickshell
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: bar
    required property ShellScreen modelData   // injected by Variants
    screen: modelData

    // top+bottom+left anchored → compositor sets the height; we only choose the width.
    anchors { top: true; bottom: true; left: true }
    implicitWidth: 40
    color: "#0c0c0c"                          // bg

    readonly property string font: "Courier Prime"

    // Clock in-process: wakes once per minute instead of fork+exec `date` every second.
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // 1px right edge in `line`: hard rectangular edge like the window borders.
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 1
        color: "#3a3a3a"
    }

    // Workspaces: event-driven via Hyprland's socket2, no polling.
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
                    font { family: bar.font; pixelSize: 15; bold: true }
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

    // Clock: HH over MM, fits the narrow bar.
    Column {
        anchors { bottom: parent.bottom; bottomMargin: 12; horizontalCenter: parent.horizontalCenter }
        Repeater {
            model: [Qt.formatDateTime(clock.date, "hh"), Qt.formatDateTime(clock.date, "mm")]
            Text {
                required property string modelData
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData
                font { family: bar.font; pixelSize: 15; bold: true }
                color: "#d6d6d6"
            }
        }
    }
}
