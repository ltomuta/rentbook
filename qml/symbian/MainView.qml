/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components

Window {
    id: root

    signal raise;

    // Common application statusbar
    StatusBar {
        id: statusBar
        anchors.top: root.top
        z: 2
    }

    Text {
        id: titleId        

        anchors {
            top: statusBar.top
            left: parent.left
            leftMargin: platformStyle.paddingSmall
        }

        z: 3

        font {
            family: platformStyle.fontFamilyRegular
            pixelSize: platformStyle.fontSizeMedium
        }

        color: platformStyle.colorNormalLight
        text: "RentBook"
    }

    // Page stack for all pages
    PageStack {
        id: pageStack

        function raiseApplication()
        {
            root.raise();
        }

        toolBar: commonToolBar

        anchors {
            top: titleId.bottom
            left: parent.left
            right: parent.right
            bottom: commonToolBar.top
            topMargin: platformStyle.paddingMedium
            bottomMargin: platformStyle.paddingSmall
        }

        Component.onCompleted: {
            // Push the first pages to the stack
            pageStack.push(Qt.resolvedUrl("RentStatusPage.qml"));
        }
    }

    // Common toolbar for the pages
    ToolBar {
         id: commonToolBar
         anchors.bottom: parent.bottom
    }
}
