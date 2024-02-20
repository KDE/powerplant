// SPDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QtQml>
#include "database.h"

class HealthHistoryModel: public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int plantId READ plantId WRITE setPlantId NOTIFY plantIdChanged)

    enum Role {
        HealthDateRole = Qt::UserRole +1,
        HealthRole
    };
public:
    explicit HealthHistoryModel(QObject *parent = nullptr);

    DB::Plant::Id plantId() const;
    void setPlantId(const DB::Plant::Id plantId);

    int rowCount(const QModelIndex &parent)const override;
    QHash<int, QByteArray> roleNames()const override;
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void addHealthEvent(const int health);

Q_SIGNALS:
    void plantIdChanged();

private:
    std::vector<DB::HealthEvent> m_data;
    int m_plantId;
};
