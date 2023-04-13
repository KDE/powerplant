// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "plantimagemodel.h"

#include <QDebug>
#include <QDir>

PlantImageModel::PlantImageModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QDir assets(":/assets/");
    m_urls = assets.entryList();
}

int PlantImageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_urls.count() + (m_customImage.isEmpty() ? 0 : 1);
}

QHash<int, QByteArray> PlantImageModel::roleNames() const
{
    return {
        { UrlRole, "url" },
    };
}

QString PlantImageModel::customImage() const
{
    return m_customImage;
}

void PlantImageModel::setCustomImage(const QString &customImage)
{
    if (m_customImage == customImage || customImage.startsWith(QStringLiteral("qrc"))) {
        return;
    }

    if (customImage.isEmpty()) {
        beginRemoveRows({}, 0, 0);
        m_customImage = customImage;
        endRemoveRows();
    } else {
        beginInsertRows({}, 0, 0);
        m_customImage = customImage;
        endInsertRows();
    }

    Q_EMIT customImageChanged();
}

int PlantImageModel::urlToIndex(const QString &url) const
{
    if (url.isEmpty()) {
        return -1;
    }
    if (url == m_customImage) {
        return 0;
    }
    const auto it = std::find_if(m_urls.cbegin(), m_urls.cend(), [&url](const QString &_url) {
        return _url == url;

    });
    if (it == m_urls.cend()) {
        return -1;
    }
    return it - m_urls.cbegin() + (m_customImage.isEmpty() ? 0 : 1);
}

QVariant PlantImageModel::data(const QModelIndex& index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    const int row = m_customImage.isEmpty() ? index.row() : index.row() - 1;

    switch (role){
    case UrlRole:
         return row == -1 ? m_customImage : "qrc:/assets/" + m_urls.at(row);
    };

    Q_UNREACHABLE();
}
