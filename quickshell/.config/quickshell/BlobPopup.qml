// Popup that "blobs" out of the item that opened it (macOS-ish): scale 0.1 → 1 with overshoot.
// The compositor owns surface geometry, so the wl_surface stays full size + transparent;
// only the inner `box` is scaled, with the transform origin placed on the source item's centre.
// Closing animates first and unmaps (visible = false) only when the animation is done.
import Quickshell
import Quickshell.Hyprland
import QtQuick

PopupWindow {
    id: root
    required property Item source            // item the popup grows out of (e.g. the bar icon)
    property bool open: false                // drive this, never `visible`
    default property alias content: box.data
    property real progress: 0                // 0 = collapsed into the icon, 1 = full size

    visible: false
    color: "transparent"

    onOpenChanged: {
        if (open) {
            // mapToItem is a one-shot, not a binding → compute the origin at open time.
            // null = scene coords = coords of the bar window, the same space anchor.rect lives in.
            const p = source.mapToItem(null, source.width / 2, source.height / 2);
            grow.origin.x = p.x - anchor.rect.x;
            grow.origin.y = p.y - anchor.rect.y;
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
        duration: 260
        easing { type: Easing.OutBack; overshoot: 1.4 }   // the "blop": goes ~5 % past 1, settles back
    }
    NumberAnimation {
        id: closeAnim
        target: root; property: "progress"; to: 0
        duration: 140
        easing.type: Easing.InCubic                       // no bounce on close, bouncing out reads as lag
        onFinished: root.visible = false
    }

    // click outside → close (compositor tells us when the grab is cleared)
    HyprlandFocusGrab {
        windows: [root]
        active: root.open
        onCleared: root.open = false
    }

    Rectangle {
        id: box
        anchors.fill: parent
        color: "#0c0c0c"
        border { width: 1; color: "#d6d6d6" }
        opacity: Math.min(1, root.progress * 2)           // fade in over the first half
        transform: Scale {
            id: grow
            xScale: 0.1 + 0.9 * root.progress
            yScale: 0.1 + 0.9 * root.progress
        }
    }
}
