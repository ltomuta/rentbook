/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components

ItemManagingPage {
    id: rentItemPage

    property int rentId: -1
    property string rentName
    property int rentCost : 0

    state: "new"
    toolTipEnabled: false

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
            color: platformStyle.colorNormalLight

            anchors {
                top: parent.top
                left: parent.left
            }

            font {
                family: platformStyle.fontFamilyRegular
                pixelSize: platformStyle.fontSizeLarge
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
                color: platformStyle.colorNormalLight
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformStyle.fontFamilyRegular
                    pixelSize: platformStyle.fontSizeMedium
                }

                text: "Name:"
            }
            TextField {
                id: nameField
                width: (grid.columns == 1) ?
                           parent.width : parent.width - nameText.width - grid.spacing;
                opacity: (rentItemPage.state == "view") ? 0 : 1;
                placeholderText: "Enter name"
                text: rentName
            }
            Item {
                id: nameReadOnlyFieldWrapper
                width: (grid.columns == 1) ? parent.width : nameField.width
                height: nameText.height
                opacity: (rentItemPage.state == "view") ? 1 : 0;

                Text {
                    id: nameReadOnlyField
                    x: (grid.columns == 1) ? 15 : 0
                    width: parent.width
                    height: nameText.height
                    color: platformStyle.colorNormalLight
                    verticalAlignment: Text.AlignVCenter

                    font {
                        family: platformStyle.fontFamilyRegular
                        pixelSize: platformStyle.fontSizeLarge
                    }

                    text: rentName
                }
            }

            // Resource price information
            Text {
                id: priceText
                width: nameText.width
                height: nameText.height
                color: platformStyle.colorNormalLight
                verticalAlignment: Text.AlignVCenter

                font {
                    family: platformStyle.fontFamilyRegular
                    pixelSize: platformStyle.fontSizeMedium
                }

                text: "Price:"
            }
            TextField {
                id: priceField
                width: nameField.width
                height: nameField.height
                opacity: nameField.opacity
                inputMethodHints: Qt.ImhPreferNumbers // Accept only numers

                text: {
                    if (rentCost == 0) {
                        return "";
                    }

                    return rentCost;
                }
            }
            Item {
                width: nameReadOnlyFieldWrapper.width
                height: nameReadOnlyFieldWrapper.height
                opacity: nameReadOnlyFieldWrapper.opacity

                Text {
                    id: priceReadOnlyField
                    x: nameReadOnlyField.x
                    width: nameReadOnlyField.width
                    height: nameReadOnlyField.height
                    color: platformStyle.colorNormalLight
                    verticalAlignment: Text.AlignVCenter

                    font {
                        family: platformStyle.fontFamilyRegular
                        pixelSize: platformStyle.fontSizeLarge
                    }

                    text: {
                        if (rentCost == 0) {
                            return "";
                        }

                        return rentCost;
                    }
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
