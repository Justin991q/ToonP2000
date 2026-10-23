//12-2021
//by oepi-loepi


import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

App {
	id: p2000App
	property bool 		debugOutput : false
	property url 		tileUrl : "P2000Tile.qml"

	property url 		thumbnailIcon: "qrc:/tsc/bad_small.png"
	property 		 	P2000Tile p2000Tile

	property			P2000Screen  p2000Screen
	property url 		p2000ScreenUrl : "P2000Screen.qml"
	property			P2000ConfigScreen  p2000ConfigScreen
	property url 		p2000ConfigScreenUrl : "P2000ConfigScreen.qml"
	property string 	url : "https://www.alarmeringen.nl/feeds/all.rss"
	property string 	woonplaats :  "xxxxxxxxxxx"   // the chosen places, ", " between them (for display)
	property var 		locations : [];   // [{name: "Assen", url: "https://alarmeringen.nl/feeds/city/assen.rss"}, ...]
	property int		maxLocations : 5
	property int		fetchGeneration : 0
	property var 		title : [];
	property var 		description : [];
	property var 		seenItems : ({})     // melding (place|guid) -> its time in ms: what was shown before
	property double		newestSeen : 0       // the time of the newest melding seen, ms
	property int		maxNotifyAgeMinutes : 15
	property var 		pubDate : [];
	property var 		pubDateFull : [];
	property var 		txtcolors : [];	
	property int		scrapetime: 60000; //every minute after first fetch
	property int		scrapetime2: 20000;  //first fetch after start
	property bool 		firststime: true;
	property bool 		enableNotifications: true;
	
	property bool 		isInNotificationMode: false
	property bool 		oldanimationRunning: 	false
	property bool 		oldisVisibleinDimState: true
	property int 		oldanimationInterval : 	1000
	
	property string 	oldqmlAnimationURL :  	""
	property string 	oldqmlAnimationText : 	""
	property string 	oldstaticImageT1 : 		""
	property string 	oldstaticImageT2 : 		""
	property string 	oldstaticImageT1dim : 	""
	property string 	oldstaticImageT2dim : 	""
			
	
	property variant p2000SettingsJson : {
		'woonplaats': "",
		'url': "",
		'enableNotifications': ""
	}
	
	FileIO {
		id: p2000SettingsFile
		source: "file:///mnt/data/tsc/p2000_userSettings.json"
	}

	signal p2000Updated()	
	
	function init() {
		registry.registerWidget("screen", p2000ConfigScreenUrl, this, "p2000ConfigScreen")
		registry.registerWidget("screen", p2000ScreenUrl, this, "bitcoinScreen")
		registry.registerWidget("tile", tileUrl, this, "p2000Tile", {thumbLabel: qsTr("P2000"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"})
	}
		
	Component.onCompleted: {
		try {
			p2000SettingsJson = JSON.parse(p2000SettingsFile.read());
			if (p2000SettingsJson['locations']) {
				setLocations(p2000SettingsJson['locations'])
			} else if (p2000SettingsJson['woonplaats'] && p2000SettingsJson['woonplaats'] != "xxxxxxxxxxx") {
				// settings of version 1.0.6 and older: one place
				setLocations([{name: p2000SettingsJson['woonplaats'], url: p2000SettingsJson['url']}])
			}
		} catch(e) {
		}
		try {
			p2000SettingsJson = JSON.parse(p2000SettingsFile.read());
			if (p2000SettingsJson['enableNotifications'] == "No") {
				enableNotifications = false
			} else {
				enableNotifications = true
			}
		} catch(e) {
		}
		scrapetime2 = 1000;
	}
	
	function saveSettings() {
		var tmpNotifications
		if (enableNotifications == true) {
			tmpNotifications = "Yes";
		} else {
			tmpNotifications = "No";
		}

 		var p2000SettingsJson = {
			"url" : url,
			"enableNotifications" : tmpNotifications,
			"woonplaats" : woonplaats,
			"locations" : locations
		}
  		p2000SettingsFile.write(JSON.stringify(p2000SettingsJson))
		title.splice(0, title.length);
		description.splice(0, description.length);
		pubDate.splice(0, pubDate.length);
		pubDateFull.splice(0, pubDateFull.length);
		txtcolors.splice(0, txtcolors.length);
		firststime = true      // the first fetch after this only remembers what is there
		seenItems = {}
		newestSeen = 0
		console.log("P2000 saved")
		p2000Updated()
		console.log("P2000 getting data")
		getP2000Data()
		
	}

	function setLocations(list) {
		locations = list
		var names = []
		for (var i = 0; i < list.length; i++) names.push(list[i].name)
		woonplaats = (names.length > 0) ? names.join(", ") : "xxxxxxxxxxx"
		url = (list.length > 0) ? list[0].url : ""
	}

	function  replaceString(inputstring, pattern, nw) {
	   var curidx = 0 ;
	   var patlen = pattern.length;
	   var res = "";
	   while(curidx != -1) {
		   curidx = inputstring.indexOf(pattern, curidx);
		   if(curidx == -1) {
			   break;
		   }
		   var end = curidx + patlen;
		   var firststring = inputstring.substring(0, curidx);
		   var endstring =  inputstring.substring(curidx + patlen, inputstring.length);
		   inputstring = firststring + nw + endstring;
		}
		return inputstring;
	}
	

    function getP2000Data(){
		scrapetime2 = scrapetime;
		if (locations.length === 0) return;
		// every place's feed; when all have answered, the newest 14 of them together
		fetchGeneration++
		var generation = fetchGeneration
		var pending = locations.length
		var found = []
		var anyOk = false
		for (var i = 0; i < locations.length; i++) {
			getFeed(locations[i], function(items, ok) {
				if (generation !== fetchGeneration) return;   // settings changed meanwhile
				if (ok) anyOk = true
				found = found.concat(items)
				pending--
				if (pending === 0 && anyOk) showItems(found)
			})
		}
	}

	function getFeed(location, onDone) {
		if (debugOutput) console.log("*********P2000: get " + location.url)
		var http = new XMLHttpRequest()
		http.open("GET", location.url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState !== 4) return;
			if (http.status !== 200) {
				if (debugOutput) console.log("*********P2000: " + http.status)
				onDone([], false)
				return
			}
			var result = []
			var items = http.responseText.toString().split("<item>")
			for (var x = 1; x < items.length && x < 15; x++) {
				var item = items[x]
				var tempdescription = item.substring(item.indexOf("<description>") + "<description>".length, item.indexOf("</description>"));
				var tempPubDate = item.substring(item.indexOf("<pubDate>") + "<pubDate>".length, item.indexOf("</pubDate>"))
				var guid = item.match(/<guid[^>]*>([^<]*)<\/guid>/)
				result.push({place: location.name, description: tempdescription, date: new Date(tempPubDate),
					key: location.name + "|" + (guid ? guid[1] : tempPubDate + "|" + tempdescription)})
			}
			onDone(result, true)
		}
		http.send();
	}

	function showItems(found) {
		// newest first; meldingen of the same second (several units for one incident) always in the same order
		found.sort(function(a, b) { return (b.date.getTime() - a.date.getTime()) || (a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)) })
		// a melding is new when it was not seen before, is not older than the newest one seen and is recent:
		// a feed that failed for a minute, or a melding that dropped out of a feed, then notifies nothing
		var now = new Date().getTime()
		var notifyIndex = -1
		for (var n = 0; n < found.length && n < 14; n++) {
			var time = found[n].date.getTime()
			if (!isNaN(time) && !seenItems[found[n].key] && time >= newestSeen && now - time <= maxNotifyAgeMinutes * 60000) {
				notifyIndex = n
				break
			}
		}
		rememberSeen(found)

		title.splice(0, title.length);
		description.splice(0, description.length);
		pubDate.splice(0, pubDate.length);
		pubDateFull.splice(0, pubDateFull.length);
		txtcolors.splice(0, txtcolors.length);

		var severalPlaces = locations.length > 1
		for (var x = 0; x < found.length && x < 14; x++) {
			var tempdescription = found[x].description
			var tempTitle = tempdescription;
			var place = found[x].place

			var lineColor = "black";
			if(tempTitle.toLowerCase().indexOf("ambu")>-1 || tempdescription.toLowerCase().indexOf("ambu")>-1){lineColor = "black";}
			if(tempTitle.toLowerCase().indexOf("politie")>-1 || tempdescription.toLowerCase().indexOf("politie")>-1){lineColor = "blue";}
			if(tempTitle.toLowerCase().indexOf("brandweer ")>-1 || tempdescription.toLowerCase().indexOf("brandweer")>-1){lineColor = "red";}

			tempdescription = replaceString(tempdescription, "Ambulance ", "Ambu ");
			tempdescription = replaceString(tempdescription, "Brandweer ", "Brw ");
			tempdescription = replaceString(tempdescription, "Politie ", "Pol ");
			tempdescription = replaceString(tempdescription, "met spoed", "spoed");
			tempdescription = replaceString(tempdescription, " in " + place , "");
			tempdescription = replaceString(tempdescription, " " + place, " ");
			if (severalPlaces) tempdescription = place + ": " + tempdescription   // which place it was

			if (debugOutput) console.log("*********P2000: " + tempdescription);

			txtcolors.push(lineColor);
			title.push(severalPlaces ? place + ": " + tempTitle : tempTitle);
			description.push(tempdescription);

			var d = found[x].date;
			var month = d.getMonth()+1;
			var day = d.getDate();
			var hour = d.getHours().toString();
			if (hour.length<2){hour = "0" + hour}
			var minutes = d.getMinutes().toString();
			if (minutes.length<2){minutes = "0" + minutes}
			pubDateFull.push(day + "-" + month  + " " + hour + ":" + minutes);

			var todayDate = new Date();
			if (todayDate.getDate() === day && todayDate.getMonth() === d.getMonth()){
				pubDate.push(hour + ":" + minutes);
			}else{
				pubDate.push(day + "-" + month);
			}
		}
		if (notifyIndex >= 0 && !isInNotificationMode && !firststime && enableNotifications) {
			createScreenNotification(pubDate[notifyIndex], title[notifyIndex])
		}
		firststime = false;
		p2000Updated();
	}

	function rememberSeen(found) {
		var seen = seenItems
		for (var i = 0; i < found.length; i++) {
			var time = found[i].date.getTime()
			if (isNaN(time)) continue
			seen[found[i].key] = time
			if (time > newestSeen) newestSeen = time
		}
		for (var key in seen) {
			if (seen[key] < newestSeen - 24 * 3600000) delete seen[key]   // older than the newest: never new again
		}
		seenItems = seen
	}
	
	
    Timer {
		id: scrapeTimer   //delay to hide the new goal screen
		interval: scrapetime2
		repeat: true
		running: true
		triggeredOnStart: false
		onTriggered: {
			getP2000Data()
		}
	}		

	function createScreenNotification(eventTime, eventDescription){
		isInNotificationMode = true
		oldanimationRunning = animationscreen.animationRunning
		oldisVisibleinDimState = animationscreen.isVisibleinDimState
		oldanimationInterval = animationscreen.animationInterval
		oldqmlAnimationURL = animationscreen.qmlAnimationURL
		oldqmlAnimationText = animationscreen.qmlAnimationText
		oldstaticImageT1 = animationscreen.staticImageT1
		oldstaticImageT2 = animationscreen.staticImageT2
		oldstaticImageT1dim = animationscreen.staticImageT1dim
		oldstaticImageT2dim =animationscreen.staticImageT2dim
		
		animationscreen.animationRunning= false
			
		if (debugOutput) console.log("*********P2000 START To Write Notification: " + eventTime +  "-" + eventDescription)
		var setJson = {
			"eventTime" : eventTime,
			"eventDescription" : eventDescription
		}
		var doc = new XMLHttpRequest()
		doc.open("PUT", "file:///qmf/qml/apps/p2000/event.json")
		doc.send(JSON.stringify(setJson))
		smallDelayTimer.running = true	
	}


	Timer {
		id: smallDelayTimer   //delay to show the goal animation screen
		interval: 100
		repeat: false
		running: false
		triggeredOnStart: false
		onTriggered: {
			animationscreen.qmlAnimationURL= "file:///qmf/qml/apps/p2000/P2000Animation.qml"
			animationscreen.animationInterval= 100000
			animationscreen.isVisibleinDimState= true
			if (oldanimationRunning){
				animationscreen.staticImageT1 = oldstaticImageT1
				animationscreen.staticImageT2 = oldstaticImageT2
				animationscreen.staticImageT1dim = oldstaticImageT1dim
				animationscreen.staticImageT2dim = oldstaticImageT2
				
			}else{
				animationscreen.staticImageT1 = ""
				animationscreen.staticImageT2 = ""
				animationscreen.staticImageT1dim = ""
				animationscreen.staticImageT2dim = ""
			}
			animationscreen.animationRunning= true;
			notificationTimer.running = true
			smallDelayTimer.running = false
		}
	}

	Timer {
		id: notificationTimer   //delay to hide the notification
		interval: 10000
		repeat: false
		running: false
		triggeredOnStart: false
		onTriggered: {
			animationscreen.animationRunning= false
			animationscreen.qmlAnimationURL = ""
			smallDelayTimer2.running = true			
			notificationTimer.running = false
		}
	}
	
	Timer {
		id: smallDelayTimer2  //delay to return to the old animation
		interval: 3000
		repeat: false
		running: false
		triggeredOnStart: false
		onTriggered: {
			if (oldanimationRunning){
				animationscreen.isVisibleinDimState = oldisVisibleinDimState
				animationscreen.animationInterval = oldanimationInterval
				animationscreen.qmlAnimationURL = oldqmlAnimationURL
				animationscreen.qmlAnimationText = oldqmlAnimationText
				animationscreen.staticImageT1 = oldstaticImageT1
				animationscreen.staticImageT2 = oldstaticImageT2
				animationscreen.staticImageT1dim = oldstaticImageT1dim
				animationscreen.staticImageT2dim = oldstaticImageT2dim
				animationscreen.animationRunning = true
			}else{
				animationscreen.animationRunning= false
				animationscreen.isVisibleinDimState= false
			}
			isInNotificationMode = false
			smallDelayTimer2.running = false
		}
	}

}