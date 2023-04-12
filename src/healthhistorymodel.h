// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include "database.h"

class HealthHistoryModel: public QAbstractListModel
{
    Q_OBJECT;

    enum Role {
        HealthDateRole = Qt::UserRole +1,
        HealthRole
    };
public:
    HealthHistoryModel(const int plantId, QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent)const override;
    QHash<int, QByteArray> roleNames()const override;
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void addHealthEvent(const int health);

private:
    std::vector<HealthEvent> m_data;
    int m_plantId;
};
