# Included by the Windows/Linux runner during a requested application build.
find_package(Python3 REQUIRED COMPONENTS Interpreter)
get_filename_component(PIXIDESK_QPDF_PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
if(CMAKE_GENERATOR_PLATFORM MATCHES "ARM64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64|arm64")
  set(PIXIDESK_QPDF_ARCHITECTURE "arm64")
else()
  set(PIXIDESK_QPDF_ARCHITECTURE "x64")
endif()
if(WIN32)
  set(PIXIDESK_QPDF_TARGET "windows-${PIXIDESK_QPDF_ARCHITECTURE}")
else()
  set(PIXIDESK_QPDF_TARGET "linux-${PIXIDESK_QPDF_ARCHITECTURE}")
endif()
set(PIXIDESK_QPDF_OUTPUT "${CMAKE_BINARY_DIR}/pixidesk_qpdf")
add_custom_target(pixidesk_qpdf_runtime
  COMMAND "${Python3_EXECUTABLE}" "${PIXIDESK_QPDF_PROJECT_ROOT}/tool/package_qpdf.py"
    --target "${PIXIDESK_QPDF_TARGET}"
    --destination "${PIXIDESK_QPDF_OUTPUT}"
  WORKING_DIRECTORY "${PIXIDESK_QPDF_PROJECT_ROOT}"
  VERBATIM)
add_dependencies(${BINARY_NAME} pixidesk_qpdf_runtime)
install(DIRECTORY "${PIXIDESK_QPDF_OUTPUT}/" DESTINATION "${CMAKE_INSTALL_PREFIX}/qpdf" COMPONENT Runtime USE_SOURCE_PERMISSIONS)
