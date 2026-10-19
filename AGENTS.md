# Workspace instructions

- Do not run application builds unless the user explicitly requests a build.
  This includes `flutter build`, `flutter run`, Xcode/CMake build commands, and
  native integration-test commands that rebuild the application.
- Use Dart analysis and unit/widget tests for routine verification. Do not treat
  a successful source change or a previous build request as permission to build.
