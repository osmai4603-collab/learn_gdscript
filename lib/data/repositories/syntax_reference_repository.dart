import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/localized_text.dart';
import '../models/model_json.dart';

class SyntaxReference {
  SyntaxReference({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.syntax,
    required this.example,
    required this.relatedLesson,
    required List<String> seeAlso,
  }) : seeAlso = List.unmodifiable(seeAlso);

  final String id;
  final String category;
  final LocalizedText title;
  final LocalizedText description;
  final String syntax;
  final String example;
  final String? relatedLesson;
  final List<String> seeAlso;

  factory SyntaxReference.fromJson(JsonObject json) {
    final relatedLesson = optionalString(json, 'relatedLesson');
    if (relatedLesson != null && relatedLesson.trim().isEmpty) {
      throw const FormatException(
        'Field "relatedLesson" must be a non-empty string or null.',
      );
    }
    return SyntaxReference(
      id: requiredString(json, 'keyword'),
      category: requiredString(json, 'category'),
      title: LocalizedText.fromJson(requiredObject(json, 'title')),
      description: LocalizedText.fromJson(requiredObject(json, 'description')),
      syntax: requiredString(json, 'syntax'),
      example: requiredString(json, 'example'),
      relatedLesson: relatedLesson,
      seeAlso: stringList(json, 'seeAlso'),
    );
  }
}

abstract interface class SyntaxReferenceRepository {
  Future<List<SyntaxReference>> search(String query, {String? category});
}

class AssetSyntaxReferenceRepository implements SyntaxReferenceRepository {
  AssetSyntaxReferenceRepository({
    required this.assetBundle,
    this.manifestAsset = 'assets/syntax_reference/manifest.json',
  });

  final AssetBundle assetBundle;
  final String manifestAsset;
  Future<List<SyntaxReference>>? _entriesFuture;

  @override
  Future<List<SyntaxReference>> search(String query, {String? category}) async {
    late final List<SyntaxReference> entries;
    try {
      entries = await (_entriesFuture ??= _loadEntries());
    } on Object {
      _entriesFuture = null;
      rethrow;
    }
    final normalizedQuery = query.trim().toLowerCase();
    return List.unmodifiable(
      entries.where((entry) {
        if (category != null && entry.category != category) return false;
        if (normalizedQuery.isEmpty) return true;
        return [
          entry.id,
          entry.category,
          entry.title.ar,
          entry.title.en,
          entry.description.ar,
          entry.description.en,
          entry.syntax,
        ].any((value) => value.toLowerCase().contains(normalizedQuery));
      }),
    );
  }

  Future<List<SyntaxReference>> _loadEntries() async {
    final manifestJson = _decodeObject(
      await assetBundle.loadString(manifestAsset),
      manifestAsset,
    );
    requiredString(manifestJson, 'version');
    final files = requiredList(manifestJson, 'entries');
    final entries = <SyntaxReference>[];
    for (var index = 0; index < files.length; index++) {
      final file = _asObject(files[index], 'entries[$index]');
      final fileName = requiredString(file, 'file');
      if (fileName.contains('/') || fileName.contains('\\')) {
        throw FormatException('Invalid syntax reference file "$fileName".');
      }
      requiredString(file, 'category');
      final expectedCount = requiredInt(file, 'count', minimum: 0);
      final assetPath = 'assets/syntax_reference/$fileName';
      final decoded = jsonDecode(await assetBundle.loadString(assetPath));
      if (decoded is! List) {
        throw FormatException('Syntax reference "$assetPath" must be a list.');
      }
      if (decoded.length != expectedCount) {
        throw FormatException(
          'Syntax reference "$assetPath" has ${decoded.length} entries; '
          'expected $expectedCount.',
        );
      }
      for (var itemIndex = 0; itemIndex < decoded.length; itemIndex++) {
        entries.add(
          SyntaxReference.fromJson(
            _asObject(decoded[itemIndex], '$assetPath[$itemIndex]'),
          ),
        );
      }
    }
    final ids = entries
        .map((entry) => '${entry.category}:${entry.id.toLowerCase()}')
        .toSet();
    if (ids.length != entries.length) {
      throw const FormatException(
        'Syntax reference contains duplicate keywords.',
      );
    }
    return List.unmodifiable(entries);
  }

  static JsonObject _decodeObject(String source, String assetPath) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw FormatException('JSON asset "$assetPath" must be an object.');
    }
    return _asObject(decoded, assetPath);
  }

  static JsonObject _asObject(Object? value, String field) {
    if (value is! Map) {
      throw FormatException('Field "$field" must be an object.');
    }
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('Field "$field" must have string keys.');
    }
  }
}

class EmptySyntaxReferenceRepository implements SyntaxReferenceRepository {
  const EmptySyntaxReferenceRepository();

  @override
  Future<List<SyntaxReference>> search(
    String query, {
    String? category,
  }) async => const [];
}
