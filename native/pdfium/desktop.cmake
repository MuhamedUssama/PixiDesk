# Packaging runs only during a requested application build, never at runtime.
find_package(Python3 REQUIRED COMPONENTS Interpreter)
get_filename_component(PIXIDESK_PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
include("${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral/generated_config.cmake")
if(WIN32)
  set(PIXIDESK_DART "${FLUTTER_ROOT}/bin/cache/dart-sdk/bin/dart.exe")
  if(CMAKE_GENERATOR_PLATFORM MATCHES "ARM64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64|arm64")
    set(PIXIDESK_PDFIUM_TARGET "windows-arm64")
  else()
    set(PIXIDESK_PDFIUM_TARGET "windows-x64")
  endif()
else()
  set(PIXIDESK_DART "${FLUTTER_ROOT}/bin/cache/dart-sdk/bin/dart")
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64|arm64")
    set(PIXIDESK_PDFIUM_TARGET "linux-arm64")
  else()
    set(PIXIDESK_PDFIUM_TARGET "linux-x64")
  endif()
endif()
set(PIXIDESK_PDFIUM_OUTPUT "${CMAKE_BINARY_DIR}/pixidesk_pdfium")
add_custom_target(pixidesk_pdfium_runtime
  COMMAND "${Python3_EXECUTABLE}" "${PIXIDESK_PROJECT_ROOT}/tool/package_pdfium.py"
    --target "${PIXIDESK_PDFIUM_TARGET}"
    --destination "${PIXIDESK_PDFIUM_OUTPUT}"
    --dart "${PIXIDESK_DART}"
  WORKING_DIRECTORY "${PIXIDESK_PROJECT_ROOT}"
  VERBATIM)
add_dependencies(${BINARY_NAME} pixidesk_pdfium_runtime)
install(DIRECTORY "${PIXIDESK_PDFIUM_OUTPUT}/" DESTINATION "${CMAKE_INSTALL_PREFIX}/pdfium" COMPONENT Runtime USE_SOURCE_PERMISSIONS)
