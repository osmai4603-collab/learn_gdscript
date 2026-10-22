# Learn GDScript

Flutter application infrastructure for an Arabic/English GDScript learning app.

## Development

The app uses the sibling [`gdscript_engine`](../gdscript_engine) Dart package.
Run:

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

The local SQLite database is created in the platform application-support
directory. Web storage is not configured yet.

The language server is a separate `gdscript_lsp` process and is intentionally
not started on Android, iOS, or web. Current release executable targets are
Linux x64, macOS arm64, and Windows x64. Set `GDSCRIPT_LSP_EXECUTABLE` to an
absolute path to the matching executable; the default lookup expects the
executable in the sibling repository's `build/` directory.
