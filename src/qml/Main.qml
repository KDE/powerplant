// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.config as KConfig
import org.kde.powerplant

Kirigami.ApplicationWindow {
    id: root

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    pageStack {
        popHiddenPages: true
        columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn

        globalToolBar {
            style: Kirigami.ApplicationHeaderStyle.ToolBar
            showNavigationButtons: {
                if (applicationWindow().pageStack.currentIndex > 0 || applicationWindow().pageStack.currentIndex > 0) {
                    Kirigami.ApplicationHeaderStyle.ShowBackButton;
                } else {
                    0;
                }
            }
        }
    }
    footer: NavigationBar {
        id: navigationbar
    }

    KConfig.WindowStateSaver {
        configGroupName: "Main"
    }
}
