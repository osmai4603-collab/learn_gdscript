# Curriculum audit CLI

Run from the repository root:

```sh
dart run tool/validate_curriculum.dart
dart run tool/validate_curriculum.dart --unit=01
dart run tool/validate_curriculum.dart --check-links
dart run tool/validate_curriculum.dart --strict --output=docs/audit_report.md
```

`--unit` accepts a directory prefix (such as `01`) or a full unit ID.
Network requests are opt-in. Markdown reports are deterministic and contain
the same findings as the console report. Exit status is `0` for a successful
non-strict audit and `1` for errors; strict mode also returns `1` when warnings
remain. Invalid CLI arguments return `2`.

The project uses the standard Dart/Flutter `pubspec.yaml`, which has no custom
script-alias field. Use the `tool/curriculum-audit` executable as a short local
alias instead of adding a non-standard pubspec key.

## Gradual strict pre-commit gate

The tracked hook at `tool/pre-commit` runs the full strict audit whenever any
file under `assets/curriculum/` is staged. This intentionally blocks curriculum
changes until the baseline violations have been fixed. Install the hook with:

```sh
ln -s ../../tool/pre-commit .git/hooks/pre-commit
```

The existing baseline currently has warnings, so curriculum changes will be
rejected until those findings are addressed. The default non-strict audit can
still be run to track the migration report.
