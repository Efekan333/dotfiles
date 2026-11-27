// Popup fused to the frame: anchored flush to the bar's right edge and the bottom strip, same fill, no outline.
// Rounded top-right corner + concave fillets where it meets the bar (top-left) and the bottom strip (bottom-right).
// The fillets sit outside the box → the surface is `rounding` px larger on top and right; the input mask
// keeps clicks to the box only. Callers size the box (boxWidth/boxHeight), not the surface.
// Opens like a drawer: content slides out from behind the bar (clipped), so it looks like the frame grows.
// The wl_surface stays full size (compositor owns geometry); only the inner item moves.
// No overshoot: OutBack would push the box past its slot and open a gap to the bar.
// Closing animates first and unmaps (visible = false) only afterwards.
import Quickshell
import Quickshell.Hyprland
import QtQuick

PopupWindow {
    id: root
    property bool open: false                // drive this, never `visible`
    default property alias content: box.data
    property real progress: 0                // 0 = hidden behind the bar, 1 = fully out
    property real boxWidth
    property real boxHeight

    visible: false
    color: "transparent"
    implicitWidth: boxWidth + Theme.rounding
    implicitHeight: boxHeight + Theme.rounding
    mask: Region { item: box }

    onOpenChanged: {
        if (open) {
            closeAnim.stop();
            visible = true;
            openAnim.start();
        } else {
            openAnim.stop();
            closeAnim.start();
        }
    }

    NumberAnimation {
        id: openAnim
        target: root; property: "progress"; to: 1
        duration: 240
        easing.type: Easing.OutQuint
    }
    NumberAnimation {
        id: closeAnim
        target: root; property: "progress"; to: 0
        duration: 160
        easing.type: Easing.InCubic
        onFinished: root.visible = false
    }

    // click outside → close
    HyprlandFocusGrab {
        windows: [root]
        active: root.open
        onCleared: root.open = false
    }

    Item {
        anchors.fill: parent
        clip: true                           // the part still "inside the bar" is cut off
        Item {                               // box + its fillets slide out together
            width: parent.width; height: parent.height
            x: -width * (1 - root.progress)

            Rectangle {
                id: box
                y: Theme.rounding
                width: root.boxWidth; height: root.boxHeight
                color: Theme.frame
                topRightRadius: Theme.rounding
            }
            Fillet { x: 0; y: 0; rotation: 270 }                                    // bar ↔ box top
            Fillet { x: root.boxWidth; y: parent.height - height; rotation: 270 }   // box right ↔ bottom strip
        }
    }
}
