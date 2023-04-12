# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

add_executable(powerplant
    main.cpp
    about.cpp
    app.cpp
    database.cpp
    plantsmodel.cpp
    healthhistorymodel.cpp
    waterhistorymodel.cpp
    resources.qrc)

target_link_libraries(powerplant
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigCore
    KF5::ConfigGui
    FutureSQL5::FutureSQL
    QCoro5::Core)

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
