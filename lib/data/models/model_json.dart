typedef JsonObject = Map<String, Object?>;

Object? requiredValue(JsonObject json, String key) {
  if (!json.containsKey(key) || json[key] == null) {
    throw FormatException('Missing required field "$key".');
  }
  return json[key];
}

String requiredString(JsonObject json, String key) {
  final value = requiredValue(json, key);
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Field "$key" must be a non-empty string.');
  }
  return value;
}

String requiredText(JsonObject json, String key) {
  final value = requiredValue(json, key);
  if (value is! String) {
    throw FormatException('Field "$key" must be a string.');
  }
  return value;
}

String? optionalString(JsonObject json, String key) {
  if (!json.containsKey(key) || json[key] == null) return null;
  final value = json[key];
  if (value is! String) {
    throw FormatException('Field "$key" must be a string or null.');
  }
  return value;
}

int requiredInt(JsonObject json, String key, {int? minimum}) {
  final value = requiredValue(json, key);
  if (value is! int || (minimum != null && value < minimum)) {
    final constraint = minimum == null
        ? 'an integer'
        : 'an integer >= $minimum';
    throw FormatException('Field "$key" must be $constraint.');
  }
  return value;
}

bool requiredBool(JsonObject json, String key) {
  final value = requiredValue(json, key);
  if (value is! bool) {
    throw FormatException('Field "$key" must be a boolean.');
  }
  return value;
}

List<Object?> requiredList(JsonObject json, String key) {
  final value = requiredValue(json, key);
  if (value is! List<Object?>) {
    throw FormatException('Field "$key" must be a list.');
  }
  return value;
}

JsonObject requiredObject(JsonObject json, String key) {
  final value = requiredValue(json, key);
  if (value is! Map) {
    throw FormatException('Field "$key" must be an object.');
  }
  try {
    return Map<String, Object?>.from(value);
  } on TypeError {
    throw FormatException('Field "$key" must have string keys.');
  }
}

List<String> stringList(JsonObject json, String key) {
  return [
    for (final value in requiredList(json, key))
      if (value is String && value.trim().isNotEmpty)
        value
      else
        throw FormatException(
          'Every item in "$key" must be a non-empty string.',
        ),
  ];
}
