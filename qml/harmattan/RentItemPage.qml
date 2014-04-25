/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components

import "UIConstants.js" as UIConstants

ItemManagingPage {
    id: rentItemPage

    property int rentId: -1
    property string rentName
    property int rentCost: 0
    property Style platformLabelStyle: LabelStyle {}

    /**
     * Adds or updates the rent data into the database.
     */
    function addRentToDatabase()
    {
        if (rentId != -1) {
            db.updateRentItem(rentId, nameField.text, priceField.text);
        }
        else {
            db.insertRentItem(nameField.text, priceField.text);
        }

        doBack();
    }

    /**
     * Displays the delete query dialog.
     */
    function showDeleteDialog()
    {
        if (!deleteDialog) {
            deleteDialog = deleteDialogComponent.createObject(rentItemPage);
        }

        deleteDialog.message = "Delete " + nameField.text + "?";
        deleteDialog.open();
    }

    /**
     * Deletes the rent data from the database.
     */
    function deleteRentFromDatabase()
    {
        db.deleteRentItem(rentId);
        doBack();
    }

    onRentIdChanged: {
        if (rentItemPage.rentId == -1) {
            state = "new";
        }
        else {
            state = "view";
        }
    }

    onSaveButtonClicked: addRentToDatabase();
    onDeleteButtonClicked: showDeleteDialog();

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

    Flickable {
        id: flickable

        anchors {
            fill: parent
            margins: 10
        }

        flickableDirection: Flickable.VerticalFlick
        contentHeight: (grid.columns == 1) ?
                           title.height + nameText.height * 4 + 70
                         : title.height + nameText.height * 2 + 50;

        Text {
            id: title
            height: font.pixelSize + 20
            color: platformLabelStyle.textColor

            anchors {
                top: parent.top
                left: parent.left
            }

            font {
                family: platformLabelStyle.fontFamily
                pixelSize: platformLabelStyle.fontPixelSize
                bold: true
            }

            text: "Resource for rent"
        }

        Grid {
            id: grid
            width: parent.width - anchors.margins * 2

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right
                margins: 5
            }

            columns: rentItemPage.width > rentItemPage.height ? 2 : 1
            spacing: 10

            // Resource name information
            Text {
                id: nameText
                width: parent.width * 0.15
                height: nameField.height
                color: platformLabelStyle.textColor
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformLabelStyle.fontFamily
                    pixelSize: platformLabelStyle.fontPixelSize
                }

                text: "Name:"
            }
            TextField {
                id: nameField
                width: (grid.columns == 1) ?
                           parent.width : parent.width - nameText.width - grid.spacing;
                enabled: (rentItemPage.state != "view")
                readOnly: !enabled
                placeholderText: "Enter name"
                text: rentName
            }

            // Resource price information
            Text {
                id: priceText
                width: nameText.width
                height: nameText.height
                color: platformLabelStyle.textColor
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformLabelStyle.fontFamily
                    pixelSize: platformLabelStyle.fontPixelSize
                }

                text: "Price:"
            }
            TextField {
                id: priceField
                width: nameField.width
                height: nameField.height
                enabled: (rentItemPage.state != "view")
                readOnly: !enabled
                inputMethodHints: Qt.ImhPreferNumbers // Accept only numers

                text: {
                    if (rentCost == 0) {
                        return "";
                    }

                    return rentCost;
                }
            }
        } // Grid
    } // Flickable

    ScrollDecorator {
        flickableItem: flickable
    }

    Component.onCompleted: {
        if (rentItemPage.rentId == -1) {
            state = "new";
        }
        else {
            state = "view";
        }
    }
}
