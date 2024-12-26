// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QTimer>
#include <KWeatherCore/WeatherForecastSource>
#include <KWeatherCore/LocationQueryResult>
#include <qqmlregistration.h>

#include <chrono>

class WeatherForecast : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString locationSearchTerm MEMBER m_locationSearchTerm NOTIFY locationSearchTermChanged)
    Q_PROPERTY(QString iconName READ iconName NOTIFY forecastChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY forecastChanged)
    Q_PROPERTY(float windSpeed READ windSpeed NOTIFY forecastChanged)
    Q_PROPERTY(double humidity READ humidity NOTIFY forecastChanged)
    Q_PROPERTY(QDateTime time READ time NOTIFY forecastChanged)
    Q_PROPERTY(QString location READ location NOTIFY forecastChanged)

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)


public:
    explicit WeatherForecast(QObject *parent = nullptr);

    void locationQuery();
    QDateTime time() const;
    QString iconName() const;
    double temperature() const;
    double windSpeed() const;
    double humidity() const;
    QString location() const;


    Q_SIGNAL void forecastChanged();
    Q_SIGNAL void locationSearchTermChanged();

    bool loading() const;
    void setLoading(bool loading);
    Q_SIGNAL void loadingChanged();

private:
    void loadData();
    QString m_locationSearchTerm;

    KWeatherCore::LocationQueryResult m_location;
    KWeatherCore::WeatherForecastSource m_source;
    KWeatherCore::HourlyWeatherForecast m_forecast;

    QTimer m_refreshTimer;
    bool m_loading;
};
