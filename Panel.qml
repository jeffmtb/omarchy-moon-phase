import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "Moon.js" as Moon

Panel {
    id: root
    moduleName: "jeffmtb.moon-phase"
    manageIpc: false
    property var anchorItem: null
    property var hostWidget: null
    readonly property var upcoming: hostWidget ? Moon.upcoming(hostWidget.now) : []
    readonly property int tileSize: Style.space(300)
    readonly property int popupPadding: Style.space(8)

    function open() {
        if (hostWidget)
            hostWidget.refresh();
        root.controller.show();
    }
    function close() {
        root.controller.hide();
    }
    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.hostWidget || root, direction);
        return false;
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher
        padding: root.popupPadding
        contentWidth: panel.fittedContentWidth(root.tileSize)
        // fittedContentHeight adds the panel's insets. Subtract them here so
        // the final card dimensions remain square.
        contentHeight: panel.fittedContentHeight(root.tileSize - panel.verticalContentInset)

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function (direction) {
                root.switchPanel(direction);
            }

            Column {
                id: content
                width: parent.width
                anchors.centerIn: parent
                spacing: Style.space(11)
                MoonIcon {
                    width: parent.width
                    height: Style.space(76)
                    fraction: root.hostWidget ? root.hostWidget.moon.fraction : 0
                    illuminatedColor: Color.accent
                    shadowColor: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2)
                }
                Text {
                    width: parent.width
                    text: root.hostWidget ? root.hostWidget.moon.name.toUpperCase() : "MOON-PHASE"
                    color: Color.foreground
                    font.bold: true
                    font.pixelSize: Style.font.subtitle
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.PlainText
                }
                Text {
                    width: parent.width
                    text: root.hostWidget ? Math.round(root.hostWidget.moon.illumination * 100) + "% lit · " + Number(root.hostWidget.moon.age).toFixed(1) + " days into the cycle" : ""
                    color: Color.foreground
                    opacity: 0.62
                    font.pixelSize: Style.font.caption
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.PlainText
                }
                // This gap separates the current phase information from the
                // upcoming events while keeping the whole column centered.
                Item {
                    width: 1
                    height: Style.space(20)
                }
                Column {
                    id: upcomingEvents
                    spacing: Style.space(7)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: root.upcoming

                        delegate: Row {
                            height: Style.space(30)
                            spacing: Style.space(8)

                            MoonIcon {
                                width: Style.space(26)
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                fraction: modelData.fraction
                                illuminatedColor: Color.accent
                                shadowColor: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2)
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name + "  ·  " + Moon.formatDate(modelData.date)
                                color: Color.foreground
                                opacity: 0.72
                                textFormat: Text.PlainText
                                font.pixelSize: Style.font.caption
                                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                            }
                        }
                    }
                }
            }
        }
    }
}
