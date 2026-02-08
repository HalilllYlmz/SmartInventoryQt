import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Scripts/DeviceApi.js" as Api
import "../Components"

Item {
    id: rootItem

    property var allDevices: []

    ListModel { id: deviceModel }

    Component.onCompleted: refreshList()

    function refreshList() {
        Api.getDevices(function(devices) {
            if (devices) {
                rootItem.allDevices = devices
                applyFilter()
            }
        })
    }


    function applyFilter() {
        deviceModel.clear()

        var searchTerm = searchField.text.toLowerCase()
        var statusFilter = statusComboBox.currentText

        var sortAscending = sortButton.checked

        var filteredList = rootItem.allDevices.filter(function(device) {
            var nameMatch = (device.deviceName || "").toLowerCase().includes(searchTerm)
            var serialMatch = (device.serialNumber || "").toLowerCase().includes(searchTerm)
            var searchMatch = nameMatch || serialMatch

            var statusMatch = (statusFilter === "Tümü") || (device.status === statusFilter)

            return searchMatch && statusMatch
        })

        filteredList.sort(function(a, b) {
            var nameA = (a.deviceName || "").toLowerCase()
            var nameB = (b.deviceName || "").toLowerCase()
            if (nameA < nameB) return sortAscending ? -1 : 1
            if (nameA > nameB) return sortAscending ? 1 : -1
            return 0
        })

        for (var i = 0; i < filteredList.length; i++) {
            deviceModel.append(filteredList[i])
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Cihaz Listesi"
                font.bold: true
                font.pixelSize: 24
                color: "#2c3e50"
                Layout.fillWidth: true
            }

            Button {
                text: "+ Yeni Cihaz"
                font.bold: true
                palette.button: "#3498db"
                palette.buttonText: "white"

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? "#2980b9" : "#3498db"
                    radius: 8
                }

                onClicked: {
                    // TODO
                }
            }
        }


        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: searchField
                placeholderText: "🔍 Cihaz ara..."
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                verticalAlignment: Text.AlignVCenter

                leftPadding: 15
                rightPadding: 15


                background: Rectangle {
                    color: "white"
                    border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                    radius: 8
                }

                onTextChanged: applyFilter()
            }

            ComboBox {
                id: statusComboBox
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                model: ["Tümü", "Aktif", "Pasif", "Bakımda", "Arızalı"]

                onCurrentTextChanged: applyFilter()

                background: Rectangle {
                    color: "white"
                    border.color: "#bdc3c7"
                    radius: 8
                }
            }

            Button {
                id: sortButton
                checkable: true
                checked: true
                text: checked ? "A ⬇" : "Z ⬆"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: "white"
                    border.color: "#bdc3c7"
                    radius: 8
                }

                onClicked: applyFilter()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: deviceModel
            spacing: 10

            Text {
                anchors.centerIn: parent
                text: "Kriterlere uygun cihaz bulunamadı."
                visible: deviceModel.count === 0
                color: "gray"
                font.pixelSize: 16
            }

            ScrollBar.vertical: ScrollBar { }

            delegate: DeviceListItem {
                width: ListView.view.width

                deviceName: model.deviceName || model.DeviceName
                serialNumber: model.serialNumber || model.SerialNumber
                status: model.status || model.Status
                maintenanceDate: model.lastMaintenanceDate

                onEditClicked: console.log("Güncelle:", model.id || model.Id)

                onDeleteClicked: {
                    var deleteId = model.id || model.Id
                    Api.deleteDevice(deleteId, function() {
                        refreshList()
                    })
                }
            }
        }
    }
}
