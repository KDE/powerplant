// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import org.kde.powerplant 1.0

Kirigami.OverlaySheet {
    id: root
    property PlantsModel plantsModel
    property int waterInterval : 2
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
    leftPadding: 0
    rightPadding: 0

    //    standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.Cancel
    title: i18n("Add Plant")
    ColumnLayout {

        MobileForm.FormCard {
            Layout.topMargin: 20
            Layout.fillWidth: true
            contentItem: ColumnLayout {
                spacing: 0
                MobileForm.FormTextFieldDelegate {
                    id: imgUrl
                    label: i18n("Image Url")
                }
                MobileForm.FormDelegateSeparator {}
                MobileForm.FormTextFieldDelegate {
                    id: name
                    label: i18n("Name")
                }
                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextFieldDelegate {
                    id: species
                    label: i18n("Species")
                }
                MobileForm.FormDelegateSeparator {}
                MobileForm.FormTextFieldDelegate {
                    id: location
                    label: i18n("Room")
                }
                MobileForm.FormDelegateSeparator {}

                MobileForm.AbstractFormDelegate {
                    id: interval
                    background: Item {}
                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: "How often does the plant need Watering?"
                        }
                        Controls.ButtonGroup {
                            id: buttonGroup
                        }
                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            id: row

                            Controls.Button {
                                text: "2 days"
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: waterInterval = 2
                            }
                            Controls.Button {
                                text: "5 days"
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: waterInterval = 5

                            }
                            Controls.Button {
                                text: "weekly"
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: waterInterval = 7

                            }
                            Controls.Button {
                                text: "2 weeks"
                                checkable: true
                                Layout.fillWidth: true
                                Controls.ButtonGroup.group: buttonGroup
                                onClicked: waterInterval = 14

                            }
                            Controls.Label {
                                text: "custom:"

                            }
                            Controls.SpinBox {
                                onValueChanged: waterInterval = value
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
                MobileForm.FormDelegateSeparator {}
                MobileForm.AbstractFormDelegate {
                    id: health
                    background: Item {}
                    contentItem: ColumnLayout {
                        Controls.Label {
                            text: "How healthy is your plant at the moment?"
                        }

                        HealthSlider {
                            id: healthSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 200
                            from:0
                            to:100
                        }
                    }
                }

            }
        }
        Controls.Label {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            text: ""
            wrapMode: Text.WordWrap
        }
    }
    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }
        Controls.Button {
            text: i18n("Add")
            icon.name: "list-add"
            onClicked: {
                plantsModel.addPlant(name.text, species.text, imgUrl.text, waterInterval, location.text, 0, healthSlider.value)
                root.close()
            }
        }
    }
}
