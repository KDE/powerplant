#include "waterhistorymodel.h"
#include <QCoroTask>
#include <QCoroFuture>
#include <QDateTime>

WaterHistoryModel::WaterHistoryModel(int plantId)
{
    auto future = Database::instance().waterEvents(plantId);
    plant_Id = plantId;
    QCoro::connect(std::move(future), this, [this](auto &&waterEvents) {
        beginResetModel();
        m_data = waterEvents;
        endResetModel();
    });
}

int WaterHistoryModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> WaterHistoryModel::roleNames() const
{
    return {
        {Role::WaterEvent, "waterEvent"}
    };
}

QVariant WaterHistoryModel::data(const QModelIndex &index, int role) const
{
    return QDateTime::fromSecsSinceEpoch(m_data.at(index.row()).value);
}

void WaterHistoryModel::waterPlant()
{
    int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    Database::instance().waterPlant(plant_Id, now);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.push_back(SingleValue<int> { now });
    endInsertRows();

}
