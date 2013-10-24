/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components

import "UIConstants.js" as UIConstants
import "../common/RentBook.js" as RentBookJS

Page {
    id: rentStatusPage

    property bool useCache: true
    property Style platformLabelStyle: LabelStyle {}

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
                                   "rentId": -1 });
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
            ToolIcon {
                iconId: "toolbar-previous"
                onClicked: calendarItem.setPriorDay();
            }
            ToolButton {
                id: dateButton
                text: RentBookJS.localeDate(calendarItem.day,
                                            calendarItem.month,
                                            calendarItem.year);
                onClicked: calendarItem.show();
            }
            ToolIcon {
                iconId: "toolbar-next"
                onClicked: calendarItem.setNextDay();
            }
        }
    }

    ScrollDecorator {
        flickableItem: listView
    }

    Rectangle {
        id: header
        height: 40

        anchors {
            top: dateToolbar.bottom
            left: parent.left
            right: parent.right
            topMargin: UIConstants.SMALL_MARGIN
        }

        color: "lightgray"

        Text {
            anchors.centerIn: parent
            color: platformLabelStyle.textColor

            font {
                family: platformLabelStyle.fontFamily
                pixelSize: platformLabelStyle.fontPixelSize
            }

            text: "Daily Booking Status"
        }
    }

    ListView {
        id: listView
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: UIConstants.SMALL_MARGIN
        }

        clip: true
        delegate: listDelegate
        model: listModel
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

        Item {
            id: listItem
            property int renterId: model.renterId
            property int rentItemId: model.rentItemId
            property string renterName: model.name
            property string renterPhone: model.phone
            property bool rented: model.rent
            property int rentId: model.rentId
            property int rentBlockId: model.rentBlockId

            height: UIConstants.LIST_ITEM_HEIGHT_DEFAULT
            width: listView.width

            Rectangle {
                radius: 8
                anchors.fill: parent
                opacity: 0.7
                color: "#1874CD"
                visible: itemMouseArea.pressed
            }
            Row {
                spacing: 20
                anchors.fill: listItem.paddingItem

                Image {
                    width: 20
                    height: listItem.height - UIConstants.SMALL_MARGIN
                    anchors.verticalCenter: parent.verticalCenter
                    source: rented ? "../common/red.png" : "../common/green.png"
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        color: platformLabelStyle.textColor

                        font {
                            family: platformLabelStyle.fontFamily
                            pixelSize: platformLabelStyle.fontPixelSize
                        }

                        text: model.titleText
                    }
                    Text {
                        color: platformLabelStyle.textColor

                        font {
                            family: platformLabelStyle.fontFamily
                            pixelSize: platformLabelStyle.fontPixelSize
                        }

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
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent

                onClicked: {
                    listView.currentIndex = index;
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
                    listView.currentIndex = index;
                    contextMenu.open();
                }
            }
        }
    }


    Item {
        id: addResourcesBtn
        anchors.centerIn: parent
        opacity: 0

        Text {
            id: textid
            anchors.centerIn: parent
            color: platformLabelStyle.textColor

            font {
                family: platformLabelStyle.fontFamily
                pixelSize: platformLabelStyle.fontPixelSize
            }

            text: "No resources"
        }
        Button {
            text: "Add"

            anchors {
                top: textid.bottom
                horizontalCenter: textid.horizontalCenter
                topMargin: 20
            }

            onClicked: pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
        }
    }

    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout

        Item { width: UIConstants.BUTTON_SPACING } // Make margins
        ToolButton {
            text: "Resources"
            onClicked: pageStack.push(Qt.resolvedUrl("RentItemsPage.qml"));
        }
        ToolButton {
            text: "Info"
            onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml"));
        }
        Item { width: UIConstants.BUTTON_SPACING } // Make margins
    }

    ContextMenu {
        id: contextMenu

        MenuLayout {
            MenuItem {
                text: "Edit"

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
