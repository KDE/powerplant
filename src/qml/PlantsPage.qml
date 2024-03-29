
// SPDX-FileCopyrightText: 2023 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.components as Components
import Qt5Compat.GraphicalEffects
import org.kde.powerplant 1.0

Kirigami.ScrollablePage {
    id: root
    rightPadding: 0
    //    leftPadding:0
    bottomPadding: 0
    Layout.fillWidth: true

    title: i18n("Plants")
    actions: Kirigami.Action {
        icon.name: "help-about-symbolic"
        onTriggered: pageStack.pushDialogLayer(Qt.createComponent('org.kde.powerplant', 'About'))
    }

    Component {
        id: addPlantComponent

        PlantEditorPage {
            plantsModel: grid.model
            mode: PlantEditor.Creator
        }
    }

    Components.FloatingButton {
        parent: root.overlay

        anchors {
            right: parent.right
            rightMargin: Kirigami.Units.largeSpacing
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing
        }

        x: root.width - width - margin
        y: root.height - height - pageStack.globalToolBar.preferredHeight - margin
        text: i18nc("@action:button", "Add Plant")
        icon.name: "list-add"
        onClicked: applicationWindow().pageStack.pushDialogLayer(addPlantComponent, {}, {
           width: Kirigami.Units.gridUnit * 25,
           height: Kirigami.Units.gridUnit * 35
        })
    }

    GridView {
        id: grid

        cellWidth: applicationWindow(
                       ).width < 500 ? grid.width / (Math.floor(
                                                         grid.width / 160)) : grid.width
                                       / (Math.floor(grid.width / 230))
        cellHeight: 310

        header: ColumnLayout {
            spacing: 0
            width: parent.width

            Controls.Label {
                text: i18n("Good Morning!")
                font {
                    bold: true
                    pixelSize: 30
                }

                Layout.margins: Kirigami.Units.largeSpacing * 2
                Layout.topMargin: Kirigami.Units.largeSpacing * 2
                Layout.bottomMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
            }

            Controls.Label {
                text: {
                    switch (plantsModel.summary) {
                    case PlantsModel.SomeNeedWater:
                        return i18n("Some of your plants need attention");
                    case PlantsModel.NothingToDo:
                        return i18n("No plants need water right now");
                    }
                }

                wrapMode: Text.WordWrap
                font.pixelSize: 20

                Layout.margins: Kirigami.Units.largeSpacing * 2
                Layout.topMargin: 0
                Layout.bottomMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
            }
        }

        model: PlantsModel {
            id: plantsModel
        }

        delegate: ColumnLayout {
            id: plantItem

            required property string imgUrl
            required property string name
            required property string species
            required property string wantsToBeWateredIn
            required property int currentHealth
            required property var dateOfBirth
            required property int plantId

            WaterHistoryModel {
                id: waterEvents
                plantId: plantItem.plantId
            }
            width: grid.cellWidth

            Kirigami.AbstractCard {
                id: card

                onClicked: pageStack.push(Qt.createComponent('org.kde.powerplant', 'PlantDetailPage.qml'), {
                                              "plantId": plantItem.plantId,
                                              "plantsModel": plantsModel
                                          })

                background: Kirigami.ShadowedRectangle {
                    radius: 5
                    color: Kirigami.ColorUtils.tintWithAlpha(
                               Kirigami.Theme.backgroundColor,
                               healthSlider.healthColor, 0.2)

                    border {
                        color: Kirigami.ColorUtils.linearInterpolation(
                                   Kirigami.Theme.backgroundColor,
                                   Kirigami.Theme.textColor, 0.3)
                        width: 1
                    }

                    shadow {
                        size: 15
                        xOffset: 5
                        yOffset: 5
                        color: Qt.rgba(0, 0, 0, 0.1)
                    }

                    Item {
                        y: 2
                        height: parent.height - 80
                        width: parent.width
                        Image {
                            anchors.fill: parent
                            id: image
                            fillMode: Image.PreserveAspectFit
                            source: imgUrl
                            layer {
                                enabled: true
                                effect: OpacityMask {
                                    maskSource: mask
                                }
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
                padding: Kirigami.Units.mediumSpacing
                implicitHeight: grid.cellHeight - 2 * Layout.margins
                contentItem: ColumnLayout {
                    Kirigami.Heading {
                        text: name
                        type: Kirigami.Heading.Type.Primary
                        Layout.topMargin: 120
                    }

                    Controls.Label {
                        text: species
                        color: Kirigami.Theme.disabledTextColor
                    }

                    TextIconBox {
                        Layout.fillWidth: true
                        label {
                            text: if (wantsToBeWateredIn > 1) {
                                      i18n("in %1 days", wantsToBeWateredIn)
                                  } else if (wantsToBeWateredIn == 1) {
                                      i18n("tomorrow")
                                  } else if (wantsToBeWateredIn == 0) {
                                      i18n("water today!")
                                  } else if (wantsToBeWateredIn < 0) {
                                      i18n("watering overdue!")
                                  }
                            font.bold: wantsToBeWateredIn <= 0
                        }
                        icon {
                            source: "raindrop"
                            color: "#64ace1"
                        }
                        action {
                            icon.name: "answer-correct"
                            onClicked: {
                                console.log(plantId)
                                waterEvents.waterPlant()
                            }
                            visible: wantsToBeWateredIn <= 0
                        }
                    }

                    HealthSlider {
                        id: healthSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: currentHealth
                        enabled: false

                        Layout.bottomMargin: 20
                    }
                }
            }
        }
    }
}
