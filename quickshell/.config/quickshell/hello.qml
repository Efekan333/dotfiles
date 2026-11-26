import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow{
	anchors.top: true
	anchors.left: true
	anchors.right: true
	implicitHeight: 30
	color: "#1a1b26"

	RowLayout {
		anchors.fill: parent
		anchors.margins: 8

		Repeater{
			model: 9
			
			Text{
				property var ws: Hyprland.workspaces.values.find(w => w.id === (index + 1))
				property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
				text: index + 1
				color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
				font {pixelSize : 14; bold: true}
				MouseArea{ //makes everything clickable 
					anchors.fill:parent
					onClicked: Hyprland.dispatch("workspace" + (index + 1))
				}
			}

		}
			
		Item {Layout.fillWidth: true} //shifts all the components to the left so fills the space up


	}




}

//this allows to give colors a name and allows them to be referenceed everywhere by rooy.colCyan for ecample 
PanelWindow {
    	id: root
    	property color colBg: "#1a1b26"
    	property color colFg: "#a9b1d6"
    	property color colMuted: "#444b6a"
    	property color colCyan: "#0db9d7"
    	property color colBlue: "#7aa2f7"
    	property color colYellow: "#e0af68"
    	property string fontFamily: "JetBrainsMono Nerd Font"
    	property int fontSize: 14
}









