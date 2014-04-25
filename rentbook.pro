
# Copyright (c) 2011-2014 Microsoft Mobile.

QT       += core gui sql declarative
CONFIG   += qt-components

TARGET = rentbook
TEMPLATE = app

VERSION = 1.0

SOURCES += \
    src/main.cpp \
    src/componentloader.cpp \
    src/DatabaseManager.cpp \
    src/telephony.cpp

HEADERS += \
    src/componentloader.h \
    src/DatabaseManager.h \
    src/telephony.h

#RESOURCES += resources.qrc

OTHER_FILES += \
    qml/common/*.qml \
    qml/common/*.js \
    qml/common/*.svg \
    qml/common/*.png

# Publish the app version to source code.
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Symbian specific
symbian {
    message(Symbian build)
    TARGET = RentBook
    TARGET.UID3 = 0xea6c2793
    TARGET.CAPABILITY += NetworkServices
    TARGET.EPOCSTACKSIZE = 0x14000
    TARGET.EPOCHEAPSIZE = 0x1000 0x1800000 # 24MB
    ICON = icons/rentbook.svg

    # Define the preprocessor macro to get the version in our app.
    contains(SYMBIAN_VERSION, Symbian3) {
        message(Symbian build)
        DEFINES += APP_VERSION=\"$$VERSION\"
    }
    else {
        message(Symbian^1 build)
        DEFINES += Q_OS_SYMBIAN_1
    }

    HEADERS += src/telephony_symbian.h
    SOURCES += src/telephony_symbian.cpp
    LIBS += -letel3rdparty

    OTHER_FILES += \
        qml/symbian/*.qml \
        qml/symbian/*.js

    RESOURCES += resources.qrc

    qmlfiles.sources = qml
    DEPLOYMENT += qmlfiles
}

# Harmattan specific
contains(MEEGO_EDITION, harmattan) {
    message(Harmattan build)
    DEFINES += Q_WS_HARMATTAN

    HEADERS += src/telephony_stub.h
    SOURCES += src/telephony_stub.cpp

    target.path = /opt/usr/bin
    INSTALLS += target

    qmlfiles.path = /home/developer/rentbook/qml/
    qmlfiles.files += qml/*
    INSTALLS += qmlfiles

    desktopfile.files = rentbook.desktop
    desktopfile.path = /usr/share/applications
    icon.files = icons/rentbook.png
    icon.path = /usr/share/icons/hicolor/64x64/apps
    INSTALLS += desktopfile icon
    
    OTHER_FILES += \
        qml/harmattan/*.qml \
        qml/harmattan/*.js
}

# Simulator
simulator {
    message(Simulator build)

    HEADERS += src/telephony_stub.h
    SOURCES += src/telephony_stub.cpp

    OTHER_FILES += qml/symbian/*.qml

    # Modify the following path if necessary
    SHADOW_BLD_PATH = ..\\rentbook-build-simulator-Simulator_Qt_for_MinGW_4_4__Qt_SDK__Debug

    system(mkdir $${SHADOW_BLD_PATH}\\qml\\symbian)
    system(mkdir $${SHADOW_BLD_PATH}\\qml\\common)
    system(copy qml\\symbian\\*.* $${SHADOW_BLD_PATH}\\qml\\symbian)
    system(copy qml\\common\\*.* $${SHADOW_BLD_PATH}\\qml\\common)
}
