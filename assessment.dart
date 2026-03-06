// lib/models/assessment.dart
// =============================================================================
//  ASSESSMENT HIERARCHY
//
//  Gradable  (interface)  ← lib/interfaces/gradable.dart
//    └─ Assessment        (abstract — describes a graded task template)
//         ├─ WrittenAssessment    (exam or quiz)
//         └─ PracticalAssessment  (lab or group project)
//
//  An Assessment is the BLUEPRINT for a graded task — it does not hold a
//  student's score. Scores live in GradeEntry (grade_entry.dart).
// =============================================================================

import 'package:grade_calculator/interfaces/gradable.dart';

// ── Assessment (abstract) ─────────────────────────────────────────────────────

abstract class Assessment extends Gradable {
  final String title;
  final double maxScore;
  final double weight; // fraction of overall course grade, e.g. 0.30 = 30 %

  Assessment({
    required this.title,
    required this.maxScore,
    required this.weight,
  });

  /// Category label shown in reports (e.g. "Exam", "Quiz", "Lab / Practical").
  String get category;

  /// Assessments are templates only — no individual score attached.
  /// percentage is therefore always null at this level.
  @override
  double? get percentage => null;

  @override
  String toString() =>
      '$category · "$title"  '
      '(max: ${maxScore.toStringAsFixed(0)}, '
      'weight: ${(weight * 100).toStringAsFixed(0)}%)';
}

// ── WrittenAssessment (extends Assessment) ────────────────────────────────────

/// A written test — either a formal exam or a shorter quiz.
class WrittenAssessment extends Assessment {
  final bool isExam; // true = midterm / final exam; false = quiz

  WrittenAssessment({
    required super.title,
    required super.maxScore,
    required super.weight,
    this.isExam = true,
  });

  @override
  String get category => isExam ? 'Exam' : 'Quiz';

  // Data-class: copyWith
  WrittenAssessment copyWith({
    String? title,
    double? maxScore,
    double? weight,
    bool? isExam,
  }) =>
      WrittenAssessment(
        title:    title    ?? this.title,
        maxScore: maxScore ?? this.maxScore,
        weight:   weight   ?? this.weight,
        isExam:   isExam   ?? this.isExam,
      );

  @override
  bool operator ==(Object o) =>
      o is WrittenAssessment &&
      o.title    == title    &&
      o.maxScore == maxScore &&
      o.weight   == weight   &&
      o.isExam   == isExam;

  @override
  int get hashCode => Object.hash(title, maxScore, weight, isExam);
}

// ── PracticalAssessment (extends Assessment) ──────────────────────────────────

/// A hands-on task — a lab session or a group project.
class PracticalAssessment extends Assessment {
  final bool isGroupWork;

  PracticalAssessment({
    required super.title,
    required super.maxScore,
    required super.weight,
    this.isGroupWork = false,
  });

  @override
  String get category => isGroupWork ? 'Group Project' : 'Lab / Practical';

  // Data-class: copyWith
  PracticalAssessment copyWith({
    String? title,
    double? maxScore,
    double? weight,
    bool? isGroupWork,
  }) =>
      PracticalAssessment(
        title:       title       ?? this.title,
        maxScore:    maxScore    ?? this.maxScore,
        weight:      weight      ?? this.weight,
        isGroupWork: isGroupWork ?? this.isGroupWork,
      );

  @override
  bool operator ==(Object o) =>
      o is PracticalAssessment &&
      o.title       == title       &&
      o.maxScore    == maxScore    &&
      o.weight      == weight      &&
      o.isGroupWork == isGroupWork;

  @override
  int get hashCode => Object.hash(title, maxScore, weight, isGroupWork);
}
