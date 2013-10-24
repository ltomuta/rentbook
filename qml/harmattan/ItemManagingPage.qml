/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // Symbian components
import com.nokia.extras 1.0 // Extras
import "UIConstants.js" as UIConstants

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

    // Page specific toolbar
    tools: {
        if (state == "new") {
            return toolBarLayoutNew;
        }

        return toolBarLayoutView;
    }

    // Tool bar for 'create new' view
    ToolBarLayout {
        id: toolBarLayoutNew
        opacity: 1

        Item { width: UIConstants.BUTTON_SPACING } // Make margins
        ToolButton {
            id: saveButtonNew
            flat: false
            text: "Save"
            onClicked: itemManagingPage.saveButtonClicked();
        }
        ToolButton {
            id: cancelButtonNew
            flat: false
            text: "Cancel"
            onClicked: doBack();
        }
        Item { width: UIConstants.BUTTON_SPACING } // Make margins
    }

    // Tool bar for 'view item' view
    ToolBarLayout {
        id: toolBarLayoutView

        ToolIcon {
            id: backButtonView
            iconId: "toolbar-back"
            onClicked: doBack();
        }
        ToolIcon {
            id: editButtonView
            iconSource: "../common/edit.svg"

            onClicked:  {
                itemManagingPage.editButtonClicked();
                itemManagingPage.state = "edit";
            }
        }
        ToolIcon {
            id: deleteButtonView
            iconId: "toolbar-delete"
            onClicked: itemManagingPage.deleteButtonClicked();
        }
    }

    // Tool bar for 'edit' view
    ToolBarLayout {
        id: toolBarLayoutEdit

        Item { width: UIConstants.BUTTON_SPACING } // Make margins
        ToolButton {
            id: saveButtonEdit
            flat: false
            text: "Save"
            onClicked: itemManagingPage.saveButtonClicked();
        }
        ToolButton {
            id: cancelButtonEdit
            flat: false
            text: "Cancel"
            onClicked: doBack();
        }
        Item { width: UIConstants.BUTTON_SPACING } // Make margins
    }

    states: [
        State {
            name: "new"

            StateChangeScript {
                name: "setToolBar"
                script: {
                    toolBar.tools = toolBarLayoutNew;
                    toolBarLayoutEdit.opacity = 0;
                    toolBarLayoutNew.opacity = 1;
                    toolBarLayoutView.opacity = 0;
                }
            }
        },
        State {
            name: "view"

            StateChangeScript {
                name: "setToolBar"
                script: {
                    toolBar.tools = toolBarLayoutView;
                    toolBarLayoutEdit.opacity = 0;
                    toolBarLayoutNew.opacity = 0;
                    toolBarLayoutView.opacity = 1;
                }
            }
        },
        State {
            name: "edit"

            StateChangeScript {
                name: "setToolBar"
                script: {
                    toolBar.tools = toolBarLayoutEdit;
                    toolBarLayoutEdit.opacity = 1;
                    toolBarLayoutNew.opacity = 0;
                    toolBarLayoutView.opacity = 0;
                }
            }
        }
    ]

    onStateChanged: console.debug("ItemManagingPage.qml: onStateChanged:", state);
}
