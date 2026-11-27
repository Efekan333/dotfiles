// `cal`-style month grid. Today = inverted. Monday first.
import QtQuick

Column {
    id: root
    property date date: new Date()
    property string font: Theme.font
    spacing: 6

    readonly property int year: date.getFullYear()
    readonly property int month: date.getMonth()
    // offset of the 1st (Mon=0) and days in month (day 0 of next month = last day of this one)
    readonly property int lead: (new Date(year, month, 1).getDay() + 6) % 7
    readonly property int days: new Date(year, month + 1, 0).getDate()

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(root.date, "MMMM yyyy")
        font { family: root.font; pixelSize: 15; bold: true }
        color: "#f0f0f0"
    }

    Grid {
        columns: 7
        spacing: 2
        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            Text {
                required property string modelData
                width: 26; horizontalAlignment: Text.AlignHCenter
                text: modelData
                font { family: root.font; pixelSize: 13; bold: true }
                color: "#a8a8a8"
            }
        }
        Repeater {
            model: 42                                  // 6 weeks always → popup never changes height
            Rectangle {
                required property int index
                readonly property int day: index - root.lead + 1
                readonly property bool valid: day >= 1 && day <= root.days
                readonly property bool today: valid && day === root.date.getDate()
                width: 26; height: 22
                color: today ? "#f0f0f0" : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: parent.valid ? parent.day : ""
                    font { family: root.font; pixelSize: 14; bold: true }
                    color: parent.today ? "#0c0c0c" : "#d6d6d6"
                }
            }
        }
    }
}
