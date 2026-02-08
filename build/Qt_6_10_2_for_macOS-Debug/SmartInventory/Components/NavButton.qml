import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control

    property string text: "Button"
    property string icon: ""
    property bool isActive: false

    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 60

    color: isActive ? "#1abc9c" : "transparent"

    radius: 5

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        spacing: 15

        Text {
            text: control.icon
            color: control.isActive ? "white" : "#bdc3c7"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: control.text
            color: control.isActive ? "white" : "#bdc3c7"
            font.pixelSize: 18
            font.bold: control.isActive
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

    }

    Rectangle {
        width: 4
        height: parent.height * 0.6
        color: "white"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: control.isActive
        radius: 2
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }

}
