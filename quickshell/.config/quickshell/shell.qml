import Quickshell // core
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick   //basic ui elements
import QtQuick.Layouts
import Quickshell.Io

PanelWindow{
	anchors{
	top: true
	bottom: true
	left: true
	right: false
	}
	
	implicitHeight: 30

	Text{
	id: clock

	anchors.centerIn: parent
	text: "Hello bar"


		Process{
		id: dateProc

		command: ["date"]
		running: true

		stdout: StdioCollector{
			onStreamFinished: clock.text = this.text
		}

		}

		Timer{ //reruns the Proccess object (the id dateProc) 
		interval: 1000
		running: true //starts timer immeadil
		repeat: true

		onTriggered: dateProc.running = true
		}


	}




}
