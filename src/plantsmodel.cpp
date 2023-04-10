#include "plantsmodel.h"
#include <QCoroTask>
#include <QCoroFuture>
#include <QDateTime>>

PlantsModel::PlantsModel()
{
    qDebug() << "2FSFSDF";
    auto future = Database::instance().plants();
    QCoro::connect(std::move(future), this, [this](auto &&plants) {
        beginResetModel();
        m_data = plants;
        endResetModel();
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
        {Role::CurrentHealth, "currentHealth"}
    };
}

QVariant PlantsModel::data(const QModelIndex &index, int role) const
{
    int i = index.row();
    auto plant = m_data.at(i);
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
            return plant.date_of_birth;
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
    int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    Database::instance().addPlant(name, species, imgUrl, waterInterval, location, dateOfBirth, now, now, health);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.push_back(Plant{(m_data.empty()? 1 :m_data.back().plant_id+1), name, species, imgUrl, waterInterval, location, dateOfBirth, 1, now, now, health});
    endInsertRows();
}
