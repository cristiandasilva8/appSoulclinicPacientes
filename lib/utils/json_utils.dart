/// Utilitários para tratamento seguro de JSON
class JsonUtils {
  /// Converte valor para String de forma segura
  static String safeString(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue ?? '';
    return value.toString();
  }

  /// Converte valor para String nullable de forma segura
  static String? safeStringNullable(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  /// Converte valor para int de forma segura
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Converte valor para DateTime de forma segura
  static DateTime safeDateTime(dynamic value, {DateTime? defaultValue}) {
    if (value == null) return defaultValue ?? DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return defaultValue ?? DateTime.now();
      }
    }
    return defaultValue ?? DateTime.now();
  }

  /// Converte valor para bool de forma segura
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Converte lista de forma segura
  static List<T> safeList<T>(dynamic value, T Function(dynamic) converter) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => converter(e)).toList();
    }
    return [];
  }

  /// Converte Map para String de forma segura
  static String safeMapToString(dynamic value, String key, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is Map && value.containsKey(key)) {
      return safeString(value[key], defaultValue: defaultValue);
    }
    return defaultValue;
  }
}
