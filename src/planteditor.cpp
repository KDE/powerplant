// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "planteditor.h"
#include "database.h"
#include <QCoroTask>
#include <QCoroFuture>

Plant::Plant(QObject *parent)
    : QObject(parent)
{}

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

        m_imgUrl = plant->img_url;
        Q_EMIT imgUrlChanged();

        m_waterIntervall = plant->water_intervall;
        Q_EMIT waterIntervallChanged();

        m_location = plant->location;
        Q_EMIT locationChanged();

        m_dateOfBirth = plant->date_of_birth;
        Q_EMIT dateOfBirthChanged();

        m_lastWatered = QDateTime::fromSecsSinceEpoch(plant->last_watered).date();
        Q_EMIT lastWateredChanged();

        m_currentHealth = plant->current_health;
        Q_EMIT currentHealthChanged();
    });
}

int Plant::wantsToBeWateredIn() const
{
    return QDate::currentDate().daysTo(m_lastWatered.addDays(m_waterIntervall));
}

PlantEditor::PlantEditor(QObject *parent)
    : QObject(parent)
    , m_plant(new Plant(this))
{}

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
        m_plantsModel->addPlant(
            m_plant->m_name,
            m_plant->m_species,
            m_plant->m_imgUrl.toString(),
            m_plant->m_waterIntervall,
            m_plant->m_location,
            0,
            m_plant->m_currentHealth
        );
    } else {
        m_plantsModel->editPlant(
            m_plant->m_plantId,
            m_plant->m_name,
            m_plant->m_species,
            m_plant->m_imgUrl.toString(),
            m_plant->m_waterIntervall,
            m_plant->m_location,
            m_plant->m_dateOfBirth
        );
    }
}
