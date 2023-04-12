#ifndef PLANTSMODEL_H
#define PLANTSMODEL_H
#include "database.h"
#include <QAbstractListModel>

class PlantsModel: public QAbstractListModel
{
    Q_OBJECT;
public:
    PlantsModel();
    int rowCount(const QModelIndex&)const override;
    enum Role {
        PlantID,
        Name,
        Species,
        ImgUrl,
        WaterInterval,
        Location,
        DateOfBirth,
        LastWatered,
        WantsToBeWateredIn,
        CurrentHealth,
        WaterEvents,
        HealthEvents
    };
    QHash<int, QByteArray> roleNames()const override;
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int health);

private:
    std::vector<Plant> m_data;
};

#endif // PLANTSMODEL_H
