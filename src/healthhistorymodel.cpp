// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "healthhistorymodel.h"
#include <QCoroFuture>
#include <QCoroTask>
#include <QDateTime>

HealthHistoryModel::HealthHistoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DB::Plant::Id HealthHistoryModel::plantId() const
{
    return m_plantId;
}

void HealthHistoryModel::setPlantId(const DB::Plant::Id plantId)
{
    if (plantId == m_plantId) {
        return;
    }
    m_plantId = plantId;
    auto future = Database::instance().healthEvents(plantId);
    QCoro::connect(std::move(future), this, [this](auto &&healthEvents) {
        beginResetModel();
        m_data = healthEvents;
        endResetModel();
    });
    Q_EMIT plantIdChanged();
}

int HealthHistoryModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QHash<int, QByteArray> HealthHistoryModel::roleNames() const
{
    return {{Role::HealthDateRole, "healthDate"}, {Role::HealthRole, "health"}};
}

QVariant HealthHistoryModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    const auto event = m_data.at(index.row());
    switch (role) {
    case Role::HealthDateRole:
        return QDateTime::fromSecsSinceEpoch(event.health_date);
    case Role::HealthRole:
        return event.health;
    };

    Q_UNREACHABLE();
}

void HealthHistoryModel::addHealthEvent(const int health)
{
    const int now = QDateTime::currentDateTime().toSecsSinceEpoch();
    Database::instance().addHealthEvent(m_plantId, now, health);
    beginInsertRows({}, m_data.size(), m_data.size());
    m_data.emplace_back(now, health);
    endInsertRows();
}
