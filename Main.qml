import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "Components"
import "Pages"

Window {
    width: 1024
    height: 600
    visible: true
    title: qsTr("Smart Inventory System")
    color: "#ecf0f1"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#2c3e50"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "SMART\nINVENTORY"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20
                }
                NavButton {
                    text: "Dashboard"
                    icon: "📊"
                    isActive: stackLayout.currentIndex === 0
                    onClicked: stackLayout.currentIndex = 0
                }

                NavButton {
                    text: "Cihaz Listesi"
                    icon: "📱"
                    isActive: stackLayout.currentIndex === 1
                    onClicked: stackLayout.currentIndex = 1
                }

                Item { Layout.fillHeight: true }
            }
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            StackLayout {
                id: stackLayout
                anchors.fill: parent
                currentIndex: 0


                DashboardScreen {

                }

                DeviceListScreen {

                }
            }
        }
    }
}
