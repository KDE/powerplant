import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import QtGraphicalEffects 1.15
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

    actions.contextualActions: [
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

    title: i18n("Plants")
    background: GridLayout {
        columnSpacing: 0
        rowSpacing: 0
        flow: wideScreen ? GridLayout.LeftToRight : GridLayout.TopToBottom
        anchors.fill: parent
        columns: 2
        Rectangle{
//            Layout.maximumWidth: 400

            color: Kirigami.Theme.backgroundColor
            Layout.fillHeight: true
            Layout.fillWidth: true
            Item {
                height: wideScreen? width*1.3: width
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
            Layout.maximumWidth: wideScreen? 400: applicationWindow().width
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
            spacing: Kirigami.Units.largeSpacing

            Layout.fillHeight: true
            Layout.fillWidth: true
            RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: Kirigami.Units.gridUnit * 30
                TextIconBox {
                    label.text: plant.location
                    icon.source: "mark-location"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: plant.dateOfBirth
                    icon.source: "chronometer"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: i18n("Parent")
                    icon.source: "view-list-tree"
                    Layout.fillWidth: true
                }
            }
            MobileForm.FormCard {
                Layout.fillWidth: true
                contentItem: ColumnLayout {
                    spacing: 0
                    MobileForm.FormCardHeader {
                        title: i18n("Water")
                    }
                    MobileForm.AbstractFormDelegate {
                        id: name
                        background: Item {}
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
//                    MobileForm.FormDelegateSeparator {}

//                    Repeater {
//                        model: waterEvents
//                        delegate: MobileForm.AbstractFormDelegate {
//                            required property date modelData
//                            background: Item {}
//                            contentItem: ColumnLayout {
//                                Controls.Label {

//                                    text: modelData
//                                }
//                            }
//                        }
//                    }
                }
            }
            MobileForm.FormCard {
                Layout.fillWidth: true
                contentItem: ColumnLayout {
                    spacing: 0
                    MobileForm.FormCardHeader {
                        title: i18n("Health")
                    }
                    MobileForm.AbstractFormDelegate {
                        id: health
                        background: Item {}

                        contentItem: ColumnLayout {
                            Controls.Label {
                                text: i18n("How healthy is your plant today?")
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

                                Item {Layout.fillWidth: true}

                                Controls.Button {
                                    text: i18n("Add")
                                    icon.name: "list-add"
                                    onClicked: healthEvents.addHealthEvent(healthSlider.value)
                                }
                            }
                        }
                    }
                    MobileForm.FormDelegateSeparator {}

                    MobileForm.AbstractFormDelegate {
                        id: healthHistory
                        background: Item {}

                        contentItem: ColumnLayout {
                            Controls.Label {
                                text: i18n("Health History")
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
