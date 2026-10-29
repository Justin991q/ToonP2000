import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: p2000SystrayIcon
	property string objectName: "p2000Tray"

	visible: app.enableSystray
	posIndex: 8500

	onClicked: {
		stage.openFullscreen(app.p2000ScreenUrl);
	}

	Image {
		id: imgP2000
		anchors.centerIn: parent
		source: "drawables/p2000Tray.png"
	}
}
