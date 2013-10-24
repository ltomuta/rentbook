/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components
import com.nokia.extras 1.1 // Extras

import "../common/RentBook.js" as RentBookJS

Page {
    id: rentItemsPage

    //property Menu pageMenu
    property QueryDialog deleteDialog
    property QueryDialog deleteDBDialog

    property bool useCache: false

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

    function freePage()
    {
        //delete pageMenu;
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

        for(var i=0;i<RentBookJS.rentItems.length;i++) {
            var item = RentBookJS.rentItems[i];
            listModel.append({"name":item.name,
                                 "id":item.index,
                                 "cost":item.cost});

            item = null;
        }


        if (listModel.count < 1)
            addResourcesBtn.opacity = 1;
        else
            addResourcesBtn.opacity = 0;

        listView.model = listModel;
    }

    // Show edit or add new rent page
    function showRendDetails()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        pageStack.push(Qt.resolvedUrl("RentItemPage.qml"),
                       { rentId : currentItem.id, rentName : currentItem.name, rentCost : currentItem.cost });

    }

    // Show dialog for deleting rent item
    function showDeleteDialog()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        if (currIndex != -1) {
            if (!deleteDialog) {
                deleteDialog = deleteDialogComponent.createObject(rentItemsPage)
            }
            deleteDialog.message = "Delete " + currentItem.name + "?"
            deleteDialog.open()
        }
    }

    // Show dialog for deleting whole database
    function showDeleteDBDialog()
    {
        if (!deleteDBDialog) {
            deleteDBDialog = deleteDBDialogComponent.createObject(rentItemsPage)
        }
        deleteDBDialog.open()

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
        if (status==PageStatus.Activating) {
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
            onAccepted: {
                deleteRentFromDatabase();
            }
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
        id: scrolldecorator
        flickableItem: listView
    }

    ListView {
        id: listView
        anchors { left: parent.left; right: parent.right;
            top: parent.top; bottom: parent.bottom }
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
            ListItemText {
                x: platformStyle.paddingLarge
                anchors.verticalCenter: listItem.verticalCenter
                mode: listItem.mode
                role: "Title"
                text: name
            }
            subItemIndicator: true
            onClicked: {
                showRendDetails();
            }
            onPressAndHold : {
                contextMenu.open();
            }

        }
    }

    ContextMenu {
        id: contextMenu
        MenuLayout {
            MenuItem {
                text: "Edit"
                onClicked: {
                    showRendDetails();
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    showDeleteDialog();
                }
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
                text: "Resource Management"
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
            id: btnAdd

            anchors {
                top: textid.bottom
                horizontalCenter: textid.horizontalCenter
                topMargin: 20
            }

            flat: false
            iconSource: "toolbar-add"
            text: "Add"

            onClicked: {
                if (!pageStack.busy) {
                    pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
                }
            }
            onPlatformPressAndHold: {
                showToolTip("Add resources for rent", btnAdd);
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

    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout

        ToolButton {
            id: btn
            flat: true
            iconSource: "toolbar-back"

            onClicked: {
                if (!toolTipEnabled) {
                    doBack();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Back to main view", btn);
            }
            onPlatformReleased: {
                hideToolTip();
            }

        }
        ToolButton {
            id: btn2
            flat: true
            iconSource: "toolbar-add"

            onClicked: {
                if (!pageStack.busy && !toolTipEnabled) {
                    pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
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
            iconSource: "toolbar-delete"

            onClicked: {
                if (!toolTipEnabled) {
                    showDeleteDBDialog();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Deleve all rents and bookings", btn3);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }
}
