#include "database.h"

#include <QStandardPaths>
#include <ThreadedDatabase>
#include <QDir>
#include <QStringBuilder>
#include <QDateTime>
#include <QCoroTask>
#include <QCoroFuture>

using namespace DB;

HealthEvent::HealthEvent(int _health_date, int _health)
    : health_date(_health_date)
    , health(_health)
{}

Database::Database()
{
    const auto databaseDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // Make sure the database directory exists
    QDir(databaseDirectory).mkpath(QStringLiteral("."));

    DatabaseConfiguration config;
    config.setDatabaseName(databaseDirectory % QDir::separator() % "plants.sqlite");
    config.setType(DatabaseType::SQLite);

    m_database = ThreadedDatabase::establishConnection(config);
    m_database->runMigrations(":/contents/migrations/");
}

QCoro::Task<DB::Plant::Id> Database::addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int lastWatered, const int healthDate, const int health)
{
    auto id = co_await m_database->getResult<SingleValue<int>>("insert into plants (name, species, img_url, water_intervall, location, date_of_birth) values (?, ?, ?, ?, ?, ?) returning plant_id", name, species, imgUrl, waterInterval, location, dateOfBirth);

    m_database->execute("insert into water_history (plant_id, water_date) values (?, ?)", id.value().value, lastWatered);
    m_database->execute("insert into health_history (plant_id, health_date, health) values (?, ?, ?)", id.value().value, healthDate, health);

    co_return id.value().value;
}

void Database::editPlant(const DB::Plant::Id plantId, const QString &name, const QString &species, const QString &imgUrl, const int waterIntervall, const QString location, const int dateOfBirth)
{

    auto future = m_database->getResult<SingleValue<int>>("update plants SET name = ?, species = ?, img_url = ?, water_intervall = ?, location = ?, date_of_birth = ? where plant_id = ?", name, species, imgUrl, waterIntervall, location, dateOfBirth, plantId);
    QCoro::connect(std::move(future), this, [=, this](auto) {
        Q_EMIT plantChanged(plantId);
    });
}

QFuture<std::vector<Plant>> Database::plants()
{
    return m_database->getResults<Plant>(R"(
    select
        plants.plant_id, name, species, img_url, water_intervall, location, date_of_birth, parent, max(water_date), max(health_date) as latest_health_date, health
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
    group by
        plants.plant_id
    )" );
}

QFuture<std::optional<Plant>> Database::plant(int plant_id)
{
    return m_database->getResult<Plant>(R"(
    select
        plants.plant_id, name, species, img_url, water_intervall, location, date_of_birth, parent, max(water_date), max(health_date) as latest_health_date, health
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
    where plants.plant_id = ?
    group by
        plants.plant_id
    )", plant_id);
}

QFuture<std::vector<SingleValue<int>>> Database::waterEvents(int plantId)
{
    return m_database->getResults<SingleValue<int>>("select water_date from water_history where plant_id = ?", plantId);
}

QFuture<std::vector<HealthEvent>> Database::healthEvents(int plantId)
{
    return m_database->getResults<HealthEvent>("select health_date, health from health_history where plant_id = ?", plantId);
}

void Database::waterPlant(const int plantId, const int waterDate)
{
    m_database->execute("insert into water_history (plant_id, water_date) values (?, ?)", plantId, waterDate);
}

void Database::addHealthEvent(const int plantId, const int waterDate, const int health)
{
    m_database->execute("insert into health_history (plant_id, health_date, health) values (?, ?, ?)", plantId, waterDate, health);
}

QFuture<std::optional<SingleValue<int>>> Database::getLastHealthDate(const int plantId)
{
    return m_database->getResult<SingleValue<int>>("select health_date from health_history where plant_id = ? order by desc limit 1", plantId);

}

//void Database::replaceLastHealthEvent(const int plantId, const int waterDate, const int health)
//{
//    m_database->execute("insert into health_history (plant_id, health_date, health) values (?, ?, ?)", plantId, waterDate, health);
//}

Database &Database::instance()
{
    static Database inst;
    return inst;
}
