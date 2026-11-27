// Left bar, layout after soramane's caelestia bar (squared to fit the rice):
//   top: workspaces · bottom (upwards): power, [wifi bt] group, clock, calendar button.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import QtQuick

PanelWindow {
    id: bar
    required property ShellScreen modelData   // injected by Variants
    screen: modelData

    // top+bottom+left anchored → compositor sets the height; we only choose the width.
    anchors { top: true; bottom: true; left: true }
    implicitWidth: Theme.bar
    color: Theme.frame                        // frame fill: bar is the frame's left side

    readonly property string textFont: Theme.font
    readonly property string iconFont: "ProggyClean CE Nerd Font Mono"
    function glyph(cp) { return String.fromCodePoint(cp) }   // Nerd Font MD icons live in the PUA

    // Popups sit on the bottom strip; snap their top edge to the top of a bar element (smallest one that fits),
    // so the edge never cuts through an icon. Reads y/height properties → re-evaluates when the stack moves.
    function snapHeight(h) {
        const base = bar.height - Theme.border;               // popup bottom edge
        let best = 0;
        for (const c of bottomStack.children) {
            if (!c.visible) continue;
            const fit = base - (bottomStack.y + c.y);           // height if the top aligns with this element
            if (fit >= h && (best === 0 || fit < best)) best = fit;
        }
        return best || h;
    }

    // lock, then blank the panel; hyprlock stays as the gate when input wakes it
    readonly property string idleCmd:
        `(pidof hyprlock || hyprlock) & sleep 1; hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'`

    // Raise-or-run: focus the window if its class exists, else start it (one instance only).
    // Goes through sh because hyprctl's exit code is the only cheap "does it exist" test.
    function raiseOrRun(cls, cmd) {
        Quickshell.execDetached(["sh", "-c",
            `hyprctl clients -j | jq -e '.[] | select(.class == "${cls}")' >/dev/null`
            + ` && hyprctl dispatch 'hl.dsp.focus({ window = "class:${cls}" })' || exec ${cmd}`]);
    }

    // Clock in-process: wakes once per minute instead of fork+exec `date` every second.
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // Reusable square icon button: dim when off, fg when on, inverted on hover.
    component IconButton: Rectangle {
        id: btn
        property string icon
        property bool on: true
        property bool active: false               // forced inversion (popup open, power armed)
        readonly property bool lit: area.containsMouse || active
        signal clicked()
        signal rightClicked()
        width: 28; height: 28
        color: lit ? "#f0f0f0" : "transparent"
        Text {
            anchors.centerIn: parent
            text: btn.icon
            font { family: bar.iconFont; pixelSize: 26 }
            color: btn.lit ? "#0c0c0c" : (btn.on ? "#d6d6d6" : "#a8a8a8")
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => mouse.button === Qt.RightButton ? btn.rightClicked() : btn.clicked()
        }
    }

    // ---- top: workspaces (event-driven via Hyprland socket2, no polling) ----
    Column {
        id: wsCol
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
                    color: ws.modelData.focused ? "#0c0c0c" : "#a8a8a8"
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
    // ---- middle: active app name, rotated 90° cw (reads top→bottom, glyph baseline faces the screen edge) ----
    // activeToplevel comes from socket2 `activewindowv2` events → no polling. Fills the gap between top and bottom stacks.
    Item {
        anchors {
            top: wsCol.bottom; bottom: bottomStack.top; topMargin: 16; bottomMargin: 16
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        Text {
            anchors.centerIn: parent
            width: parent.height                       // pre-rotation width = available vertical space
            rotation: 90
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            // app id (= Hyprland "class"), not the title: titles carry page names + " — Mozilla Firefox"
            text: (Hyprland.activeToplevel?.wayland?.appId ?? "").toLowerCase()
            font { family: bar.textFont; pixelSize: 15; bold: true }
            color: "#a8a8a8"                            // mid
        }
    }

    Column {
        id: bottomStack
        anchors { bottom: parent.bottom; bottomMargin: 10; horizontalCenter: parent.horizontalCenter }
        spacing: 10

        IconButton {
            id: calendarBtn
            anchors.horizontalCenter: parent.horizontalCenter
            icon: bar.glyph(0xF00ED)                      // calendar
            active: calendar.open
            onClicked: calendar.open = !calendar.open
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

        // battery %: UPower's displayDevice = aggregate of all laptop batteries (D-Bus property signals, no polling)
        Rectangle {
            id: battery
            readonly property var dev: UPower.displayDevice
            readonly property int pct: Math.round(dev.percentage * 100)   // Quickshell reports 0..1
            readonly property bool charging: dev.state === UPowerDeviceState.Charging
                                          || dev.state === UPowerDeviceState.FullyCharged
            readonly property bool low: !charging && pct <= 10
            property bool warned: false               // fire each threshold once per discharge
            property bool idled: false
            visible: dev.ready && dev.isLaptopBattery
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32; height: 22
            color: low ? "#f0f0f0" : "transparent"
            Text {
                anchors.centerIn: parent
                text: (battery.charging ? "+" : "") + battery.pct
                font { family: bar.textFont; pixelSize: 15; bold: true }
                color: battery.low ? "#0c0c0c" : (battery.charging ? "#f0f0f0" : "#a8a8a8")
            }
            function check() {
                if (!visible) return;
                if (charging) { warned = false; idled = false; return; }
                if (pct <= 10 && !warned) {
                    warned = true;
                    Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "battery",
                                             "Battery low", pct + "% left - plug in"]);
                }
                if (pct <= 2 && !idled) {
                    idled = true;
                    Quickshell.execDetached(["sh", "-c", bar.idleCmd]);
                }
            }
            onPctChanged: check()
            onChargingChanged: check()
            onVisibleChanged: check()
        }

        // status group on a darker plate spanning the full bar width (edge to edge)
        Rectangle {
            width: bar.width; height: toggles.height + 8
            color: "#161616"                              // surface
            Column {
                id: toggles
                anchors.centerIn: parent
                spacing: 2
                // State comes straight from NetworkManager / BlueZ over D-Bus; writing toggles the radio.
                IconButton {
                    icon: bar.glyph(Networking.wifiEnabled ? 0xF05A9 : 0xF05AA)
                    on: Networking.wifiEnabled
                    onClicked: bar.raiseOrRun("nmtui", "kitty --class nmtui -e nmtui")   // TUI → needs a terminal
                    onRightClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                IconButton {
                    readonly property var adapter: Bluetooth.defaultAdapter
                    icon: bar.glyph(adapter && adapter.enabled ? 0xF00AF : 0xF00B2)
                    on: !!adapter && adapter.enabled
                    onClicked: bar.raiseOrRun("blueman-manager", "blueman-manager")
                    onRightClicked: if (adapter) adapter.enabled = !adapter.enabled
                }
            }
        }

        IconButton {
            id: powerBtn
            anchors.horizontalCenter: parent.horizontalCenter
            icon: bar.glyph(0xF0425)
            active: powerMenu.open
            onClicked: powerMenu.open = !powerMenu.open
        }
    }

    // ---- calendar popup (xdg_popup: drawn above all windows, anchored to the bar) ----
    DrawerPopup {
        id: calendar
        anchor { window: bar; rect.x: bar.width; rect.y: bar.height - implicitHeight - Theme.border }   // flush to bar + bottom strip
        boxWidth: cal.implicitWidth + 32
        boxHeight: bar.snapHeight(cal.implicitHeight + 24)

        Calendar { id: cal; anchors.centerIn: parent; date: clock.date; font: bar.textFont }
    }

    // ---- power popup ----
    // shutdown/logout go through hyprshutdown: it sends xdg_toplevel.close to every window (= SUPER+C),
    // waits for them to exit (save dialogs block it), then exits Hyprland and runs the post command.
    // Plain `systemctl poweroff` would SIGTERM the session cgroup instead → no save prompts, "crashed" Firefox.
    DrawerPopup {
        id: powerMenu
        anchor { window: bar; rect.x: bar.width; rect.y: bar.height - implicitHeight - Theme.border }   // flush to bar + bottom strip
        boxWidth: actions.implicitWidth + 16
        boxHeight: bar.snapHeight(actions.implicitHeight + 16)

        Column {
            id: actions
            anchors.centerIn: parent
            Repeater {
                model: [
                    { label: "idle",     icon: 0xF0904, cmd: bar.idleCmd },
                    { label: "logout",   icon: 0xF0343, cmd: "hyprshutdown -t 'Logging out...'" },
                    { label: "shutdown", icon: 0xF0425, cmd: "hyprshutdown -t 'Shutting down...' --post-cmd 'systemctl poweroff'" }
                ]
                Rectangle {
                    id: row
                    required property var modelData
                    width: 140; height: 28
                    color: rowArea.containsMouse ? "#f0f0f0" : "transparent"
                    Row {
                        anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text {
                            text: bar.glyph(row.modelData.icon)
                            font { family: bar.iconFont; pixelSize: 22 }
                            color: rowArea.containsMouse ? "#0c0c0c" : "#d6d6d6"
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.label
                            font { family: bar.textFont; pixelSize: 15; bold: true }
                            color: rowArea.containsMouse ? "#0c0c0c" : "#d6d6d6"
                        }
                    }
                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerMenu.open = false;
                            Quickshell.execDetached(["sh", "-c", row.modelData.cmd]);
                        }
                    }
                }
            }
        }
    }
}
