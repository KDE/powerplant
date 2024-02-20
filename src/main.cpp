/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>
#include <QIcon>

#include "app.h"
#include "database.h"
#include "planteditor.h"
#include "plantimagemodel.h"
#include "colorgradientinterpolator.h"
#include "plantsmodel.h"
#include "waterhistorymodel.h"
#include "healthhistorymodel.h"
#include "version-powerplant.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include <QCoro/QCoroTask>
#include <QCoro/QCoroFuture>

#include "powerplantconfig.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("powerplant");

    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("powerplant"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("PowerPlant"),
                         // A displayable program name string.
                         i18nc("@title", "PowerPlant"),
                         // The program version string.
                         QStringLiteral(POWERPLANT_VERSION_STRING),
                         // Short description of what the app does.
                         i18n("A small app to track your plants"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) 2023"));
    aboutData.addAuthor(i18nc("@info:credit", "Mathis Brüchert"),
                        i18nc("@info:credit", "Author"),
                        QStringLiteral("mbb@kaidan.im"));
    KAboutData::setApplicationData(aboutData);

    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.powerplant")));

    QQmlApplicationEngine engine;

    auto config = powerplantConfig::self();

    qmlRegisterSingletonInstance("org.kde.powerplant", 1, 0, "Config", config);

    qmlRegisterType<WaterHistoryModel>("org.kde.powerplant", 1, 0, "WaterHistoryModel");
    qmlRegisterType<HealthHistoryModel>("org.kde.powerplant", 1, 0, "HealthHistoryModel");
    qmlRegisterType<Plant>("org.kde.powerplant", 1, 0, "Plant");
    qmlRegisterType<PlantEditor>("org.kde.powerplant", 1, 0, "PlantEditor");
    qmlRegisterType<PlantsModel>("org.kde.powerplant", 1, 0, "PlantsModel");
    qmlRegisterType<PlantImageModel>("org.kde.powerplant", 1, 0, "PlantImageModel");
    qmlRegisterType<ColorGradientInterpolator>("org.kde.powerplant", 1, 0, "ColorInterpolator");

    qmlRegisterSingletonType("org.kde.powerplant", 1, 0, "About", [](QQmlEngine *engine, QJSEngine *) -> QJSValue {
        return engine->toScriptValue(KAboutData::applicationData());
    });


    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    return app.exec();
}
