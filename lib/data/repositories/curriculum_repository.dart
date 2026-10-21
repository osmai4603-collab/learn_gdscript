import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_models.dart';

class CurriculumRepository {
  CurriculumRepository({
    required this._assetBundle,
    this.manifestAsset = 'assets/curriculum/manifest.json',
  });

  final AssetBundle _assetBundle;
  final String manifestAsset;

  Future<Curriculum> loadCurriculum() async {
    final source = await _assetBundle.loadString(manifestAsset);
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Curriculum manifest must be a JSON object.');
    }
    try {
      return Curriculum.fromJson(Map<String, Object?>.from(decoded));
    } on TypeError {
      throw const FormatException(
        'Curriculum manifest must have string object keys.',
      );
    }
  }
}
