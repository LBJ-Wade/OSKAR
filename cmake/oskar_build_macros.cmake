#
# cmake/oskar_build_macros.cmake
#

#
# A collection of cmake macros used by the oskar build system.
#

include(oskar_cmake_utilities)

# Macro to build and install apps that depend on Qt.
#
# Usage:
#   qt_app(name
#         [NO_INSTALL]
#         source1 source2 ...
#         [QT_MOC_SRC source1 source2 ...]
#         [EXTRA_LIBS lib1 lib2 ...]
#   )
#
# name       = Name of the app (binary name)
# source1..N = List of sources from which to build the app
# QT_MOC_SRC = List of QT moc headers which require a precompile step.
# EXTRA_LIBS = List of additional libraries to link the app against.
# NO_INSTALL = Do not install this app (i.e. don't add to the make install
#              target).
#
# Note: Named options can appear in any order
#
macro(QT_APP)
    parse_arguments(APP         # prefix
        "QT_MOC_SRC;EXTRA_LIBS" # arg names
        "NO_INSTALL"            # option names
        ${ARGN}
    )
    CAR(APP_NAME ${APP_DEFAULT_ARGS})
    CDR(APP_SOURCES ${APP_DEFAULT_ARGS})

    if (NOT QT4_FOUND)
        message(FATAL_ERROR "Unable to build oskar app ${APP_NAME}, Qt4 not found!")
    endif ()

    # Create a target name from the app name.
    # Note:
    # - Appending app allows for binaries to exist with the same name
    # as targets used elsewhere.
    # - app targets can then be build individually using the command:
    #      $ make <name>_app
    #   where <name> is the (binary) name of the app to be built.
    set(target "${APP_NAME}_app")

    qt4_wrap_cpp(APP_SOURCES ${APP_QT_MOC_SRC})

    add_executable(${target} ${APP_SOURCES})
    target_link_libraries(${target}
        ${QT_QTCORE_LIBRARY} # default libs
        ${APP_EXTRA_LIBS}    # extra libs
    )
    set_target_properties(${target} PROPERTIES
        INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
        INSTALL_RPATH_USE_LINK_PATH TRUE
        OUTPUT_NAME   ${APP_NAME}
    )

    # FIXME hack for now to only build the oskar.app (make this an option?)
    set(OSX_APP FALSE)
    #if (${APP_NAME} STREQUAL "oskar")
    #    set(OSX_APP TRUE)
    #endif ()
    if (APPLE AND OSX_APP)
        set(target "${APP_NAME}_osx_app")
        add_executable(${target} MACOSX_BUNDLE ${APP_SOURCES})
        set(MACOSX_BUNDLE_BUNDLE_NAME ${APP_NAME})
        set(MACOSX_BUNDLE_ICON_FILE ${PROJECT_SOURCE_DIR}/widgets/icons/icon.icns)
        #add_custom_command(TARGET ${target} POST_BUILD
        #    COMMAND mkdir ARGS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.app/Contents/Resources
        #    COMMAND cp ARGS ${MACOSX_BUNDLE_ICON_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.app/Contents/Resources
        #    #COMMAND cp ARGS *.qm ${CMAKE_CURRENT_BINARY_DIR}/${target}.app/Content/Resources
        #)
        target_link_libraries(${target}
            ${QT_QTCORE_LIBRARY} # default libs
            ${APP_EXTRA_LIBS}    # extra libs
        )
        set_target_properties(${target} PROPERTIES
            OUTPUT_NAME   ${APP_NAME}
        )
    endif (APPLE AND OSX_APP)

    # Create the install target if the NO_INSTALL option isn't specified.
    if (NOT APP_NO_INSTALL)
        install(TARGETS ${target} DESTINATION ${OSKAR_BIN_INSTALL_DIR})
    endif()

endmacro(QT_APP)


# Macro to build and install oskar apps.
#
# Usage:
#   oskar_app(name
#         [NO_INSTALL]
#         source1 source2 ...
#         [EXTRA_LIBS lib1 lib2 ...]
#   )
#
# name       = Name of the app (binary name)
# source1..N = List of sources from which to build the app
# EXTRA_LIBS = List of additional libraries to link the app against.
# NO_INSTALL = Do not install this app (i.e. don't add to the make install
#              target).
#
# Note: Named options can appear in any order
#
macro(OSKAR_APP)
    parse_arguments(APP   # prefix
        "EXTRA_LIBS"      # arg names
        "NO_INSTALL"      # option names
        ${ARGN}
    )
    CAR(APP_NAME ${APP_DEFAULT_ARGS})
    CDR(APP_SOURCES ${APP_DEFAULT_ARGS})

    # Create a target name from the app name.
    # Note:
    # - Appending app allows for binaries to exist with the same name
    # as targets used elsewhere.
    # - app targets can then be build individually using the command:
    #      $ make <name>_app
    #   where <name> is the (binary) name of the app to be built.
    set(target "${APP_NAME}_app")

    add_executable(${target} ${APP_SOURCES})
    target_link_libraries(${target}
        oskar               # default libs
        oskar_apps
        ${APP_EXTRA_LIBS}   # extra libs
    )
    # We do need the OpenMP flags here, otherwise programs will crash.
    if (MSVC)
        set_target_properties(${target} PROPERTIES
            COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
            OUTPUT_NAME   "${APP_NAME}"
        )
    else ()
        if (APPLE)
            set_target_properties(${target} PROPERTIES
                INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
                INSTALL_RPATH_USE_LINK_PATH TRUE
                COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
                LINK_FLAGS    "${OpenMP_CXX_FLAGS}"
                OUTPUT_NAME   "${APP_NAME}"
            )
        else ()
            set_target_properties(${target} PROPERTIES
                INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
                INSTALL_RPATH_USE_LINK_PATH TRUE
                COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
                LINK_FLAGS    "${OpenMP_CXX_FLAGS}"
                OUTPUT_NAME   "${APP_NAME}"
            )
        endif ()
    endif()

    # Create the install target if the NO_INSTALL option isn't specified.
    if (NOT APP_NO_INSTALL)
        install(TARGETS ${target} DESTINATION ${OSKAR_BIN_INSTALL_DIR})
    endif()

endmacro(OSKAR_APP)


# Macro to build and install oskar apps that depend on Qt.
#
# Usage:
#   oskar_app(name
#         [NO_INSTALL]
#         source1 source2 ...
#         [QT_MOC_SRC source1 source2 ...]
#         [EXTRA_LIBS lib1 lib2 ...]
#   )
#
# name       = Name of the app (binary name)
# source1..N = List of sources from which to build the app
# QT_MOC_SRC = List of QT moc headers which require a precompile step.
# EXTRA_LIBS = List of additional libraries to link the app against.
# NO_INSTALL = Do not install this app (i.e. don't add to the make install
#              target).
#
# Note: Named options can appear in any order
#
macro(OSKAR_QT_APP)
    parse_arguments(APP   # prefix
        "QT_MOC_SRC;EXTRA_LIBS" # arg names
        "NO_INSTALL"      # option names
        ${ARGN}
    )
    CAR(APP_NAME ${APP_DEFAULT_ARGS})
    CDR(APP_SOURCES ${APP_DEFAULT_ARGS})

    if (NOT QT4_FOUND)
        message(CRITICAL "Unable to build oskar app ${APP_NAME}, Qt4 not found!")
    endif ()

    #message("APP: NAME       = ${APP_NAME}")
    #message("     SRC        = ${APP_SOURCES}")
    #message("     MOC        = ${APP_QT_MOC_SRC}")
    #message("     EXTRA_LIBS = ${APP_EXTRA_LIBS}")
    #if (NOT APP_NO_INSTALL)
    #    message("     INSTALL    = yes")
    #else()
    #    message("     INSTALL    = no")
    #endif()

    # Create a target name from the app name.
    # Note:
    # - Appending app allows for binaries to exist with the same name
    # as targets used elsewhere.
    # - app targets can then be build individually using the command:
    #      $ make <name>_app
    #   where <name> is the (binary) name of the app to be built.
    set(target "${APP_NAME}_app")

    qt4_wrap_cpp(APP_SOURCES ${APP_QT_MOC_SRC})

    add_executable(${target} ${APP_SOURCES})
    target_link_libraries(${target}
        # Defaults libs
        oskar
        oskar_apps
        ${QT_QTCORE_LIBRARY}
        # Extra libs
        ${APP_EXTRA_LIBS}
    )
    # We do need the OpenMP flags here, otherwise programs will crash.
    if (MSVC)
        set_target_properties(${target} PROPERTIES
            COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
            OUTPUT_NAME   "${APP_NAME}"
        )
    else ()
        if (APPLE)
            set_target_properties(${target} PROPERTIES
                INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
                INSTALL_RPATH_USE_LINK_PATH TRUE
                COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
                LINK_FLAGS    "${OpenMP_CXX_FLAGS}"
                OUTPUT_NAME   "${APP_NAME}"
            )
        else()
            set_target_properties(${target} PROPERTIES
                INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
                INSTALL_RPATH_USE_LINK_PATH TRUE
                COMPILE_FLAGS "${OpenMP_CXX_FLAGS}"
                LINK_FLAGS    "${OpenMP_CXX_FLAGS}"
                OUTPUT_NAME   "${APP_NAME}"
            )
        endif()
    endif ()

    # Create the install target if the NO_INSTALL option isn't specified.
    if (NOT APP_NO_INSTALL)
        install(TARGETS ${target} DESTINATION ${OSKAR_BIN_INSTALL_DIR})
    endif()

endmacro(OSKAR_QT_APP)


# Macro to build and install oskar python modules.
#
# Usage:
#       oskar_py_module(name
#           source
#           [LIBS lib1 lib2 ...])
#
#       name       = name of python module
#       source     = source file containing python module
#       LIBS       = list of libraries to link against.
#
macro(OSKAR_PY_MODULE)
    parse_arguments(PY   # prefix
        "LIBS"           # arg names
        ""               # option names
        ${ARGN})

    CAR(PY_NAME ${PY_DEFAULT_ARGS})
    CDR(PY_SOURCES ${PY_DEFAULT_ARGS})

    # Over-ride compiler flags for python modules
    # FIXME(BM) are these flags local?! also true for other macros in this file?
    # ==> At the moment these are needed or the python module seems to break...
    set(CMAKE_C_FLAGS "-fpic -std=c99")
    set(CMAKE_C_FLAGS_RELEASE "-O2")
    set(CMAKE_C_FLAGS_DEBUG "-O0 -g")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g")

    # Get a unique build target name
    get_filename_component(target ${PY_SOURCES} NAME_WE)
    add_library(${target} MODULE ${PY_SOURCES})
    target_link_libraries(${target} ${PYTHON_LIBRARIES} ${PY_LIBS})

    set_target_properties(${target} PROPERTIES
        INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/${OSKAR_LIB_INSTALL_DIR}
        INSTALL_RPATH_USE_LINK_PATH TRUE
        OUTPUT_NAME   "${PY_NAME}"
        PREFIX        ""
        SUFFIX        ".so")

    # Install target for python module.
    install(TARGETS ${target} DESTINATION ${OSKAR_PYTHON_INSTALL_DIR})
endmacro(OSKAR_PY_MODULE)
