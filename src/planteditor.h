// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDateTime>
#include <QObject>
#include <QUrl>
#include <qqmlregistration.h>

#include "database.h"
#include "plantsmodel.h"

/// This class represent a plant and is directly usable from QML
class Plant : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    /// This property holds the database id of the plant
    Q_PROPERTY(int plantId READ plantId WRITE setPlantId NOTIFY plantIdChanged)

    /// This property holds the name of the plant
    Q_PROPERTY(QString name MEMBER m_name NOTIFY nameChanged)

    /// This property holds the species of the plant
    Q_PROPERTY(QString species MEMBER m_species NOTIFY speciesChanged)

    /// This property holds the img url of the plant
    Q_PROPERTY(QUrl imgUrl MEMBER m_imgUrl NOTIFY imgUrlChanged)

    /// This property holds the interval in which this plant should be watered
    Q_PROPERTY(int waterInterval MEMBER m_waterInterval NOTIFY waterIntervalChanged)

    /// This property holds the interval in which this plant should be fertilized
    Q_PROPERTY(int fertilizerInterval MEMBER m_fertilizerInterval NOTIFY fertilizerIntervalChanged)

    /// This property holds the interval in which this plant should be watered
    Q_PROPERTY(QString location MEMBER m_location NOTIFY locationChanged)

    /// This property holds the date of birth of this plant
    Q_PROPERTY(QDate dateOfBirth MEMBER m_dateOfBirth NOTIFY dateOfBirthChanged)

    /// This property holds the time when this plant was last watered
    Q_PROPERTY(QDate lastWatered MEMBER m_lastWatered NOTIFY lastWateredChanged)

    /// This property holds the time when this plant was last watered
    Q_PROPERTY(QDate lastFertilized MEMBER m_lastFertilized NOTIFY lastFertilizedChanged)

    /// This property holds the time when this plant want to be watered next
    Q_PROPERTY(int wantsToBeWateredIn READ wantsToBeWateredIn NOTIFY lastWateredChanged)

    /// This property holds the time when this plant want to be watered next
    Q_PROPERTY(int wantsToBeFertilizedIn READ wantsToBeFertilizedIn NOTIFY lastFertilizedChanged)

    /// This property holds the time when this plant want to be watered next
    Q_PROPERTY(int currentHealth MEMBER m_currentHealth NOTIFY currentHealthChanged)

public:
    explicit Plant(QObject *parent = nullptr);

    DB::Plant::Id plantId() const;
    void setPlantId(const DB::Plant::Id plantId);

    int wantsToBeWateredIn() const;
    int wantsToBeFertilizedIn() const;

Q_SIGNALS:
    void plantIdChanged();
    void locationChanged();
    void waterIntervalChanged();
    void fertilizerIntervalChanged();
    void nameChanged();
    void speciesChanged();
    void imgUrlChanged();
    void dateOfBirthChanged();
    void lastWateredChanged();
    void lastFertilizedChanged();
    void currentHealthChanged();

private:
    void refresh();

    DB::Plant::Id m_plantId;
    QString m_name;
    QString m_species;
    QUrl m_imgUrl;
    QString m_location;
    QDate m_dateOfBirth;
    QDate m_lastWatered;
    QDate m_lastFertilized;
    int m_waterInterval = 2;
    int m_fertilizerInterval = 2;
    int m_currentHealth = 50;

    friend class PlantEditor;
};

class PlantEditor : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(Mode mode MEMBER m_mode NOTIFY modeChanged REQUIRED)
    Q_PROPERTY(int plantId READ plantId WRITE setPlantId NOTIFY plantIdChanged)
    Q_PROPERTY(Plant *plant READ plant CONSTANT)
    Q_PROPERTY(PlantsModel *plantsModel MEMBER m_plantsModel NOTIFY plantsModelChanged REQUIRED)

public:
    enum Mode {
        Editor,
        Creator
    };
    Q_ENUM(Mode);

    explicit PlantEditor(QObject *parent = nullptr);

    DB::Plant::Id plantId() const;
    void setPlantId(const DB::Plant::Id plantId);

    Plant *plant() const;

    Q_INVOKABLE void save();

Q_SIGNALS:
    void modeChanged();
    void plantIdChanged();
    void plantsModelChanged();

private:
    enum SpecialValues {
        InvalidPlantId = -1,
    };

    Mode m_mode = Creator;
    DB::Plant::Id m_plantId = InvalidPlantId;
    Plant *const m_plant;
    PlantsModel *m_plantsModel = nullptr;
};
