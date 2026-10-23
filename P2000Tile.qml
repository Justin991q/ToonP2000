import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0
import qb.components 1.0

Tile {
	id: p2000Tile
	property bool waiting:true
	property bool dimState: screenStateController.dimmedColors
	onClicked: {
		stage.openFullscreen(app.p2000ScreenUrl)
	}

	Component.onCompleted: {
		app.p2000Updated.connect(updateP2000List);
		updateP2000List();
	}

	Component.onDestruction: app.p2000Updated.disconnect(updateP2000List)
	
		
    function updateP2000List() {
        if (app.description.length>0){waiting=false}else{waiting=true}
        if (app.description[0]){
		    var shortDescription0 = app.description[0].substring(0, 55);
            eventText0.text= shortDescription0
            timeText0.text = app.pubDate[0]
        }
        if (app.description[1]){
		    var shortDescription1 = app.description[1].substring(0, 55);
            eventText1.text= shortDescription1
            timeText1.text=  app.pubDate[1]
        }
        if (app.description[2]){
		    var shortDescription2 = app.description[2].substring(0, 55);
            eventText2.text= shortDescription2
            timeText2.text=  app.pubDate[2]
        }
		
		
    }

    Text{
        id: waitText
        text: "Wacht op meldingen"
        font.pixelSize: isNxt? 25:20
        font.family:  qfont.bold.name
        anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
        }
        color: dimState? "white" : "grey"
        visible: (waiting & app.woonplaats != "xxxxxxxxxxx")? true: false
    }
	
	Text{
		id: setupText
		text: "Selecteer een plaats" 
		font.pixelSize: isNxt? 25:20
		font.family:  qfont.bold.name
		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
        }
		color: dimState? "white" : "grey" 
		visible: (app.woonplaats != "xxxxxxxxxxx")? false: true
	}
	
	Text{
		id: p2000Text
		text: "P2000" 
		font.pixelSize: isNxt? 25:20
		font.family:  qfont.bold.name
		anchors {
			bottom: setupText.top
			bottomMargin: isNxt? 16:12
			horizontalCenter: parent.horizontalCenter
        }
		color: dimState? "white" : "grey" 
		visible: (setupText.visible || waitText.visible)
	}	

	Text{
		id: wpText
		text: "P2000 - " + app.woonplaats
		wrapMode: Text.WordWrap
		width : isNxt? parent.width - 24 : parent.width - 18
		font.pixelSize: isNxt? 16:12
		font.family:  qfont.bold.name
		anchors {
		    top: parent.top
			left: parent.left
            leftMargin:  isNxt? 12:9
            topMargin: isNxt? 6:5
        }
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		visible: (!setupText.visible && !waitText.visible)
	}
	

    Grid {
		id: gridContainer1
		columns: 2
		spacing: isNxt? 7:5
		rowSpacing: 2
		height : isNxt? parent.height  - 100: parent.height  - 16
		width :   parent.width
		anchors {
			top: wpText.bottom
			left: parent.left
			leftMargin:  isNxt? 12:9
			topMargin: isNxt? 6:5
		}
		Text {id: timeText0;width:40; font.pixelSize: isNxt? 16:12;font.family: qfont.regular.name; color: dimState?  "white" : "black"}
		Text {id: eventText0;wrapMode: Text.WordWrap;width:parent.width - 57;font.pixelSize: isNxt? 16:12;font.family: qfont.regular.name;color: dimState?  "white" : "black"}
		Text {id: timeText1;width: 40;font.pixelSize: isNxt? 16:12;font.family:  qfont.regular.name; color: dimState?  "white" : "black"}
		Text {id: eventText1; wrapMode: Text.WordWrap;width:parent.width - 57;font.pixelSize: isNxt? 16:12;font.family: qfont.regular.name;color: dimState?  "white" : "black"}
		Text {id: timeText2;width:40; font.pixelSize: isNxt? 16:12;font.family: qfont.regular.name; color: dimState?  "white" : "black"}
		Text {id: eventText2; wrapMode: Text.WordWrap;width:parent.width - 57;font.pixelSize: isNxt? 16:12;font.family: qfont.regular.name;color: dimState?  "white" : "black"}
 }
}
	
