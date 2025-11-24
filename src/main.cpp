/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
*/

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include <QFont>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "config-powerplant.h"
#include "version-powerplant.h"
#include <KAboutData>
#if HAVE_KCRASH
#include <KCrash>
#endif
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include <QCoro/QCoroFuture>

#ifdef Q_OS_WINDOWS
#include <Windows.h>
#endif

using namespace Qt::Literals::StringLiterals;

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));
#else
    QIcon::setFallbackThemeName(u"breeze"_s);
    QApplication app(argc, argv);
    // Default to org.kde.desktop style unless the user forces another style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
#endif

#ifdef Q_OS_WINDOWS
    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
    }

    QApplication::setStyle(QStringLiteral("breeze"));
    QFont font(QStringLiteral("Segoe UI Emoji"));
    font.setPointSize(10);
    font.setHintingPreference(QFont::PreferNoHinting);
    app.setFont(font);
#endif

    KLocalizedString::setApplicationDomain("powerplant");

    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("powerplant"),
        // A displayable program name string.
        i18nc("@title", "PowerPlant"),
        // The program version string.
        QStringLiteral(POWERPLANT_VERSION_STRING),
        // Short description of what the app does.
        i18n("A small app to track your plants"),
        // The license this code is released under.
        KAboutLicense::GPL,
        // Copyright Statement.
        i18n("© 2023-2024 Mathis Brüchert"));
    aboutData.addAuthor(i18nc("@info:credit", "Mathis Brüchert"), i18nc("@info:credit", "Author"), QStringLiteral("mbb@kaidan.im"));
    aboutData.setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"), i18nc("EMAIL OF TRANSLATORS", "Your emails"));
    KAboutData::setApplicationData(aboutData);
#if HAVE_KCRASH
    KCrash::initialize();
#endif
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.powerplant")));

    QQmlApplicationEngine engine;

    KLocalization::setupLocalizedContext(&engine);
    engine.loadFromModule(u"org.kde.powerplant"_s, u"Main"_s);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    return app.exec();
}
