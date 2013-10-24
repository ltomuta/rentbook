RentBook
========

RentBook is a Nokia Developer example application for keeping track of items for rent. The
application demonstrates the use of Qt Quick components and SQLite database.

The application allows the user to add items for rent into a database and, for example, 
keep track of for whom the item is rented on a certain date. The UI is
implemented using Qt Quick components and the Symbian version follows the
Symbian design guidelines. 

This application has been tested on Symbian, MeeGo 1.2 Harmattan, and
Qt Simulator (Windows desktop).


1. Usage
-------------------------------------------------------------------------------

When the application is first installed, the database is empty. The user can
then start defining items for rent in the resource management view. After one or
more items have been created, the items can be booked for certain dates.
The rent period can be defined for 1-7 days.


2. Prequisites
-------------------------------------------------------------------------------

 - Qt basics
 - Qt Quick basics


3. Project Structure and implementation
-------------------------------------------------------------------------------

3.1 Folders
-----------

 |                  The root folder contains the project file, resource files,
 |                  license information, and this file (release notes).
 |
 |- bin             Contains the compiled binaries.
 |
 |- doc             Contains the documentation, including the class diagram and
 |                  database design.
 |
 |- icons           Contains application icons.
 |
 |- qml             Root folder for QML and Javascript files.
 |  |
 |  |- common       Common, cross-platform QML, Javascript files, and graphics.
 |  |
 |  |- harmattan    Harmattan-specific QML and Javascript files.
 |  |
 |  |- symbian      Symbian-specific QML and Javascript files.
 |
 |- qtc_packaging   Contains the Harmattan (Debian) packaging files.
 |
 |- src             Contains the Qt/C++ source code files.


3.2 Important files and classes
-------------------------------

- src/DatabaseManager.h/.cpp: Handling SQLite database
- src/telephony.h/.cpp: Dialing in Symbian
- qml/Symbian/MainView.qml: Main application view in Symbian
- qml/Harmattan/MainView.qml: Main application view in Harmattan


3.3 Used Qt C++ classes and Qt Quick Components
-----------------------------------------------

Important classes Qt C++ classes: QSqlDatabase, QSqlQuery, QDeclarativeView
Important Qt Quick Components: DatePickerDialog, Tumbler


4. Compatibility
-------------------------------------------------------------------------------

- Qt 4.7.4 or higher
- Qt Quick Components 1.0 or higher

Tested on:
- Nokia C7-00
- Nokia E6-00
- Nokia E7-00
- Nokia N8-00
- Nokia N900 (PR1.3)
- Nokia N9
- Nokia N950
- Windows desktop with Qt Simulator

4.1 Required capabilities
-------------------------

None.


4.2 Known issues
----------------

The tool bar buttons may disappear on Symbian Anna version if several pages are
pushed into the page stack rapidly. The issue is fixed in Symbian Qt Quick
Components version 1.1. For more information, see bug
https://bugreports.qt.nokia.com/browse/QTCOMPONENTS-741


5. Building, installing, and running the application
-------------------------------------------------------------------------------

5.1 Preparations
----------------

Check that you have the latest Qt SDK installed in the development environment
and the latest Qt version on the device.

Qt Quick Components 1.0 or higher required.

5.2 Using Qt SDK
----------------

You can install and run the application on the device by using the Qt SDK.
Open the project in the SDK, set up the correct target (depending on the device
platform) and click the Run button. For more details about this approach, 
visit Qt Getting Started at Nokia Developer
(http://www.developer.nokia.com/Develop/Qt/Getting_started/).

5.3 Symbian device
------------------

Make sure your device is connected to your computer. Locate the .sis
installation file and open it with Ovi Suite. Accept all requests from Ovi
Suite and the device. Note that you can also install the application by copying
the installation file onto your device and opening it with the Symbian File
Manager application.

After the application is installed, locate the application icon from the
application menu and launch the application by tapping the icon.

5.4 Nokia N9 and Nokia N950
---------------------------

Copy the application Debian package onto the device. Locate the file with the
device and run it; this installs the application. Note that you can also
use the terminal application and install the application typing the command
'dpkg -i <package name>.deb' on the command line. To install the application
using the terminal application, make sure you have the right privileges 
to do so (for example, root access).

Once the application is installed, locate the application icon from the
application menu and launch the application by tapping the icon.


6. License
-------------------------------------------------------------------------------

See the license text file delivered with this project. The license file is also
available online at
http://projects.developer.nokia.com/rentbook/browser/trunk/Licence.txt


7. Related documentation
-------------------------------------------------------------------------------
Qt Quick Components
- http://doc.qt.nokia.com/qt-components-symbian-1.0/index.html
- http://harmattan-dev.nokia.com/docs/library/html/qt-components/qt-components.html

Qt: QRentBook Example v1.2 (uses QWidgets)
http://www.developer.nokia.com/info/sw.nokia.com/id/65e18c3b-6b69-4bb7-bf18-96e64d37f0ea/Qt_QRentBook_Example_v1_2_en.zip.html


8. Version History
-------------------------------------------------------------------------------

1.0 Initial release
