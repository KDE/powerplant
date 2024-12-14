
import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
import org.kde.powerplant


Kirigami.ShadowedRectangle {
    property alias icon: icon
    property alias label: label
    property alias action: action
    property bool showShadow: true

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    readonly property real borderWidth: 1
    readonly property bool isDarkColor: {
        const temp = Qt.darker(Kirigami.Theme.backgroundColor, 1);
        return temp.a > 0 && getDarkness(Kirigami.Theme.backgroundColor) >= 0.4;
    }

    function getDarkness(background: color): real {
        // Thanks to Gojir4 from the Qt forum
        // https://forum.qt.io/topic/106362/best-way-to-set-text-color-for-maximum-contrast-on-background-color/
        var temp = Qt.darker(background, 1);
        var a = 1 - ( 0.299 * temp.r + 0.587 * temp.g + 0.114 * temp.b);
        return a;
    }

    border {
        color: showShadow? (isDarkColor ? Qt.darker(Kirigami.Theme.backgroundColor, 1.2) : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)) : Kirigami.ColorUtils.linearInterpolation(
                               Kirigami.Theme.backgroundColor,
                               Kirigami.Theme.textColor, 0.3)
        width: borderWidth
    }

    radius: Kirigami.Units.cornerRadius
    color: Kirigami.Theme.backgroundColor

    height: waterInLayout.implicitHeight + Kirigami.Units.mediumSpacing
    shadow {
        size: showShadow ? (isDarkColor ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing) : 0
        color: Qt.alpha(Kirigami.Theme.textColor, 0.10)
    }

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
