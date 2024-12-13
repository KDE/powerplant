
import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
import org.kde.powerplant


Kirigami.ShadowedRectangle {
    property alias icon: icon
    property alias label: label
    property alias action: action

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    border.color: Kirigami.ColorUtils.linearInterpolation(
                      Kirigami.Theme.backgroundColor,
                      Kirigami.Theme.textColor, 0.3)
    border.width: 1
    color: Kirigami.Theme.backgroundColor
    radius: 5
    height: waterInLayout.implicitHeight + Kirigami.Units.mediumSpacing
    RowLayout {
        id: waterInLayout
        anchors.fill: parent
        Kirigami.Icon {
            id: icon
            isMask: true
            implicitHeight: Kirigami.Units.gridUnit * 1.5
        }
        Controls.Label {
            id: label
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
            elide: Qt.ElideRight
            color: Kirigami.Theme.disabledTextColor
        }
        Controls.ToolButton {
            id: action
            implicitHeight: Kirigami.Units.gridUnit * 1.5
            Layout.rightMargin: 3
            Layout.margins: 0
            visible: false
        }
    }
}
