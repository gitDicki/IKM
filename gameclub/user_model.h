#pragma once

#include <QSqlQueryModel>
#include <QHash>
#include <QByteArray>

class UserModel : public QSqlQueryModel {
    Q_OBJECT
public:
    enum UserRoles {
        IdRole = Qt::UserRole + 1,
        EmailRole,
        LastNameRole,
        FirstNameRole,
        PhoneRole
    };

    UserModel(QObject *parent = nullptr) : QSqlQueryModel(parent) {
        updateModel();
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[IdRole] = "user_id";
        roles[EmailRole] = "email";
        roles[LastNameRole] = "last_name";
        roles[FirstNameRole] = "first_name";
        roles[PhoneRole] = "phone";
        return roles;
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (role < Qt::UserRole) return QSqlQueryModel::data(index, role);
        int column = role - Qt::UserRole - 1;
        return QSqlQueryModel::data(this->index(index.row(), column), Qt::DisplayRole);
    }

    void updateModel() {
        setQuery("SELECT user_id, email, фамилия, имя, телефон FROM users");
    }
};

