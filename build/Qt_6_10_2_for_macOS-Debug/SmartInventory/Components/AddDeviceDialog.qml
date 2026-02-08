import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../Scripts/DeviceApi.js" as Api

Dialog {
    id: rootDialog

    modal: true
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 480

    background: Rectangle {
        color: "white"
        radius: 24
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true; shadowOpacity: 0.25; shadowBlur: 2.0; shadowVerticalOffset: 10
        }
    }

    signal deviceAdded()
    signal deviceUpdated()

    property bool isEditMode: false
    property int currentDeviceId: 0
    property var selectedDate: new Date()

    function openForAdd() {
        isEditMode = false
        currentDeviceId = 0
        titleText.text = "Yeni Cihaz Ekle"
        saveButtonText.text = "Kaydet"

        nameField.text = ""
        serialField.text = ""
        statusCombo.currentIndex = 0
        selectedDate = new Date()
        updateDateText()

        open()
    }

    function openForEdit(deviceData) {
        isEditMode = true
        currentDeviceId = deviceData.id
        titleText.text = "Cihazı Güncelle"
        saveButtonText.text = "Güncelle"

        nameField.text = deviceData.deviceName
        serialField.text = deviceData.serialNumber

        var statusIndex = statusCombo.model.indexOf(deviceData.status)
        statusCombo.currentIndex = (statusIndex >= 0) ? statusIndex : 0

        if (deviceData.maintenanceDate) {
            selectedDate = new Date(deviceData.maintenanceDate)
        } else {
            selectedDate = new Date()
        }
        updateDateText()

        open()
    }

    function updateDateText() {
        dateDisplay.text = selectedDate.toLocaleDateString(Qt.locale("tr_TR"), "dd.MM.yyyy")
    }

    function getISODate() {
        var d = new Date(selectedDate.getTime() - (selectedDate.getTimezoneOffset() * 60000));
        return d.toISOString().split('T')[0] + "T00:00:00";
    }

    contentItem: ColumnLayout {
        spacing: 25

        Text {
            id: titleText
            text: "Yeni Cihaz"
            font.bold: true; font.pixelSize: 24; color: "#2d3436"
            Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 10
        }

        GridLayout {
            columns: 2
            rowSpacing: 20; columnSpacing: 15; Layout.fillWidth: true

            Text { text: "Cihaz Adı"; font.bold: true; color: "#636e72"; font.pixelSize: 14 }
            TextField {
                id: nameField; Layout.fillWidth: true; Layout.preferredHeight: 48
                placeholderText: "Örn: Motor Bloğu"; font.pixelSize: 15; verticalAlignment: TextInput.AlignVCenter; leftPadding: 12
                background: Rectangle { color: parent.activeFocus ? "white" : "#f1f2f6"; radius: 12; border.color: parent.activeFocus ? "#3498db" : "transparent"; border.width: 2 }
            }

            Text { text: "Seri No"; font.bold: true; color: "#636e72"; font.pixelSize: 14 }
            TextField {
                id: serialField; Layout.fillWidth: true; Layout.preferredHeight: 48
                placeholderText: "Örn: SN-999"; font.pixelSize: 15; verticalAlignment: TextInput.AlignVCenter; leftPadding: 12
                background: Rectangle { color: parent.activeFocus ? "white" : "#f1f2f6"; radius: 12; border.color: parent.activeFocus ? "#3498db" : "transparent"; border.width: 2 }
            }

            Text { text: "Durum"; font.bold: true; color: "#636e72"; font.pixelSize: 14 }
            ComboBox {
                id: statusCombo; Layout.fillWidth: true; Layout.preferredHeight: 48
                model: ["Aktif", "Pasif", "Bakımda", "Arızalı"]
                font.pixelSize: 15
                contentItem: Text { leftPadding: 12; text: statusCombo.displayText; font: statusCombo.font; color: "#2d3436"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                background: Rectangle { color: "#f1f2f6"; radius: 12; border.width: 0 }
            }

            Text { text: "Bakım Tarihi"; font.bold: true; color: "#636e72"; font.pixelSize: 14 }
            Rectangle {
                id: dateInputArea; Layout.fillWidth: true; Layout.preferredHeight: 48
                color: "#f1f2f6"; radius: 12; border.color: calendarPopup.opened ? "#3498db" : "transparent"; border.width: 2
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                    Text { id: dateDisplay; text: "01.01.2026"; color: "#2d3436"; font.pixelSize: 15; Layout.fillWidth: true }
                    Text { text: "📅"; font.pixelSize: 18 }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var globalPos = dateInputArea.mapToItem(rootDialog.parent, 0, 0)
                        var spaceBelow = rootDialog.parent.height - (globalPos.y + dateInputArea.height)
                        if (spaceBelow < 330) calendarPopup.y = -calendarPopup.height - 5
                        else calendarPopup.y = dateInputArea.height + 5
                        calendarPopup.open()
                    }
                }
                Popup {
                    id: calendarPopup
                    width: 300; height: 320; modal: true; focus: true
                    x: (parent.width - width) / 2
                    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 } }
                    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 } }
                    background: Rectangle { color: "white"; radius: 16; border.color: "#dfe6e9"; layer.enabled: true; layer.effect: MultiEffect { shadowEnabled: true; shadowOpacity: 0.15; shadowBlur: 10 } }
                    contentItem: ColumnLayout {
                        spacing: 10
                        RowLayout {
                             Layout.fillWidth: true; Layout.margins: 10
                             Button { text: "<"; flat: true; onClicked: changeMonth(-1) }
                             Text { text: calendarGrid.title; font.bold: true; font.pixelSize: 16; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                             Button { text: ">"; flat: true; onClicked: changeMonth(1) }
                        }
                        MonthGrid {
                            id: calendarGrid; Layout.fillWidth: true; Layout.fillHeight: true
                            month: new Date().getMonth(); year: new Date().getFullYear(); locale: Qt.locale("tr_TR")
                            delegate: Rectangle {
                                width: calendarGrid.cellWidth; height: calendarGrid.cellHeight; color: "transparent"
                                property bool isToday: model.date.toDateString() === new Date().toDateString()
                                property bool isSelected: model.date.toDateString() === rootDialog.selectedDate.toDateString()
                                property bool isCurrentMonth: model.month === calendarGrid.month
                                Rectangle { anchors.centerIn: parent; width: 32; height: 32; radius: 16; color: isSelected ? "#3498db" : (isToday ? "#dfe6e9" : "transparent") }
                                Text { anchors.centerIn: parent; text: model.day; color: isSelected ? "white" : (isCurrentMonth ? "#2d3436" : "#b2bec3"); font.bold: isSelected || isToday }
                                MouseArea { anchors.fill: parent; onClicked: { if (model.month === calendarGrid.month) { rootDialog.selectedDate = model.date; rootDialog.updateDateText(); calendarPopup.close() } } }
                            }
                        }
                    }
                    function changeMonth(delta) {
                        var newMonth = calendarGrid.month + delta
                        if(newMonth > 11) { calendarGrid.month = 0; calendarGrid.year++ }
                        else if(newMonth < 0) { calendarGrid.month = 11; calendarGrid.year-- }
                        else { calendarGrid.month = newMonth }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight; Layout.topMargin: 20; spacing: 15
            Button { text: "İptal"; flat: true; font.bold: true; palette.buttonText: "#636e72"; background: null; onClicked: rootDialog.close() }

            Button {
                text: "Kaydet"
                font.bold: true
                contentItem: Text {
                    id: saveButtonText // ID verdik
                    text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: parent.down ? "#2980b9" : "#3498db"; radius: 12; layer.enabled: true; layer.effect: MultiEffect { shadowEnabled: true; shadowOpacity: 0.3; shadowVerticalOffset: 2 } }

                onClicked: {
                    if (nameField.text === "" || serialField.text === "") return

                    var deviceData = {
                        "id": isEditMode ? currentDeviceId : 0,
                        "deviceName": nameField.text,
                        "serialNumber": serialField.text,
                        "status": statusCombo.currentText,
                        "lastMaintenanceDate": getISODate()
                    }

                    if (isEditMode) {
                        Api.updateDevice(currentDeviceId, deviceData, function(success) {
                            if (success) {
                                rootDialog.deviceUpdated()
                                rootDialog.close()
                            }
                        })
                    } else {
                        Api.addDevice(deviceData, function(success) {
                            if (success) {
                                rootDialog.deviceAdded()
                                rootDialog.close()
                            }
                        })
                    }
                }
            }
        }
    }
}
