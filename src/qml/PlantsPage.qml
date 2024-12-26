// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as Components
import org.kde.kirigamiaddons.formcard as FormCard
import Qt5Compat.GraphicalEffects
import org.kde.powerplant

Kirigami.ScrollablePage {
    id: root
    rightPadding: 0
    //    leftPadding:0
    bottomPadding: 0
    Layout.fillWidth: true
    property bool wideScreen: applicationWindow().width >= 800

    title: i18n("Plants")
    actions: Kirigami.Action {
        icon.name: "help-about-symbolic"
        onTriggered: pageStack.pushDialogLayer(Qt.createComponent('org.kde.kirigamiaddons.formcard', 'AboutPage'))
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
            rightMargin: Kirigami.Units.largeSpacing + (root.contentItem.Controls.ScrollBar && root.contentItem.Controls.ScrollBar.vertical.visible ? root.contentItem.Controls.ScrollBar.vertical.width : 0)
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing
        }

        text: i18nc("@action:button", "Add Plant")
        icon.name: "list-add-symbolic"
        onClicked: applicationWindow().pageStack.pushDialogLayer(addPlantComponent, {}, {
            width: Kirigami.Units.gridUnit * 25,
            height: Kirigami.Units.gridUnit * 35
        })
    }

    GridView {
        id: grid

        cellWidth: applicationWindow().width < 500 ? grid.width / (Math.floor(grid.width / 160)) : grid.width / (Math.floor(grid.width / 230))
        cellHeight: 350

        header: GridLayout {
            flow: wideScreen ? GridLayout.LeftToRight : GridLayout.TopToBottom
            width: parent.width
            columnSpacing: 0

            ColumnLayout {
                id: welcomeTextLayout
                Layout.fillWidth:true
                spacing: 0

                Controls.Label {
                    text: i18n("Good Morning!")
                    font {
                        bold: true
                        pixelSize: 30
                    }

                    Layout.margins: Kirigami.Units.largeSpacing * 2
                    Layout.topMargin: Kirigami.Units.largeSpacing * 2
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
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
                }
            }

            Item { Layout.fillWidth: true }

            Controls.ScrollView {
                Layout.fillWidth: !wideScreen
                width: wideScreen ? root.width - welcomeTextLayout.width  - effectiveScrollBarHeight : root.width  - effectiveScrollBarHeight
                height: cardsLayout.height
                Layout.alignment: wideScreen ? Qt.AlignRight : Qt.AlignLeft

                RowLayout {
                    id: cardsLayout

                    spacing: 0

                    Layout.fillHeight: true

                    Controls.AbstractButton {
                        id: tasksCard

                        leftPadding: Kirigami.Units.largeSpacing
                        topPadding: Kirigami.Units.largeSpacing
                        rightPadding: Kirigami.Units.largeSpacing
                        bottomPadding: Kirigami.Units.largeSpacing

                        onClicked: pageStack.push(Qt.resolvedUrl("TaskPage.qml"));

                        Layout.fillWidth: false
                        Layout.fillHeight: true
                        Layout.margins: Kirigami.Units.largeSpacing
                        Layout.alignment: Qt.AlignRight

                        background: Kirigami.ShadowedRectangle {
                            radius: Kirigami.Units.cornerRadius
                            color: Kirigami.Theme.backgroundColor

                            border {
                                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
                                width: 1
                            }

                            shadow {
                                size: 15
                                xOffset: 5
                                yOffset: 5
                                color: Qt.rgba(0, 0, 0, 0.1)
                            }
                        }


                        contentItem: RowLayout {
                            id: tasksCardLayout

                            spacing: Kirigami.Units.largeSpacing

                            Rectangle {
                                height: Kirigami.Units.gridUnit  *1.5
                                width: height
                                radius: height/2
                                color: switch (plantsModel.summary) {
                                case PlantsModel.SomeNeedWater:
                                    return Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, "#f16445" , 0.5);
                                case PlantsModel.NothingToDo:
                                    return Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, "#b4e479" , 0.5);
                                }

                                Layout.alignment: Qt.AlignCenter

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    source: switch (plantsModel.summary) {
                                    case PlantsModel.SomeNeedWater:
                                        return "folder-important-symbolic";
                                    case PlantsModel.NothingToDo:
                                        return "answer-correct";
                                    }
                                    height: parent.height - Kirigami.Units.largeSpacing
                                }
                            }

                            Controls.Label {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true

                                text: {
                                    switch (plantsModel.summary) {
                                    case PlantsModel.SomeNeedWater:
                                        return i18n("Incomplete Tasks");
                                    case PlantsModel.NothingToDo:
                                        return i18n("All Tasks Complete");
                                    }
                                }
                            }
                        }
                    }

                    Controls.AbstractButton {
                        id: weatherCard

                        leftPadding: Kirigami.Units.largeSpacing
                        topPadding: Kirigami.Units.largeSpacing
                        rightPadding: Kirigami.Units.largeSpacing
                        bottomPadding: Kirigami.Units.largeSpacing

                        Layout.fillWidth: false
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight
                        Layout.margins: Kirigami.Units.largeSpacing

                        onClicked: locationDialog.open()

                        background: Kirigami.ShadowedRectangle {
                            radius: Kirigami.Units.cornerRadius
                            color: Kirigami.Theme.backgroundColor

                            border {
                                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
                                width: 1
                            }

                            shadow {
                                size: 15
                                xOffset: 5
                                yOffset: 5
                                color: Qt.rgba(0, 0, 0, 0.1)
                            }
                        }

                        contentItem: RowLayout {
                            id: weatherForecastLayout

                            spacing: Kirigami.Units.largeSpacing

                            Kirigami.Icon {
                                source: weatherforecast.iconName

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0

                                Kirigami.Heading {
                                    text: weatherforecast.location != ", " ? i18nc("temperature", "%1°C", weatherforecast.temperature) : "-- / --"
                                    level: 2

                                    Layout.fillWidth: true
                                }

                                Controls.Label {
                                    text: weatherforecast.location != ", " ? weatherforecast.location : i18n("Select your Location")

                                    Layout.fillWidth: true
                                }
                            }
                        }

                        WeatherForecast {
                            id: weatherforecast
                            locationSearchTerm: Config.weatherLocation
                        }

                        FormCard.FormCardDialog {
                            id: locationDialog
                            title: i18nc("@title:dialog", "Enter your Location")

                            parent: root
                            modal: true

                            standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                            onAccepted: locationTextField.accepted()
                            onOpened: locationTextField.forceActiveFocus()

                            FormCard.FormTextFieldDelegate {
                                id: locationTextField
                                label: i18n("Location name:")
                                onAccepted: {
                                    Config.weatherLocation = text
                                    Config.save()
                                    locationDialog.close()
                                }
                            }
                        }

                    }
                }
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
            required property string wantsToBeFertilizedIn
            required property int currentHealth
            required property var dateOfBirth
            required property int plantId

            WaterHistoryModel {
                id: waterEvents
                plantId: plantItem.plantId
            }
            FertilizerHistoryModel {
                id: fertilizerEvents
                plantId: plantItem.plantId
            }
            width: grid.cellWidth

            Kirigami.AbstractCard {
                id: card

                onClicked: pageStack.push(Qt.createComponent('org.kde.powerplant', 'PlantDetailPage'), {
                    "plantId": plantItem.plantId,
                    "plantsModel": plantsModel
                })

                background: Kirigami.ShadowedRectangle {
                    radius: 5
                    color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, healthSlider.healthColor, 0.2)

                    border {
                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
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
                            id: image
                            anchors.fill: parent
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
                Layout.margins: Kirigami.Units.largeSpacing
                padding: Kirigami.Units.mediumSpacing
                implicitHeight: grid.cellHeight - 2 * Layout.margins
                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Item {
                        Layout.fillHeight: true
                    }

                    Kirigami.Heading {
                        text: name
                        type: Kirigami.Heading.Type.Primary
                    }

                    Controls.Label {
                        text: species
                        color: Kirigami.Theme.disabledTextColor
                        visible: text.length > 0
                        Layout.topMargin: -Kirigami.Units.smallSpacing
                    }

                    TextIconBox {
                        Layout.fillWidth: true
                        showShadow: false
                        label {
                            text: if (wantsToBeWateredIn > 1) {
                                return i18ncp("@info", "In %1 day", "In %1 days", wantsToBeWateredIn);
                            } else if (wantsToBeWateredIn == 1) {
                                return i18nc("@info", "Tomorrow");
                            } else if (wantsToBeWateredIn == 0) {
                                return i18nc("@info", "Water today!");
                            } else if (wantsToBeWateredIn < 0) {
                                return i18nc("@info", "Watering overdue!");
                            }
                            font.bold: wantsToBeWateredIn <= 0
                        }
                        icon {
                            source: "raindrop-symbolic"
                            color: "#64ace1"
                        }
                        action {
                            icon.name: "answer-correct-symbolic"
                            onClicked: {
                                console.log(plantId);
                                waterEvents.waterPlant();
                            }
                            visible: wantsToBeWateredIn <= 0
                        }
                    }
                    TextIconBox {
                        Layout.fillWidth: true
                        showShadow: false
                        label {
                            text: if (wantsToBeFertilizedIn > 1) {
                                return i18ncp("@info", "In %1 day", "In %1 days", wantsToBeFertilizedIn);
                            } else if (wantsToBeFertilizedIn == 1) {
                                return i18nc("@info", "Tomorrow");
                            } else if (wantsToBeFertilizedIn == 0) {
                                return i18nc("@info", "Fertilize today!");
                            } else if (wantsToBeFertilizedIn < 0) {
                                return i18nc("@info", "Fertilizing overdue!");
                            }
                            font.bold: wantsToBeFertilizedIn <= 0
                        }
                        icon {
                            source: "raindrop-symbolic"
                            color: "yellow"
                        }
                        action {
                            icon.name: "answer-correct-symbolic"
                            onClicked: {
                                console.log(plantId);
                                fertilizerEvents.fertilizePlant();
                            }
                            visible: wantsToBeFertilizedIn <= 0
                        }
                    }

                    HealthSlider {
                        id: healthSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: currentHealth
                        enabled: false

                        Layout.bottomMargin: Kirigami.Units.gridUnit
                    }
                }
            }
        }
    }
}
