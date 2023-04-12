#include "healthhistorymodel.h"
#include <QCoroTask>
#include <QCoroFuture>
#include <QDateTime>

HealthHistoryModel::HealthHistoryModel(int plantId)
{
    auto future = Database::instance().healthEvents(plantId);
    plant_Id = plantId;
    QCoro::connect(std::move(future), this, [this](auto &&healthEvents) {
        beginResetModel();
        m_data = healthEvents;
        endResetModel();
    });
}

int HealthHistoryModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> HealthHistoryModel::roleNames() const
{
    return {
        {Role::HealthDate, "healthDate"},
        {Role::Health, "health"}

    };
}

QVariant HealthHistoryModel::data(const QModelIndex &index, int role) const
{
    int i = index.row();
    auto event = m_data.at(i);
    switch(role){
        case Role::HealthDate:
            return QDateTime::fromSecsSinceEpoch(event.health_date);
        case Role::Health:
            return event.health;
    };

    Q_UNREACHABLE();

}

void HealthHistoryModel::addHealthEvent(const int health)
{
    int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    Database::instance().addHealthEvent(plant_Id, now, health);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.push_back(HealthEvent { now, health });
    endInsertRows();

}
