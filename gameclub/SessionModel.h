#pragma once
#include <QSqlQueryModel>
#include <QHash>
#include <QByteArray>

class SessionModel : public QSqlQueryModel {
    Q_OBJECT
public:
    enum SessionRoles {
        IdRole = Qt::UserRole + 1,
        UserFioRole,
        StationInfoRole,
        StartTimeRole,
        EndTimeRole,
        StatusRole
    };

    SessionModel(QObject *parent = nullptr) : QSqlQueryModel(parent) {}

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[IdRole] = "session_id";
        roles[UserFioRole] = "user_email";
        roles[StationInfoRole] = "station_info";
        roles[StartTimeRole] = "start_time";
        roles[EndTimeRole] = "end_time";
        roles[StatusRole] = "status";
        return roles;
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (role < Qt::UserRole) return QSqlQueryModel::data(index, role);
        int column = role - Qt::UserRole - 1;
        return QSqlQueryModel::data(this->index(index.row(), column), Qt::DisplayRole);
    }

    Q_INVOKABLE void updateByStatus(QString status) {
        QString query = QString(
                            "WITH RankedStatuses AS ("
                            "    SELECT "
                            "        session_id, "
                            "        status_id, "
                            "        ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY date DESC) as rn "
                            "    FROM session_statuses"
                            ") "
                            "SELECT "
                            "    s.session_id, "
                            "    (u.email) as email, "
                            "    (st.тип || ' #' || st.station_id) as station, "
                            "    TO_CHAR(s.Время_начала, 'DD.MM HH24:MI') as start_time, "
                            "    TO_CHAR(s.Время_окончания, 'DD.MM HH24:MI') as end_time, "
                            "    bs.status "
                            "FROM sessions s "
                            "JOIN users u ON s.пользователь_id = u.user_id "
                            "JOIN stations st ON s.station_id = st.station_id "
                            "JOIN RankedStatuses rs ON s.session_id = rs.session_id AND rs.rn = 1 "
                            "JOIN booking_statuses bs ON rs.status_id = bs.status_id "
                            "WHERE bs.status = '%1' "
                            "ORDER BY s.Время_начала ASC"
                            ).arg(status);
        setQuery(query);
    }
};
