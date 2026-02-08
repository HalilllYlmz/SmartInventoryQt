import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtWebSockets
import QtQuick.Effects

Item {
    id: root

    property int currentTemp: 0
    property bool isCritical: currentTemp >= 80

    WebSocket {
        id: socket
        url: "ws://localhost:5113/sensorHub"
        active: true

        onStatusChanged: {
            if (socket.status === WebSocket.Open) {
                socket.sendTextMessage('{"protocol":"json","version":1}' + String.fromCharCode(0x1E))
            }
        }

        onTextMessageReceived: (rawMessage) => {
            var messages = rawMessage.split(String.fromCharCode(0x1E))
            for (var i = 0; i < messages.length; i++) {
                var msg = messages[i];
                if (msg.trim() === "") continue;

                try {
                    var json = JSON.parse(msg)
                    if (json.type === 1 && json.target === "ReceiveTemperature") {
                        root.currentTemp = json.arguments[0]
                    }
                } catch (e) { }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30

        Text {
            text: "Sensör Durumu"
            font.pixelSize: 24
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }


        Rectangle {
            id: gaugeContainer
            width: 280
            height: 280
            radius: 140
            color: "white"
            border.color: "#dfe6e9"
            border.width: 1
            Layout.alignment: Qt.AlignHCenter

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.1
                shadowBlur: 15
            }

            Repeater {
                model: 40
                Item {
                    width: 280; height: 280
                    anchors.centerIn: parent
                    rotation: 135 + (index * (270 / 39))

                    Rectangle {
                        width: 2
                        height: (index % 5 === 0) ? 12 : 6
                        color: (index % 5 === 0) ? "#bdc3c7" : "#ecf0f1"
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 15
                    }
                }
            }

            Shape {
                anchors.centerIn: parent
                width: 250; height: 250
                ShapePath {
                    strokeColor: "#f1f2f6"
                    strokeWidth: 20
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 125; centerY: 125
                        radiusX: 95; radiusY: 95
                        startAngle: 135
                        sweepAngle: 270
                    }
                }
            }

            Shape {
                id: progressShape
                anchors.centerIn: parent
                width: 250; height: 250
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: root.isCritical ? "#e74c3c" : "#3498db"
                    strokeWidth: 20
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    Behavior on strokeColor { ColorAnimation { duration: 300 } }

                    PathAngleArc {
                        centerX: 125; centerY: 125
                        radiusX: 95; radiusY: 95
                        startAngle: 135
                        sweepAngle: 270 * (root.currentTemp / 100)
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    text: "⚠️"
                    font.pixelSize: 32
                    visible: root.isCritical
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 40

                    OpacityAnimator on opacity {
                        from: 0; to: 1; duration: 500
                        loops: Animation.Infinite
                        running: root.isCritical
                    }
                }

                Item {
                    visible: !root.isCritical
                    Layout.preferredHeight: 40
                    Layout.fillWidth: true
                }

                Text {
                    text: root.currentTemp + "°C"
                    font.pixelSize: 48
                    font.bold: true
                    color: root.isCritical ? "#e74c3c" : "#2c3e50"
                    Layout.alignment: Qt.AlignHCenter
                    Behavior on color { ColorAnimation { duration: 300 } }
                }

                Text {
                    text: root.isCritical ? "KRİTİK!" : "Normal"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: root.isCritical ? "#e74c3c" : "#95a5a6"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
