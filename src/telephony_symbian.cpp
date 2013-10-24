/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#include "telephony_symbian.h"
#include <e32std.h>
#include <QtGlobal>

// Symbian static constructor.
TelephonyPrivate* TelephonyPrivate::NewL(Telephony *aPublicAPI)
{
    TelephonyPrivate* self = new (ELeave) TelephonyPrivate(aPublicAPI);
    CleanupStack::PushL(self);
    self->ConstructL();
    CleanupStack::Pop(self);
    return self;
}

// Symbian second stage constructor.
void TelephonyPrivate::ConstructL()
{
    iTelephony = CTelephony::NewL();
}

// Private constructor - initialise the pointer to the public API class
// and make this standard priority for scheduling.
TelephonyPrivate::TelephonyPrivate(Telephony *aPublicAPI)
    : iPublic(aPublicAPI), iCallStatusPckg(iCallStatus), CActive(CActive::EPriorityStandard)
{
    // Set idle state
    iCallState = EIdle;

    // Set the call status to unknown
    iCallStatus.iStatus = CTelephony::EStatusUnknown;

    // Active objects like this one must register
    // themselves with an Active scheduler.
    CActiveScheduler::Add(this);
}

TelephonyPrivate::~TelephonyPrivate()
{
    // Cancel any outstanding async request before this object is destroyed
    // in order to avoid stray signals.
    // This destructor cannot leave.
    Cancel(); //  Calls DoCancel()
    delete iTelephony;
}


// Public interface slot implementation - start a call using number.
void TelephonyPrivate::startCall(QString number)
{
    // Only allow one call to be active at any time
    if (iCallState != EIdle) {
        return;
    }

    // Convert the QString to a descriptor
    // typedef TBuf<KMaxTelNumberSize> TTelNumber;
    CTelephony::TTelNumber telNumber(number.utf16());

    // Dial the call
    CTelephony::TCallParamsV1 callParams;
    callParams.iIdRestrict = CTelephony::EIdRestrictDefault;
    CTelephony::TCallParamsV1Pckg callParamsPckg(callParams);

    // iCallId is set to a unique ID which can be used to end the call later.
    iTelephony->DialNewCall(iStatus, callParamsPckg, telNumber, iCallId);

    // Emit the callDialling signal to clients.
    iCallState = EDialling;

    // This function is only called from Qt code so no need to wrap in QT_TRY_CATCH_LEAVING.
    emit iPublic->callDialling(number);

    SetActive();
}

// Public interface slot implementation - end the current call.
void TelephonyPrivate::endCall()
{
    // If the call is still dialling, cancel that request
    if (iCallState == EDialling) {
        Cancel(); // Calls DoCancel() to cancel any outstanding async request
        iCallState = EIdle;

        // Notify clients that the call disconnected.
        // This function is only called from Qt code so no need to wrap in QT_TRY_CATCH_LEAVING.
        emit iPublic->callDisconnected();
        return;
    }

    // The call has been answered - so hang up.
    // Note this will ONLY work if the CALLING party hangs up
    // If the CALLED party hangs up then this code is not called.
    // Called party hang-up is handled by calling CTelephony::NotifyChange()
    // after the call has been connected - see RunL()
    else if (iCallState == EConnected) {
        Cancel();
        iTelephony->Hangup(iStatus, iCallId);
        iCallState = EDisconnecting;

        // Only emit callDisconnected() when this async request has completed - see RunL().
        SetActive();
    }
}

// Called when an asynchronous service request completes.
// This is called when requests for connecting and disconnecting calls complete.
void TelephonyPrivate::RunL()
{

    // Check return code and emit the appropriate signal based on iCallState.
    if (iStatus == KErrNone)
    {
        // Start call request has completed successfully.
        if (iCallState == EDialling) {
            iCallState = EConnected;

            // Call connect was succesful - notify clients.
            // This Qt code could throw, need to convert to a Symbian Leave if it does.
            QT_TRYCATCH_LEAVING( emit iPublic->callConnected() );

            // Start a new async request to be notified if the called party hangs up.
            iTelephony->NotifyChange(iStatus, CTelephony::EVoiceLineStatusChange, iCallStatusPckg);
            SetActive();
        }

        // Hang up request has completed successfully.
        else if (iCallState == EDisconnecting) {
            iCallState = EIdle;

            // Notify clients of call disconnection.
            QT_TRYCATCH_LEAVING( emit iPublic->callDisconnected() );
        }

        // CTelephony::NotifyChange() has completed.
        // The call state has changed. Check if the called party has hung-up
        // by checking for disconnecting status.
        // Emit callDisconnected if necessary
        else if (iCallState == EConnected) {

            // Is the call disconnecting?
            if (iCallStatus.iStatus == CTelephony::EStatusDisconnecting ||
                    iCallStatus.iStatus == CTelephony::EStatusIdle) {

                iCallState = EIdle;

                // Notify clients of call disconnection.
                QT_TRYCATCH_LEAVING( emit iPublic->callDisconnected() );
            }
        }

    }
    // Return code was not KErrNone - so it could be an error or a timeout.
    // Convert the Symbian error code into an enum value defined on the Telephony interface.
    else {
        iCallState = EIdle;
        ConvertErrorL(iStatus.Int());
    }
}

// Cancel an outstanding asynchronous request.
// What to do here depends on what state the call is in.
void TelephonyPrivate::DoCancel()
{
    if (iCallState == EDialling) {
        iTelephony->CancelAsync(CTelephony::EDialNewCallCancel);
    }
    else if (iCallState == EDisconnecting)
    {
        iTelephony->CancelAsync(CTelephony::EHangupCancel);
    }
    else if (iCallState == EConnected)
    {
        iTelephony->CancelAsync(CTelephony::EVoiceLineStatusChangeCancel);
    }
    // If iCallState is EIdle there is no outstanding async request.
}

// Convert from a Symbian error code to a Telephony::TelephonyErrors enum value.
// This is called from RunL() and it could leave if emitting the signal throws.
void TelephonyPrivate::ConvertErrorL(int err)
{
    // Full error conversion code is not implemented in this example.
    // switch (err) {
    //    case:
    // }

    // Just emit Telephony::TelephonyError for any error.
    Telephony::TelephonyErrors error = Telephony::TelephonyError;
    QT_TRYCATCH_LEAVING( emit iPublic->error(error) );
}

