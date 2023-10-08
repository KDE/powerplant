// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "plantsmodel.h"
#include <QCoroTask>
#include <QCoroFuture>
#include <QDateTime>
#include <unordered_map>

using namespace DB;

PlantsModel::PlantsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    auto future = Database::instance().plants();

    QCoro::connect(std::move(future), this, [this](auto &&plants) {
        beginResetModel();
        m_data = plants;
        endResetModel();
    });

    connect(&Database::instance(), &Database::plantChanged, this, [this](DB::Plant::Id plantId) {
        const auto it = std::find_if(m_data.cbegin(), m_data.cend(), [plantId](const auto &plant) {
            return plantId == plant.plant_id;
        });

        if (it == m_data.cend()) {
            return;
        }

        const int row = it - m_data.cbegin();

        auto future = Database::instance().plant(plantId);

        QCoro::connect(std::move(future), this, [this, row](auto &&plant) {
            if (plant) {
                m_data[row] = plant.value();
                const auto idx = index(row, 0);
                Q_EMIT dataChanged(idx, idx);
            }
        });
    });
}

int PlantsModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> PlantsModel::roleNames() const
{
    return {
        {Role::PlantID, "plantId"},
        {Role::Name, "name" },
        {Role::Species, "species"},
        {Role::ImgUrl, "imgUrl"},
        {Role::WaterInterval, "waterInterval"},
        {Role::Location, "location"},
        {Role::DateOfBirth, "dateOfBirth"},
        {Role::LastWatered, "lastWatered"},
        {Role::WantsToBeWateredIn, "wantsToBeWateredIn"},
        {Role::CurrentHealth, "currentHealth"},
    };
}

QVariant PlantsModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    const auto plant = m_data.at(index.row());

    static std::unordered_map<int,std::vector<QDateTime>> waterEvents;

    switch(role){
        case Role::PlantID:
            return plant.plant_id;
        case Role::Name:
            return plant.name;
        case Role::Species:
            return plant.species;
        case Role::ImgUrl:
            return plant.img_url;
        case Role::WaterInterval:
            return plant.water_intervall;
        case Role::Location:
            return plant.location;
        case Role::DateOfBirth:
            return QDateTime::fromSecsSinceEpoch(plant.date_of_birth).date();
        case Role::LastWatered:
            return QDateTime::fromSecsSinceEpoch(plant.last_watered).date();
        case Role::WantsToBeWateredIn:
            return QDate::currentDate().daysTo(QDateTime::fromSecsSinceEpoch(plant.last_watered).date().addDays(plant.water_intervall));
        case Role::CurrentHealth:
            return plant.current_health;
    };

    Q_UNREACHABLE();
}

void PlantsModel::addPlant(const QString &name, const QString &species, const QString &imgUrl, const int waterInterval, const QString location, const int dateOfBirth, const int health)
{
    const int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    auto future = Database::instance().addPlant(name, species, imgUrl, waterInterval, location, dateOfBirth, now, now, health);

    QCoro::connect(std::move(future), this, [=, this](auto &&result) {
        beginInsertRows({}, m_data.size(), m_data.size());
        m_data.push_back(Plant{result, name, species, imgUrl, waterInterval, location, dateOfBirth, 1, now, now, health});
        endInsertRows();
    });
}

void PlantsModel::editPlant(const DB::Plant::Id plantId, const QString &name, const QString &species, const QString &imgUrl, const int waterIntervall, const QString location, const int dateOfBirth)
{
    const int row = [&]() {
        const auto it = std::find_if(m_data.cbegin(), m_data.cend(), [plantId](const auto &plant) {
            return plantId == plant.plant_id;
        });

        Q_ASSERT(it != m_data.cend());

        return it - m_data.cbegin();
    }();

    Database::instance().editPlant(plantId, name, species, imgUrl, waterIntervall, location, dateOfBirth);

    const auto idx = index(row, 0);

    auto &plant = m_data[row];
    plant.name = name;
    plant.species = species;
    plant.img_url = imgUrl;
    plant.water_intervall = waterIntervall;
    plant.location = location;
    plant.date_of_birth = dateOfBirth;

    emit dataChanged(idx, idx);
}

void PlantsModel::deletePlant(const int plantId)
{
    const int row = [&]() {
        const auto it = std::find_if(m_data.cbegin(), m_data.cend(), [plantId](const auto &plant) {
            return plantId == plant.plant_id;
        });

        Q_ASSERT(it != m_data.cend());

        return it - m_data.cbegin();
    }();

    m_data.erase(m_data.begin() + row);

    beginRemoveRows({}, row, row);
    Database::instance().deletePlant(plantId);
    endRemoveRows();
}
