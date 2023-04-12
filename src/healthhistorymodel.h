#ifndef HealthHistoryModel_H
#define HealthHistoryModel_H
#include "database.h"
#include <QAbstractListModel>


class HealthHistoryModel: public QAbstractListModel
{
    Q_OBJECT;
public:
    HealthHistoryModel(int plantId);
    int rowCount(const QModelIndex&)const override;
    QHash<int, QByteArray> roleNames()const override;
    enum Role {
        HealthDate,
        Health
    };
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void addHealthEvent(const int health);

private:
    std::vector<HealthEvent> m_data;
    int plant_Id;

};



#endif // HealthHistoryModel_H
