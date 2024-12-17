// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.powerplant

Kirigami.NavigationTabBar {
    id: root

    visible: pageStack.layers.depth < 2
    actions: [
        Kirigami.Action {
            text: i18n("Plants")
            icon.name: "battery-profile-powersave"
            onTriggered: {
                while (pageStack.depth > 1) {
                    pageStack.pop();
                }
                pageStack.replace(Qt.resolvedUrl("PlantsPage.qml"));
            }
            Component.onCompleted: trigger()
        },
        Kirigami.Action {
            text: i18n("Tasks")
            icon.name: "view-calendar-tasks"
            onTriggered: {
                while (pageStack.depth > 1) {
                    pageStack.pop();
                }
                pageStack.replace(Qt.resolvedUrl("TaskPage.qml"));
            }
        }
    ]
}
