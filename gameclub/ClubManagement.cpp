#include "ClubManagement.h"
#include <QRegularExpression>
#include <QRegularExpressionMatch>

ClubManagement::ClubManagement(QObject *parent) : QObject(parent) {}

bool ClubManagement::connectToDb(QString host, QString dbName, QString user, QString pass) {
    if (db.isOpen()) db.close(); 

    db = QSqlDatabase::addDatabase("QPSQL", "main_connection");

    db.setHostName(host);
    db.setDatabaseName(dbName);
    db.setUserName(user);
    db.setPassword(pass);

    if (!db.open()) {
        return false;
    }
    return true;
}

bool ClubManagement::addUser(QString fio, QString phone, QString email) {
    QStringList parts = fio.split(" ");
    QString lastName = parts.value(0);
    QString firstName = parts.value(1);
    QString middleName = parts.value(2);

    QSqlQuery query;
    query.prepare("INSERT INTO users (email, фамилия, имя, отчество, телефон) "
                  "VALUES (?, ?, ?, ?, ?)");
    query.addBindValue(email);
    query.addBindValue(lastName);
    query.addBindValue(firstName);
    query.addBindValue(middleName);
    query.addBindValue(phone);

    return query.exec();
}

bool ClubManagement::checkExists(QString email, QString phone) {
    QSqlQuery query;
    query.prepare("SELECT user_id FROM users WHERE email = ? OR телефон = ?");
    query.addBindValue(email);
    query.addBindValue(phone);
    
    if (query.exec() && query.next()) {
        return true;
    }
    return false;
}

int ClubManagement::checkUser(QString email, QString phone) {
    QSqlQuery query;

    query.prepare("SELECT 1 FROM users WHERE email = ?");
    query.addBindValue(email);
    if (query.exec() && query.next()) return 1; 

    query.prepare("SELECT 1 FROM users WHERE телефон = ?");
    query.addBindValue(phone);
    if (query.exec() && query.next()) return 2;

    return 0;
}

int ClubManagement::validateAndCheckUser(QString fio, QString phone, QString email) {

    QStringList parts = fio.split(" ", Qt::SkipEmptyParts);
    if (parts.count() < 2) {
        return 5;
    }

    QRegularExpression emailRegex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$");
    if (!emailRegex.match(email).hasMatch()) {
        return 3;
    }

    QRegularExpression phoneRegex("^\\+7\\d{10}$");
    if (!phoneRegex.match(phone).hasMatch()) {
        return 4;
    }
    
    QSqlQuery query;

    query.prepare("SELECT 1 FROM users WHERE email = ?");
    query.addBindValue(email);
    if (query.exec() && query.next()) return 1; 

    query.prepare("SELECT 1 FROM users WHERE телефон = ?");
    query.addBindValue(phone);
    if (query.exec() && query.next()) return 2;

    return 0;
}

bool ClubManagement::addStation(QString type, QString status) {
    QSqlQuery query;
    query.prepare("INSERT INTO stations (тип, статус) VALUES (?, ?)");
    query.addBindValue(type);
    query.addBindValue(status);
    return query.exec();
}

void ClubManagement::refreshUsers(UserModel *model) {
    if (model) model->updateModel();
}

void ClubManagement::refreshStations(StationModel *model) {
    if (model) model->updateModel();
}

bool ClubManagement::deleteStation(int stationId) {
    QSqlQuery query;
    query.prepare("DELETE FROM stations WHERE station_id = ?");
    query.addBindValue(stationId);
    
    bool success = query.exec();
    
    return success;
}

bool ClubManagement::deleteUser(int userId) {
    QSqlQuery query;
    query.prepare("DELETE FROM users WHERE user_id = ?");
    query.addBindValue(userId);
    
    bool success = query.exec();
    
    return success;
}

bool ClubManagement::isTimeSlotFree(int stationId, const QDateTime& start, const QDateTime& end) {
    QSqlQuery query;

    query.prepare(
        "SELECT 1 FROM sessions s "
        "WHERE s.station_id = ? AND s.session_id NOT IN ("
        "    SELECT ss.session_id FROM session_statuses ss "
        "    JOIN booking_statuses bs ON ss.status_id = bs.status_id "
        "    WHERE bs.status = 'Завершена'"
        ") AND ("
        "    (? BETWEEN s.Время_начала AND s.Время_окончания) OR "
        "    (? BETWEEN s.Время_начала AND s.Время_окончания) OR "
        "    (s.Время_начала BETWEEN ? AND ?)"
        ")"
    );
    query.addBindValue(stationId);
    query.addBindValue(start);
    query.addBindValue(end);
    query.addBindValue(start);
    query.addBindValue(end);
    
    if (query.exec() && query.next()) {
        return false; 
    }
    return true;
}

bool ClubManagement::createBooking(int userId, int stationId, QString startStr, QString endStr) {

    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT статус FROM stations WHERE station_id = ?");
    checkQuery.addBindValue(stationId);
    if (checkQuery.exec() && checkQuery.next()) {
        if (checkQuery.value(0).toString() == "Ремонт") {
            return false; 
        }
    }

    QDateTime start = QDateTime::fromString(startStr, "yyyy-MM-dd HH:mm:ss");
    QDateTime end = QDateTime::fromString(endStr, "yyyy-MM-dd HH:mm:ss");

    if (!isTimeSlotFree(stationId, start, end)) return false;

    db.transaction();
    QSqlQuery query;
    query.prepare("INSERT INTO sessions (пользователь_id, station_id, Время_начала, Время_окончания) "
                  "VALUES (?, ?, ?, ?) RETURNING session_id");
    query.addBindValue(userId);
    query.addBindValue(stationId);
    query.addBindValue(start);
    query.addBindValue(end);

    if (query.exec() && query.next()) {
        int sessionId = query.value(0).toInt();
        QSqlQuery statusQuery;

        statusQuery.prepare("INSERT INTO session_statuses (session_id, status_id, date) "
                            "SELECT ?, status_id, NOW() FROM booking_statuses WHERE status = 'Бронь'");
        statusQuery.addBindValue(sessionId);
        if (statusQuery.exec()) {
            db.commit();
            return true;
        }
    }
    db.rollback();
    return false;
}

bool ClubManagement::updateSessionStatus(int sessionId, QString statusName) {
    QSqlQuery query;
    query.prepare("INSERT INTO session_statuses (session_id, status_id, date) "
                  "SELECT ?, status_id, NOW() FROM booking_statuses WHERE status = ? "
                  "ON CONFLICT (session_id, status_id) DO UPDATE SET date = EXCLUDED.date");
    query.addBindValue(sessionId);
    query.addBindValue(statusName);

    return query.exec();
}

bool ClubManagement::deleteSession(int sessionId) {
    QSqlQuery query;

    query.prepare("DELETE FROM sessions WHERE session_id = ?");
    query.addBindValue(sessionId);
    return query.exec();
}

void ClubManagement::refreshSessions(SessionModel *model, QString status) {
    if (model) model->updateByStatus(status);
}

bool ClubManagement::toggleStationMaintenance(int stationId, QString currentStatus) {
    QString newStatus;
    if (currentStatus == "Свободна") {
        newStatus = "Ремонт";
    } else if (currentStatus == "Ремонт") {
        newStatus = "Свободна";
    } else {
        return false;
    }

    QSqlQuery query;
    query.prepare("UPDATE stations SET статус = ? WHERE station_id = ?");
    query.addBindValue(newStatus);
    query.addBindValue(stationId);
    
    return query.exec();
}

QString ClubManagement::generatePeriodReport(QString startStr, QString endStr) {
    QString queryString = QString(
        "SELECT "
        "    s.session_id, "
        "    u.email, "
        "    st.station_id, "
        "    s.Время_начала, "
        "    s.Время_окончания "
        "FROM sessions s "
        "JOIN users u ON s.пользователь_id = u.user_id "
        "JOIN stations st ON s.station_id = st.station_id "
        "JOIN session_statuses ss ON s.session_id = ss.session_id "
        "JOIN booking_statuses bs ON ss.status_id = bs.status_id "
        "WHERE bs.status = 'Завершена' "
        "AND ss.date = (SELECT MAX(date) FROM session_statuses WHERE session_id = s.session_id) "
        "AND s.Время_начала >= TIMESTAMP '%1' AND s.Время_окончания <= TIMESTAMP '%2' "
        "ORDER BY s.Время_начала ASC"
    ).arg(startStr).arg(endStr);

    QSqlQuery query;
    if (!query.exec(queryString)) {
        return "Ошибка при расчете данных: " + query.lastError().text();
    }

    double totalRevenue = 0;
    int sessionCount = 0;
    QString reportContent = "Финансовый отчет за период.\n";
    reportContent += "Период: " + startStr + " - " + endStr + "\n";
    reportContent += "-------------------------------------------------------------------\n";

    reportContent += QString("%1 | %2 | %3 | %4 | %5 | %6\n")
                         .arg("Сессия", -7)
                         .arg("Email", -25)
                         .arg("Станция", -7)
                         .arg("Начало", -16)
                         .arg("Конец", -16)
                         .arg("Мин", -5);
    reportContent += "-------------------------------------------------------------------\n";


    while (query.next()) {
        QDateTime sStart = query.value("Время_начала").toDateTime();
        QDateTime sEnd = query.value("Время_окончания").toDateTime();
        qint64 durationSeconds = sStart.secsTo(sEnd);
        double minutes = durationSeconds / 60.0;
        double cost = minutes * 2.0;

        totalRevenue += cost;
        sessionCount++;

        reportContent += QString("%1 | %2 | %3 | %4 | %5 | %6\n")
                             .arg(query.value("session_id").toInt(), -7)
                             .arg(query.value("email").toString(), -25)
                             .arg(query.value("station_id").toInt(), -7)
                             .arg(sStart.toString("dd.MM HH:mm"), -16)
                             .arg(sEnd.toString("dd.MM HH:mm"), -16)
                             .arg(qRound(minutes), -5);
    }

    reportContent += "-------------------------------------------------------------------\n";
    reportContent += QString("Общее количество сессий: %1\n").arg(sessionCount);
    reportContent += QString("ИТОГО:    %1 руб.\n").arg(totalRevenue, 0, 'f', 2);
    reportContent += "===================================================================\n";
    reportContent += "Дата отчета: " + QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm:ss");

    QString path = QDir::currentPath() + "/финансовый_отчет" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".txt";
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << reportContent;
        file.close();
        return "Отчет успешно создан и сохранен!\nПуть: " + path;
    }

    return "Ошибка записи файла";
}

bool compareMinutes(const QPair<int, double> &a, const QPair<int, double> &b) {
    return a.second > b.second;
}


QString ClubManagement::generateStationLoadReport(QString startStr, QString endStr) {
    QDateTime start = QDateTime::fromString(startStr, "yyyy-MM-dd HH:mm:ss");
    QDateTime end = QDateTime::fromString(endStr, "yyyy-MM-dd HH:mm:ss");

    qint64 totalPeriodSeconds = start.secsTo(end);
    double totalPeriodMinutes = totalPeriodSeconds / 60.0;

    if (totalPeriodMinutes <= 0) return "Неверный период. Конец раньше начала.";

    QMap<int, double> stationMinutes; 
    QMap<int, QString> stationTypes;

    QSqlQuery stationsQuery;
    stationsQuery.prepare("SELECT station_id, тип FROM stations");
    if (!stationsQuery.exec()) {
        return "Ошибка БД при получении списка станций: " + stationsQuery.lastError().text();
    }
    while (stationsQuery.next()) {
        int id = stationsQuery.value(0).toInt();
        stationTypes[id] = stationsQuery.value(1).toString();
        stationMinutes[id] = 0.0;
    }

    QSqlQuery sessionsQuery;
    QString queryString = QString(
        "SELECT station_id, Время_начала, Время_окончания FROM sessions s "
        "WHERE (s.Время_начала >= TIMESTAMP '%1' AND s.Время_начала <= TIMESTAMP '%2') OR "
        "      (s.Время_окончания >= TIMESTAMP '%1' AND s.Время_окончания <= TIMESTAMP '%2') OR "
        "      (s.Время_начала <= TIMESTAMP '%1' AND s.Время_окончания >= TIMESTAMP '%2')"
    ).arg(startStr).arg(endStr);
    
    if (!sessionsQuery.exec(queryString)) {
        return "Ошибка БД при получении данных о сессиях: " + sessionsQuery.lastError().text();
    }

    while (sessionsQuery.next()) {
        int stationId = sessionsQuery.value("station_id").toInt();
        QDateTime sStart = sessionsQuery.value("Время_начала").toDateTime();
        QDateTime sEnd = sessionsQuery.value("Время_окончания").toDateTime();

        QDateTime overlapStart = (sStart > start) ? sStart : start;
        QDateTime overlapEnd = (sEnd < end) ? sEnd : end;

        if (overlapStart < overlapEnd) {
            double minutes = overlapStart.secsTo(overlapEnd) / 60.0;
            stationMinutes[stationId] += minutes;
        }
    }

    QList<QPair<int, double>> sortedStations;
    QMapIterator<int, double> i(stationMinutes);
    while (i.hasNext()) {
        i.next();
        sortedStations.append(qMakePair(i.key(), i.value()));
    }
    std::sort(sortedStations.begin(), sortedStations.end(), compareMinutes);
    

    QString reportContent = "Использование станций в минутах за период.\n";
    reportContent += "Период: " + startStr + " - " + endStr + "\n";
    reportContent += "---------------------------------------------------\n";
    reportContent += QString("%1 | %2 | %3\n")
                         .arg("Станция", -7)
                         .arg("Минуты", -12)
                         .arg("Тип", -10);
    reportContent += "---------------------------------------------------\n";

    foreach (const auto& pair, sortedStations) {
        int stationId = pair.first;
        double usedMins = pair.second;
        reportContent += QString("%1 | %2 | %3\n")
                             .arg(stationId, -7)
                             .arg(qRound(usedMins), -12)
                             .arg(stationTypes.value(stationId), -10);
    }
    
    reportContent += "===================================================\n";
    
    QString path = QDir::currentPath() + "/station_top_load_report_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".txt";
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << reportContent;
        file.close();
        return "Отчет по топ-станциям успешно создан!\nПуть: " + path;
    }

    return "Ошибка записи файла";
}