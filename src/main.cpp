/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

#include <QDeclarativeComponent> // qmlRegisterType
#include <QtGui/QApplication>
#include <QDeclarativeView>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDir>
#include <QDebug>
#include <QDesktopWidget>

#include "componentloader.h"
#include "DatabaseManager.h"

#ifdef Q_OS_SYMBIAN
#include "telephony.h"
#endif

// Constants
const int SplashScreenDelay =
#ifdef Q_WS_HARMATTAN
    1000;
#else
    3000;
#endif


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QDeclarativeView view;
    view.setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view.setAutoFillBackground(false);

    view.setGeometry(QApplication::desktop()->screenGeometry());
    view.rootContext()->setContextProperty("appWidth", view.geometry().width());
    view.rootContext()->setContextProperty("appHeight", view.geometry().height());

    // Setting database Qt class handle to QML
    DatabaseManager* db = new DatabaseManager();
    db->open();
    view.rootContext()->setContextProperty("db", db);

    // CTelephony API for the native Symbian
#ifdef Q_OS_SYMBIAN
    view.rootContext()->setContextProperty("telephony", new Telephony);
#else
    view.rootContext()->setContextProperty("telephony", 0);
#endif

    // App version to QML in Symbian^3 version build
#ifndef Q_OS_SYMBIAN_1
    app.setApplicationVersion(APP_VERSION);
    view.rootContext()->setContextProperty("appversion",
                                           app.applicationVersion());
#endif

    // Start QML page
#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    view.setSource(QUrl::fromLocalFile("qml/common/SplashScreen.qml"));
#else
    #ifdef Q_WS_HARMATTAN
        // Skip the splash screen in Harmattan
        view.setSource(QUrl::fromLocalFile(MainQMLPath));
    #else
        view.setSource(QUrl::fromLocalFile("/home/developer/rentbook/qml/common/SplashScreen.qml"));
    #endif

    QDeclarativeEngine *engine = view.engine();
    QObject::connect(engine, SIGNAL(quit()), &app, SLOT(quit()));
#endif

    // Show application in full screen mode
    view.showFullScreen();

#ifndef Q_WS_HARMATTAN
    // Hides splash screen and shows application main screen after few seconds
    ComponentLoader componentLoader(view);
    componentLoader.load(SplashScreenDelay);
#endif

    // Start the application
    int ret = app.exec();
    delete db;
    return ret;
}
