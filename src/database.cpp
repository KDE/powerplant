// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "database.h"

#include <QCoroFuture>
#include <QCoroTask>
#include <QDateTime>
#include <QDir>
#include <QStandardPaths>
#include <QStringBuilder>
#include <ThreadedDatabase>

using namespace DB;
using namespace Qt::Literals::StringLiterals;

HealthEvent::HealthEvent(int _health_date, int _health)
    : health_date(_health_date)
    , health(_health)
{
}

Database::Database()
{
    const auto databaseDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    // Make sure the database directory exists
    QDir(databaseDirectory).mkpath(QStringLiteral("."));

    QFile file(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + u"/KDE/PowerPlant/plants.sqlite"_s);
    if (file.exists()) {
        QFile::remove(databaseDirectory + u"/plants.sqlite"_s);
        const auto ok = file.rename(databaseDirectory + u"/plants.sqlite"_s);
        if (!ok) {
            qWarning() << "Failed copying legacy file location to new location";
        }
    }

    DatabaseConfiguration config;
    config.setDatabaseName(databaseDirectory + u"/plants.sqlite"_s);
    config.setType(DatabaseType::SQLite);

    m_database = ThreadedDatabase::establishConnection(config);
    m_database->runMigrations(u":/contents/migrations/"_s);
}

QCoro::Task<DB::Plant::Id> Database::addPlant(const QString &name,
                                              const QString &species,
                                              const QString &imgUrl,
                                              const int waterInterval,
                                              const int fertilizerInterval,
                                              const QString location,
                                              const int dateOfBirth,
                                              const int lastWatered,
                                              const int lastFertilized,
                                              const int healthDate,
                                              const int health)
{
    auto id = co_await m_database->getResult<SingleValue<int>>(
        u"insert into plants (name, species, img_url, water_intervall, fertilizer_interval, location, date_of_birth) values (?, ?, ?, ?, ?, ?, ?) returning plant_id"_s,
        name,
        species,
        imgUrl,
        waterInterval,
        fertilizerInterval,
        location,
        dateOfBirth);

    m_database->execute(u"insert into water_history (plant_id, water_date) values (?, ?)"_s, id.value().value, lastWatered);
    m_database->execute(u"insert into fertilizer_history (plant_id, fertilizer_date) values (?, ?)"_s, id.value().value, lastFertilized);
    m_database->execute(u"insert into health_history (plant_id, health_date, health) values (?, ?, ?)"_s, id.value().value, healthDate, health);

    co_return id.value().value;
}

void Database::editPlant(const DB::Plant::Id plantId,
                         const QString &name,
                         const QString &species,
                         const QString &imgUrl,
                         const int waterInterval,
                         const int fertilizerInterval,
                         const QString location,
                         const int dateOfBirth)
{
    auto future = m_database->getResult<SingleValue<int>>(
        u"update plants SET name = ?, species = ?, img_url = ?, water_intervall = ?, fertilizer_interval = ?,  location = ?, date_of_birth = ? where plant_id = ?"_s,
        name,
        species,
        imgUrl,
        waterInterval,
        fertilizerInterval,
        location,
        dateOfBirth,
        plantId);
    QCoro::connect(std::move(future), this, [=, this](auto) {
        Q_EMIT plantChanged(plantId);
    });
}

void Database::deletePlant(const DB::Plant::Id plantId)
{
    auto future = m_database->execute(u"delete from plants where plant_id = ?"_s, plantId);
    QCoro::connect(std::move(future), this, [=, this]() {
        m_database->execute(u"delete from water_history where plant_id = ?"_s, plantId);
        m_database->execute(u"delete from health_history where plant_id = ?"_s, plantId);
        Q_EMIT plantChanged(plantId);
    });
}
QFuture<std::vector<Plant>> Database::plants()
{
    return m_database->getResults<Plant>(QStringLiteral(R"(
    select
        plants.plant_id, name, species, img_url, water_intervall, fertilizer_interval, location, date_of_birth, parent, max(water_date), max(fertilizer_date), max(health_date) as latest_health_date, health
    from
        plants
    left join
        water_history
    on
        plants.plant_id = water_history.plant_id
    left join
        health_history
    on
        plants.plant_id = health_history.plant_id
    left join
        fertilizer_history
    on
        plants.plant_id = fertilizer_history.plant_id
    group by
        plants.plant_id
    )"));
}

QFuture<std::optional<Plant>> Database::plant(int plant_id)
{
    return m_database->getResult<Plant>(QStringLiteral(R"(
    select
        plants.plant_id, name, species, img_url, water_intervall, fertilizer_interval, location, date_of_birth, parent, max(water_date), max(fertilizer_date), max(health_date) as latest_health_date, health
    from
        plants
    left join
        water_history
    on
        plants.plant_id = water_history.plant_id
    left join
        health_history
    on
        plants.plant_id = health_history.plant_id
    left join
        fertilizer_history
    on
        plants.plant_id = fertilizer_history.plant_id
    where plants.plant_id = ?
    group by
        plants.plant_id
    )"), plant_id);
}

QFuture<std::vector<SingleValue<int>>> Database::waterEvents(int plantId)
{
    return m_database->getResults<SingleValue<int>>(u"select water_date from water_history where plant_id = ?"_s, plantId);
}

QFuture<std::vector<SingleValue<int>>> Database::fertilizerEvents(int plantId)
{
    return m_database->getResults<SingleValue<int>>(u"select fertilizer_date from fertilizer_history where plant_id = ?"_s, plantId);
}

QFuture<std::vector<HealthEvent>> Database::healthEvents(int plantId)
{
    return m_database->getResults<HealthEvent>(u"select health_date, health from health_history where plant_id = ?"_s, plantId);
}

void Database::waterPlant(const int plantId, const int waterDate)
{
    m_database->execute(u"insert into water_history (plant_id, water_date) values (?, ?)"_s, plantId, waterDate);
    Q_EMIT plantChanged(plantId);
}

void Database::fertilizePlant(const int plantId, const int fertilizerDate)
{
    m_database->execute(u"insert into fertilizer_history (plant_id, fertilizer_date) values (?, ?)"_s, plantId, fertilizerDate);
    Q_EMIT plantChanged(plantId);
}

void Database::addHealthEvent(const int plantId, const int waterDate, const int health)
{
    m_database->execute(u"insert into health_history (plant_id, health_date, health) values (?, ?, ?)"_s, plantId, waterDate, health);
    Q_EMIT plantChanged(plantId);
}

QFuture<std::optional<SingleValue<int>>> Database::getLastHealthDate(const int plantId)
{
    return m_database->getResult<SingleValue<int>>(u"select health_date from health_history where plant_id = ? order by desc limit 1"_s, plantId);
}

// void Database::replaceLastHealthEvent(const int plantId, const int waterDate, const int health)
//{
//     m_database->execute("insert into health_history (plant_id, health_date, health) values (?, ?, ?)", plantId, waterDate, health);
// }

Database &Database::instance()
{
    static Database inst;
    return inst;
}
