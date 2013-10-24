/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components
import com.nokia.extras 1.0 // Extras
import "UIConstants.js" as UIConstants

Item {
    id: container

    property int day:  0
    property int month: 0
    property int year: 0

    signal dateChanged();

    function getCurrentFullDate()
    {
        var date = new Date();
        date.setFullYear(year, month - 1, day); // year, month (0-based), day
        return date;
    }

    function show()
    {
        container.opacity = 1;
        dialog.day = day;
        dialog.month = month;
        dialog.year = year;
        dialog.open()
    }

    function setToday()
    {
        var date = new Date(); // http://www.w3schools.com/js/js_obj_date.asp
        year = date.getFullYear();
        month = date.getMonth() + 1;
        day = date.getDate();
    }

    function setNextDay()
    {
        var date = new Date();
        date.setFullYear(year, month - 1, day); // year, month (0-based), day
        date.setDate(date.getDate() + 1);

        year = date.getFullYear();
        month = date.getMonth() + 1;
        day = date.getDate();

        dateChanged();
    }

    function setPriorDay()
    {
        var date = new Date();
        date.setFullYear(year, month - 1, day); // year, month (0-based), day
        date.setDate(date.getDate() - 1);

        year = date.getFullYear();
        month = date.getMonth() + 1;
        day = date.getDate();

        dateChanged();
    }

    function callbackFunction() {
        day = dialog.day;
        month = dialog.month;
        year = dialog.year;

        dateChanged();
    }

    Component.onCompleted: {
        setToday();
    }

    DatePickerDialog {
        id: dialog
        titleText: "Calendar"

        buttons: ToolBar {
            id: buttons
            tools: Row {
                anchors.centerIn: parent
                spacing: UIConstants.SMALL_MARGIN

                ToolButton {
                    flat: false
                    text: "Select"
                    width: (buttons.width - 3 * 4) / 2
                    onClicked: dialog.accept()
                }

                ToolButton {
                    flat: false
                    text: "Cancel"
                    width: (buttons.width - 3 * 4) / 2
                    onClicked: dialog.reject()
                }
            }
        }

        onAccepted: {
            callbackFunction();
        }
        onRejected: { }
    }
}
