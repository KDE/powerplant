// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Shapes as Shapes
import Qt5Compat.GraphicalEffects
import org.kde.powerplant

Controls.Slider {
    id: root
    focusPolicy: Qt.TabFocus

    implicitHeight: 30
    property int weirdNumber: 25
    property string healthColor: colorInterpolation.color

    readonly property var gradient: [
        { position: 0.0, color: "#c8c196" },
        { position: 0.33, color: "#e5d975" },
        { position: 1.0, color: "#b4e479" },
    ]

    ColorInterpolator {
        id: colorInterpolation
        progress: root.value / 100
        gradientStops: [
            {
                "position": root.gradient[0].position,
                "color": root.gradient[0].color
            },
            {
                "position": root.gradient[1].position,
                "color": root.gradient[1].color
            },
            {
                "position": root.gradient[2].position,
                "color": root.gradient[2].color
            }
        ]
    }
    background: Rectangle {
        id: background
        x: root.leftPadding
        y: root.topPadding + weirdNumber - height / 2
        implicitWidth: 200
        implicitHeight: 15
        width: root.availableWidth
        height: implicitHeight
        radius: 5
        border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
        border.width: 1
        Rectangle {
            property int margin: 2
            width: parent.width - margin * 2
            height: parent.height - margin * 2
            anchors.centerIn: parent
            radius: parent.radius - margin / 2

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    id: gradientStop1
                    position: root.gradient[0].position
                    color: root.gradient[0].color
                }
                GradientStop {
                    id: gradientStop2

                    position: root.gradient[1].position
                    color: root.gradient[1].color
                }
                GradientStop {
                    id: gradientStop3

                    position: root.gradient[1].position
                    color: root.gradient[2].color
                }
            }
        }
    }
    DropShadow {
        z: handleShape.z - 1
        anchors.fill: handleShape
        horizontalOffset: 2
        verticalOffset: 2
        radius: 10
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.3)
        source: handleShape
    }
    handle: Shapes.Shape {
        id: handleShape
        Rectangle {
            height: 10
            width: 10
            radius: 5
            color: healthColor
            border.color: root.hovered || root.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
            border.width: 1
            x: -4.5
            y: -5
        }
        x: root.leftPadding + root.visualPosition * (root.availableWidth)
        y: root.topPadding + weirdNumber - height / 2
        implicitWidth: 26
        implicitHeight: 26
        antialiasing: true
        Shapes.ShapePath {
            strokeWidth: 1
            strokeColor: root.hovered || root.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
            fillGradient: Shapes.LinearGradient {
                x1: 0
                y1: 0
                x2: 0
                y2: 26
                GradientStop {
                    position: 0
                    color: Kirigami.Theme.backgroundColor
                }
                GradientStop {
                    position: 1
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.3)
                }
            }
            PathSvg {
                path: "m 0.238879,-10.451756 c -5.236275,0 -9.481142,4.1008135 -9.481142,9.1594965 0,11.5813965 9.481142,18.3189895 9.481142,18.3189895 0,0 9.481178,-6.737593 9.481178,-18.3189895 0,-5.058683 -4.244867,-9.1594965 -9.481178,-9.1594965 z"
            }
        }
    }
}
