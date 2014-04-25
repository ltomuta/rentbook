/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components
import com.nokia.extras 1.1 // Extras

Page {
    id: itemManagingPage

    property QueryDialog deleteDialog
    property bool toolTipEnabled: false

    signal saveButtonClicked()
    signal editButtonClicked()
    signal deleteButtonClicked()

    /**
     * Frees the allocated resources of the page.
     */
    function freePage()
    {
        delete deleteDialog;
    }

    /**
     * Called when this page needs to be popped from the page stack.
     */
    function doBack()
    {
        freePage();
        pageStack.pop();
    }

    /**
     * Displays a tool tip.
     *
     * @param text The text of the tool tip.
     * @param target The target item of the tool tip.
     */
    function showToolTip(text, target)
    {
        toolTip.text = text;
        toolTip.target = target;
        toolTip.visible = true;
        toolTipEnabled = true;
    }

    /**
     * Hides the tool tip.
     */
    function hideToolTip()
    {
        toolTip.visible = false;
    }

    ToolTip {
        id: toolTip
        visible: false
    }

    // Page specific toolbar
    tools: null

    // Tool bar for 'create new' view
    ToolBarLayout {
        id: toolBarLayoutNew

        ToolButton {
            id: saveButtonNew
            flat: false
            text: "Save"

            onClicked:  {
                if (!toolTipEnabled) {
                    itemManagingPage.saveButtonClicked();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Save information", saveButtonNew);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
        ToolButton {
            id: cancelButtonNew
            flat: false
            text: "Cancel"

            onClicked: {
                if (!toolTipEnabled) {
                    doBack();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Go back and discard changes", cancelButtonNew);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }

    // Tool bar for 'view item' view
    ToolBarLayout {
        id: toolBarLayoutView

        ToolButton {
            id: backButtonView
            flat: true
            iconSource: "toolbar-back"

            onClicked: {
                if (!toolTipEnabled) {
                    doBack();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Go back", backButtonView);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
        ToolButton {
            id: editButtonView
            flat: true
            iconSource: "../common/edit.svg"

            onClicked:  {
                if (!toolTipEnabled) {
                    itemManagingPage.editButtonClicked();
                    itemManagingPage.state = "edit";
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold:{
                showToolTip("Edit information", editButtonView);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
        ToolButton {
            id: deleteButtonView
            flat: true
            iconSource: "toolbar-delete"

            onClicked: {
                if (!toolTipEnabled) {
                    itemManagingPage.deleteButtonClicked();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Delete", deleteButtonView);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }

    // Tool bar for 'edit' view
    ToolBarLayout {
        id: toolBarLayoutEdit

        ToolButton {
            id: saveButtonEdit
            flat: false
            text: "Save"

            onClicked:  {
                if (!toolTipEnabled) {
                    itemManagingPage.saveButtonClicked();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold: {
                showToolTip("Save information", saveButtonEdit);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
        ToolButton {
            id: cancelButtonEdit
            flat: false
            text: "Cancel"

            onClicked: {
                if (!toolTipEnabled) {
                    doBack();
                }

                toolTipEnabled = false;
            }
            onPlatformPressAndHold:{
                showToolTip("Go back and discard changes", cancelButtonEdit);
            }
            onPlatformReleased: {
                hideToolTip();
            }
        }
    }

    states: [
        State {
            name: "new"

            StateChangeScript {
                name: "setToolBar"
                script: itemManagingPage.tools = toolBarLayoutNew;
            }
        },
        State {
            name: "view"

            StateChangeScript {
                name: "setToolBar"
                script: itemManagingPage.tools = toolBarLayoutView;
            }
        },
        State {
            name: "edit"

            StateChangeScript {
                name: "setToolBar"
                script: toolBar.tools = toolBarLayoutEdit;
            }
        }
    ]

    onStateChanged: console.debug("ItemManagingPage.qml: onStateChanged:", state);
}
