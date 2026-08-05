// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.powerplant

Kirigami.NavigationTabBar {
    id: navigationBar

    property var pageStack

    visible: pageStack.layers.depth < 2

    actions: [
        Kirigami.Action {
            text: i18nc("@action Navigation bar element", "Plants")
            icon.name: "battery-profile-powersave-symbolic"
            onTriggered: {
                while (navigationBar.pageStack.depth > 1) {
                    navigationBar.pageStack.pop();
                }
                navigationBar.pageStack.replace(Qt.resolvedUrl("PlantsPage.qml"));
            }
            Component.onCompleted: trigger()
        },
        Kirigami.Action {
            text: i18n("Tasks")
            icon.name: "view-calendar-tasks-symbolic"
            onTriggered: {
                while (navigationBar.pageStack.depth > 1) {
                    navigationBar.pageStack.pop();
                }
                navigationBar.pageStack.replace(Qt.resolvedUrl("TaskPage.qml"));
            }
        }
    ]
}
