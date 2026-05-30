extension StringExtensions on String {
  /// Capitalizes the first character of the string.
  /// Returns empty string if the original is empty.
  ///
  /// Example: "mystery & suspense" → "Mystery & suspense"
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first character of each word.
  ///
  /// Example: "mystery & suspense" → "Mystery & Suspense"
  String get capitalizeEachWord {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalizeFirst).join(' ');
  }
}
