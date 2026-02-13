class TerminalUtils {
  static const String defaultTitle = 'Terminal';

  /// Sanitizes and validates the terminal title.
  ///
  /// Returns a safe, printable string. If the input is null or empty,
  /// returns [defaultTitle].
  /// Removes control characters to prevent display issues.
  static String sanitizeTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return defaultTitle;
    }

    // Remove control characters (characters with code unit < 32),
    // except for spaces.
    // Also consider removing other non-printable characters if necessary.
    // For simplicity, we filter out common control codes.
    final sanitized = title.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    if (sanitized.trim().isEmpty) {
      return defaultTitle;
    }

    return sanitized.trim();
  }
}
