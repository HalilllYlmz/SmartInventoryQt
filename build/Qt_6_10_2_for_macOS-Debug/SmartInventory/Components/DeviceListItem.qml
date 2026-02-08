import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: parent.width
    height: 90 // Yüksekliği biraz artırdık ki tarih sığsın
    color: "white"
    radius: 10

    property string deviceName: "Cihaz Adı"
    property string serialNumber: "SN-12345"
    property string status: "Pasif"
    property string maintenanceDate: "" // Yeni özellik

    signal editClicked()
    signal deleteClicked()

    // Tarihi formatlamak için yardımcı fonksiyon
    function formatDate(dateString) {
        if (!dateString) return "Belirtilmemiş";
        var date = new Date(dateString);
        return date.toLocaleDateString(Qt.locale("tr_TR"), "dd.MM.yyyy");
    }

    function getStatusColor() {
        switch(status) {
        case "Aktif": return "#2ecc71"
        case "Arızalı": return "#e74c3c"
        case "Bakımda": return "#f1c40f"
        default: return "#95a5a6"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 15
        spacing: 15

        // SOL: Renkli Durum Çubuğu
        Rectangle {
            width: 6
            Layout.fillHeight: true
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            color: getStatusColor()
            radius: 4
        }

        // ORTA: Bilgiler
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // 1. Cihaz Adı
            Text {
                text: root.deviceName
                font.bold: true
                font.pixelSize: 18
                color: "#2c3e50"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // 2. Seri No ve Durum (Yan Yana)
            RowLayout {
                spacing: 8
                Text {
                    text: root.serialNumber
                    color: "#7f8c8d"
                    font.pixelSize: 14
                }

                Rectangle { width: 4; height: 4; radius: 2; color: "#bdc3c7" } // Nokta

                Text {
                    text: root.status
                    color: getStatusColor()
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            // 3. Son Bakım Tarihi (YENİ EKLENEN KISIM)
            RowLayout {
                spacing: 5
                Text {
                    text: "📅" // Takvim ikonu
                    font.pixelSize: 12
                }
                Text {
                    text: "Son Bakım: " + formatDate(root.maintenanceDate)
                    color: "#95a5a6"
                    font.pixelSize: 12
                }
            }
        }

        // SAĞ: Menü Butonu
        // SAĞ: Menü Butonu
        ToolButton {
            text: "⋮"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            background: Rectangle {
                color: parent.down ? "#ecf0f1" : "transparent"
                radius: 5
            }

            onClicked: optionsMenu.open()

            Menu {
                id: optionsMenu
                y: parent.height // Butonun hemen altından başla

                // --- İŞTE BU SATIR SORUNU ÇÖZER ---
                // Menüyü, kendi genişliği kadar sola çekiyoruz ki sağa taşmasın.
                x: parent.width - width
                // ----------------------------------

                MenuItem {
                    text: "✏️ Güncelle"
                    onTriggered: root.editClicked()
                }

                MenuSeparator {}

                MenuItem {
                    text: "🗑️ Sil"
                    contentItem: Text {
                        text: parent.text
                        color: "#e74c3c"
                        font: parent.font
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    onTriggered: root.deleteClicked()
                }
            }
        }
    }
}
