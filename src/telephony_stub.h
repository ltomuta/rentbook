/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef TELEPHONY_STUB_H
#define TELEPHONY_STUB_H

#include <QObject>
#include "telephony.h"

// Forward declaration of the implementation class.
class TelephonyPrivate;


/*!
  \class TelephonyPrivate
  \brief A stub QObject implementation of the Telephony interface.
         startCall() and endCall() are not implemented.
*/
class TelephonyPrivate : public QObject
{
    Q_OBJECT

public:
    explicit TelephonyPrivate(Telephony *parent = 0);
    ~TelephonyPrivate();

public slots:
    // Calling these methods emits error(Telephony::TelephonyNotSupported)
    void startCall(QString number);
    void endCall();

private: // Data
    // Pointer to the public interface. Not owned.
    Telephony *publicAPI;
};

#endif // TELEPHONY_STUB_H
