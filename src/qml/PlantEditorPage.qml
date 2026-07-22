// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.kirigamiaddons.components as Components
import Qt5Compat.GraphicalEffects
import Qt.labs.platform

import org.kde.powerplant

FormCard.FormCardPage {
    id: root

    required property PlantsModel plantsModel
    property int waterInterval: 2
    property int fertilizerInterval: 14

    required property int mode
    property int plantId: -1

    readonly property PlantEditor plantEditor: PlantEditor {
        plantId: root.plantId
        mode: root.mode
        plantsModel: root.plantsModel
    }

    title: mode === PlantEditor.Creator ? i18nc("@title:window","Add Plant") : i18nc("@title:window %1 is the plant name", "Edit %1", plantEditor.plant.name)

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.gridUnit

        FormCard.AbstractFormDelegate {
            background: null
            contentItem: ColumnLayout {
                clip: true
                Controls.Label {
                    text: i18nc("@title:row","Image:")
                }

                ListView {
                    id: imageView

                    Layout.preferredHeight: Kirigami.Units.gridUnit * 10
                    Layout.fillWidth: true
                    onCurrentIndexChanged: if (currentIndex >= 0) {
                        plantEditor.plant.imgUrl = currentItem.url;
                    }
                    currentIndex: -1

                    Connections {
                        target: plantEditor.plant
                        function onImgUrlChanged() {
                            plantImageModel.customImage = plantEditor.plant.imgUrl;
                            imageView.currentIndex = plantImageModel.urlToIndex(plantEditor.plant.imgUrl);
                        }
                    }

                    Controls.ScrollBar.horizontal: Controls.ScrollBar { }
                    orientation: ListView.Horizontal

                    header: Item {
                        width: 120
                        height: ListView.view.height

                        Components.FloatingButton{
                            anchors.centerIn: parent
                            icon.name: "list-add-symbolic"
                            text: i18nc("@action:button","Use custom image")
                            onClicked: fileDialog.open()
                        }

                        FileDialog {
                            id: fileDialog
                            title: i18nc("@title:window","Please choose a file")
                            folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                            onAccepted: {
                                plantImageModel.customImage = file;

                                // Hack force refresh
                                imageView.currentIndex = -1;
                                imageView.currentIndex = 0;
                            }

                            nameFilters: [i18nc("Name filter for image files", "Image files (*.png *.jpg *.webp)")]
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
                                GradientStop {
                                    position: 0.0
                                    color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, healthSlider.healthColor, 0.5)
                                }
                                GradientStop {
                                    position: 0.5
                                    color: Kirigami.Theme.backgroundColor
                                }
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

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextFieldDelegate {
            label: i18nc("@title:row","Name")
            text: plantEditor.plant.name
            onTextChanged: plantEditor.plant.name = text
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextFieldDelegate {
            label: i18nc("@title:row","Species")
            text: plantEditor.plant.species
            onTextChanged: plantEditor.plant.species = text
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextFieldDelegate {
            label: i18nc("@title:row","Room")
            text: plantEditor.plant.location
            onTextChanged: plantEditor.plant.location = text
        }

        FormCard.FormDelegateSeparator {}

        FormCard.AbstractFormDelegate {
            id: waterIntervalDelegate
            background: null
            contentItem: ColumnLayout {
                Controls.Label {
                    text: i18nc("@title:row","How often does the plant need Watering?")
                }
                Controls.ButtonGroup {
                    id: buttonGroup
                }

                RowLayout {
                    id: row

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","2 days")
                        checkable: true
                        Controls.ButtonGroup.group: buttonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.waterInterval = 2
                    }

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","5 days")
                        checkable: true
                        Controls.ButtonGroup.group: buttonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.waterInterval = 5
                    }

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","weekly")
                        checkable: true
                        Controls.ButtonGroup.group: buttonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.waterInterval = 7
                    }

                    Controls.Button {
                        id: buttonWeeks
                        text: i18nc("@action:button button to select preset time","2 weeks")
                        checkable: true
                        Controls.ButtonGroup.group: buttonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.waterInterval = 14
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Controls.Label {
                        text: i18nc("@title:row","Custom (days):")
                    }

                    Controls.SpinBox {
                        onValueChanged: plantEditor.plant.waterInterval = value
                        value: plantEditor.plant.waterInterval
                        Layout.fillWidth: true
                    }
                }
            }
        }

        FormCard.FormDelegateSeparator {}
        FormCard.AbstractFormDelegate {
            id: fertilizerIntervalDelegate
            background: null
            contentItem: ColumnLayout {
                Controls.Label {
                    text: i18nc("@title:row", "How often does the plant need Fertilizing?")
                }
                Controls.ButtonGroup {
                    id: fertilizerButtonGroup
                }

                RowLayout {
                    id: fertilizeRow

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","2 days")
                        checkable: true
                        Controls.ButtonGroup.group: fertilizerButtonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.fertilizerInterval = 2
                    }

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","5 days")
                        checkable: true
                        Controls.ButtonGroup.group: fertilizerButtonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.fertilizerInterval = 5
                    }

                    Controls.Button {
                        text: i18nc("@action:button button to select preset time","weekly")
                        checkable: true
                        Controls.ButtonGroup.group: fertilizerButtonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.fertilizerInterval = 7
                    }

                    Controls.Button {
                        id: fertilizerButtonWeeks
                        text: i18nc("@action:button button to select preset time","2 weeks")
                        checkable: true
                        Controls.ButtonGroup.group: fertilizerButtonGroup
                        Layout.fillWidth: true
                        onClicked: plantEditor.plant.fertilizerInterval = 14
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Controls.Label {
                        text: i18nc("@title:row","Custom (days):")
                    }

                    Controls.SpinBox {
                        onValueChanged: plantEditor.plant.fertilizerInterval = value
                        value: plantEditor.plant.fertilizerInterval
                        Layout.fillWidth: true
                    }
                }
            }
        }

        FormCard.FormDelegateSeparator {
            visible: root.mode === PlantEditor.Creator
        }

        FormCard.AbstractFormDelegate {
            id: health
            visible: root.mode === PlantEditor.Creator
            background: null
            contentItem: ColumnLayout {
                Controls.Label {
                    text: i18nc("@title:row","How healthy is your plant at the moment?")
                }

                HealthSlider {
                    id: healthSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 200
                    from: 0
                    to: 100
                    onValueChanged: plantEditor.plant.currentHealth = value
                }
            }
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:row","Birthday")
    }

    FormCard.FormCard {
        FormCard.FormDateTimeDelegate {
            dateTimeDisplay: FormCard.FormDateTimeDelegate.DateTimeDisplay.Date
            initialValue: plantEditor.plant.dateOfBirth
            onValueChanged: plantEditor.plant.dateOfBirth = value
        }
    }

    footer: Controls.ToolBar {
        contentItem: RowLayout {
            Item {
                Layout.fillWidth: true
            }

            Controls.Button {
                text: plantEditor.mode === PlantEditor.Editor ? i18nc("@action:button","Save") : i18nc("@action:button","Add")
                icon.name: plantEditor.mode === PlantEditor.Editor ? "checkmark" : "list-add-symbolic"
                onClicked: {
                    plantEditor.save();
                    root.closeDialog();
                }
            }
            Controls.Button {
                text: i18nc("@action:button", "Cancel")
                icon.name: "dialog-cancel"
                onClicked: {
                    root.closeDialog();
                }
            }
        }
    }
}
