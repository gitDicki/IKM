import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects


import Qt.labs.qmlmodels

ApplicationWindow {
    id: window
    width: 1000
    height: 700
    visible: true
    title: qsTr("Gaming Club Management")
    color: "#121212"

    // Константы стиля
    property color accentColor: "#00FF9D"
    property color secondaryBg: "#1E1E1E"
    property color textColor: "#FFFFFF"
    property color fieldBg: "#2A2A2A"

    property bool hasError: false

    property string statusText: "Создание новой учетной записи"
    property color statusColor: "#666666"
    property bool emailError: false
    property bool phoneError: false
    property bool nameError: false

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 240
            color: "#181818"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: "Управление"
                    color: accentColor
                    font.pixelSize: 22
                    font.bold: true
                    Layout.bottomMargin: 30
                }

                Repeater {
                    model: ["Подключение к БД", "Регистрация", "Станции", "Сеансы", "Пользователи", "Отчёты"]
                    delegate: Button {
                        Layout.fillWidth: true
                        height: 50
                        flat: true

                        contentItem: Text {
                            text: modelData
                            color: mainStack.currentIndex === index ? accentColor : "#888888"
                            font.pixelSize: 16
                            font.weight: mainStack.currentIndex === index ? Font.DemiBold : Font.Normal
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }

                        background: Rectangle {
                            color: mainStack.currentIndex === index ? "#252525" : "transparent"
                            radius: 8
                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height * 0.5
                                width: 4
                                color: accentColor
                                visible: mainStack.currentIndex === index
                                radius: 2
                            }
                        }

                        onClicked: mainStack.currentIndex = index
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "transparent"

                Text {
                    id: headerTitle
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    text: ["Подключение к БД", "Регистрация", "Станции", "Сеансы", "Пользователи", "Отчёты"][mainStack.currentIndex]
                    color: textColor
                    font.pixelSize: 28
                    font.weight: Font.Bold
                }
            }

            StackLayout {
                id: mainStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                Item {
                    id: settingsTab

                    property string dbStatus: "Нет подключения"
                    property color dbStatusColor: "#666666"

                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 40
                        width: Math.min(parent.width * 0.6, 500)
                        spacing: 25

                        Text {
                            text: settingsTab.dbStatus
                            color: settingsTab.dbStatusColor
                            font.pixelSize: 14
                        }

                        ColumnLayout {
                            spacing: 8; Layout.fillWidth: true
                            Text { text: "Хост базы данных"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: hostField
                                Layout.fillWidth: true
                                text: "localhost"
                                color: "white"; font.pixelSize: 16; leftPadding: 15
                                background: Rectangle { color: fieldBg; radius: 8; border.color: parent.activeFocus ? accentColor : "transparent"; border.width: 2 }
                            }
                        }

                        ColumnLayout {
                            spacing: 8; Layout.fillWidth: true
                            Text { text: "Имя базы данных"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: dbNameField
                                Layout.fillWidth: true
                                text: "postgres"
                                color: "white"; font.pixelSize: 16; leftPadding: 15
                                background: Rectangle { color: fieldBg; radius: 8; border.color: parent.activeFocus ? accentColor : "transparent"; border.width: 2 }
                            }
                        }

                        ColumnLayout {
                            spacing: 8; Layout.fillWidth: true
                            Text { text: "Пользователь"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: userField
                                Layout.fillWidth: true
                                text: "postgres"
                                color: "white"; font.pixelSize: 16; leftPadding: 15
                                background: Rectangle { color: fieldBg; radius: 8; border.color: parent.activeFocus ? accentColor : "transparent"; border.width: 2 }
                            }
                        }

                        ColumnLayout {
                            spacing: 8; Layout.fillWidth: true
                            Text { text: "Пароль"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: passField
                                Layout.fillWidth: true
                                echoMode: TextInput.Password
                                text: "123"
                                color: "white"; font.pixelSize: 16; leftPadding: 15
                                background: Rectangle { color: fieldBg; radius: 8; border.color: parent.activeFocus ? accentColor : "transparent"; border.width: 2 }
                            }
                        }

                        Button {
                            id: connectButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 55
                            Layout.topMargin: 15

                            contentItem: Text {
                                text: "ПОДКЛЮЧИТЬСЯ"
                                font.pixelSize: 14; font.bold: true; color: "black"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.down ? "#00CC7E" : (parent.hovered ? "#33FFB1" : accentColor)
                                radius: 8
                            }

                            onClicked: {
                                if (clubManager.connectToDb(hostField.text, dbNameField.text, userField.text, passField.text)) {
                                    settingsTab.dbStatus = "Подключено к " + dbNameField.text
                                    settingsTab.dbStatusColor = accentColor

                                    userModel.updateModel()
                                    stationModel.updateModel()
                                    sessionModel.updateByStatus("Бронь")

                                } else {
                                    settingsTab.dbStatus = "Ошибка подключения! Проверьте данные."
                                    settingsTab.dbStatusColor = "#FF4B4B"
                                }
                            }
                        }
                    }
                }


                Item {
                    id: registrationTab

                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 40
                        width: Math.min(parent.width * 0.6, 500)
                        spacing: 25

                        Text {
                            text: statusText
                            color: statusColor
                            font.pixelSize: 14
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true
                            Text { text: "Ф.И.О. клиента"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: fullNameField
                                Layout.fillWidth: true
                                placeholderText: "Иванов Иван Иванович"
                                color: "white"
                                font.pixelSize: 16
                                leftPadding: 15
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                        color: fieldBg
                                        radius: 8
                                        border.color: nameError ? "#FF4B4B" : (parent.activeFocus ? accentColor : "transparent")
                                        border.width: 2
                                    }
                                    onTextChanged: { nameError = false; resetStatus() }
                            }
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true
                            Text { text: "Номер телефона"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: phoneField
                                Layout.fillWidth: true
                                placeholderText: "+7 (___) ___-__-__"
                                color: "white"
                                font.pixelSize: 16
                                leftPadding: 15
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                        color: fieldBg
                                        radius: 8
                                        border.color: phoneError ? "#FF4B4B" : (parent.activeFocus ? accentColor : "transparent")
                                        border.width: 2
                                    }
                                onTextChanged: { phoneError = false; resetStatus() }
                            }
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true
                            Text { text: "Электронная почта"; color: "#AAAAAA"; font.pixelSize: 13; leftPadding: 5 }
                            TextField {
                                id: emailField
                                Layout.fillWidth: true
                                placeholderText: "example@mail.com"
                                color: "white"
                                font.pixelSize: 16
                                leftPadding: 15
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                        color: fieldBg
                                        radius: 8
                                        border.color: emailError ? "#FF4B4B" : (parent.activeFocus ? accentColor : "transparent")
                                        border.width: 2
                                    }
                                onTextChanged: { emailError = false; resetStatus() }

                            }
                        }

                        Button {
                            id: registerButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 55
                            Layout.topMargin: 15

                            contentItem: Text {
                                text: "ЗАРЕГИСТРИРОВАТЬ"
                                font.pixelSize: 14
                                font.bold: true
                                color: "black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.letterSpacing: 1
                            }

                            background: Rectangle {
                                color: parent.down ? "#00CC7E" : (parent.hovered ? "#33FFB1" : accentColor)
                                radius: 8

                                // Небольшое свечение кнопки (опционально)
                                layer.enabled: true
                                layer.effect: Qt.createComponent("QtQuick.Effects").createObject(this)
                            }

                            function resetErrors() {
                                emailError = false
                                phoneError = false
                                nameError = false
                                statusText = "Создание новой учетной записи"
                                statusColor = "#666666"
                            }

                            onClicked: {
                                resetErrors()

                                let check = clubManager.validateAndCheckUser(fullNameField.text, phoneField.text, emailField.text)

                                if (check === 0) {
                                    if (clubManager.addUser(fullNameField.text, phoneField.text, emailField.text)) {
                                        statusText = "Пользователь успешно зарегистрирован!"
                                        statusColor = accentColor
                                        fullNameField.text = ""; phoneField.text = ""; emailField.text = ""
                                        clubManager.refreshUsers(userModel)
                                    } else {
                                        statusText = "Ошибка добавления записи в базу (SQL Error)"
                                        statusColor = "#FF4B4B"
                                    }
                                } else {
                                    statusColor = "#FF4B4B"
                                    switch(check) {
                                        case 1:
                                            emailError = true
                                            statusText = "Пользователь с таким Email уже существует"
                                            break
                                        case 2:
                                            phoneError = true
                                            statusText = "Пользователь с таким номером уже существует"
                                            break
                                        case 3:
                                            emailError = true
                                            statusText = "Неверный формат Email (example@mail.com)"
                                            break
                                        case 4:
                                            phoneError = true
                                            statusText = "Неверный формат телефона (+79991112233)"
                                            break
                                        case 5:
                                            nameError = true
                                            statusText = "Введите ФИО полностью"
                                            break
                                    }
                                }
                            }
                        }
                    }
                }

                // 2. Станции
                Item {
                    id: stationsTab
                    onVisibleChanged: if (visible) clubManager.refreshStations(stationModel)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 25

                        Rectangle {
                            Layout.fillWidth: true
                            height: 100
                            color: "#181818"
                            radius: 12
                            border.color: "#252525"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                ColumnLayout {
                                    Text { text: "Тип устройства"; color: "#888888"; font.pixelSize: 12 }
                                    ComboBox {
                                        id: typeCombo
                                        model: ["ПК", "Консоль"]
                                        Layout.preferredWidth: 150
                                    }
                                }

                                ColumnLayout {
                                    Text { text: "Начальный статус"; color: "#888888"; font.pixelSize: 12 }
                                    ComboBox {
                                        id: statusCombo
                                        model: ["Свободна", "Ремонт"]
                                        Layout.preferredWidth: 180
                                    }
                                }

                                Button {
                                    Layout.alignment: Qt.AlignBottom
                                    text: "ДОБАВИТЬ СТАНЦИЮ"
                                    Layout.preferredHeight: 40
                                    onClicked: {
                                        if (clubManager.addStation(typeCombo.currentText, statusCombo.currentText)) {
                                            clubManager.refreshStations(stationModel)
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }

                        RowLayout {
                            id: headerRow
                            width: parent.width
                            height: 30
                            spacing: 10
                            Text { text: "ID"; color: "#666666"; Layout.preferredWidth: 50 }
                            Text { text: "Тип"; color: "white"; font.bold: true; Layout.preferredWidth: 120 }
                            Text { text: "Статус"; color: "white"; font.bold: true; Layout.preferredWidth: 120 }
                            Item { Layout.fillWidth: true }
                        }

                        ListView {
                            id: stationListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: stationModel
                            clip: true
                            spacing: 10

                            delegate: Rectangle {
                                width: stationListView.width
                                height: 60
                                color: "#1E1E1E"
                                radius: 8

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15; anchors.rightMargin: 15

                                    Text { text: "#" + model.station_id; color: "#666666"; Layout.preferredWidth: 50 }

                                    Text {
                                        text: model.тип
                                        color: "white"
                                        font.bold: true
                                        Layout.preferredWidth: 120
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 130
                                        height: 28
                                        radius: 14
                                        color: model.статус === "Свободна" ? "#153025" : (model.статус === "Занята" ? "#301515" : "#252525")
                                        border.color: model.статус === "Свободна" ? accentColor : (model.статус === "Занята" ? "#FF4B4B" : "#888888")

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.статус
                                            color: parent.border.color
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: model.статус === "Ремонт" ? "В работу" : "В ремонт"
                                        visible: model.статус !== "Занята" // Скрываем, если там кто-то играет
                                        onClicked: {
                                            if (clubManager.toggleStationMaintenance(model.station_id, model.статус)) {
                                                clubManager.refreshStations(stationModel)
                                            }
                                        }
                                    }

                                    Button {
                                        text: "Удалить"
                                        visible: model.статус !== "Занята"
                                        palette.button: "#FF4B4B"
                                        palette.buttonText: "#000000"

                                        onClicked: {
                                            if (clubManager.deleteStation(model.station_id))
                                                clubManager.refreshStations(stationModel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 3.СЕАНСЫ
                Item {
                    id: sessionsTab
                    Component.onCompleted: sessionModel.updateByStatus("Бронь")

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Row {
                            id: statusSwitcher
                            spacing: 10
                            Layout.alignment: Qt.AlignHCenter
                            property string currentS: "Бронь"

                            Repeater {
                                model: ["Бронь", "Активна", "Завершена"]
                                Button {
                                    text: modelData
                                    highlighted: statusSwitcher.currentS === modelData
                                    onClicked: {
                                        statusSwitcher.currentS = modelData
                                        sessionModel.updateByStatus(modelData)
                                    }
                                }
                            }
                        }
                        Rectangle {
                            visible: statusSwitcher.currentS === "Бронь"
                            Layout.fillWidth: true
                            height: 140
                            color: "#181818"; radius: 10; border.color: "#333"

                            GridLayout {
                                anchors.fill: parent; anchors.margins: 15
                                columns: 5

                                ComboBox {
                                    id: userSelect; textRole: "email"; model: userModel
                                    Layout.fillWidth: true
                                    displayText: currentText
                                }

                                ComboBox {
                                    id: stationSelect
                                    textRole: "station_id"
                                    model: stationModel
                                    Layout.fillWidth: true
                                    displayText: "Станция ID: " + currentText

                                    onPressedChanged: {
                                        if (pressed) {
                                            stationModel.updateModel()
                                        }
                                    }
                                }

                                TextField {
                                    id: startTime; placeholderText: "Начало..."; Layout.fillWidth: true
                                    text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") // По умолчанию сейчас
                                }

                                TextField {
                                    id: endTime; placeholderText: "Конец..."; Layout.fillWidth: true
                                    text: Qt.formatDateTime(new Date(new Date().getTime() + 3600000), "yyyy-MM-dd HH:mm:ss") // +1 час
                                }

                                Button {
                                    text: "СЕЙЧАС"
                                    onClicked: {
                                        startTime.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                                        endTime.text = Qt.formatDateTime(new Date(new Date().getTime() + 3600000), "yyyy-MM-dd HH:mm:ss")
                                    }
                                }

                                Button {
                                    text: "СОЗДАТЬ БРОНЬ"
                                    Layout.columnSpan: 5
                                    Layout.fillWidth: true
                                    onClicked: {
                                        let userId = userModel.data(userModel.index(userSelect.currentIndex, 0), 257 /* IdRole */)
                                        let stationId = stationSelect.currentText

                                        if(clubManager.createBooking(userId, stationId, startTime.text, endTime.text)) {
                                            sessionModel.updateByStatus("Бронь")
                                        }
                                    }
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: sessionModel
                            clip: true
                            spacing: 8
                            delegate: Rectangle {
                                width: parent.width; height: 70; color: "#222"; radius: 5
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 15
                                    Column {
                                        Text { text: model.user_email; color: "white"; font.bold: true }
                                        Text { text: model.station_info; color: "#aaa"; font.pixelSize: 12 }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text { text: model.start_time + " - " + model.end_time; color: "white" }

                                    // Кнопки управления
                                    Button {
                                        text: "Активировать"
                                        visible: model.status === "Бронь"
                                        onClicked: {
                                            if(clubManager.updateSessionStatus(model.session_id, "Активна")) {
                                                sessionModel.updateByStatus("Бронь")
                                                clubManager.refreshStations(stationModel) // Обновляем список станций
                                            }
                                        }
                                    }
                                    Button {
                                        text: "Завершить"
                                        visible: model.status === "Активна"
                                        onClicked: {
                                            if(clubManager.updateSessionStatus(model.session_id, "Завершена")) {
                                                sessionModel.updateByStatus("Активна")
                                                clubManager.refreshStations(stationModel) // Обновляем список станций
                                            }
                                        }
                                    }
                                    Button {
                                        text: "X"
                                        visible: model.status === "Бронь"
                                        onClicked: if(clubManager.deleteSession(model.session_id)) sessionModel.updateByStatus("Бронь")
                                    }
                                }
                            }
                        }
                    }
                }

                // 4.пользователи
                Item {
                    id: usersTab

                    onVisibleChanged: {
                        if (visible) {
                            clubManager.refreshUsers(userModel)
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 25
                    
                        RowLayout {
                            width: parent.width
                            height: 30
                            spacing: 10
                            Text { text: "ID"; color: "#666666"; Layout.preferredWidth: 40 }
                            Text { text: "Фамилия"; color: "white"; font.bold: true; Layout.preferredWidth: 120 }
                            Text { text: "Имя"; color: "white"; font.bold: true; Layout.preferredWidth: 100 }
                            Text { text: "Телефон"; color: "white"; font.bold: true; Layout.preferredWidth: 120 }
                            Text { text: "Email"; color: "white"; font.bold: true; Layout.fillWidth: true }
                            Item { Layout.preferredWidth: 80 }
                        }

                        ListView {
                            id: userListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: userModel
                            clip: true
                            spacing: 10

                            delegate: Rectangle {
                                width: userListView.width
                                height: 60
                                color: "#1E1E1E"
                                radius: 8

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15; anchors.rightMargin: 15
                                    spacing: 10

                                    Text { text: "#" + model.user_id; color: "#666666"; Layout.preferredWidth: 40 }

                                    Text { text: model.last_name; color: "white"; Layout.preferredWidth: 120 }
                                    Text { text: model.first_name; color: "white"; Layout.preferredWidth: 100 }

                                    Text { text: model.phone; color: "white"; Layout.preferredWidth: 120 }

                                    Text { text: model.email; color: "white"; Layout.fillWidth: true }

                                    Button {
                                        text: "Удалить"
                                        onClicked: {
                                            if (clubManager.deleteUser(model.user_id))
                                                clubManager.refreshUsers(userModel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: financeReportTab

                    onVisibleChanged: {
                        if (visible) {
                            reportStatus.text = ""
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 30
                        spacing: 20

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            color: "#1e1e1e"
                            radius: 12
                            border.color: "#333"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                Text {
                                    text: "Формирование отчетов"
                                    color: "white"
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                ComboBox {
                                    id: reportTypeSelector
                                    Layout.fillWidth: true
                                    model: ["Финансовый отчет (Выручка)", "Отчет по загрузке станций"]
                                    currentIndex: 0
                                }

                                RowLayout {
                                    spacing: 20
                                    ColumnLayout {
                                        Text { text: "Начало периода:"; color: "#888" }
                                        TextField {
                                            id: reportFrom
                                            text: Qt.formatDateTime(new Date(new Date().getFullYear(), new Date().getMonth(), 1), "yyyy-MM-dd 00:00:00")
                                            placeholderText: "ГГГГ-ММ-ДД ЧЧ:ММ:СС"
                                            Layout.preferredWidth: 200
                                        }
                                    }
                                    ColumnLayout {
                                        Text { text: "Конец периода:"; color: "#888" }
                                        TextField {
                                            id: reportTo
                                            text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                                            placeholderText: "ГГГГ-ММ-ДД ЧЧ:ММ:СС"
                                            Layout.preferredWidth: 200
                                        }
                                    }
                                }

                                Button {
                                    text: "СФОРМИРОВАТЬ И ВЫГРУЗИТЬ В TXT"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    onClicked: {
                                        let result = ""
                                        if (reportTypeSelector.currentIndex === 0) {
                                            result = clubManager.generatePeriodReport(reportFrom.text, reportTo.text)
                                        } else {
                                            result = clubManager.generateStationLoadReport(reportFrom.text, reportTo.text)
                                        }
                                        reportStatus.text = result
                                    }
                                }

                                Text {
                                    id: reportStatus
                                    color: "#4CAF50"
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

            }
        }
    }
}

