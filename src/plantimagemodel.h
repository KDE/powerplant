// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QAbstractListModel>

class PlantImageModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString customImage READ customImage WRITE setCustomImage NOTIFY customImageChanged)

public:
    PlantImageModel(QObject *parent = nullptr);

    enum Roles {
        UrlRole = Qt::UserRole + 1,
    };

    QString customImage() const;
    void setCustomImage(const QString &customImage);

    int rowCount(const QModelIndex &parent)const override;
    QHash<int, QByteArray> roleNames()const override;
    QVariant data(const QModelIndex& index, int role) const override;

    Q_INVOKABLE int urlToIndex(const QString &url) const;

Q_SIGNALS:
    void customImageChanged();

private:
    QVector<QString> m_urls;
    QString m_customImage;
};