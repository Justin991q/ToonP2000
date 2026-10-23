//Textanimation
import QtQuick 2.1
import FileIO 1.0

Item {
    id: p2000animation
    property bool dimState: screenStateController.dimmedColors
	
	property  string	eventTime : ""
	property  string	eventDescription : ""

	FileIO {
		id: p2000File
		source: "file:///qmf/qml/apps/p2000/event.json"
 	}
	
	property variant newEvent : {
		"eventTime" : "",
		"eventDescription" : ""
	}
	
	Timer { //allow some time for the app to close the file
		id: newTimer
		running: true
		repeat: false
		interval: 300
		onTriggered: {
			newEvent = JSON.parse(p2000File.read())
			eventTime = newEvent['eventTime']	
			eventDescription = newEvent['eventDescription']
		}
	}

    width: isNxt? 500:400
    height: isNxt? 200:160
    x : (parent.width - p2000animation.width)/2
    y : (parent.height- p2000animation.height)/2

    Item {
        id: textPlate
        anchors.centerIn: parent
		height: parent.height
        width: parent.width
        clip: true

		Rectangle {
			id: textPlateImage
			color: "lightgreen"
			anchors.fill: parent 
			radius: 4   
			Text{
				id:text1
				font.pixelSize: isNxt ? 32:24
				font.family: qfont.regular.name
				font.bold: true
				color:  "black" 
				text: eventTime
				anchors {
					top: parent.top
					topMargin: isNxt ?  20:16
					horizontalCenter: parent.horizontalCenter	 		
				}    		
			}
			Text{
				id:text2
				font.pixelSize: isNxt ? 32:24
				font.family: qfont.regular.name
				font.bold: true
				color:  "black" 
				width :   isNxt ? parent.width - 64:parent.width - 48

				wrapMode: Text.WordWrap
				text: eventDescription
				anchors {
					top: text1.bottom
					left: parent.left
					leftMargin: isNxt ? 32:24
				}    		
			}
			
			MouseArea{
				id: buttonMouseArea
				anchors.fill: parent 
				onClicked: {animationscreen.animationRunning= false;p2000animation.destroy();}
			}		
		}
    }
	
	Timer {
		interval: 2500
		running: true
		repeat: true
		onTriggered: {
		if (animationscreen.animationRunning==false) {
					p2000animation.destroy();
				}
	}
}

}