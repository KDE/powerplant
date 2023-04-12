import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import QtGraphicalEffects 1.15
import org.kde.quickcharts 1.0 as Charts

import "components"

Kirigami.ScrollablePage {
    id: root
    property var model
    property bool wideScreen: applicationWindow().width >= 800
    property var waterEvents: root.model.waterEvents
    property var healthEvents: root.model.healthEvents

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
                    source: root.model.imgUrl
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
                            position: 1
                            color: "transparent"
                        }
                    }
                }
            }
            Kirigami.Heading {
                text: root.model.name
                type: Kirigami.Heading.Type.Primary
                Layout.alignment: Qt.AlignHCenter
            }
            Controls.Label {
                text: root.model.species
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
                    label.text: root.model.location
                    icon.source: "mark-location"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: "Age of Plant"
                    icon.source: "chronometer"
                    Layout.fillWidth: true
                }
                TextIconBox {
                    label.text: "Parent"
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
                                text: if (root.model.wantsToBeWateredIn > 1) {
                                          i18n("has to be watered in %1 days", root.model.wantsToBeWateredIn)
                                      } else if (root.model.wantsToBeWateredIn == 1) {
                                          i18n("has to be watered tomorrow")
                                      } else if (root.model.wantsToBeWateredIn == 0) {
                                          i18n("needs to be watered today!")
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
                                    value: root.model.currentHealth
                                    from: 0
                                    to: 100
                                }
                                Item {Layout.fillWidth: true}
                                Controls.Button {
                                    text: i18n("Add")
                                    icon.name: "list-add"
                                    onClicked: root.healthEvents.addHealthEvent(healthSlider.value)

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
                                    model: root.healthEvents
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
//                    root.healthEvents.addHealthEvent(healthSlider.value)
//                }
//            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}