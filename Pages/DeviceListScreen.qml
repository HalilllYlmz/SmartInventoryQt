import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
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
            var statusMatch = (statusFilter === "Tümü") || (device.status === statusFilter)
            return (nameMatch || serialMatch) && statusMatch
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
        id: mainContent
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        layer.enabled: addDeviceDialog.opened
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            saturation: 0.5
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Cihaz Listesi"
                font.bold: true
                font.pixelSize: 26
                color: "#2c3e50"
                Layout.fillWidth: true
            }

            Button {
                text: "+ Yeni Cihaz"
                font.bold: true
                // Buton Tasarımı
                background: Rectangle {
                    color: parent.down ? "#2980b9" : "#3498db"
                    radius: 12
                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowOpacity: 0.2; shadowVerticalOffset: 3 }
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: addDeviceDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TextField {
                id: searchField
                placeholderText: "🔍 Cihaz ara..."
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15
                background: Rectangle {
                    color: "white"
                    border.color: parent.activeFocus ? "#3498db" : "#dfe6e9"
                    border.width: parent.activeFocus ? 2 : 1
                    radius: 12
                }
                onTextChanged: applyFilter()
            }

            ComboBox {
                id: statusComboBox
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48
                model: ["Tümü", "Aktif", "Pasif", "Bakımda", "Arızalı"]
                onCurrentTextChanged: applyFilter()
                background: Rectangle {
                    color: "white"
                    border.color: "#dfe6e9"
                    radius: 12
                }
            }

            Button {
                id: sortButton
                checkable: true
                checked: true
                text: checked ? "A ⬇" : "Z ⬆"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 48
                background: Rectangle {
                    color: "white"
                    border.color: "#dfe6e9"
                    radius: 12
                }
                onClicked: applyFilter()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: deviceModel
            spacing: 12

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

                onEditClicked: {
                    var itemData = {
                        "id": model.id || model.Id,
                        "deviceName": model.deviceName || model.DeviceName,
                        "serialNumber": model.serialNumber || model.SerialNumber,
                        "status": model.status || model.Status,
                        "maintenanceDate": model.lastMaintenanceDate
                    }

                    addDeviceDialog.openForEdit(itemData)
                }
                onDeleteClicked: {
                    var deleteId = model.id || model.Id
                    Api.deleteDevice(deleteId, function() { refreshList() })
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: addDeviceDialog.opened ? 0.5 : 0.0

        Behavior on opacity { NumberAnimation { duration: 250 } }

        MouseArea {
            anchors.fill: parent
            enabled: addDeviceDialog.opened
        }
    }
    AddDeviceDialog {
        id: addDeviceDialog
        anchors.centerIn: parent
        dim: false

        onDeviceAdded: {
            rootItem.refreshList()
        }
        onDeviceUpdated: {
            rootItem.refreshList()
        }
    }
}
