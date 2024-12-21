# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>

add_library(powerplant_static STATIC)
ecm_add_qml_module(powerplant_static
    GENERATE_PLUGIN_SOURCE
    URI org.kde.powerplant
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/PlantsPage.qml
        qml/HealthSlider.qml
        qml/PlantEditorPage.qml
        qml/PlantDetailPage.qml
        qml/NavigationBar.qml
        qml/TaskPage.qml
        qml/components/TextIconBox.qml
    DEPENDENCIES
        QtCore
        QtQuick
)

ecm_qt_declare_logging_category(powerplant_static
    HEADER powerplant_debug.h
    IDENTIFIER POWERPLANT_LOG
    CATEGORY_NAME org.kde.powerplant
    DESCRIPTION "powerplant"
    DEFAULT_SEVERITY Warning
    EXPORT POWERPLANT
)

target_sources(powerplant_static PRIVATE
    database.cpp database.h
    plantsmodel.cpp plantsmodel.h
    healthhistorymodel.cpp healthhistorymodel.h
    waterhistorymodel.cpp waterhistorymodel.h
    fertilizerhistorymodel.cpp fertilizerhistorymodel.h
    colorgradientinterpolator.cpp colorgradientinterpolator.h
    plantimagemodel.cpp plantimagemodel.h
    planteditor.cpp planteditor.cpp
)

target_link_libraries(powerplant_static PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    Qt::Widgets
    KF6::I18n
    KF6::I18nQml
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    FutureSQL6::FutureSQL
    QCoro6::Core)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
endif()

kconfig_target_kcfg_file(powerplant_static FILE powerplantconfig.kcfg CLASS_NAME Config MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS PARENT_IN_CONSTRUCTOR QML_REGISTRATION SINGLETON)

## Excutable
add_executable(powerplant main.cpp resources.qrc)
target_link_libraries(powerplant PRIVATE powerplant_static powerplant_staticplugin KF6::Crash)
install(TARGETS powerplant ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
