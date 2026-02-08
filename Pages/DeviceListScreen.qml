import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Scripts/DeviceApi.js" as Api
import "../Components"

Item {
    ListModel { id: deviceModel }

    Component.onCompleted: refreshList()

    function refreshList() {
        console.log("API'den veri çekiliyor...")
        Api.getDevices(function(devices) {
            console.log("Gelen cihaz sayısı:", devices.length)
            if (devices.length > 0) {
                 // Veri yapısını konsolda görmek için:
                console.log("Örnek Veri:", JSON.stringify(devices[0]))
            }

            deviceModel.clear()
            for (var i = 0; i < devices.length; i++) {
                deviceModel.append(devices[i])
            }
        })

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Cihaz Listesi"
            font.bold: true
            font.pixelSize: 24
            color: "#2c3e50"
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: deviceModel
            spacing: 10

            Text {
                anchors.centerIn: parent
                text: "Kayıtlı cihaz bulunamadı."
                visible: deviceModel.count === 0
                color: "gray"
                font.pixelSize: 16
            }

            ScrollBar.vertical: ScrollBar { }

            delegate: DeviceListItem {
                width: ListView.view.width

                deviceName: model.deviceName !== undefined ? model.deviceName : model.DeviceName
                serialNumber: model.serialNumber !== undefined ? model.serialNumber : model.SerialNumber
                status: model.status !== undefined ? model.status : model.Status
                maintenanceDate: model.lastMaintenanceDate

                onEditClicked: console.log("Güncelle:", model.id || model.Id)
                onDeleteClicked: {
                    var deleteId = model.id !== undefined ? model.id : model.Id
                    Api.deleteDevice(deleteId, function() {
                        refreshList()
                    })
                }
            }
        }
    }
}
