#ifndef CLUBMANAGEMENT_H
#define CLUBMANAGEMENT_H

#include <QObject>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QSqlTableModel>
#include <QDateTime>
#include <QFile> 
#include <QTextStream>
#include <QDir>
#include <QtMath> 
#include <QMap> 
#include <QList>
#include <QPair>
#include <QtAlgorithms> 

#include "user_model.h"
#include "StationModel.h"
#include "SessionModel.h"


class ClubManagement : public QObject
{
    Q_OBJECT
public:
    explicit ClubManagement(QObject *parent = nullptr);

    Q_INVOKABLE bool connectToDb(QString host = "localhost", 
                               QString dbName = "postgres", 
                               QString user = "postgres", 
                               QString pass = "123");

    Q_INVOKABLE bool addUser(QString fio, QString phone, QString email);
    Q_INVOKABLE bool addStation(QString type, QString status);

    Q_INVOKABLE bool checkExists(QString email, QString phone);
    Q_INVOKABLE int checkUser(QString email, QString phone);
    Q_INVOKABLE int validateAndCheckUser(QString fio, QString phone, QString email);

    Q_INVOKABLE void refreshUsers(UserModel *model);
    Q_INVOKABLE void refreshStations(StationModel *model);
    Q_INVOKABLE void refreshSessions(SessionModel *model, QString status);

    Q_INVOKABLE bool deleteStation(int stationId);
    Q_INVOKABLE bool deleteUser(int userId);
    Q_INVOKABLE bool deleteSession(int sessionId);

    Q_INVOKABLE bool createBooking(int userId, int stationId, QString start, QString end);
    Q_INVOKABLE bool updateSessionStatus(int sessionId, QString statusName);

    Q_INVOKABLE bool toggleStationMaintenance(int stationId, QString currentStatus);
    Q_INVOKABLE QString generatePeriodReport(QString startStr, QString endStr);
    Q_INVOKABLE QString generateStationLoadReport(QString startStr, QString endStr);

private:
    QSqlDatabase db;

    bool isTimeSlotFree(int stationId, const QDateTime& start, const QDateTime& end);
};

#endif // CLUBMANAGEMENT_H
