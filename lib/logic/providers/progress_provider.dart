import 'package:flutter/foundation.dart';
import '../../data/models/async_state.dart';
import '../../data/models/progress_models.dart';
import '../../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);

  final ProgressRepository _repository;
  AsyncState<UserProgress?> state = const AsyncState.initial();

  Future<void> load(String visitorId) async {
    state = const AsyncState.loading();
    notifyListeners();
    try {
      state = AsyncState.data(await _repository.load(visitorId));
      notifyListeners();
    } on Object catch (error) {
      state = AsyncState.error(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> save(UserProgress progress) async {
    await _repository.save(progress);
    state = AsyncState.data(progress);
    notifyListeners();
  }
}
