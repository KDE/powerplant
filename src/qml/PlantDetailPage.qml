// SPDX-FileCopyrightText: 2023 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlhwan.eu>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import Qt5Compat.GraphicalEffects
import org.kde.quickcharts 1.0 as Charts
import org.kde.powerplant 1.0

import "components"

Kirigami.ScrollablePage {
    id: root

    required property var plantsModel
    required property int plantId
    property bool wideScreen: applicationWindow().width >= 800

    Plant {
        id: plant
        plantId: root.plantId
    }

    WaterHistoryModel {
        id: waterEvents
        plantId: root.plantId
    }

    HealthHistoryModel {
        id: healthEvents
        plantId: root.plantId
    }

    Component {
        id: editPlantComponent

        PlantEditorPage {
            mode: PlantEditor.Editor
            plantsModel: root.plantsModel
            plantId: root.plantId
        }
    }

    actions: [
        Kirigami.Action {
            icon.name: "document-edit"
            text: i18nc("@action:button", "Edit")
            onTriggered: {
                applicationWindow().pageStack.pushDialogLayer(editPlantComponent, {}, {
                    width: Kirigami.Units.gridUnit * 25,
                    height: Kirigami.Units.gridUnit * 35,
                })
            }
        },
        Kirigami.Action {
            icon.name: "delete"
            text: i18nc("@action:button", "Delete")
            onTriggered: {
                plantsModel.deletePlant(plant.plantId);
                applicationWindow().pageStack.pop();
            }
        }
    ]

    leftPadding: 0
    rightPadding: 0

    title: plant.name
    background: GridLayout {
        columnSpacing: 0
        rowSpacing: 0
        flow: wideScreen ? GridLayout.LeftToRight : GridLayout.TopToBottom
        columns: 2
        Rectangle{
//            Layout.maximumWidth: 400

            color: Kirigami.Theme.backgroundColor
            Layout.fillHeight: true
            Layout.fillWidth: true
            Item {
                height: parent.height
                width: parent.width
                anchors.centerIn:parent
                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Kirigami.ColorUtils.tintWithAlpha(
                                                                 Kirigami.Theme.backgroundColor,
                                                                 healthSlider.healthColor, 0.5)}
                        GradientStop { position: 0.5; color: Kirigami.Theme.backgroundColor }
                    }
                }
            }
        }
        Rectangle{
            color: Kirigami.Theme.backgroundColor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    GridLayout {
        flow: wideScreen ? GridLayout.LeftToRight : GridLayout.TopToBottom

        anchors.fill: parent
        columns: 2

        ColumnLayout {
            Layout.maximumWidth: wideScreen ? applicationWindow().width / 2 - Kirigami.Units.gridUnit * 3 : applicationWindow().width
            Layout.fillHeight: true
            Layout.fillWidth: true
            Item {
                Layout.fillHeight: true
            }

            Item {
                height: 300
                Layout.fillWidth: true
                Image {
                    anchors.fill: parent
                    id: image
                    fillMode: Image.PreserveAspectFit
                    source: plant.imgUrl
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
                            position: 1
                            color: "transparent"
                        }
                    }
                }
            }
            Kirigami.Heading {
                text: plant.name
                type: Kirigami.Heading.Type.Primary
                Layout.alignment: Qt.AlignHCenter
            }
            Controls.Label {
                text: plant.species
                color: Kirigami.Theme.disabledTextColor
                Layout.alignment: Qt.AlignHCenter
            }
            Item {
                Layout.fillHeight: true
            }
        }

        ColumnLayout {
            spacing: 0

            Layout.fillHeight: true
            Layout.fillWidth: true

            Layout.maximumWidth: applicationWindow().width / (wideScreen ? 2 : 1)

            RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: Kirigami.Units.gridUnit * 30
                TextIconBox {
                    label.text: plant.location
                    icon.source: "mark-location"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: Qt.formatDate(plant.dateOfBirth)
                    icon.source: "chronometer"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: i18n("Parent")
                    icon.source: "view-list-tree"
                    Layout.fillWidth: true
                }
            }

            FormCard.FormHeader {
                title: i18n("Water")
            }

            FormCard.FormCard {
                FormCard.AbstractFormDelegate {
                    id: name
                    background: null
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            id: icon
                            source: "raindrop"
                            color: "#64ace1"
                            isMask: true
                            implicitHeight: Kirigami.Units.gridUnit * 1.5
                        }
                        Controls.Label {
                            Layout.fillWidth: true
                            text: if (plant.wantsToBeWateredIn > 1) {
                                      i18n("has to be watered in %1 days", plant.wantsToBeWateredIn)
                                  } else if (plant.wantsToBeWateredIn == 1) {
                                      i18n("has to be watered tomorrow")
                                  } else if (plant.wantsToBeWateredIn == 0) {
                                      i18n("needs to be watered today!")
                                  } else if (plant.wantsToBeWateredIn < 0) {
                                      i18n("should have been watered already!")
                                  }
                        }
                        Controls.Button {
                            text: i18n("Watered")
                            icon.name: "answer-correct"
                            onClicked: waterEvents.waterPlant()
                        }
                    }
                }

//              FormCard.FormDelegateSeparator {}

//              Repeater {
//                  model: waterEvents
//                  delegate: FormCard.AbstractFormDelegate {
//                      required property date modelData
//                      background: null
//                      contentItem: ColumnLayout {
//                          Controls.Label {
//                              text: modelData
//                          }
//                      }
//                  }
//              }
            }

            FormCard.FormHeader {
                title: i18n("Health")
            }

            FormCard.FormCard {
                FormCard.AbstractFormDelegate {
                    id: health

                    background: null
                    text: i18n("How healthy is your plant today?")

                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: health.text
                        }
                        RowLayout {
                            HealthSlider {
                                id: healthSlider
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                Layout.maximumWidth: 200
                                value: plant.currentHealth
                                from: 0
                                to: 100
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Controls.Button {
                                text: i18n("Add")
                                icon.name: "list-add"
                                onClicked: healthEvents.addHealthEvent(healthSlider.value)
                            }
                        }
                    }
                }

                FormCard.FormDelegateSeparator {}

                FormCard.AbstractFormDelegate {
                    id: healthHistory

                    text: i18n("Health History")

                    background: null
                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: healthHistory.text
                        }

                        Charts.LineChart {
                            height: 60
                            Layout.topMargin: 10
                            Layout.bottomMargin: 10
                            clip: false
                            Layout.fillWidth: true
                            colorSource: Charts.SingleValueSource {
                                value: "#b4e479"
                            }
                            nameSource: Charts.SingleValueSource {
                                value: health
                            }
                            fillOpacity: 0.3

                            smooth: true

                            valueSources: Charts.ModelSource {
                                model: healthEvents
                                roleName: "health"
                            }
                        }
                    }
                }
            }
//            Timer{
//                id: healthTimer
//                repeat: false
//                interval: 1000
//                running: false
//                triggeredOnStart: false
//                onTriggered: {
//                    healthEvents.addHealthEvent(healthSlider.value)
//                }
//            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
