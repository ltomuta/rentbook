/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef COMPONENTLOADER_H
#define COMPONENTLOADER_H

#include <QDeclarativeComponent>
#include <QDeclarativeView>
#include <QObject>

// Constants
const QString MainQMLPath =
#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
        "qml/symbian/MainView.qml";
#elif defined(Q_WS_HARMATTAN)
        "/home/developer/rentbook/qml/harmattan/MainView.qml";
#else
        "";
#endif

// Forward declarations
class QDeclarativeItem;


class ComponentLoader : public QObject
{
    Q_OBJECT

public:
    explicit ComponentLoader(QDeclarativeView &view, QObject *parent = 0);

public slots:
    void load(int delayInMs = 0);

private slots:
    void createComponent(QDeclarativeComponent::Status status =
            QDeclarativeComponent::Ready);

private: // Data
    QDeclarativeComponent *m_component; // Owned
    QDeclarativeItem *m_item; // Not owned
    QDeclarativeView &m_view;
};

#endif // COMPONENTLOADER_H
