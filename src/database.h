#pragma once

#include <tuple>
#include <threadeddatabase.h>

struct Plant
{
    using ColumnTypes = std::tuple<int, QString, QString, QString, int, QString, int, int, int, int, int>;

    int plant_id;
    QString name;
    QString species;
    QString img_url;
    int water_intervall;
    QString location;
    int date_of_birth;
    int parent_id;
    int last_watered;
    int last_health_date;
    int current_health;
};

struct HealthEvent
{
    using ColumnTypes = std::tuple<int, int>;
    int health_date;
    int health;
};

class Database : public QObject
{
    Q_OBJECT
public:
    Database();

    void addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int lastWatered, const int healthDate, const int health);
    QFuture<std::vector<Plant>> plants();
    QFuture<std::optional<Plant>> plant(int plant_id);
    QFuture<std::vector<SingleValue<int>>> waterEvents(int plantId);
    QFuture<std::vector<HealthEvent>> healthEvents(int plantId);
    void waterPlant(const int plantId, const int waterDate);
    void addHealthEvent(const int plantId, const int healthDate, const int health);
    QFuture<std::optional<SingleValue<int>>> getLastHealthDate(const int plantId);
//    void replaceLastHealthEvent(const int plantId, const int waterDate, const int health);
    static Database & instance();


private:
    std::unique_ptr<ThreadedDatabase> m_database;

};
