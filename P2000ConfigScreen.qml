import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: p2000ConfigScreen
	screenTitle: "P2000 App Setup"
	property string tempWoonplaats: app.woonplaats
	
	property var placenames : []
	property var cityURLs : []

    property int bw : isNxt? 70:56
    property int bh : isNxt? 35:28
	property string tempUrl : app.url
	
	property bool tempNotifications : app.enableNotifications
	property var tempLocations : []
	property bool firstShown: true  // closing the keyboard shows the screen again: keep the unsaved list
	property string searchStatus: ""
	property int searchCount: 0     // only the latest search may fill the list

	onShown: {
		addCustomTopRightButton("Opslaan")
		if (firstShown) {
			tempLocations = app.locations.slice(0)
			tempNotifications = app.enableNotifications
			notificationModeToggle.isSwitchedOn = tempNotifications;
			var last = tempLocations.length > 0 ? tempLocations[tempLocations.length - 1].name : ""
			woonplaatsEdit.inputText = last
			getPlaces2(last)
			firstShown = false
		}
	}

	onCustomButtonClicked: {
		app.setLocations(tempLocations)
		app.enableNotifications = tempNotifications
		app.saveSettings()
		firstShown = true
		hide()
	}

	function saveWoonplaats(plaats,plaatsURL) {
		if (!plaats) return;
		if (app.debugOutput) console.log("*********P2000 plaats: " + plaats)
		var newUrl = replaceString("https://alarmeringen.nl/feeds/city/" + plaatsURL + ".rss", " ", "-")
		if (app.debugOutput) console.log("*********P2000 tempUrl: " + newUrl)
		var list = tempLocations.slice(0)
		for (var i = 0; i < list.length; i++) {
			if (list[i].url === newUrl) return;   // already chosen
		}
		if (list.length >= app.maxLocations) return;
		list.push({name: plaats, url: newUrl})
		tempLocations = list
	}

	function removeWoonplaats(index) {
		var list = tempLocations.slice(0)
		list.splice(index, 1)
		tempLocations = list
	}
	
	function updateList(){
        if (app.debugOutput) console.log("*********P2000 updateListToon1")
        if (placesModel){
			placesModel.clear()
			for (var i in placenames) {
				placesModel.append({place: placenames[i]});
			}
		}
    }
	
	Text {
		id: instelText
		text:  "Instellingen"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: 20
			topMargin:isNxt? 16:12
		}
	}
	
	Text {
		id: infoText
		text:  "kijk op https://alarmeringen.nl/plaatsen.html voor de juiste spelling van de plaatsnaam."
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left:instelText.left
			top: instelText.bottom
			topMargin:isNxt? 16:12
		}
	}
	
	Text {
		id: infoText2
		text:  "Zoek een plaats, kies hem in de lijst en druk op Voeg toe (maximaal " + app.maxLocations + " plaatsen): "
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			top: infoText.bottom
			left:instelText.left
			topMargin:isNxt? 10:8
		}
	}
	
	EditTextLabel4421 { 
		id: woonplaatsEdit
		width: (parent.width*0.4) - 40		
		height: 30
		inputText:""
		leftTextAvailableWidth: 100
		leftText: "Plaats: "
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left:instelText.left
			top: infoText2.bottom
			topMargin:isNxt? 16:12
		}
		onClicked: {
			qkeyboard.open(woonplaatsEdit.leftText, woonplaatsEdit.inputText, getPlaces2)
		}
	}
	
	Text {
		id: notificationMode
		text: "Schermnotificatie bij nieuwe melding: "
		font.pixelSize:  isNxt ? 18:14
		font.family: qfont.semiBold.name

		anchors {
			left: upButton.right
			top: woonplaatsEdit.top
			leftMargin: isNxt ? 18:14
		}
	}

	OnOffToggle {
		id: notificationModeToggle
		height:  30
		
		anchors {
			left: notificationMode.right
			top: notificationMode.top
			leftMargin: isNxt ? 18:14
		}
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tempNotifications = true;
			} else {
				tempNotifications = false;
			}
		}
	}

	
	Rectangle{
        id: listviewContainer1
        width: isNxt ? 400 : 320
		height: isNxt? 200:160
        color: "white"
        radius: isNxt ? 5 : 4
        border.color: "black"
        border.width: isNxt ? 3 : 2
        anchors {
            top:		woonplaatsEdit.bottom
            topMargin: 	isNxt? 20:16
            left:   	instelText.left
        }

        Component {
            id: aniDelegate
            Item {
                width: isNxt ? (listview1.width-20) : (listview1.width-16)
                height: isNxt ? 22 : 18
                Text {
                    id: tst
                    text: place
                    font.pixelSize: isNxt ? 18:14
                }
            }
        }

        ListModel {
                id: placesModel
        }

        ListView {
            id: listview1
            anchors {
                top: parent.top
                topMargin:isNxt ? 20 : 16
                leftMargin: isNxt ? 12 : 9
                left: parent.left
            }
            width: parent.width
            height: isNxt ? (parent.height-50) : (parent.height-40)
            model:placesModel
            delegate: aniDelegate
            highlight: Rectangle {
                color: "lightsteelblue";
                radius: isNxt ? 5 : 4
            }
            focus: true
        }

        Text {
            anchors.centerIn: parent
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: searchStatus
            font.family: qfont.semiBold.name
            font.pixelSize: isNxt ? 18:14
            color: "grey"
            visible: searchStatus !== ""
        }
    }
	
	IconButton {
		id: upButton
		anchors {
			top: listviewContainer1.top
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/up.png"
		onClicked: {
			if (listview1.currentIndex>0){
				listview1.currentIndex  = listview1.currentIndex -1
			}
		}	
	}
	

	IconButton {
		id: downButton
		anchors {
			bottom: listviewContainer1.bottom
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2

		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
			listview1.currentIndex  = listview1.currentIndex +1
		}

	}

	NewTextLabel {
		id: selText
		width: listviewContainer1.width 
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  tempLocations.length >= app.maxLocations ? "Maximaal " + app.maxLocations + " plaatsen" : "Voeg toe"
		anchors {
			top: listviewContainer1.bottom
			left: instelText.left
			topMargin: isNxt? 5: 4
			}
		onClicked: {
			saveWoonplaats(placenames[listview1.currentIndex],cityURLs[listview1.currentIndex])
		}
	}

	Text {
		id: chosenText
		text: tempLocations.length > 0 ? "Gekozen plaatsen:" : "Nog geen plaats gekozen"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			top: listviewContainer1.top
			left: notificationMode.left
		}
	}

	Column {
		id: chosenList
		spacing: isNxt ? 6 : 5
		anchors {
			top: chosenText.bottom
			topMargin: isNxt ? 10 : 8
			left: notificationMode.left
		}

		Repeater {
			model: tempLocations.length

			Row {
				spacing: isNxt ? 12 : 10

				NewTextLabel {
					width: isNxt ? 120 : 96
					height: isNxt ? 32 : 26
					buttonActiveColor: "lightgrey"
					buttonHoverColor: "blue"
					enabled : true
					textColor : "black"
					buttonText: "Verwijder"
					onClicked: removeWoonplaats(index)
				}

				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: tempLocations[index] ? tempLocations[index].name : ""
					font.family: qfont.semiBold.name
					font.pixelSize: isNxt ? 18:14
				}
			}
		}
	}


    function  replaceString(inputstring, pattern, nw) {
       var curidx = 0 ;
       var patlen = pattern.length;
       var res = "";
       while(curidx !== -1) {
           curidx = inputstring.indexOf(pattern, curidx);
           if (app.debugOutput) console.log("*********P2000 curidx: " + curidx);
           if(curidx === -1) {
               break;
           }
           var end = curidx + patlen;
           var firststring = inputstring.substring(0, curidx);
           var endstring =  inputstring.substring(curidx + patlen, inputstring.length);
           inputstring = firststring + nw + endstring;
        }
        return inputstring;
    }
	
	
    function getPlaces2(plaats){

		placenames.splice(0, placenames.length);
		cityURLs.splice(0, cityURLs.length);
		updateList()
		searchStatus = ""
		woonplaatsEdit.inputText = plaats
		searchCount++
		var search = searchCount
		if (!plaats) return;

        if (app.debugOutput) console.log("*********P2000: Start getPlaces")
        var http = new XMLHttpRequest()
		http.open("GET", "https://alarmeringen.nl/city_autocomplete/?q=" + plaats, true);
		if (app.debugOutput) console.log("*********P2000: URL: " + "https://alarmeringen.nl/city_autocomplete/?q=" + plaats)
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (search !== searchCount) return;
			if (http.readyState === 4) {
				if (http.status === 200) {
					if (app.debugOutput) console.log("*********P2000: responseText: " +http.responseText)
					var JsonString = http.responseText
					var JsonObject
					try {
						JsonObject = JSON.parse(JsonString)
					} catch(e) {
						// alarmeringen.nl sends browsers (the Toon too) to a cookie consent page instead of the
						// search; its RSS feeds are not behind it: try the feed of the name as typed
						if (app.debugOutput) console.log("*********P2000: search unavailable, trying the feed")
						getPlaceFromFeed(plaats)
						return
					}
					if (JsonObject.length === 0) searchStatus = "Geen plaats gevonden"
					for(var x = 0;x < JsonObject.length;x++){
						placenames.push(JsonObject[x].value)
						if (app.debugOutput) console.log("*********P2000 pushing to placenames: " + JsonObject[x].value)
						var einde = JsonObject[x].url.length -2
						var begin = JsonObject[x].url.lastIndexOf("/", einde) + 1
						cityURLs.push(JsonObject[x].url.substring(begin, (JsonObject[x].url.length -1)))
						if (app.debugOutput) console.log("*********P2000 pushing to cityURLs: " + JsonObject[x].url.substring(begin, JsonObject[x].url.length -1))
					}
					updateList()
				} else {
					if (app.debugOutput) console.log("*********P2000 http.status: " + http.status)
					getPlaceFromFeed(plaats)
				}
			}
		}
		http.send();
    }

	function getPlaceFromFeed(plaats) {
		// the feed's address is the place name in lower case with '-' (Den Haag: den-haag); its channel
		// description has the name as alarmeringen.nl writes it
		var slug = plaats.toLowerCase().replace(/^'/, "").replace(/[^a-z0-9à-ÿ]+/g, "-").replace(/^-+|-+$/g, "")
		if (!slug) return;
		searchStatus = "Zoeken..."
		var search = searchCount
		var http = new XMLHttpRequest()
		http.open("GET", "https://alarmeringen.nl/feeds/city/" + slug + ".rss", true);
		http.onreadystatechange = function() {
			if (http.readyState !== 4 || search !== searchCount) return;
			var m = (http.status === 200) ? http.responseText.match(/Alle alarmeringen voor: ([^<]+)</) : null
			if (!m) {
				searchStatus = "Plaats niet gevonden, controleer de spelling"
				return
			}
			placenames.splice(0, placenames.length);
			cityURLs.splice(0, cityURLs.length);
			placenames.push(m[1])
			cityURLs.push(slug)
			searchStatus = ""
			updateList()
		}
		http.send();
	}

}




