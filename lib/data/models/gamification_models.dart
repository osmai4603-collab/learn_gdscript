import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'model_json.dart';

enum BadgeCategory { milestone, skill, streak, explorer }

@immutable
class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.order,
    required this.conditionType,
    required this.targetValue,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String iconName;
  final BadgeCategory category;
  final int order;
  final String conditionType;
  final int targetValue;

  factory BadgeDefinition.fromJson(JsonObject json) {
    final categoryName = requiredString(json, 'category');
    final categories = BadgeCategory.values.where(
      (value) => value.name == categoryName,
    );
    if (categories.isEmpty) {
      throw FormatException('Unsupported badge category "$categoryName".');
    }
    return BadgeDefinition(
      id: requiredString(json, 'id'),
      title: LocalizedText.fromJson(requiredObject(json, 'title')),
      description: LocalizedText.fromJson(requiredObject(json, 'description')),
      iconName: requiredString(json, 'iconName'),
      category: categories.first,
      order: requiredInt(json, 'order', minimum: 0),
      conditionType: requiredString(json, 'conditionType'),
      targetValue: requiredInt(json, 'targetValue', minimum: 0),
    );
  }

  JsonObject toJson() => {
    'id': id,
    'title': title.toJson(),
    'description': description.toJson(),
    'iconName': iconName,
    'category': category.name,
    'order': order,
    'conditionType': conditionType,
    'targetValue': targetValue,
  };
}

@immutable
class EarnedBadge {
  const EarnedBadge({required this.badgeId, required this.earnedAt});

  final String badgeId;
  final DateTime earnedAt;

  factory EarnedBadge.fromJson(JsonObject json) {
    final earnedAt = requiredString(json, 'earnedAt');
    try {
      return EarnedBadge(
        badgeId: requiredString(json, 'badgeId'),
        earnedAt: DateTime.parse(earnedAt),
      );
    } on FormatException {
      throw const FormatException('Field "earnedAt" must be an ISO-8601 date.');
    }
  }

  JsonObject toJson() => {
    'badgeId': badgeId,
    'earnedAt': earnedAt.toIso8601String(),
  };
}

enum XpReason {
  lessonCompleted,
  exerciseFirstTry,
  exerciseRetry,
  exampleExecuted,
  hintUsed,
  solutionViewed,
  unitCompleted,
  dailyStreakBonus,
}

@immutable
class XpTransaction {
  const XpTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.relatedEntityId,
  });

  final String id;
  final int amount;
  final XpReason reason;
  final DateTime timestamp;
  final String? relatedEntityId;

  factory XpTransaction.fromJson(JsonObject json) {
    final reasonName = requiredString(json, 'reason');
    final reasons = XpReason.values.where((value) => value.name == reasonName);
    if (reasons.isEmpty) {
      throw FormatException('Unsupported XP reason "$reasonName".');
    }
    final timestamp = requiredString(json, 'timestamp');
    try {
      return XpTransaction(
        id: requiredString(json, 'id'),
        amount: requiredInt(json, 'amount'),
        reason: reasons.first,
        timestamp: DateTime.parse(timestamp),
        relatedEntityId: optionalString(json, 'relatedEntityId'),
      );
    } on FormatException {
      throw const FormatException(
        'Field "timestamp" must be an ISO-8601 date.',
      );
    }
  }

  JsonObject toJson() => {
    'id': id,
    'amount': amount,
    'reason': reason.name,
    'timestamp': timestamp.toIso8601String(),
    'relatedEntityId': relatedEntityId,
  };
}
