class AppValidators {
  /// A standards-based email regex that supports plus-addressing (e.g. user_tag+1@example.com)
  /// and long TLDs while rejecting invalid labels.
  static const emailPattern =
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';

  static bool isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email.trim());
  }
}
