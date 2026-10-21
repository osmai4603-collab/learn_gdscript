import 'package:learn_gdscript/data/models/localized_text.dart';
import '../../data/models/exercise_models.dart';

class HintService {
  const HintService();

  LocalizedText? nextHint(Exercise exercise, {required int hintsAlreadyShown}) {
    if (hintsAlreadyShown < 0) {
      throw ArgumentError.value(hintsAlreadyShown, 'hintsAlreadyShown');
    }
    if (hintsAlreadyShown >= exercise.hints.length) return null;
    return exercise.hints[hintsAlreadyShown];
  }
}
