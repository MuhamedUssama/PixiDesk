# Workspace instructions

- Do not run application builds unless the user explicitly requests a build.
  This includes `flutter build`, `flutter run`, Xcode/CMake build commands, and
  native integration-test commands that rebuild the application.
- Use Dart analysis and unit/widget tests for routine verification. Do not treat
  a successful source change or a previous build request as permission to build.

## Architecture and UI references

- When available in this checkout, read `docs/architecture-and-rules.md` before
  implementing or restructuring a feature. It defines the project's Flutter
  Clean Architecture boundaries, Freezed presentation states, Cubit/Bloc choice,
  dependency injection, naming, concurrency, localization, and verification rules.
- For visual changes, also read `docs/theme.md`; keep it focused on the shared
  theme and UI system.
- `docs/` contains local, Git-ignored documentation. Do not force-add it or assume
  those files exist in a fresh checkout. If absent, follow the instructions above
  and the user's architecture requirements in the active conversation.
