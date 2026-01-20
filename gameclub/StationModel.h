#pragma once

#include <QSqlQueryModel>
#include <QHash>
#include <QByteArray>

class StationModel : public QSqlQueryModel {
    Q_OBJECT
public:
    enum StationRoles {
        IdRole = Qt::UserRole + 1,
        TypeRole,
        StatusRole
    };

    StationModel(QObject *parent = nullptr) : QSqlQueryModel(parent) {
        updateModel();
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[IdRole] = "station_id";
        roles[TypeRole] = "тип";
        roles[StatusRole] = "статус";
        return roles;
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (role < Qt::UserRole) return QSqlQueryModel::data(index, role);
        int column = role - Qt::UserRole - 1;
        return QSqlQueryModel::data(this->index(index.row(), column), Qt::DisplayRole);
    }

    void updateModel() {
        setQuery("SELECT station_id, тип, статус FROM stations ORDER BY station_id ASC");
    }

    Q_INVOKABLE void updateAvailableOnly() {
        setQuery("SELECT station_id, тип, статус FROM stations WHERE статус = 'Свободна' ORDER BY station_id ASC");
    }
};
