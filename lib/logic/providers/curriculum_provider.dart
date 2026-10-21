import 'package:flutter/foundation.dart';

import '../../data/models/async_state.dart';
import '../../data/models/curriculum_models.dart';
import '../../data/repositories/curriculum_repository.dart';

class CurriculumProvider extends ChangeNotifier {
  CurriculumProvider(this._repository);

  final CurriculumRepository _repository;
  AsyncState<Curriculum> state = const AsyncState.initial();

  Future<void> load() async {
    state = const AsyncState.loading();
    notifyListeners();
    try {
      state = AsyncState.data(await _repository.loadCurriculum());
      notifyListeners();
    } on Object catch (error) {
      state = AsyncState.error(error);
      notifyListeners();
      rethrow;
    }
  }
}
