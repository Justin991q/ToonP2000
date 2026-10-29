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
        meldingModel.clear()
        for (var i = 0; i < app.description.length && i < 3; i++) {
            meldingModel.append({time: app.pubDate[i], service: app.services[i] || "",
                                 place: app.meldingPlace[i] || "", text: app.meldingText[i] || ""})
        }
    }

    ListModel {
        id: meldingModel
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
		text: "P2000"
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

	// per melding: time, service, place (grey) and text; what does not fit ends in "..."
	Column {
		id: meldingList
		spacing: isNxt? 6:5
		width: parent.width - 2 * anchors.leftMargin
		anchors {
			top: wpText.bottom
			left: parent.left
			leftMargin:  isNxt? 12:9
			topMargin: isNxt? 6:5
		}
		visible: wpText.visible

		Repeater {
			model: meldingModel

			// several places: the place on the first line, the melding below it over the full width
			Row {
				id: meldingRow
				width: meldingList.width
				spacing: isNxt? 7:5

				Text {
					id: timeText
					width: isNxt? 44:35
					text: model.time
					font.pixelSize: isNxt? 16:12
					font.family: qfont.regular.name
					color: dimState? "white" : "black"
				}
				ServiceIcon {
					id: icon
					y: (timeText.height - height) / 2
					service: model.service
					dimState: p2000Tile.dimState
				}
				Column {
					width: meldingRow.width - timeText.width - icon.width - 2 * meldingRow.spacing

					Text {
						width: parent.width
						visible: model.place !== ""
						elide: Text.ElideRight
						text: model.place
						font.pixelSize: isNxt? 16:12
						font.family: qfont.regular.name
						color: dimState? "#bbbbbb" : "#808080"
					}
					Text {
						width: parent.width
						elide: Text.ElideRight
						text: model.text
						font.pixelSize: isNxt? 16:12
						font.family: qfont.regular.name
						color: dimState? "white" : "black"
					}
				}
			}
		}
	}
}
