/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components
import com.nokia.extras 1.0 // Extras

import "UIConstants.js" as UIConstants
import "../common/RentBook.js" as RentBookJS

Page {
    id: rentItemsPage

    property QueryDialog deleteDialog
    property QueryDialog deleteDBDialog
    property Style platformLabelStyle: LabelStyle {}
    property bool useCache: false

    function freePage()
    {
        delete deleteDialog;
        delete deleteDBDialog;
    }

    // Free menu and pop
    function doBack()
    {
        freePage();
        pageStack.pop();
    }
    
    // Update page data
    function fillListModel()
    {
        listView.model = emptyListModel;
        listModel.clear();

        RentBookJS.rentItems = db.rentItems(useCache);

        for (var i = 0; i < RentBookJS.rentItems.length; i++) {
            var item = RentBookJS.rentItems[i];
            listModel.append( {"name": item.name,
                               "id": item.index,
                               "cost": item.cost });
            item = null;
        }


        if (listModel.count < 1) {
            addResourcesBtn.opacity = 1;
        }
        else {
            addResourcesBtn.opacity = 0;
        }

        listView.model = listModel;
    }

    // Show edit or add new rent page
    function showRendDetails()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        pageStack.push(Qt.resolvedUrl("RentItemPage.qml"),
                       { rentId: currentItem.id,
                         rentName: currentItem.name,
                         rentCost: currentItem.cost });
    }

    // Show dialog for deleting rent item
    function showDeleteDialog()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);

        if (currIndex != -1) {
            if (!deleteDialog) {
                deleteDialog = deleteDialogComponent.createObject(rentItemsPage);
            }

            deleteDialog.message = "Delete " + currentItem.name + "?";
            deleteDialog.open();
        }
    }

    // Show dialog for deleting whole database
    function showDeleteDBDialog()
    {
        if (!deleteDBDialog) {
            deleteDBDialog = deleteDBDialogComponent.createObject(rentItemsPage);
        }

        deleteDBDialog.open();
    }

    // Delete rent item from database
    function deleteRentFromDatabase()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);

        if (currIndex != -1) {
            db.deleteRentItem(currentItem.id);
        }

        fillListModel();
    }

    // Update page data on page PageStatus.Activating state
    onStatusChanged: {
        if (status == PageStatus.Activating) {
            fillListModel();
        }
    }


    // Page content

    Component {
        id: deleteDialogComponent

        QueryDialog {
            titleText: "Delete?"
            message: ""
            acceptButtonText: "Delete"
            rejectButtonText: "Cancel"
            onAccepted: deleteRentFromDatabase();
        }
    }

    Component {
        id: deleteDBDialogComponent

        QueryDialog {
            titleText: "Delete whole database?"
            message: "Delete all rent items and bookings?"
            acceptButtonText: "Delete all"
            rejectButtonText: "Cancel"

            onAccepted: {
                db.deleteDB();
                db.open();
                fillListModel();
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
            top: parent.top
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

            text: "Resource Management"
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
            width: listView.width
            height: UIConstants.LIST_ITEM_HEIGHT_SMALL

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
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    color: "transparent"
                    width: 5
                    height: parent.height
                }
                Image {
                    source: "../common/for-rent.png"
                    opacity: 0.7
                    fillMode: Image.PreserveAspectFit
                    height: listItem.height - 10
                    width: listItem.height - 10
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        font {
                            family: platformLabelStyle.fontFamily
                            pixelSize: platformLabelStyle.fontPixelSize
                        }

                        color: platformLabelStyle.textColor
                        text: name
                    }
                    Text {
                        font {
                            family: platformLabelStyle.fontFamily
                            pixelSize: platformLabelStyle.fontPixelSize
                        }

                        color: platformLabelStyle.textColor
                        text: "Value is " + cost
                    }
                }
            }
            MouseArea {
                id: itemMouseArea
                anchors.fill: parent

                onClicked: {
                    listView.currentIndex = index;
                    showRendDetails();
                }
                onPressAndHold: {
                    listView.currentIndex = index;
                    contextMenu.open();
                }
            }
        }
    }

    ContextMenu {
        id: contextMenu

        MenuLayout {
            MenuItem {
                text: "Edit"
                onClicked: showRendDetails();
            }
            MenuItem {
                text: "Delete"
                onClicked: showDeleteDialog();
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

            onClicked: {
                pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
            }
        }
    }

    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout

        ToolIcon {
            iconId: "toolbar-back"
            onClicked: doBack();
        }
        ToolIcon {
            iconId: "toolbar-add"
            onClicked: pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
        }
        ToolIcon {
            iconId: "toolbar-delete"
            onClicked: showDeleteDBDialog();
        }
    }
}
