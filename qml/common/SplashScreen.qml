/**
 * Copyright (c) 2011-2014 Microsoft Mobile.
 */

import QtQuick 1.0

Rectangle {
    id: splashScreen
    width: appWidth
    height: appHeight
    color: "black"

    /**
     * Creates the animated splash screen image items.
     */
    function createItems()
    {
        for (var i = 0; i < 15; i++) {
            var imageObject = imageComponent.createObject(splashScreen);
            imageObject.animateFromX = width * 0.3;
            imageObject.animateFromY = height;

            imageObject.animateToX = imageObject.rand(-10, width - 80);
            imageObject.animateToY = imageObject.rand(0,height * 0.7);
            imageObject.animateDuration = imageObject.rand(500, 2000);
            imageObject.opacity = 1;
        }
    }

    Image {
        id: background
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "../common/splash-screen-image.png"
        opacity: 0.4
    }

    Component {
        id: imageComponent

        Image {
            id: image
            width: 80
            height: 80
            smooth: true
            source: "../common/rentbook.png"

            opacity: 0

            property int animateDuration

            property int animateToX
            property int animateToY

            property int animateFromX
            property int animateFromY

            function rand(min,max)
            {
                return Math.floor(Math.random() * max + min);
            }

            function show()
            {
                anim.restart();

            }

            Behavior on opacity {
                ScriptAction {
                    script: show();
                }
            }

            ParallelAnimation {
                id: anim
                NumberAnimation {
                    target: image; property: "rotation"; from: rand(-90, 0);
                    to: rand(0, 90); duration: image.animateDuration
                }
                PropertyAnimation {
                    target: image; property: "x"; from: image.animateFromX;
                    to: image.animateToX; duration: image.animateDuration
                }
                PropertyAnimation {
                    target: image; property: "y"; from: image.animateFromY;
                    to: image.animateToY; duration: image.animateDuration
                }
            }
        }
    }

    Component.onCompleted: {
        createItems();
    }
}
