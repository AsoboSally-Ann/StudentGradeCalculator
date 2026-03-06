// lib/interfaces/gradable.dart
// =============================================================================
//  GRADABLE — abstract interface
//  Any entity that can produce a percentage and letter grade implements this.
//  Used by: Assessment, GradeEntry, Student (and all subclasses)
// =============================================================================

abstract class Gradable {
  /// Raw percentage 0–100. Returns null when not yet available.
  double? get percentage;

  /// Letter grade derived via Elvis-style chained ternary.
  /// Inherited automatically by every implementing class.
  String get letterGrade {
    final p = percentage;         // safe call: may be null
    if (p == null) return 'N/A'; // Elvis: null → 'N/A'
    return p >= 90
        ? 'A'
        : p >= 80
            ? 'B'
            : p >= 70
                ? 'C'
                : p >= 60
                    ? 'D'
                    : 'F';
  }

  /// GPA points on a 4.0 scale, derived from letterGrade.
  double get gpaPoints {
    const map = {'A': 4.0, 'B': 3.0, 'C': 2.0, 'D': 1.0, 'F': 0.0};
    return map[letterGrade] ?? 0.0; // Elvis: missing key → 0.0
  }
}
