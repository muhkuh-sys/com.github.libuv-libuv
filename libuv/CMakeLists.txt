CMAKE_MINIMUM_REQUIRED(VERSION 3.7)

SET(VERSION_EXTERNAL "1.23.2")
SET(VERSION_PACKAGE "1")

PROJECT("libuv")

SET(PROJECT_VERSION "${VERSION_EXTERNAL}.${VERSION_PACKAGE}")

INCLUDE(ExternalProject)


# Python is required for the patch script.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)


#----------------------------------------------------------------------------
#
# Build the project.
#

IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"  AND  "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
	SET(LOCAL_CFLAGS "-fPIC")
ELSE("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"  AND  "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
	SET(LOCAL_CFLAGS "")
ENDIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"  AND  "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")

SET(PRJ_CMAKE_ARGS "")

LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} ${LOCAL_CFLAGS}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_AR=${CMAKE_AR}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
        LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_RC_COMPILER=${CMAKE_RC_COMPILER}")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=''")

ExternalProject_Add(TARGET_libuv
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/v${VERSION_EXTERNAL}
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/v${VERSION_EXTERNAL}.tar.gz
                    URL_HASH SHA1=a0a7d57320e8d834ecd9461c38b90e111726ddfe
                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/v${VERSION_EXTERNAL}/src/TARGET_libuv --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CMAKE_ARGS ${PRJ_CMAKE_ARGS}
                    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/install
)


#----------------------------------------------------------------------------
#
# Build a package for the selected platform.
#
SET(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_BINARY_DIR}/../repository/com/github/libuv/libuv/${PROJECT_VERSION})
SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
SET(CPACK_PACKAGE_FILE_NAME "libuv-${PROJECT_VERSION}-${JONCHKI_PLATFORM}")

SET(CPACK_GENERATOR "TXZ")
INCLUDE(CPack)

IF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
	# Package a windows build.

	CONFIGURE_FILE(installer/install_windows.lua
	               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
	               @ONLY)
ELSE(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
	# Package a linux build.

	CONFIGURE_FILE(installer/install_linux.lua
	               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
	               @ONLY)
ENDIF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")

INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
        DESTINATION .)

INSTALL(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/include DESTINATION .)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libuv_a.a
        DESTINATION lib)

CONFIGURE_FILE(installer/libuv.xml
               ${CPACK_OUTPUT_FILE_PREFIX}/libuv-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
               @ONLY)


#-----------------------------------------------------------------------------
#
# Create a custom target named "pack".
# It builds the package and creates the hashes.
#
ADD_CUSTOM_TARGET(pack
                  COMMAND ${CMAKE_MAKE_PROGRAM}
                  COMMAND ${CMAKE_MAKE_PROGRAM} package
                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/libuv-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/libuv-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.tar.xz
                  COMMENT "Pack the artifact and generate the hashes...")


#-----------------------------------------------------------------------------
#
# Filter the pom.xml file.
#
SET(POM_ARTIFACT_ID  "libuv")
SET(POM_GROUP_ID     "com.github.libuv")
SET(POM_VERSION      "${PROJECT_VERSION}")
SET(POM_PACKAGING    "tar.xz")
CONFIGURE_FILE(installer/pom.xml
               ${CPACK_OUTPUT_FILE_PREFIX}/libuv-${PROJECT_VERSION}.pom
               @ONLY)
