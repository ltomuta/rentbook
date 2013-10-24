
#include <QtGui/QApplication>
#include <QDeclarativeView>
#include <QDir>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    
    // NOTE: Qt Quick desktop components have to be build
    // Application tries to find plugins and QML files from
    // ..\QtSDK\Desktop\Qt\4.7.4\mingw\imports\QtDesktop

    // Open view to show QML
    QDeclarativeView view;
    view.setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view.setSource(QUrl::fromLocalFile("qml/Gallery.qml"));
    view.show();
    return a.exec();
}
