// lib/core/extensions/string_extension.dart

extension StringExtension on String {
  /// Capitalizes only the first character.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Truncates string to [maxLength] and adds ellipsis if needed.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Returns true if this string is a valid Indonesian plate number format.
  /// Valid: "B 1234 ABC", "B 12 ABC", "AB 1234 CD"
  bool get isValidPlateNumber {
    final pattern = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');
    return pattern.hasMatch(toUpperCase().trim());
  }

  /// Formats raw plate number input to standard form.
  /// Example: "b1234sky" → "B 1234 SKY" (best-effort, not guaranteed)
  String get formattedPlate => toUpperCase().trim();
}

extension NullableStringExtension on String? {
  /// Returns true if string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns value or empty string if null.
  String get orEmpty => this ?? '';
}
