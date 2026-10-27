# Curriculum validation rules

The CLI in `tool/validate_curriculum.dart` applies the following checks.
Structural defects and broken identifiers are errors; content-quality gaps are
warnings so the existing curriculum can be baselined and migrated incrementally.
`--strict` makes warnings fail the command.

| Rule | Check | Current behavior |
|---|---|---|
| 1 | Schema integrity | Parse manifests, units, lessons, exercises, test cases, and documentation sources with project models; reject malformed values. |
| 2 | Identifier integrity | Match unit and lesson files to manifest IDs and validate lesson/exercise references and uniqueness. |
| 3 | Five-section structure | Look for the required Arabic concept, rules, example, errors, and summary sections. |
| 4 | Hint repetition | Find identical normalized Arabic or English hints and report their exercise locations. |
| 5 | Template questions | Flag known generic question phrases in Arabic and English. |
| 6 | Answer distribution | Warn when more than 40% of a lesson's multiple-choice answers use index zero; flag fewer than three options. |
| 7 | Test-case coverage | Require two cases for `writeCode` and `fixBug`, with a basic diversity check. |
| 8 | Official directives | Warn if lesson content has none of `[!WARNING]`, `[!NOTE]`, or `[!TIP]`. |
| 9 | Documentation links | Require the official HTTPS host and a Godot 4.3 URL; optionally check HTTP status with `--check-links`. |
| 10 | Concept map | Check lesson coverage, references, duplicate lesson mappings, and graph validity. |
| 11 | Time estimate | Estimate a broad duration from the larger localized word count and exercise count; warn outside half-to-twice that estimate, bounded to 8–25 minutes. |
| 12 | Cumulative challenge | Check the last ordered lesson in each unit for a guided or explicitly cumulative task. |

The checks are deliberately explicit and repeatable. Network checks are opt-in
to keep default runs deterministic and usable offline. The concept map's own
model rejects cycles and unknown prerequisite IDs while parsing.

The current ten-exercise template follows the explicit per-type allocation in
the approved phase plan (including `reorderSteps`) and therefore represents six
of the seven available exercise types. Requiring all seven without reducing
another requested type's count would require an eleventh exercise.

The pre-commit hook in `tool/pre-commit` runs the complete audit in strict mode
for every staged change under `assets/curriculum/`. Since the existing content
is a known-warning baseline, curriculum edits remain blocked until the strict
findings are resolved.

Run the complete audit:

```sh
dart run tool/validate_curriculum.dart
dart run tool/validate_curriculum.dart --output=docs/baseline_curriculum_audit_report.md
dart run tool/validate_curriculum.dart --unit=01 --strict
```

In the present baseline, findings are expected. Enable strict gating for a unit
only after its lessons have been brought up to the new standard.
