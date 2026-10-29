//the service of a melding: B (brandweer), A (ambulance), H (traumaheli), P (politie), or a grey square when it is not clear
import QtQuick 2.1

Rectangle {
	id: serviceIcon
	property string service: ""
	property bool dimState: false

	property string fillColor: service === "brandweer" ? "#d7191c" : service === "ambulance" ? "#f2c200" : service === "traumaheli" ? "#e8590c" : service === "politie" ? "#1f4e9c" : "#b0b0b0"

	width: isNxt ? 20 : 16
	height: width
	radius: isNxt ? 4 : 3
	color: dimState ? "transparent" : fillColor
	border.color: dimState ? "white" : fillColor
	border.width: 1

	Text {
		anchors.centerIn: parent
		text: serviceIcon.service === "brandweer" ? "B" : serviceIcon.service === "ambulance" ? "A" : serviceIcon.service === "traumaheli" ? "H" : serviceIcon.service === "politie" ? "P" : ""
		color: (serviceIcon.dimState || serviceIcon.service !== "ambulance") ? "white" : "black"
		font.pixelSize: isNxt ? 14 : 11
		font.family: qfont.bold.name
	}
}
