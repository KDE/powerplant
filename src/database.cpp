#include "database.h"

#include <QStandardPaths>
#include <ThreadedDatabase>
#include <QDir>
#include <QStringBuilder>

#include <QCoroTask>
#include <QCoroFuture>

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

void Database::addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int lastWatered, const int healthDate, const int health)
{
    auto future = m_database->getResult<SingleValue<int>>("insert into plants (name, species, img_url, water_intervall, location, date_of_birth) values (?, ?, ?, ?, ?, ?) returning plant_id", name, species, imgUrl, waterInterval, location, dateOfBirth);
    QCoro::connect(std::move(future), this, [=, this](auto id) {
        m_database->execute("insert into water_history (plant_id, water_date) values (?, ?)", id.value().value, lastWatered);
        m_database->execute("insert into health_history (plant_id, health_date, health) values (?, ?, ?)", id.value().value, healthDate, health);
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
    return m_database->getResult<Plant>("select * from plants where plant_id = ?", plant_id);
}

Database &Database::instance()
{
    static Database inst;
    return inst;
}
