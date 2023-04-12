#ifndef WATERHISTORYMODEL_H
#define WATERHISTORYMODEL_H
#include "database.h"
#include <QAbstractListModel>


class WaterHistoryModel: public QAbstractListModel
{
    Q_OBJECT;
public:
    WaterHistoryModel(int plantId);
    int rowCount(const QModelIndex&)const override;
    QHash<int, QByteArray> roleNames()const override;
    enum Role {
        WaterEvent
    };
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE void waterPlant();

private:
    std::vector<SingleValue<int>> m_data;
    int plant_Id;

};



#endif // WATERHISTORYMODEL_H
