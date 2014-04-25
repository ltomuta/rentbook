/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components
import com.nokia.extras 1.0 // Extras

import "UIConstants.js" as UIConstants
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

    property Style platformLabelStyle: LabelStyle {}

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
            width: parent.width - 20
            height: font.pixelSize + textFieldsGrid.spacing
            verticalAlignment: Text.AlignVCenter

            anchors {
                top: parent.top
                left: parent.left
                topMargin: 10
                leftMargin: 10
            }

            color: platformLabelStyle.textColor

            font {
                family: platformLabelStyle.fontFamily
                pixelSize: platformLabelStyle.fontPixelSize
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
                margins: 20
            }

            spacing: 10
            columns: bookPage.width > bookPage.height ? 2 : 1

            // Name information of the renter
            Text {
                id: nameText
                width: parent.width * 0.15
                height: nameField.height
                color: platformLabelStyle.textColor
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformLabelStyle.fontFamily;
                    pixelSize: platformLabelStyle.fontPixelSize
                }

                text: "Name:"
            }
            TextField {
                id: nameField
                width: (textFieldsGrid.columns == 1) ?
                           parent.width - textFieldsGrid.spacing
                         : parent.width - nameText.width - textFieldsGrid.spacing * 2;
                enabled: (bookPage.state != "view")
                readOnly: !enabled
                placeholderText: "Enter name"
                text: renterName
            }

            // Phone number of the renter
            Text {
                id: phoneText
                width: nameText.width
                height: nameText.height
                color: platformLabelStyle.textColor
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformLabelStyle.fontFamily;
                    pixelSize: platformLabelStyle.fontPixelSize
                }

                text: "Phone:"
            }
            TextField {
                id: phoneField
                width: nameField.width
                height: nameField.height
                enabled: (bookPage.state != "view")
                readOnly: !enabled
                inputMethodHints: Qt.ImhPreferNumbers // Accept only numers
                text: renterPhone
            }
        }
        Column {
            id: tumblerAndCallButtonColumn
            width: parent.width - anchors.margins * 2
            height: (bookPage.state == "new") ?
                        bookingEndsText.height + tumblerContainer.height + spacing * 3
                      : bookingEndsText.height + callButton.height + spacing * 3;

            anchors {
                top: textFieldsGrid.bottom
                left: parent.left
                right: parent.right
                margins: 20
            }

            spacing: 20

            // Booking ends
            Text {
                id: bookingEndsText

                property string bookingEndsDate: ""

                width: tumblerAndCallButtonColumn.width
                color: platformLabelStyle.textColor

                font {
                    family: platformLabelStyle.fontFamily
                    pixelSize: platformLabelStyle.fontPixelSize
                }

                text: {
                    if (bookPage.state == "new") {
                        return "Booking ends";
                    }

                    return "Booking ends: " + bookingEndsDate;
                }
            }
            Item {
                id: tumblerContainer
                width: tumblerAndCallButtonColumn.width
                height: (bookPage.state == "new") ? 300 : 0;

                Tumbler {
                    id: dateTumbler
                    width: parent.width
                    height: parent.height
                    opacity: (bookPage.state == "new") ? 1 : 0;
                    columns: tumblerColumn

                    Behavior on opacity { NumberAnimation { duration: 400 } }
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
            }
            Button {
                id: callButton
                x: (tumblerAndCallButtonColumn.width - width) / 2
                opacity: (bookPage.state == "new") ? 0 : 1;
                text: "Call..."

                onClicked: {
                    if (phoneField.text.length < 1) {
                        callInfobanner.text = "Check the phone number";
                        callInfobanner.show();
                    }
                    else {
                        Qt.openUrlExternally("tel:" + phoneField.text);
                    }
                }
            }
        } // Column
    } // Flickable

    ScrollDecorator {
        flickableItem: flickable
    }

    InfoBanner {
        id: callInfobanner
    }

    Component.onCompleted: {
        console.debug("BookPage.qml: Component.onCompleted: renterId ==", renterId);

        if (bookPage.renterId == -1) {
            bookPage.state = "new";
        }
        else {
            bookPage.state = "view";
        }
    }
}
