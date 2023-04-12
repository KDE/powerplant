// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.powerplant 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("powerplant")

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    pageStack.initialPage: "qrc:/PlantsPage.qml"

    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton
    pageStack.popHiddenPages:true
    pageStack.columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn

}
