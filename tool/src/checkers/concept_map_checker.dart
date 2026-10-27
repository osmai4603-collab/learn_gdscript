import '../audit_context.dart';
import '../audit_models.dart';

void checkConceptMap(AuditContext context) {
  final conceptsByLesson = <String, String>{};
  final conceptIds = context.concepts.map((concept) => concept.id).toSet();
  for (final concept in context.concepts) {
    if (conceptsByLesson.containsKey(concept.lessonId)) {
      context.report.add(
        IssueSeverity.error,
        'concept-map',
        'More than one concept maps to lesson "${concept.lessonId}".',
        path: 'assets/concept_map/manifest.json',
      );
    }
    conceptsByLesson[concept.lessonId] = concept.id;
    for (final prerequisiteId in concept.prerequisiteIds) {
      if (!conceptIds.contains(prerequisiteId)) {
        context.report.add(
          IssueSeverity.error,
          'concept-map',
          'Concept "${concept.id}" references missing prerequisite '
          '"$prerequisiteId".',
          path: 'assets/concept_map/manifest.json',
        );
      }
    }
  }
  for (final concept in context.concepts) {
    if (!context.allLessonIds.contains(concept.lessonId)) {
      context.report.add(
        IssueSeverity.error,
        'concept-map',
        'Concept "${concept.id}" references unknown lesson "${concept.lessonId}".',
        path: 'assets/concept_map/manifest.json',
      );
    }
  }
  final checkedLessonIds = context.lessons
      .map((record) => record.lesson.id)
      .toSet();
  for (final lessonId in checkedLessonIds.difference(conceptsByLesson.keys.toSet())) {
    context.report.add(
      IssueSeverity.warning,
      'concept-coverage',
      'Lesson "$lessonId" is missing from the concept map.',
      path: 'assets/concept_map/manifest.json',
    );
  }
}
