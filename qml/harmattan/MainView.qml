/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.1
import com.nokia.meego 1.0 // MeeGo 1.2 Harmattan components

PageStackWindow {
    id: root

    showStatusBar: true
    showToolBar: true

    initialPage: RentStatusPage {}

    property Style platformLabelStyle: LabelStyle {}
}
