/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

#include "telephony.h"
#include <QtGlobal>

// Conditional compilation for the target platform.
#ifdef Q_OS_SYMBIAN
#include "telephony_symbian.h"   // Symbian definition of private implementation class.
#else
#include "telephony_stub.h"      // Stub class for all other platforms.
#endif

// Constructor.
Telephony::Telephony(QObject *parent) : QObject(parent)
{
    #ifdef Q_OS_SYMBIAN
        // Symbian private class implementation.
        // This code can generate a Symbian Leave.
        // If it does, convert it into a throw.
        QT_TRAP_THROWING(d_ptr = TelephonyPrivate::NewL(this));
    #else
        // Stub class implementation
        d_ptr = new TelephonyPrivate(this);
    #endif
}

// Destructor - this public object owns the private implementation.
Telephony::~Telephony()
{
    delete d_ptr;
}

// Start a call using number.
void Telephony::startCall(QString number)
{
    d_ptr->startCall(number);
}

// Ends the current call.
void Telephony::endCall()
{
    d_ptr->endCall();
}

