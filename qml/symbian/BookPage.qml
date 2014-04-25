/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components
import com.nokia.extras 1.0 // Extras

import "../common/RentBook.js" as RentBookJS

ItemManagingPage {
    id: bookPage

    property int rentId
    property int rentItemId
    property int rentBlockId

    property int renterId
    property string renterName
    property string renterPhone

    property int year
    property int month
    property int day

    toolTipEnabled: false

    /**
     * Stores the data into the database.
     */
    function storeDataToDatabase()
    {
        if (renterId != -1) {
            // Update renter data
            db.updateRenter(renterId, nameField.text, phoneField.text);
        }
        else {
            // Insert new renter
            renterId = db.insertRenter(nameField.text, phoneField.text);

            // Add new rents
            addRentsToDatabase();
        }

        doBack();
    }

    /**
     * Adds the rental information into the database.
     */
    function addRentsToDatabase()
    {
        // Insert new rent
        var selDayIndex = tumblerColumn.selectedIndex;
        var date = new Date();
        var rentBlockId = db.nextId();

        for (var i = 0; i < selDayIndex + 1; i++) {
            date.setFullYear(year, month - 1, day + i); // year, month (0-based), day + i
            db.insertRent(date.getFullYear(), date.getMonth() + 1,
                          date.getDate(), rentBlockId,rentItemId, renterId);
        }
    }

    /**
     * Displays the delete query dialog.
     */
    function showDeleteDialog()
    {
        if (!deleteDialog) {
            deleteDialog = deleteDialogComponent.createObject(bookPage);
        }

        deleteDialog.message = "Delete whole booking?";
        deleteDialog.open();
    }

    /**
     * Deletes the rental information from the database.
     */
    function deleteRent()
    {
        db.deleteRentBlock(rentBlockId);
        doBack();
    }

    /**
     * Sets the booking start day and the available days into the tumbler
     * component.
     */
    function fillFreeDays()
    {
        tumblerColumn.items = emptyDayList;
        freeDayList.clear();
        var date = null;

        if (renterId != -1) {
            // Edit rent view
            var firstDate = db.firstBookedRentBlockDate(rentBlockId);
            date = new Date(firstDate);
            title.text = "Booking begins " + date.toDateString();

            var lastDate = db.lastBookedRentBlockDate(rentBlockId);
            date = new Date(lastDate);
            bookingEndsText.bookingEndsDate = date.toDateString();
            date = null;
        }
        else {
            // New rent view
            title.text = "Booking begins "
                    + RentBookJS.localeDate(day, month, year);

            for (var i = 0; i < 7; i++) {
                date = new Date();
                date.setFullYear(year, month - 1, day + i); // year, month (0-based), day + i
                var isFree = db.isFreeRentDate(rentItemId,
                                               date.getFullYear(),
                                               date.getMonth() + 1,
                                               date.getDate());

                if (isFree) {
                    freeDayList.append({ "index": i,
                                         "value": date.toDateString(),
                                         "year": date.getFullYear(),
                                         "month": date.getMonth() + 1,
                                         "day": date.getDate() });
                }
                else {
                    break;
                }

                date = null;
            }
        }

        tumblerColumn.items = freeDayList;
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            // Fill view after small delay
            delayedDataFillerTimer.restart();
        }
    }

    onRenterIdChanged: {
        console.debug("BookPage.qml: onRenterIdChanged:", renterId);

        if (renterId == -1) {
            state = "new";
        }
    }

    // Signals from ItemManagingPage
    onSaveButtonClicked: storeDataToDatabase();
    onDeleteButtonClicked: showDeleteDialog();

    Timer {
        id: delayedDataFillerTimer
        interval: 200
        repeat: false
        onTriggered: fillFreeDays();
    }

    // Page content

    Component {
        id: deleteDialogComponent

        QueryDialog {
            titleText: "Delete?"
            message: ""
            acceptButtonText: "Delete"
            rejectButtonText: "Cancel"
            onAccepted: deleteRent();
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: title.height + textFieldsGrid.height
                       + tumblerAndCallButtonColumn.height;
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Text {
            id: title
            height: font.pixelSize + textFieldsGrid.spacing

            anchors {
                top: parent.top
                left: parent.left
            }

            color: platformStyle.colorNormalLight

            font {
                family: platformStyle.fontFamilyRegular
                pixelSize: platformStyle.fontSizeLarge
                bold: true
            }

            text: " "
        }

        Grid {
            id: textFieldsGrid
            width: parent.width - anchors.margins * 2
            height: (textFieldsGrid.columns == 1) ?
                        nameText.height * 4 + spacing * 4 :
                        nameText.height * 2 + spacing * 2;

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right
                margins: platformStyle.paddingMedium
            }

            spacing: platformStyle.paddingLarge
            columns: bookPage.width > bookPage.height ? 2 : 1

            // Name information of the renter
            Text {
                id: nameText
                width: parent.width * 0.15
                height: nameField.height
                color: platformStyle.colorNormalLight
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformStyle.fontFamilyRegular;
                    pixelSize: platformStyle.fontSizeMedium
                }

                text: "Name:"
            }
            TextField {
                id: nameField
                width: (textFieldsGrid.columns == 1) ?
                           parent.width - textFieldsGrid.spacing
                         : parent.width - nameText.width - textFieldsGrid.spacing * 2;
                opacity: (bookPage.state == "view") ? 0 : 1;
                placeholderText: "Enter name"
                text: renterName
            }
            Item {
                id: nameReadOnlyFieldWrapper
                width: (textFieldsGrid.columns == 1) ?
                           parent.width : nameField.width;
                height: nameText.height
                opacity: (bookPage.state == "view") ? 1 : 0;

                Text {
                    id: nameReadOnlyField
                    x: (textFieldsGrid.columns == 1) ? 15 : 0
                    width: parent.width
                    height: nameText.height
                    color: platformStyle.colorNormalLight
                    verticalAlignment: Text.AlignVCenter

                    font {
                        family: platformStyle.fontFamilyRegular;
                        pixelSize: platformStyle.fontSizeLarge
                    }

                    text: renterName
                }
            }

            // Phone number of the renter
            Text {
                id: phoneText
                width: nameText.width
                height: nameText.height
                color: platformStyle.colorNormalLight
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformStyle.fontFamilyRegular;
                    pixelSize: platformStyle.fontSizeMedium
                }

                text: "Phone:"
            }
            TextField {
                id: phoneField
                width: nameField.width
                height: nameField.height
                opacity: nameField.opacity
                inputMethodHints: Qt.ImhPreferNumbers // Accept only numers
                text: renterPhone
            }
            Item {
                width: nameReadOnlyFieldWrapper.width
                height: nameReadOnlyFieldWrapper.height
                opacity: nameReadOnlyFieldWrapper.opacity

                Text {
                    id: phoneReadOnlyField
                    x: nameReadOnlyField.x
                    width: nameReadOnlyField.width
                    height: nameReadOnlyField.height
                    color: platformStyle.colorNormalLight
                    verticalAlignment: Text.AlignVCenter

                    font {
                        family: platformStyle.fontFamilyRegular;
                        pixelSize: platformStyle.fontSizeLarge
                    }

                    text: renterPhone
                }
            }
        }
        Column {
            id: tumblerAndCallButtonColumn
            width: parent.width - anchors.margins * 2
            height: (bookPage.state == "new") ?
                        bookingEndsText.height + dateTumbler.height + spacing * 3
                      : bookingEndsText.height + callButton.height + spacing * 3;

            anchors {
                top: textFieldsGrid.bottom
                left: parent.left
                right: parent.right
                margins: platformStyle.paddingMedium
            }

            spacing: platformStyle.paddingLarge

            // Booking ends
            Text {
                id: bookingEndsText

                property string bookingEndsDate: ""

                height: nameText.height
                color: platformStyle.colorNormalLight
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformStyle.fontFamilyRegular
                    pixelSize: platformStyle.fontSizeMedium
                }

                text: {
                    if (bookPage.state == "new") {
                        return "Booking ends";
                    }

                    return "Booking ends: " + bookingEndsDate;
                }
            }

            Tumbler  {
                id: dateTumbler
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                columns: tumblerColumn
            }
            TumblerColumn {
                id: tumblerColumn
                items: freeDayList
            }
            ListModel {
                id: freeDayList
            }
            ListModel {
                id: emptyDayList
            }
            ToolButton {
                id: callButton

                property bool isCalling: false

                anchors.horizontalCenter: parent.horizontalCenter
                opacity: (bookPage.state == "new") ? 0 : 1;
                flat: false
                text: isCalling ? "Disconnect" : "Call...    "

                onClicked: {
                    if (toolTipEnabled) {
                        toolTipEnabled = false;
                        return;
                    }

                    if (telephony) {
                        if (isCalling) {
                            isCalling = false;
                            telephony.endCall();
                        }
                        else {
                            if(phoneField.text.length < 2) {
                                callInfobanner.close();
                                callInfobanner.text = "Check the phone number";
                                callInfobanner.timeout = 3 * 1000;
                                callInfobanner.open();
                            }
                            else {
                                isCalling = true;
                                telephony.startCall(phoneField.text);
                            }
                        }
                    }
                }
                onPlatformPressAndHold:{
                    showToolTip("Dial to renter", callButton);
                }
                onPlatformReleased: {
                    hideToolTip();
                }
            }
        } // Column
    } // Flickable

    ScrollDecorator {
        flickableItem: flickable
    }

    ToolTip {
        id: toolTip
        visible: false
    }

    Connections {
        target: telephony

        onError:  {
            callButton.isCalling = false;
            pageStack.raiseApplication();
        }
        onCallDialling: {
            callButton.isCalling = true;
            pageStack.raiseApplication();
        }
        onCallConnected: {
            callButton.isCalling = true;
        }
        onCallDisconnected: {
            callButton.isCalling = false;
            pageStack.raiseApplication();
        }
    }

    InfoBanner {
        id: callInfobanner
    }

    transitions: [
        Transition {
            to: "new"

            SequentialAnimation {
                PauseAnimation { duration: 400 }
                NumberAnimation {
                    target: dateTumbler
                    property: "opacity"
                    from: 0; to: 1
                    duration: 1000
                }
            }
        }
    ]

    Component.onCompleted: {
        console.debug("BookPage.qml: Component.onCompleted: renterId ==", renterId);

        if (bookPage.renterId == -1) {
            state = "new";
        }
        else {
            state = "view";
        }
    }
}
