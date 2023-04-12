import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import QtGraphicalEffects 1.0

import org.kde.powerplant 1.0

import "components"

Kirigami.Page {
    id: root
    rightPadding: 0
//    leftPadding:0
    bottomPadding:0
    Layout.fillWidth: true

    title: i18n("Plants")
    mainAction: Kirigami.Action {
        icon.name: "help-about-symbolic"
        onTriggered: pageStack.pushDialogLayer("qrc:/About.qml")


    }
    AddPlantSheet {
        id: addSheet
        plantsModel: plantsModel
    }
    ActionButton {
        parent: root.overlay
        x: root.width - width - margin
        y: root.height - height - pageStack.globalToolBar.preferredHeight - margin
        singleAction: Kirigami.Action {
            text: i18n("add Note")
            icon.name: "list-add"
            onTriggered: addSheet.open()
        }
    }
    ColumnLayout {

        anchors.fill: parent

        Controls.Label {
            text: "Good Morning!"
            font.bold: true
            font.pixelSize: 30
        }
        Controls.Label {
            text: "Some of your plants need attention"
            font.pixelSize: 20
        }
        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridView {
                clip: true
                id: grid

                model: PlantsModel {
                    id: plantsModel
                }
                cellWidth: grid.width / (Math.floor(grid.width / 230))
                cellHeight: 310

                delegate: ColumnLayout {
                    id: plantItem
                    required property string imgUrl
                    required property string name
                    required property string species
                    required property string wantsToBeWateredIn
                    required property int currentHealth
                    required property var model


                    width: grid.cellWidth
                    Kirigami.Card {
                        id: card

                        onClicked: {
                            pageStack.push("qrc:/PlantDetailPage.qml", {model: plantItem.model})
                        }

                        background: Kirigami.ShadowedRectangle {
                            radius: 5
                            color: Kirigami.ColorUtils.tintWithAlpha(
                                       Kirigami.Theme.backgroundColor,
                                       healthSlider.healthColor, 0.2)
                            border.color: Kirigami.ColorUtils.linearInterpolation(
                                              Kirigami.Theme.backgroundColor,
                                              Kirigami.Theme.textColor, 0.3)
                            border.width: 1
                            shadow.size: 15
                            shadow.xOffset: 5
                            shadow.yOffset: 5
                            shadow.color: Qt.rgba(0, 0, 0, 0.1)
                            Item {
                                y: 2
                                height: parent.height - 80
                                width: parent.width
                                Image {
                                    anchors.fill: parent
                                    id: image
                                    fillMode: Image.PreserveAspectFit
                                    source: imgUrl
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: mask
                                    }
                                }
                                Rectangle {
                                    id: mask
                                    anchors.fill: parent
                                    visible: false
                                    gradient: Gradient {
                                        GradientStop {
                                            position: 0.5
                                            color: "white"
                                        }
                                        GradientStop {
                                            position: 0.75
                                            color: "transparent"
                                        }
                                    }
                                }
                            }
                        }
                        Layout.alignment: Qt.AlignHCenter
                        Layout.margins: 10
                        padding: 0
                        implicitHeight: grid.cellHeight - 2 * Layout.margins
                        contentItem: ColumnLayout {

                            Item {
                                height: 120
                            }
                            Kirigami.Heading {
                                text: name
                                type: Kirigami.Heading.Type.Primary
                            }
                            Controls.Label {
                                text: species
                                color: Kirigami.Theme.disabledTextColor
                            }
                            TextIconBox {
                                Layout.fillWidth: true
                                label.text: if (wantsToBeWateredIn > 1) {
                                    i18n("in %1 days",
                                             wantsToBeWateredIn)
                                    } else if (wantsToBeWateredIn == 1) {
                                        i18n("tomorrow")
                                    } else if (wantsToBeWateredIn == 0) {
                                        i18n("needs to be watered")
                                    }
                                icon.source: "raindrop"
                                icon.color: "#64ace1"

                            }
                            HealthSlider {
                                id: healthSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: currentHealth
                                enabled: false
                            }
                            Item {
                                height: 20
                            }
                        }
                    }
                }
            }
        }
    }
}
