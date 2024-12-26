// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "weathermodel.h"

#include <KWeatherCore/LocationQuery>
#include <KWeatherCore/LocationQueryReply>

using namespace Qt::Literals::StringLiterals;
using namespace std::chrono_literals;

WeatherForecast::WeatherForecast(QObject *parent)
    : QObject(parent)
    , m_loading(true)
{
    connect(this, &WeatherForecast::locationSearchTermChanged, this, &WeatherForecast::locationQuery);
}

void WeatherForecast::locationQuery()
{
    auto *query = new KWeatherCore::LocationQuery(this);
    auto reply = query->query(m_locationSearchTerm);
    connect(reply, &KWeatherCore::Reply::finished, this, [this, reply]() {
        if (reply->result().empty()) {
            qWarning() << "Failed to resolve weather location";
            if (reply->error() != KWeatherCore::Reply::NoError) {
                qWarning() << reply->errorMessage();
            }
            return;
        };
        m_location = reply->result().front();

        reply->deleteLater();

        loadData();
    });

    // Set up refreshing
    m_refreshTimer.setInterval(20s);
    m_refreshTimer.setSingleShot(false);
    m_refreshTimer.callOnTimeout(this, &WeatherForecast::loadData);
    m_refreshTimer.start();
}


QDateTime WeatherForecast::time() const
{
    return m_forecast.date();
}

QString WeatherForecast::iconName() const
{
    return m_forecast.weatherIcon();
}

double WeatherForecast::temperature() const
{
    return m_forecast.temperature();
}

double WeatherForecast::windSpeed() const
{
    return m_forecast.windSpeed();
}

double WeatherForecast::humidity() const
{
    return m_forecast.humidity();
}

QString WeatherForecast::location() const
{
    return m_location.name() + u", "_s + m_location.countryName();
}


void WeatherForecast::loadData()
{
    qDebug() << "Fetching new weather forecast for" << m_location.latitude() << m_location.longitude();
    auto pending = m_source.requestData(m_location.latitude(), m_location.longitude());

    auto loadReceivedData = [=, this] {
        m_forecast = pending->value().dailyWeatherForecast().front().hourlyWeatherForecast().front();
        qDebug() << "Received forecast";
        pending->deleteLater();
        Q_EMIT forecastChanged();
        setLoading(false);
    };

    connect(pending, &KWeatherCore::PendingWeatherForecast::finished, this, loadReceivedData);

    connect(pending, &KWeatherCore::PendingWeatherForecast::finished, this, [this, pending, loadReceivedData] {
        if (pending->error() != KWeatherCore::Reply::NoError) {
            qDebug() << "Network error while fetching weather forecast";
            pending->deleteLater();
            setLoading(false);
        } else {
            loadReceivedData();
        }
    });
}

bool WeatherForecast::loading() const {
    return m_loading;
}

void WeatherForecast::setLoading(bool loading)
{
    m_loading = loading;
    Q_EMIT loadingChanged();
}
