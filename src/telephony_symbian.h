/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef TELEPHONY_SYMBIAN_H
#define TELEPHONY_SYMBIAN_H

#include "telephony.h"
#include <e32base.h>
#include <etel3rdparty.h>


/*!
  \class TelephonyPrivate
  \brief The Symbian implementation of Telephony interface. Starts and stops
         a phone call on Symbian and notify clients of the call status.
*/
class TelephonyPrivate : public CActive
{
public:
    /*!
      Symbian style static constructor,
    */
    static TelephonyPrivate* NewL(Telephony *aPublicAPI);

    ~TelephonyPrivate();

private:
    // An enum for tracking the connection state of this object
    enum TCallStates { EIdle, EDialling, EConnected, EDisconnecting };

    /*!
      Constructor is private - NewL must be used to create objects.
    */
    TelephonyPrivate(Telephony *publicInterface);

    /*!
      Symbian second stage constructor.
    */
    void ConstructL();

    /*!
      Converts the given Symbian error code to interface
      Telephony::TelephonyErrors enum.
    */
    void ConvertErrorL(int err);

public:
    /*!
      Starts a call using \a number
    */
    void startCall(QString number);

    /*!
      Ends the current call.
    */
    void endCall();

public: // From CActive
    /*!
      Cancels an outstanding request.
    */
    void DoCancel();

    /*!
      Called when an asynchronous service request completes.
    */
    void RunL();

private: // Data
    // The Symbian telephony API class for making phone calls
    CTelephony *iTelephony;

    // Pointer to the public interface object that owns this private implementation
    Telephony *iPublic;

    // ID of the current call - used to end the call
    CTelephony::TCallId iCallId;

    // Status of the call
    CTelephony::TCallStatusV1 iCallStatus;
    CTelephony::TCallStatusV1Pckg iCallStatusPckg;

    // The connection state of this object
    TCallStates iCallState;
};

#endif // TELEPHONY_SYMBIAN_H
