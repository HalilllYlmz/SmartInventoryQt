import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "DeviceApi.js" as Api

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    property int selectedDeviceId: -1

    ListModel {
        id: deviceModel
    }

    Component.onCompleted: refreshList()

    function refreshList() {
        Api.getDevices(function(devices) {
            deviceModel.clear()
            for (var i = 0; i < devices.length; i++) {
                deviceModel.append(devices[i])
            }
        })
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        GroupBox {
            title: "Cihaz Bilgileri"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                TextField {
                    id: txtName
                    placeholderText: "Device Name"
                    Layout.fillWidth: true
                }
                TextField {
                    id: txtSerial
                    placeholderText: "Serial Number"
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: cmbStatus
                    Layout.fillWidth: true
                    model: ["Aktif", "Pasif", "Bakımda", "Arızalı"]
                }

                RowLayout {
                    Layout.fillWidth: true

                    // EKLE BUTONU
                    Button {
                        text: "Ekle (POST)"
                        Layout.fillWidth: true
                        highlighted: true
                        onClicked: {
                            var newDevice = {
                                "deviceName": txtName.text,
                                "serialNumber": txtSerial.text,
                                "status": cmbStatus.currentText,
                                "lastMaintenanceDate": new Date().toISOString() // Şimdilik bugünün tarihi
                            }

                            Api.addDevice(newDevice, function() {
                                clearInputs()
                                refreshList()
                            })
                        }
                    }

                    // GÜNCELLE BUTONU
                    Button {
                        text: "Güncelle (PUT)"
                        Layout.fillWidth: true
                        enabled: selectedDeviceId !== -1 // Bir şey seçiliyse aktif olsun
                        onClicked: {
                            var updatedDevice = {
                                "id": selectedDeviceId,
                                "deviceName": txtName.text,
                                "serialNumber": txtSerial.text,
                                "status": cmbStatus.currentText,
                                "lastMaintenanceDate": new Date().toISOString()
                            }

                            Api.updateDevice(selectedDeviceId, updatedDevice, function() {
                                clearInputs()
                                refreshList()
                            })
                        }
                    }
                }
                Button {
                    text: "Seçimi Temizle"
                    visible: selectedDeviceId !== -1
                    onClicked: clearInputs()
                }
            }

        }

        Text { text: "Cihaz Listesi"; font.bold: true; font.pixelSize: 16 }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: deviceModel
            clip: true
            spacing: 5

            delegate: Rectangle {
                width: parent.width
                height: 60
                color: (model.id === selectedDeviceId) ? "#d5f5e3" : "#f2f3f4" // Seçiliyse yeşilimsi yap
                radius: 5
                border.color: "#bdc3c7"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Listeden bir öğeye tıklayınca bilgileri inputlara doldur
                        selectedDeviceId = model.id
                        txtName.text = model.deviceName
                        txtSerial.text = model.serialNumber
                        cmbStatus.currentIndex = cmbStatus.indexOfValue(model.status)
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Column {
                        Layout.fillWidth: true
                        Text { text: model.deviceName; font.bold: true }
                        Text { text: model.serialNumber + " | " + model.status; font.pixelSize: 12 }
                    }

                    // SİL BUTONU
                    Button {
                        text: "Sil"
                        onClicked: {
                            Api.deleteDevice(model.id, function() {
                                if(selectedDeviceId === model.id) clearInputs()
                                refreshList()
                            })
                        }
                    }
                }
            }
        }
    }

    function clearInputs() {
        selectedDeviceId = -1
        txtName.text = ""
        txtSerial.text = ""
        cmbStatus.currentIndex = 0
    }

}
