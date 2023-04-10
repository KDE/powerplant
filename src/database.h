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

class Database : public QObject
{
    Q_OBJECT
public:
    Database();

    void addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int lastWatered, const int healthDate, const int health);
    QFuture<std::vector<Plant>> plants();
    QFuture<std::optional<Plant>> plant(int plant_id);
    static Database & instance();


private:
    std::unique_ptr<ThreadedDatabase> m_database;

};
