import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'model_json.dart';

@immutable
class Unit {
  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String iconName;
  final int order;
  final List<String> lessonIds;

  Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.order,
    required List<String> lessonIds,
  }) : lessonIds = List.unmodifiable(lessonIds) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    if (order < 0) throw ArgumentError.value(order, 'order');
  }

  factory Unit.fromJson(JsonObject json) => Unit(
    id: requiredString(json, 'id'),
    title: LocalizedText.fromJson(requiredObject(json, 'title')),
    description: LocalizedText.fromJson(requiredObject(json, 'description')),
    iconName: requiredString(json, 'iconName'),
    order: requiredInt(json, 'order', minimum: 0),
    lessonIds: stringList(json, 'lessonIds'),
  );

  JsonObject toJson() => {
    'id': id,
    'title': title.toJson(),
    'description': description.toJson(),
    'iconName': iconName,
    'order': order,
    'lessonIds': lessonIds,
  };
}

@immutable
class Curriculum {
  final String version;
  final String targetGDScriptVersion;
  final List<Unit> units;

  Curriculum({
    required this.version,
    required this.targetGDScriptVersion,
    required List<Unit> units,
  }) : units = List.unmodifiable(units) {
    if (version.trim().isEmpty) throw ArgumentError.value(version, 'version');
    if (targetGDScriptVersion.trim().isEmpty) {
      throw ArgumentError.value(targetGDScriptVersion, 'targetGDScriptVersion');
    }
  }

  factory Curriculum.fromJson(JsonObject json) {
    final units = requiredList(json, 'units');
    return Curriculum(
      version: requiredString(json, 'version'),
      targetGDScriptVersion: requiredString(json, 'targetGDScriptVersion'),
      units: [
        for (var index = 0; index < units.length; index++)
          _parseUnit(units[index], index),
      ],
    );
  }

  static Unit _parseUnit(Object? value, int index) {
    if (value is! Map) {
      throw FormatException('Field "units[$index]" must be an object.');
    }
    return Unit.fromJson(Map<String, Object?>.from(value));
  }

  JsonObject toJson() => {
    'version': version,
    'targetGDScriptVersion': targetGDScriptVersion,
    'units': units.map((unit) => unit.toJson()).toList(growable: false),
  };
}
