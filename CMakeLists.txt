# SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

project(powerplant VERSION 0.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FeatureSummary)

set(QT_MIN_VERSION 6.6)
set(KF_MIN_VERSION 6.12)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMQmlModule)
include(ECMDeprecationSettings)
include(ECMAddAndroidApk)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX POWERPLANT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/version-powerplant.h"
)

kde_enable_exceptions()

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2 Svg Widgets)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami CoreAddons Config I18n )
find_package(KWeatherCore REQUIRED)

if (NOT ANDROID)
   find_package(KF6 ${KF_MIN_VERSION} OPTIONAL_COMPONENTS Crash)
endif()

find_package(KF6KirigamiAddons 1.6.0)
set_package_properties(KF6KirigamiAddons PROPERTIES
    TYPE REQUIRED
    PURPOSE "Required application components and runtime dependency"
)

if (TARGET KF6::Crash)
    set(HAVE_KCRASH TRUE)
endif()

find_package(FutureSQL6 REQUIRED)
find_package(QCoro6 REQUIRED COMPONENTS Core)

ecm_set_disabled_deprecation_versions(QT 6.8.1
    KF 6.10.0
)

add_subdirectory(src)

ki18n_install(po)

install(PROGRAMS org.kde.powerplant.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.powerplant.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.powerplant.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
