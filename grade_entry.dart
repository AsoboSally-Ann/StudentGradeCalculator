// lib/models/grade_entry.dart
// =============================================================================
//  GRADE ENTRY
//
//  Gradable  (interface)
//    └─ GradeEntry   — pairs one Assessment with a student's nullable score
//
//  `score` is double? (nullable).
//  null  → the student has not yet submitted / been graded.
//  value → the raw score earned (clamped to maxScore as an edge-case guard).
//
//  Elvis (??) and safe calls (?.) are used throughout.
// =============================================================================

import 'package:grade_calculator/interfaces/gradable.dart';
import 'package:grade_calculator/models/assessment.dart';

class GradeEntry extends Gradable {
  final Assessment assessment;
  final double? score; // ← nullable: null = not yet graded

  GradeEntry({
    required this.assessment,
    this.score, // defaults to null
  });

  // ── Internal helpers ─────────────────────────────────────────────

  /// Clamp score to maxScore to guard against data-entry errors.
  double? get _safeScore {
    if (score == null) return null;                        // safe call: null check
    return score! > assessment.maxScore ? assessment.maxScore : score;
  }

  // ── Gradable implementation ──────────────────────────────────────

  @override
  double? get percentage =>
      _safeScore != null                                   // safe call
          ? (_safeScore! / assessment.maxScore) * 100
          : null;

  /// Weighted contribution to the course average; null when ungraded.
  double? get weightedScore =>
      percentage != null ? percentage! * assessment.weight : null;

  // ── Data-class ────────────────────────────────────────────────────

  GradeEntry copyWith({
    Assessment? assessment,
    double? score,
    bool clearScore = false, // set true to explicitly null the score
  }) =>
      GradeEntry(
        assessment: assessment ?? this.assessment,
        score: clearScore ? null : (score ?? this.score),
      );

  @override
  bool operator ==(Object o) =>
      o is GradeEntry && o.assessment == assessment && o.score == score;

  @override
  int get hashCode => Object.hash(assessment, score);

  // ── Display ────────────────────────────────────────────────────────

  @override
  String toString() {
    // Elvis (??) provides fallback strings for every nullable value
    final scoreStr = score?.toStringAsFixed(1)     ?? 'N/A';
    final pctStr   = percentage?.toStringAsFixed(1) ?? 'N/A';
    return '${assessment.category.padRight(16)}'
        '"${assessment.title}": $scoreStr / ${assessment.maxScore.toStringAsFixed(0)}'
        '  ($pctStr%)  [$letterGrade]  '
        'wt=${(assessment.weight * 100).toStringAsFixed(0)}%';
  }
}
