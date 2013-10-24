/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#include "componentloader.h"

#include <QDebug>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QDeclarativeView>
#include <QString>
#include <QTimer>


/*!
  Constructor.
*/
ComponentLoader::ComponentLoader(QDeclarativeView &view, QObject *parent)
    : QObject(parent),
      m_component(0),
      m_item(0),
      m_view(view)
{
    m_component = new QDeclarativeComponent(m_view.engine(),
                                            QUrl::fromLocalFile(MainQMLPath),
                                            this);

}


/*!
  Loads the component in \a delayInMs (milliseconds).
*/
void ComponentLoader::load(int delayInMs /* = 0 */)
{
    QTimer::singleShot(delayInMs, this, SLOT(createComponent()));
}


/*!
  Creates and displays the main component of the application.
*/
void ComponentLoader::createComponent(QDeclarativeComponent::Status status)
{

    qDebug() << "ComponentLoader::createComponent():" << status;

    if (!m_component->isReady()) {
        qDebug() << "ComponentLoader::createComponent():"
                 << "Component not ready! Connecting to status changed signal.";

        connect(m_component, SIGNAL(statusChanged(QDeclarativeComponent::Status)),
                this, SLOT(createComponent(QDeclarativeComponent::Status)),
                Qt::UniqueConnection);
        return;
    }
    else if (m_item) {
        qDebug() << "ComponentLoader::createComponent():"
                 << "Component already created!";
        return;
    }

    if (status == QDeclarativeComponent::Ready) {
        // Create the component
        m_item = qobject_cast<QDeclarativeItem*>(m_component->create());

        if (m_item) {
            m_view.scene()->addItem(m_item);

#ifndef Q_WS_HARMATTAN
            // Listen application raise signal
            connect(m_item, SIGNAL(raise()), &m_view, SLOT(raise()));
#endif
        }
        else {
            qDebug() << "ComponentLoader::createComponent():"
                     << "Failed to create the declarative item!";
        }
    }
    else if (status == QDeclarativeComponent::Error) {
        qDebug() << "ComponentLoader::createComponent(): Error status:"
                 << m_component->errors();
    }
}
