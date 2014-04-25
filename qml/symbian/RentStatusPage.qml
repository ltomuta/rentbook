/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components

import "../common/RentBook.js" as RentBookJS

Page {
    id: rentStatusPage

    property bool useCache: true
    property bool toolTipEnabled: false

    function showToolTip(text,target)
    {
        toolTip.text = text;
        toolTip.target = target;
        toolTip.visible = true;
        toolTipEnabled = true;
    }

    function hideToolTip()
    {
        toolTip.visible = false;
    }

    function fillListModel()
    {
        listView.model = emptyListModel;
        listModel.clear();

        RentBookJS.rentItems = db.rentItems(useCache);

        // Get rents
        var rentsData = db.dateRents(calendarItem.year,
                                     calendarItem.month,
                                     calendarItem.day);

        // Fill rent status list
        var rentItem;
        var rentsDataItem;
        var rentExists = false;

        for (var i = 0; i < RentBookJS.rentItems.length; i++) {
            rentItem = RentBookJS.rentItems[i];
            rentExists = false;

            for (var j = 0; j < rentsData.length; j++) {
                rentsDataItem = rentsData[j];

                if (rentItem.index == rentsDataItem.itemId) {
                    // Rent exists
                    var renterData = db.renter(rentsDataItem.renterId);
                    listModel.append({ "titleText": rentItem.name,
                                       "name": renterData.name,
                                       "phone": renterData.phone,
                                       "rent": true,
                                       "renterId": renterData.index,
                                       "rentItemId": rentItem.index,
                                       "rentBlockId": rentsDataItem.rentBlockIndex,
                                       "rentId": rentsDataItem.index });
                    rentExists = true;
                    renterData = null;
                    break;
                }

                rentsDataItem = null;
            }

            // Free item
            if (!rentExists) {
                listModel.append({ "titleText": rentItem.name,
                                   "name": "",
                                   "phone": "",
                                   "rent": false,
                                   "renterId": -1,
                                   "rentItemId": rentItem.index,
                                   "rentBlockId": -1,
                                   "rentId": -1});
            }

            rentItem = null;
        }

        if (listModel.count < 1) {
            addResourcesBtn.opacity = 1;
            listView.opacity = 0;
        }
        else {
            addResourcesBtn.opacity = 0;
            listView.opacity = 1;
        }

        listView.model = listModel;
        rentsData = null;
    }

    // Opens context menu for list
    function showContextMenu()
    {
        var currIndex = listView.currentIndex;
        var listModelItem = listModel.get(currIndex);

        if (listModelItem.rent) {
            contextMenu.title = "Edit booking";
        }
        else {
            contextMenu.title = "Add booking";
        }

        contextMenu.open();
    }


    // Page content

    // Update page data on page PageStatus.Activating state
    onStatusChanged: {
        if (status == PageStatus.Activating) {
            fillListModel();
        }
    }

    CalendarItem {
        id: calendarItem
        opacity: 0
        onDateChanged: fillListModel();
    }

    // Change date toolbar
    ToolBar {
        id: dateToolbar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        tools: ToolBarLayout {
            ToolButton {
                id: yesterdayBtn
                iconSource: "toolbar-previous"

                onClicked: {
                    if (!toolTipEnabled) {
                        calendarItem.setPriorDay();
                    }

                    toolTipEnabled = false;
                }
                onPlatformPressAndHold: {
                    showToolTip("Show yesterday", yesterdayBtn);
                }
                onPlatformReleased: {
                    hideToolTip();
                }
            }

            // The plain Button component is used (instead of a ToolButton)
            // in order to be able to explicitly define its width. Otherwise,
            // in landscape the button is too narrow to display the full date.
            Button {
                id: dateButton
                width: rentStatusPage.width / 2
                anchors.centerIn: parent

                text: RentBookJS.localeDate(calendarItem.day,
                                            calendarItem.month,
                                            calendarItem.year);

                onClicked: {
                    if (!toolTipEnabled) {
                        calendarItem.show();
                    }

                    toolTipEnabled = false;
                }

                onPlatformPressAndHold: {
                    showToolTip("Select active day from calendar", dateButton);
                }
                onPlatformReleased: {
                    hideToolTip();
                }
            }

            ToolButton {
                id: tomorrowBtn
                iconSource: "toolbar-next"

                onClicked: {
                    if (!toolTipEnabled) {
                        calendarItem.setNextDay();
                    }

                    toolTipEnabled = false;
                }
                onPlatformPressAndHold: {
                    showToolTip("Show tomorrow", tomorrowBtn);
                }
                onPlatformReleased: {
                    hideToolTip();
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: listView
    }

    ListView {
        id: listView

        anchors {
            top: dateToolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin:platformStyle.paddingMedium
        }

        clip: true
        delegate: listDelegate
        model: listModel
        header: listHeading
        focus: true
    }

    ListModel {
        id: listModel
    }

    ListModel {
        id: emptyListModel
    }

    Component {
        id: listDelegate

        ListItem {
            id: listItem
            property int renterId: model.renterId
            property int rentItemId: model.rentItemId
            property string renterName: model.name
            property string renterPhone: model.phone
            property bool rented: model.rent
            property int rentId: model.rentId
            property int rentBlockId: model.rentBlockId

            Image {
                width: 10
                height:  listItem.height - 4

                anchors {
                    left: parent.left
                    leftMargin: 4
                    verticalCenter: parent.verticalCenter
                }

                source: rented? "../common/red.png" : "../common/green.png"
            }
            Column {
                anchors.leftMargin: 10
                anchors.fill: listItem.paddingItem

                ListItemText {
                    mode: listItem.mode
                    role: "Title"
                    text: model.titleText
                }
                ListItemText {
                    mode: listItem.mode
                    role: "SubTitle"

                    text: {
                        if (listItem.rented) {
                            return "Rented by: " + model.name;
                        }
                        else {
                            return "Available";
                        }
                    }
                }
            }

            subItemIndicator: true

            onClicked: {
                pageStack.push(Qt.resolvedUrl("BookPage.qml"),
                               { renterId: listItem.renterId,
                                 renterName: listItem.renterName,
                                 renterPhone: listItem.renterPhone,
                                 rentItemId: listItem.rentItemId,
                                 year: calendarItem.year,
                                 month: calendarItem.month,
                                 day: calendarItem.day,
                                 rentBlockId: listItem.rentBlockId,
                                 rentId: listItem.rentId });
            }
            onPressAndHold: {
                showContextMenu();
            }
        }
    }

    Component {
        id: listHeading

        ListHeading {
            width: parent.width

            ListItemText {
                anchors.fill: parent.paddingItem
                role: "Heading"
                text: "Daily Booking Status"
            }
        }
    }

    Item {
        id: addResourcesBtn
        anchors.centerIn: parent
        opacity: 0

        Text {
            id: textid
            text: "No resources"
            color: "white"
            anchors.centerIn: parent
        }

        ToolButton {
            id: btn

            anchors {
                top: textid.bottom
                topMargin: 20
                horizontalCenter: textid.horizontalCenter
            }

            flat: false
            iconSource: "toolbar-add"
            text: "Add"

            onClicked: {
                if (!pageStack.busy && !toolTipEnabled) {
                    pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold:{
                showToolTip("Add resources for rent", btn);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }

    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout

        ToolButton {
            id: btn1
            flat: true
            iconSource: "toolbar-back"
            onClicked: Qt.quit()
        }
        ToolButton {
            id: btn2
            flat: false
            text: "Resources"

            onClicked: {
                if (!pageStack.busy && !toolTipEnabled) {
                    pageStack.push(Qt.resolvedUrl("RentItemsPage.qml"));
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold:{
                showToolTip("Add resources for rent", btn2);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
        ToolButton {
            id: btn3
            flat: true
            iconSource: "../common/info.png"

            onClicked: {
                if (!pageStack.busy && !toolTipEnabled) {
                    pageStack.push(Qt.resolvedUrl("InfoPage.qml"));
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold:{
                showToolTip("Informations about RentBook", btn3);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }

    ToolTip {
        id: toolTip
        visible: false
    }

    ContextMenu {
        id: contextMenu
        property string title

        MenuLayout {
            MenuItem {
                text: contextMenu.title
                onClicked: {
                    var currIndex = listView.currentIndex;
                    var listModelItem = listModel.get(currIndex);
                    pageStack.push(Qt.resolvedUrl("BookPage.qml"),
                                   { renterId: listModelItem.renterId,
                                     renterName: listModelItem.name,
                                     renterPhone: listModelItem.phone,
                                     rentItemId: listModelItem.rentItemId,
                                     year: calendarItem.year,
                                     month: calendarItem.month,
                                     day: calendarItem.day,
                                     rentId: listModelItem.rentId });
                }
            }
        }
    }
}
