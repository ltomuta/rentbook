/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.1 // Symbian components
import "../common/CommonConstants.js" as Constants

Page {
    id: infoPage

    function doBack()
    {
        pageStack.pop();
    }

    // Page content

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: textContainer.height
        clip: true

        Item {
            id: textContainer
            height: text.height + anchors.margins * 2

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 20
            }

            Text {
                id: text
                width: parent.width
                color: "white"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                style: Text.Raised
                styleColor: "black"
                font.pixelSize: width * 0.05
                text: "<h2>RentBook " + appversion + "</h2>" + Constants.INFO_TEXT;
                onLinkActivated: Qt.openUrlExternally(link);
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: doBack();
        }
    }
}
