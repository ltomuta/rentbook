/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

#include "telephony_stub.h"

TelephonyPrivate::TelephonyPrivate(Telephony* parent) : QObject(parent)
{
    publicAPI = parent;
}

TelephonyPrivate::~TelephonyPrivate()
{
}

// No telephony support in this stub
void TelephonyPrivate::startCall(QString)
{
    Telephony::TelephonyErrors err = Telephony::TelephonyNotSupported;
    emit publicAPI->error(err);
}

// No telephony support in this stub
void TelephonyPrivate::endCall()
{
    Telephony::TelephonyErrors err = Telephony::TelephonyNotSupported;
    emit publicAPI->error(err);
}

