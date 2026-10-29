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
		if ((statusModel)) {
			statusModel.clear()
			timeModel.clear()
			for (var i in app.description) {			    
				var shortDescription = app.description[i].substring(0, 55);
				statusModel.append({status: shortDescription, txtcolor: app.txtcolors[i], service: app.services[i] || ""});
				timeModel.append({time: app.pubDateFull[i], txtcolor: app.txtcolors[i]});
			}
		}
	}
	
	ListModel {
        id: timeModel
    }

    ListModel {
        id: statusModel
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


    GridView {
        id: timeListView
        model: timeModel
        delegate: Text {
                id: mytext1
                text: time
                color: txtcolor
                font {
                    family: qfont.semiBold.name
                    pixelSize:  isNxt? 25:20
                }
            }
        flow: GridView.BottomToTop
        cellWidth: isNxt?  parent.width-20:  parent.width-16
        cellHeight: isNxt? 30:24
        height : parent.height
        width :  isNxt? 140:110
        anchors {
            top: woonplaatsText.bottom
            left: parent.left
            leftMargin:  isNxt? 50:40
            topMargin: isNxt? 20:16
        }
        visible: (!setupText.visible && !waitText.visible)
    }


    GridView {
        id: statusListView
        model: statusModel
        delegate: Row {
                spacing: isNxt? 10:8
                ServiceIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    service: model.service
                    dimState: screenStateController.dimmedColors
                }
                Text {
                    id: mytext2
                    text: status
                    color: dimState? "white" : "grey" 
                    font {
                        family: qfont.semiBold.name
                        pixelSize:  isNxt? 25:20
                    }
                }
            }
        flow: GridView.BottomToTop
        cellWidth: isNxt?  parent.width-20:  parent.width-16
        cellHeight: isNxt? 30:24
        height : parent.height
        width :  isNxt? parent.width-170:parent.width-135
        anchors {
            top: timeListView.top
            left: timeListView.right
            leftMargin:  isNxt? 25:20
        }
       visible: (!setupText.visible && !waitText.visible)
    }	
	
}




