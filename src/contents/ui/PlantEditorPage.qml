// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1
import "components"

import org.kde.powerplant 1.0

Kirigami.ScrollablePage {
    id: root

    required property PlantsModel plantsModel
    property int waterInterval: 2
    required property int mode
    property int plantId: -1

    readonly property PlantEditor plantEditor: PlantEditor {
        plantId: root.plantId
        mode: root.mode
        plantsModel: root.plantsModel
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
    leftPadding: 0
    rightPadding: 0

    title: mode === PlantEditor.Creator ? i18n("Add Plant") : i18n("Edit %1", plantEditor.plant.name)

    ColumnLayout {
        MobileForm.FormCard {
            Layout.topMargin: 20
            Layout.fillWidth: true
            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.AbstractFormDelegate {
                    background: null
                    contentItem: ColumnLayout {
                        clip: true
                        Controls.Label {
                            text: i18n("Image:")
                        }

                        ListView {
                            id: imageView

                            Layout.preferredHeight: Kirigami.Units.gridUnit * 10
                            Layout.fillWidth: true
                            onCurrentIndexChanged: if (currentIndex >= 0) {
                                plantEditor.plant.imgUrl = currentItem.url
                            }
                            currentIndex: -1

                            Connections {
                                target: plantEditor.plant
                                function onImgUrlChanged() {
                                    plantImageModel.customImage = plantEditor.plant.imgUrl;
                                    imageView.currentIndex = plantImageModel.urlToIndex(plantEditor.plant.imgUrl);
                                }
                            }

                            orientation: ListView.Horizontal

                            header: Item {
                                width: 120
                                height: ListView.view.height

                                ActionButton {
                                    anchors.centerIn: parent
                                    icon.name: "list-add"
                                    text: i18n("Use custom image")
                                    onClicked: fileDialog.open()
                                }

                                FileDialog {
                                    id: fileDialog
                                    title: i18n("Please choose a file")
                                    folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                                    onAccepted: {
                                        plantImageModel.customImage = file;

                                        // Hack force refresh
                                        imageView.currentIndex = -1;
                                        imageView.currentIndex = 0;
                                    }

                                    nameFilters: [i18nc("Name filter for image files", "Image files (*.png *.jpg* *.webp)")]
                                }
                            }

                            model: PlantImageModel {
                                id: plantImageModel
                            }

                            delegate: Controls.ItemDelegate {
                                id: imageDelegate

                                required property string index
                                required property string url

                                y: 2

                                height: ListView.view.height
                                width: ListView.view.height

                                onClicked: imageView.currentIndex = index

                                background: RadialGradient {
                                    visible: imageDelegate.ListView.isCurrentItem

                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Kirigami.ColorUtils.tintWithAlpha(
                                                                                 Kirigami.Theme.backgroundColor,
                                                                                 healthSlider.healthColor, 0.5)}
                                        GradientStop { position: 0.5; color: Kirigami.Theme.backgroundColor }
                                    }
                                }

                                Image {
                                    id: image
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    source: parent.url
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
                    }
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Name")
                    text: plantEditor.plant.name
                    onTextChanged: plantEditor.plant.name = text
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Species")
                    text: plantEditor.plant.species
                    onTextChanged: plantEditor.plant.species = text
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Room")
                    text: plantEditor.plant.location
                    onTextChanged: plantEditor.plant.location = text
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.AbstractFormDelegate {
                    id: interval
                    background: null
                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: i18n("How often does the plant need Watering?")
                        }
                        Controls.ButtonGroup {
                            id: buttonGroup
                        }
                        RowLayout {
                            id: row

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Controls.Button {
                                text: i18n("2 days")
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: plantEditor.plant.waterIntervall = 2
                            }

                            Controls.Button {
                                text: i18n("5 days")
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: plantEditor.plant.waterIntervall = 5
                            }

                            Controls.Button {
                                text: i18n("weekly")
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: plantEditor.plant.waterIntervall = 7
                            }

                            Controls.Button {
                                text: i18n("2 weeks")
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: plantEditor.plant.waterIntervall = 14

                            }

                            Controls.Label {
                                text: i18n("custom:")
                            }

                            Controls.SpinBox {
                                onValueChanged: plantEditor.plant.waterIntervall = value
                                value: plantEditor.plant.waterIntervall
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                MobileForm.FormDelegateSeparator {
                    visible: root.mode === PlantEditor.Creator
                }

                MobileForm.AbstractFormDelegate {
                    id: health
                    visible: root.mode === PlantEditor.Creator
                    background: null
                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: i18n("How healthy is your plant at the moment?")
                        }

                        HealthSlider {
                            id: healthSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 200
                            from:0
                            to:100
                            onValueChanged: plantEditor.plant.currentHealth = value
                        }
                    }
                }
            }
        }

        Controls.Label {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            wrapMode: Text.WordWrap
        }
    }

    footer: Controls.ToolBar {
        contentItem: RowLayout {
            Item {
                Layout.fillWidth: true
            }

            Controls.Button {
                text: plantEditor.mode === PlantEditor.Editor ? i18n("Edit") : i18n("Add")
                icon.name:  plantEditor.mode === PlantEditor.Editor ? "document-edit" : "list-add"
                onClicked: {
                    plantEditor.save();
                    root.closeDialog()
                }
            }
        }
    }
}
