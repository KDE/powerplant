// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "database.h"
#include <QAbstractListModel>

class WaterHistoryModel: public QAbstractListModel
{
    Q_OBJECT;
public:
    WaterHistoryModel(int plantId, QObject *parent = nullptr);
    int rowCount(const QModelIndex&)const override;
    QHash<int, QByteArray> roleNames()const override;
    enum Role {
        WaterEventRole = Qt::UserRole + 1,
    };
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void waterPlant();

private:
    std::vector<SingleValue<int>> m_data;
    int m_plantId;
};
