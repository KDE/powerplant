# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>

add_library(powerplant_static STATIC)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config-powerplant.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-powerplant.h)

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
    planteditor.cpp planteditor.h
    weathermodel.cpp weathermodel.h
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
    KWeatherCore
    FutureSQL6::FutureSQL
    QCoro6::Core)


if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        help-about-symbolic
        view-calendar-tasks-symbolic
        battery-profile-powersave-symbolic
        document-edit-symbolic
        delete-symbolic
        go-home-symbolic
        view-calendar-birthday-symbolic
        raindrop-symbolic
        answer-correct-symbolic
        list-add-symbolic

        ${KIRIGAMI_ADDONS_ICONS}
    )
endif()

kconfig_target_kcfg_file(powerplant_static FILE powerplantconfig.kcfg CLASS_NAME Config MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS PARENT_IN_CONSTRUCTOR QML_REGISTRATION SINGLETON)

## Executable
add_executable(powerplant main.cpp resources.qrc)

target_link_libraries(powerplant PRIVATE powerplant_static powerplant_staticplugin)
if (TARGET KF6::Crash)
   target_link_libraries(powerplant PRIVATE KF6::Crash)
endif()	
install(TARGETS powerplant ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

ecm_add_android_apk(powerplant ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)

