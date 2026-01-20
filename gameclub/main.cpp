#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ClubManagement.h"
#include <QSqlTableModel>

#include <QSqlDatabase>

int main(int argc, char *argv[])
{

    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
    db.setHostName("localhost");
    db.setDatabaseName("postgres");
    db.setUserName("postgres");
    db.setPassword("123");

    if (!db.open()) return -1;

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    ClubManagement management;
    management.connectToDb();

    StationModel stationModel;
    UserModel *userModel = new UserModel();
    SessionModel sessionModel;

    engine.rootContext()->setContextProperty("sessionModel", &sessionModel);
    engine.rootContext()->setContextProperty("stationModel", &stationModel);
    engine.rootContext()->setContextProperty("userModel", userModel);

    engine.rootContext()->setContextProperty("clubManager", &management);

    const QUrl url(u"qrc:/gameclub/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
