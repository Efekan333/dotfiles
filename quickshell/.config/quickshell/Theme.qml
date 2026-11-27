// Shared look values. Singleton → every QML file in this dir can read `Theme.frame` etc.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // Frame = bar + top/right/bottom strips + attached popups, all one fill → they read as one shape.
    // Also hardcoded in wofi/style.css (GTK can't read this) → change both.
    readonly property color frame: "#262626"   // palette `frame`; #3a3a3a too light, #0c0c0c vanished into the wallpaper
    readonly property string font: "Rice Mono"   // fontconfig alias (fonts.conf) → real font chosen there
    readonly property int bar: 40               // left bar width = frame's left side
    readonly property int border: 8            // thickness of the top/right/bottom strips
    readonly property int rounding: 16         // radius of the frame's inner corners (Fillet.qml)
}
