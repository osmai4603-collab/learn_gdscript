# Lesson review checklist

Complete both the pedagogical and technical review before merging a lesson.

## Structure and learning design

- [ ] Objective names a measurable learner action and matches the exercises.
- [ ] Arabic and English explain the same concept at a comparable level.
- [ ] Content includes all five sections: concept and goal; syntax and rules;
  explained practical example; common errors and warnings; golden rule and
  summary.
- [ ] The example is runnable in Godot 4.3 and each important line is explained.
- [ ] `[!WARNING]`, `[!NOTE]`, and `[!TIP]` blocks are accurate and useful.
- [ ] Lesson length is realistic (8–25 minutes), including reading and practice.

## Exercises

- [ ] Ten exercises use the prescribed mix: four `writeCode`, two
  `multipleChoice`, and one each of `fixBug`, `predictOutput`, `fillBlank`, and
  either `reorderSteps` or `guidedTask`.
- [ ] Note: this ten-exercise allocation represents six types. Covering all
  seven types while retaining the other requested counts requires eleven
  exercises; confirm the curriculum owner's choice before changing the mix.
- [ ] Prompts test the lesson objective and are not interchangeable templates.
- [ ] Multiple-choice distractors are plausible, and correct answers are not
  concentrated at index zero.
- [ ] `writeCode` and `fixBug` have at least two distinct test cases, including
  a boundary or alternate input where appropriate.
- [ ] Hints progress from concept to approach to a concrete structural cue;
  they do not reveal the full solution immediately.
- [ ] Starter code, solution code, steps, and expected outputs agree.
- [ ] Exercise IDs, lesson links, and order values are unique and correct.

## Technical and editorial review

- [ ] JSON parses and model fields match the Dart lesson/exercise models.
- [ ] Documentation URLs are official, version-pinned to Godot 4.3, and relevant.
- [ ] Lesson is represented in the concept map; prerequisite edges are valid
  and acyclic.
- [ ] The final lesson in the unit contains a cumulative task.
- [ ] Arabic terminology, punctuation, and code directionality have been checked.
- [ ] `dart run tool/validate_curriculum.dart --unit=NN --strict` passes for a
  unit that has been migrated to the strict standard.
- [ ] Relevant Flutter tests pass.

Reviewer:  
Lesson ID:  
Date:  
Decision: Approve / Request changes
