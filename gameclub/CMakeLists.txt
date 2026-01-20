cmake_minimum_required(VERSION 3.16)

project(gameclub VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2 QuickLayouts Sql)

qt_standard_project_setup()

qt_add_executable(appgameclub
    main.cpp
)

qt_add_qml_module(appgameclub
    URI gameclub
    VERSION 1.0
    QML_FILES Main.qml
    SOURCES
        ClubManagement.h
        ClubManagement.cpp
        SOURCES
        SOURCES user_model.h
        SOURCES StationModel.h
        SOURCES SessionModel.h

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appgameclub PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appgameclub
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appgameclub
    PRIVATE Qt6::Quick
    Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appgameclub
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
