import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import QtQuick.Shapes 1.5 as Shapes
import QtGraphicalEffects 1.0

import "ColorInterpolation"

Controls.Slider {
    id: control

    implicitHeight: 30
    property int weirdNumber: 25
    property string healthColor: colorInterpolation.getColorAt(control.value/100)
    ColorInterpolation {
            id: colorInterpolation
            stops: [
                InterpolationStop { position: gradientStop1.position; color: gradientStop1.color },
                InterpolationStop { position: gradientStop2.position; color: gradientStop2.color },
                InterpolationStop { position: gradientStop3.position; color: gradientStop3.color }

            ]
        }
    background: Rectangle {
            id: background
            x: control.leftPadding
            y: control.topPadding + weirdNumber - height / 2
            implicitWidth: 200
            implicitHeight: 15
            width: control.availableWidth
            height: implicitHeight
            radius: 5
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3);
            border.width: 1
            Rectangle{
                property int margin : 2
                width: parent.width - margin * 2
                height: parent.height - margin * 2
                anchors.centerIn: parent
                radius: parent.radius-margin/2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        id: gradientStop1
                        position: 0.0
                        color: "#c8c196"
                    }
                    GradientStop {
                        id: gradientStop2

                        position: 0.33
                        color: "#e5d975"
                    }
                    GradientStop {
                        id: gradientStop3

                        position: 1.0
                        color: "#b4e479"
                    }
                }
            }

        }
        DropShadow {
            z: handleShape.z-1
            anchors.fill: handleShape
            horizontalOffset: 2
            verticalOffset: 2
            radius: 10
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.3)
            source: handleShape
        }
        handle: Shapes.Shape {
            Rectangle {
                height: 10
                width: 10
                radius: 5
                color: healthColor
                border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3);
                border.width: 1
                x: - 4.5
                y: - 5

            }
            id: handleShape
            x: control.leftPadding + control.visualPosition * (control.availableWidth)
            y: control.topPadding + weirdNumber - height / 2
            implicitWidth: 26
            implicitHeight: 26
            antialiasing: true
            Shapes.ShapePath {
                strokeWidth: 1
                strokeColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3);
                fillGradient: Shapes.LinearGradient {
                    x1: 0; y1: 0
                    x2: 0; y2: 26
                    GradientStop { position: 0; color: Kirigami.Theme.backgroundColor }
                    GradientStop { position: 1; color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3); }
                }
                PathSvg { path: "m 0.238879,-10.451756 c -5.236275,0 -9.481142,4.1008135 -9.481142,9.1594965 0,11.5813965 9.481142,18.3189895 9.481142,18.3189895 0,0 9.481178,-6.737593 9.481178,-18.3189895 0,-5.058683 -4.244867,-9.1594965 -9.481178,-9.1594965 z" }
            }
        }


}
