// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "fertilizerhistorymodel.h"
#include <QCoroFuture>
#include <QCoroTask>
#include <QDateTime>

FertilizerHistoryModel::FertilizerHistoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DB::Plant::Id FertilizerHistoryModel::plantId() const
{
    return m_plantId;
}

void FertilizerHistoryModel::setPlantId(const DB::Plant::Id plantId)
{
    if (plantId == m_plantId) {
        return;
    }
    m_plantId = plantId;
    auto future = Database::instance().fertilizerEvents(plantId);

    QCoro::connect(std::move(future), this, [this](auto &&fertilizerEvents) {
        beginResetModel();
        m_data = fertilizerEvents;
        endResetModel();
    });
    Q_EMIT plantIdChanged();
}

int FertilizerHistoryModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> FertilizerHistoryModel::roleNames() const
{
    return {{FertilizerEventRole, "fertilizerEvent"}};
}

QVariant FertilizerHistoryModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    return QDateTime::fromSecsSinceEpoch(m_data.at(index.row()).value);
}

void FertilizerHistoryModel::fertilizePlant()
{
    const int now = QDateTime::currentSecsSinceEpoch();
    Database::instance().fertilizePlant(m_plantId, now);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.emplace_back(SingleValue<int>{now});
    endInsertRows();
}
