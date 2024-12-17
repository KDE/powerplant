// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "waterhistorymodel.h"
#include <QCoroFuture>
#include <QCoroTask>
#include <QDateTime>

WaterHistoryModel::WaterHistoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DB::Plant::Id WaterHistoryModel::plantId() const
{
    return m_plantId;
}

void WaterHistoryModel::setPlantId(const DB::Plant::Id plantId)
{
    if (plantId == m_plantId) {
        return;
    }
    m_plantId = plantId;
    auto future = Database::instance().waterEvents(plantId);

    QCoro::connect(std::move(future), this, [this](auto &&waterEvents) {
        beginResetModel();
        m_data = waterEvents;
        endResetModel();
    });
    Q_EMIT plantIdChanged();
}

int WaterHistoryModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> WaterHistoryModel::roleNames() const
{
    return {{WaterEventRole, "waterEvent"}};
}

QVariant WaterHistoryModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    return QDateTime::fromSecsSinceEpoch(m_data.at(index.row()).value);
}

void WaterHistoryModel::waterPlant()
{
    const int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    Database::instance().waterPlant(m_plantId, now);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.emplace_back(SingleValue<int>{now});
    endInsertRows();
}
