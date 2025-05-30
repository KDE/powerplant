// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "database.h"
#include <QAbstractListModel>
#include <qqmlregistration.h>

class PlantsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Summary summary READ summary NOTIFY summaryChanged)

public:
    enum Summary {
        NothingToDo,
        SomeNeedWater
    };
    Q_ENUM(Summary);

    explicit PlantsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &) const override;
    enum Role {
        PlantID,
        Name,
        Species,
        ImgUrl,
        WaterInterval,
        FertilizerInterval,
        Location,
        DateOfBirth,
        LastWatered,
        WantsToBeWateredIn,
        LastFertilized,
        WantsToBeFertilizedIn,
        CurrentHealth,
    };
    Q_ENUM(Role);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    Q_INVOKABLE void addPlant(const QString &name,
                              const QString &species,
                              const QString &imgUrl,
                              const int waterInterval,
                              const int fertilizerInterval,
                              const QString location,
                              const int dateOfBirth,
                              const int health);
    Q_INVOKABLE void editPlant(const DB::Plant::Id plantId,
                               const QString &name,
                               const QString &species,
                               const QString &imgUrl,
                               const int waterInterval,
                               const int fertilizerInterval,
                               const QString location,
                               const int dateOfBirth);
    Q_INVOKABLE void deletePlant(const int plantId);

    Summary summary() const;
    Q_SIGNAL void summaryChanged();

private:
    std::vector<DB::Plant> m_data;
};
