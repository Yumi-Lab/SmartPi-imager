# CreateUnsignedDMG.cmake — build-time unsigned DMG creation
#
# Expected -D inputs:
#   VERSION_VARS_FILE — path to imager_version_vars.cmake
#   APP_NAME          — display name (e.g. "Raspberry Pi Imager")
#   APP_BUNDLE_PATH   — path to .app bundle
#   BUILD_DIR         — CMAKE_BINARY_DIR

include("${VERSION_VARS_FILE}")

set(FINAL_DMG_PATH "${BUILD_DIR}/SmartPi-Imager-${IMAGER_VERSION_STR}.dmg")

# Ad-hoc sign the bundle: macdeployqt invalidates the linker signatures when
# it rewrites library paths, and arm64 macOS refuses to launch a bundle whose
# signature is broken ("app is damaged"). Ad-hoc keeps it launchable; a real
# Developer ID + notarization is still needed to avoid Gatekeeper warnings.
message(STATUS "Ad-hoc signing ${APP_BUNDLE_PATH}...")
execute_process(
    COMMAND codesign --force --deep --sign - "${APP_BUNDLE_PATH}"
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "codesign failed with exit code ${result}")
endif()

message(STATUS "Creating DMG at ${FINAL_DMG_PATH}...")
execute_process(
    COMMAND hdiutil create
        -volname "${APP_NAME}"
        -srcfolder "${APP_BUNDLE_PATH}"
        -ov -format UDBZ
        "${FINAL_DMG_PATH}"
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "hdiutil create failed with exit code ${result}")
endif()
