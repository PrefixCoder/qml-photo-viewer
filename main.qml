import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.1
import Qt.labs.folderlistmodel 2.15

Window {
    id: window
    width: 640
    height: 560
    visible: true

    FolderDialog {
        id: folderDialog
        onAccepted: {
            folderModel.folder = folderDialog.folder;
            showCurrentView();
        }
    }

    FolderListModel {
        id: folderModel
        showDirs: false
        nameFilters: [ "*.png", "*.jpeg", "*.jpg", "*.gif" ]
    }

    Button {
        id: buttonSelectFolder
        text: "Select folder"
        anchors.left: parent.left
        anchors.rightMargin: 3
        width: parent.width / 2 - 3
        onClicked: folderDialog.open();
    }

    function makeViewsInvisible() {
        listViewContainer.visible = false;
        listView.focus = false;
        gridViewContainer.visible = false;
        gridView.focus = false;
        pathViewContainer.visible = false;
        pathView.focus = false;
    }

    function showCurrentView() {
        switch(comboBox.currentIndex) {
        case 0:
            listViewContainer.visible = true;
            listView.focus = true;
            break;
        case 1:
            gridViewContainer.visible = true;
            gridView.focus = true;
            break;
        case 2:
            pathViewContainer.visible = true;
            pathView.focus = true;
            break;
        }
    }

    ComboBox {
        id: comboBox
        anchors.left: buttonSelectFolder.right
        anchors.leftMargin: 3
        width: parent.width / 2
        model: [ "list", "grid", "path" ]
        onCurrentIndexChanged: {
            makeViewsInvisible();
            showCurrentView();
        }
    }

    function maximizeImage(img) {
        makeViewsInvisible();
        maxemizedImage.source = img.source
        maxemizedImage.visible = true;
        maxemizedImage.focus = true;
    }

    Rectangle {
        id: listViewContainer
        width: parent.width
        height: parent.height - comboBox.height
        anchors.top: comboBox.bottom
        clip: true

        ListView {
            id: listView
            anchors.fill: parent
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            model: folderModel
            delegate: Item {
                width: listView.width; height: 140
                Keys.onSpacePressed: maximizeImage(listViewItemImage);
                Image {
                    id: listViewItemImage
                    x: 5; y: 5
                    width: 128; height: 128
                    source: fileUrl
                }
                Text {
                    y: 5
                    anchors.left: listViewItemImage.right
                    anchors.leftMargin: 10
                    text: fileName
                    font.pointSize: 16
                }
                MouseArea { anchors.fill: parent; onReleased: maximizeImage(listViewItemImage); }
            }
        }
    }

    Rectangle {
        id: gridViewContainer
        width: parent.width
        height: parent.height - comboBox.height - 5
        anchors.top: comboBox.bottom
        anchors.topMargin: 5
        clip: true


        GridView {
            id: gridView
            anchors.fill: parent
            cellWidth: 140; cellHeight: 150
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }

            model: folderModel
            delegate: Column {
                Keys.onSpacePressed: maximizeImage(gridViewItemImage);
                width: gridView.cellWidth; height: gridView.cellHeight
                Image {
                    id: gridViewItemImage
                    source: fileUrl
                    width: 128; height: 128
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea { anchors.fill: parent; onReleased: maximizeImage(parent); }
                }
                Text { text: fileName; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }
    }

    Rectangle {
        id: pathViewContainer
        width: 240; height: 200
        anchors.centerIn: parent

        PathView {
            id: pathView
            anchors.fill: parent
            Keys.onLeftPressed: decrementCurrentIndex();
            Keys.onRightPressed: incrementCurrentIndex();
            model: folderModel
            delegate: Column {
                Keys.onSpacePressed: maximizeImage(pathViewItemImage);
                opacity: PathView.isCurrentItem ? 1 : 0.1
                z: PathView.isCurrentItem ? 1 : 0
                Image {
                    id: pathViewItemImage
                    anchors.horizontalCenter: pathViewItemText.horizontalCenter
                    width: 256; height: 256
                    source: fileUrl
                    MouseArea { anchors.fill: parent; onReleased: maximizeImage(parent); }
                }
                Text {
                    id: pathViewItemText
                    text: fileName
                    font.pointSize: 16
                }
            }

            path: Path {
                startX: 200; startY: 100
                PathQuad { x: 200; y: 25; controlX: 560; controlY: 75 }
                PathQuad { x: 200; y: 100; controlX: -200; controlY: 75 }

            }
        }
    }

    function minimizeImage() {
        maxemizedImage.visible = false;
        showCurrentView();
    }

    Image {
        id: maxemizedImage
        width: parent.width
        height: parent.height - comboBox.height
        anchors.top: comboBox.bottom
        visible: false
        Keys.onSpacePressed: minimizeImage();
        MouseArea {
            anchors.fill: parent
            onReleased: minimizeImage();
        }
    }
}
