abstract final class AppRoutes {
  static const root = '/';
  static const learningPath = '/path';
  static const settings = '/settings';
  static const syntaxReference = '/syntax-reference';
  static const onboarding = '/onboarding';
  static const workspace = '/workspace';
  static const workspaceSearch = '/workspace/search';
  static const badges = '/badges';
  static const review = '/review';
  static const conceptMap = '/concept-map';
  static const capstone = '/capstone';
  static const lesson = '/lesson/:lessonId';
  static const lessonComplete = '/lesson-complete/:lessonId';

  static const spacedRepetition = '/spaced-repetition';
  static const miniGame = '/projects/mini-game';

  static String lessonPath(String lessonId) =>
      '/lesson/${Uri.encodeComponent(lessonId)}';

  static String lessonCompletePath(String lessonId) =>
      '/lesson-complete/${Uri.encodeComponent(lessonId)}';
}
