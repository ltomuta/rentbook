/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef TELEPHONY_H
#define TELEPHONY_H

#include <QObject>

// Forward declaration of the implementation class.
class TelephonyPrivate;


/*!
  \class Telephony
  \brief An interface to start and stop a phone call and notify clients of
         the call status.
*/
class Telephony : public QObject
{
    Q_OBJECT

public:
    explicit Telephony(QObject *parent = 0);
    ~Telephony();

    // An enum for returning error codes to clients of this interface.
    // This enum is not fully defined in this demonstration code.
    // Your own interface should define some meaningful errors.
    enum TelephonyErrors {
        TelephonyNotSupported,
        TelephonyError,
        TelephonyError2,
        TelephonyError3
    };

public slots:
    /*!
      Starts a call using \a number.
    */
    void startCall(QString number);

    /*!
      Ends the current call.
    */
    void endCall();

signals:
    /*!
      Emitted when the request for the call is first made.
    */
    void callDialling(QString number);

    /*!
      Emitted when telephone call is connected.
    */
    void callConnected();

    /*!
      Emitted when telephone call is disconnected.
    */
    void callDisconnected();

    /*!
      Emitted if some kind of error occurs.
    */
    void error(Telephony::TelephonyErrors error);

private:
    // The class that does the work.
    TelephonyPrivate *d_ptr;

    // Make TelephonyPrivate a friend so it can emit
    // signals using its pointer to its parent Telephony object.
    friend class TelephonyPrivate;
};

#endif // TELEPHONY_H
