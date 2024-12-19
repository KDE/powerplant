/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
*/

#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "version-powerplant.h"
#include <KAboutData>
#include <KCrash>
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include <QCoro/QCoroFuture>

using namespace Qt::Literals::StringLiterals;

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
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
    KAboutData::setApplicationData(aboutData);

    KCrash::initialize();

    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.powerplant")));

    QQmlApplicationEngine engine;

    KLocalization::setupLocalizedContext(&engine);
    engine.loadFromModule(u"org.kde.powerplant"_s, u"Main"_s);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    return app.exec();
}
