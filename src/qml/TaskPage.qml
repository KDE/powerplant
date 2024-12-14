import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.powerplant
import org.kde.kirigamiaddons.formcard as FormCard
import QtQuick.Layouts
import org.kde.kitemmodels

Kirigami.ScrollablePage {
    id: root
    title: i18n("Tasks")

    rightPadding: 0
    leftPadding: 0
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    ListView {
        // model:
        model: KSortFilterProxyModel {
                   id: filterModel
                   property int sortOrder: Qt.AscendingOrder
                   sortRole: PlantsModel.WantsToBeWateredIn
                   sourceModel:PlantsModel {
                        id: plantsModel

                        onModelReset:{
                            console.warn("hey")
                            filterModel.sort(0, filterModel.sortOrder)
                        }
                    }
                   Component.onCompleted: filterModel.sort(0, filterModel.sortOrder)
               }


        delegate: ColumnLayout {
            id: taskDelegate

            required property string imgUrl
            required property string name
            required property string species
            required property string wantsToBeWateredIn
            required property string location
            required property int currentHealth
            required property var dateOfBirth
            required property int plantId

            width: root.width

            FormCard.FormCard {
                Layout.bottomMargin: Kirigami.Units.largeSpacing
                FormCard.AbstractFormDelegate {
                    height: delegateLayout.height
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        id: delegateLayout
                        Rectangle{
                            Layout.margins: Kirigami.Units.largeSpacing * 2
                            radius: height/2
                            width: Kirigami.Units.gridUnit * 4
                            height: width
                            color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor,healthSlider.healthColor, 0.3)
                            HealthSlider {
                                id: healthSlider
                                visible: false
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: taskDelegate.currentHealth
                                enabled: false

                                Layout.bottomMargin: 20
                            }
                            Image {
                                anchors.fill: parent
                                source: taskDelegate.imgUrl
                            }
                        }

                        ColumnLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Kirigami.Heading {
                                text: taskDelegate.name
                                type: Kirigami.Heading.Type.Primary
                                Layout.bottomMargin: - Kirigami.Units.smallSpacing


                            }
                            Controls.Label {
                                text: taskDelegate.location
                                color: Kirigami.Theme.disabledTextColor
                                Layout.bottomMargin: Kirigami.Units.smallSpacing
                            }
                            Rectangle{
                                color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor,"#64ace1", 0.3)


                                radius: height/2
                                height: actionLabel.height + Kirigami.Units.smallSpacing
                                width: actionLabel.width + Kirigami.Units.smallSpacing * 7

                                Controls.Label {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: i18n("water")
                                }

                            }

                        }

                    }
                }
            }
        }
        section {
            property: "wantsToBeWateredIn"
            delegate: FormCard.FormHeader {
                title: i18n("in %1 days",section)
                width: root.width

            }
        }

    }
}
