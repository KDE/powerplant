// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "planteditor.h"
#include "database.h"
#include <QCoroFuture>
#include <QCoroTask>
#include <algorithm>

Plant::Plant(QObject *parent)
    : QObject(parent)
{
}

DB::Plant::Id Plant::plantId() const
{
    return m_plantId;
}

void Plant::setPlantId(const DB::Plant::Id plantId)
{
    if (m_plantId == plantId) {
        return;
    }
    if (m_plantId >= 0) {
        disconnect(&Database::instance(), &Database::plantChanged, this, nullptr);
    }

    m_plantId = plantId;
    refresh();

    if (m_plantId >= 0) {
        connect(&Database::instance(), &Database::plantChanged, this, [this](DB::Plant::Id plantId) {
            if (m_plantId == plantId) {
                refresh();
            }
        });
    }

    Q_EMIT plantIdChanged();
}

void Plant::refresh()
{
    if (m_plantId == -1) {
        return;
    }

    auto future = Database::instance().plant(m_plantId);

    QCoro::connect(std::move(future), this, [this](auto &&plant) {
        if (!plant.has_value()) {
            return;
        }

        m_name = plant->name;
        Q_EMIT nameChanged();

        m_species = plant->species;
        Q_EMIT speciesChanged();

        m_imgUrl = QUrl(plant->img_url);
        Q_EMIT imgUrlChanged();

        m_waterInterval = plant->water_interval;
        Q_EMIT waterIntervalChanged();

        m_fertilizerInterval = plant->fertilizer_interval;
        Q_EMIT fertilizerIntervalChanged();

        m_location = plant->location;
        Q_EMIT locationChanged();

        m_dateOfBirth = QDateTime::fromSecsSinceEpoch(plant->date_of_birth).date();
        Q_EMIT dateOfBirthChanged();

        m_lastWatered = QDateTime::fromSecsSinceEpoch(plant->last_watered).date();
        Q_EMIT lastWateredChanged();

        m_lastFertilized = QDateTime::fromSecsSinceEpoch(plant->last_fertilized).date();
        Q_EMIT lastFertilizedChanged();

        m_currentHealth = plant->current_health;
        Q_EMIT currentHealthChanged();
    });
}

int Plant::wantsToBeWateredIn() const
{
    return std::max(qint64(-1), QDate::currentDate().daysTo(m_lastWatered.addDays(m_waterInterval)));
}

int Plant::wantsToBeFertilizedIn() const
{
    return std::max(qint64(-1), QDate::currentDate().daysTo(m_lastFertilized.addDays(m_fertilizerInterval)));
}

PlantEditor::PlantEditor(QObject *parent)
    : QObject(parent)
    , m_plant(new Plant(this))
{
}

DB::Plant::Id PlantEditor::plantId() const
{
    return m_plantId;
}

void PlantEditor::setPlantId(const DB::Plant::Id plantId)
{
    if (m_plantId == plantId) {
        return;
    }
    m_plantId = plantId;
    if (m_plantId >= 0) {
        m_plant->setPlantId(plantId);
    }
    Q_EMIT plantIdChanged();
}

Plant *PlantEditor::plant() const
{
    return m_plant;
}

void PlantEditor::save()
{
    if (m_mode == Creator) {
        m_plantsModel->addPlant(m_plant->m_name,
                                m_plant->m_species,
                                m_plant->m_imgUrl.toString(),
                                m_plant->m_waterInterval,
                                m_plant->m_fertilizerInterval,
                                m_plant->m_location,
                                m_plant->m_dateOfBirth.startOfDay().toSecsSinceEpoch(),
                                m_plant->m_currentHealth);
    } else {
        m_plantsModel->editPlant(m_plant->m_plantId,
                                 m_plant->m_name,
                                 m_plant->m_species,
                                 m_plant->m_imgUrl.toString(),
                                 m_plant->m_waterInterval,
                                 m_plant->m_fertilizerInterval,
                                 m_plant->m_location,
                                 m_plant->m_dateOfBirth.startOfDay().toSecsSinceEpoch());
    }
}
