/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components
import "../common/CommonConstants.js" as Constants

Page {
    id: infoPage

    property Style platformLabelStyle: LabelStyle {}

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
                color: "black"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                style: Text.Raised
                styleColor: "white"
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

        ToolIcon {
            iconId: "toolbar-back"
            onClicked: doBack();
        }
    }
}
