#pragma once

#include <tuple>
#include <threadeddatabase.h>
#include <QCoroTask>

namespace DB
{

struct Plant
{
    using Id = int;
    using ColumnTypes = std::tuple<int, QString, QString, QString, int, int, QString, int, int, int, int, int, int>;

    Plant::Id plant_id;
    QString name;
    QString species;
    QString img_url;
    int water_interval;
    int fertilizer_interval;
    QString location;
    int date_of_birth;
    int parent_id;
    int last_watered;
    int last_fertilized;
    int last_health_date;
    int current_health;
};

struct HealthEvent
{
    using ColumnTypes = std::tuple<int, int>;
    explicit HealthEvent(int health_date, int health);
    int health_date;
    int health;
};

}

class Database : public QObject
{
    Q_OBJECT
public:
    Database();

    QCoro::Task<DB::Plant::Id> addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const int fertilizerInterval, const QString location, const int dateOfBirth, const int lastWatered, const int lastFertilized, const int healthDate, const int health);
    void editPlant(const DB::Plant::Id plantId, const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const int fertilizerInterval, const QString location, const int dateOfBirth);
    void deletePlant(const DB::Plant::Id plantId);
    QFuture<std::vector<DB::Plant>> plants();
    QFuture<std::optional<DB::Plant>> plant(int plant_id);
    QFuture<std::vector<SingleValue<int>>> waterEvents(int plantId);
    QFuture<std::vector<SingleValue<int>>> fertilizerEvents(int plantId);
    QFuture<std::vector<DB::HealthEvent>> healthEvents(int plantId);
    void waterPlant(const int plantId, const int waterDate);
    void fertilizePlant(const int plantId, const int fertilizerDate);
    void addHealthEvent(const int plantId, const int healthDate, const int health);
    QFuture<std::optional<SingleValue<int>>> getLastHealthDate(const int plantId);
//    void replaceLastHealthEvent(const int plantId, const int waterDate, const int health);
    static Database & instance();

Q_SIGNALS:
    void plantChanged(const DB::Plant::Id plantId);


private:
    std::unique_ptr<ThreadedDatabase> m_database;

};
