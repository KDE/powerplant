# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

add_executable(powerplant
    main.cpp
    app.cpp
    database.cpp
    plantsmodel.cpp
    healthhistorymodel.cpp
    waterhistorymodel.cpp
    colorgradientinterpolator.cpp
    plantimagemodel.cpp
    planteditor.cpp
    resources.qrc
)

target_link_libraries(powerplant
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    Qt::Widgets
    KF${QT_MAJOR_VERSION}::I18n
    KF${QT_MAJOR_VERSION}::CoreAddons
    KF${QT_MAJOR_VERSION}::ConfigCore
    KF${QT_MAJOR_VERSION}::ConfigGui
    FutureSQL${QT_MAJOR_VERSION}::FutureSQL
    QCoro${QT_MAJOR_VERSION}::Core)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
endif()

kconfig_add_kcfg_files(powerplant GENERATE_MOC powerplantconfig.kcfgc)
install(TARGETS powerplant ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
