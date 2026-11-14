import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: p2000Screen
	screenTitle: "P2000 App"
	property bool waiting:true

	onShown: {    
		addCustomTopRightButton("Instellingen")
    	}
	
	onCustomButtonClicked: {
		if (app.p2000ConfigScreen) app.p2000ConfigScreen.firstShown = true   // start from the saved places
		stage.openFullscreen(app.p2000ConfigScreenUrl)
	}
	
	Component.onCompleted: {
		app.p2000Updated.connect(updateP2000List);
	}
	
	function updateP2000List() {
		if (app.description.length>0){waiting=false}else{waiting=true}
		if ((meldingModel)) {
			meldingModel.clear()
			for (var i in app.description) {
				meldingModel.append({time: app.pubDateFull[i], txtcolor: app.txtcolors[i], service: app.services[i] || "",
				                     status: app.description[i]});
			}
		}
	}

	ListModel {
		id: meldingModel
	}

	Text{
		id: woonplaatsText
		text: app.woonplaats
		font.pixelSize: isNxt? 25:20
		font.family:  qfont.bold.name
		anchors {
            	top: parent.top
				topMargin: isNxt? 20:16
				left: parent.left
				leftMargin:  isNxt? 50:40
        }
		color: dimState? "white" : "grey" 
		visible: (app.woonplaats != "xxxxxxxxxxx")? true: false
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


	// one list, one row per melding (time, service, text), that does not scroll: the 14 meldingen fit,
	// and time and text can no longer slide apart
	ListView {
		id: meldingListView
		model: meldingModel
		interactive: false
		height: count * (isNxt? 30:24)
		anchors {
			top: woonplaatsText.bottom
			left: parent.left
			right: parent.right
			leftMargin:  isNxt? 50:40
			rightMargin: isNxt? 20:16
			topMargin: isNxt? 20:16
		}
		visible: (!setupText.visible && !waitText.visible)

		delegate: Row {
			width: meldingListView.width
			height: isNxt? 30:24
			spacing: isNxt? 10:8

			Text {
				id: timeText
				width: isNxt? 155:122
				anchors.verticalCenter: parent.verticalCenter
				text: model.time
				color: model.txtcolor
				font {
					family: qfont.semiBold.name
					pixelSize:  isNxt? 25:20
				}
			}
			ServiceIcon {
				id: icon
				anchors.verticalCenter: parent.verticalCenter
				service: model.service
				dimState: screenStateController.dimmedColors
			}
			Text {
				anchors.verticalCenter: parent.verticalCenter
				width: parent.width - timeText.width - icon.width - 2 * parent.spacing
				elide: Text.ElideRight
				text: model.status
				color: dimState? "white" : "grey"
				font {
					family: qfont.semiBold.name
					pixelSize:  isNxt? 25:20
				}
			}
		}
	}
}
