// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "database.h"
#include <QAbstractListModel>

class WaterHistoryModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int plantId READ plantId WRITE setPlantId NOTIFY plantIdChanged)

    enum Role {
        WaterEventRole = Qt::UserRole + 1,
    };
public:
    explicit WaterHistoryModel(QObject *parent = nullptr);

    DB::Plant::Id plantId() const;
    void setPlantId(const DB::Plant::Id plantId);

    int rowCount(const QModelIndex&)const override;
    QHash<int, QByteArray> roleNames()const override;
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void waterPlant();

Q_SIGNALS:
    void plantIdChanged();

private:
    std::vector<SingleValue<int>> m_data;
    DB::Plant::Id m_plantId;
};
