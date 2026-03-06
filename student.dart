// lib/models/student.dart
// =============================================================================
//  STUDENT HIERARCHY
//
//  Person  (abstract)          ← lib/models/person.dart
//    └─ Student  (abstract, implements Gradable)
//         ├─ UndergraduateStudent   (yearOfStudy, enrolmentYear)
//         └─ PostgraduateStudent    (researchArea, nullable supervisorId)
//
//  Student extends Person AND implements Gradable so a student can report
//  its own weighted average, letter grade, and GPA directly.
//  Grade computations are shared here; subclasses only add their own fields.
// =============================================================================

import 'package:grade_calculator/interfaces/gradable.dart';
import 'package:grade_calculator/models/grade_entry.dart';
import 'package:grade_calculator/models/person.dart';

// ── Student (abstract) ────────────────────────────────────────────────────────

abstract class Student extends Person implements Gradable {
  final List<GradeEntry> grades;

  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    this.grades = const [],
  });

  // ── Shared grade computations ────────────────────────────────────

  /// Only entries where the student has actually submitted a score.
  List<GradeEntry> get gradedEntries =>
      grades.where((g) => g.score != null).toList();

  double get _totalGradedWeight =>
      gradedEntries.fold(0.0, (sum, g) => sum + g.assessment.weight);

  @override
  double? get percentage {
    if (gradedEntries.isEmpty) return null; // safe call: nothing to average yet

    final tw = _totalGradedWeight;
    // Edge case: all weights are zero → fall back to simple unweighted mean
    if (tw == 0) {
      return gradedEntries.fold(0.0, (s, g) => s + (g.percentage ?? 0.0)) /
          gradedEntries.length;
    }
    return gradedEntries.fold(0.0, (s, g) => s + (g.weightedScore ?? 0.0)) / tw;
  }

  // letterGrade and gpaPoints are inherited from Gradable — no override needed.

  /// Titles of assessments that have not yet been scored (score == null).
  List<String> get missingAssessments =>
      grades.where((g) => g.score == null).map((g) => g.assessment.title).toList();

  /// The highest-scoring graded entry; null when nothing is graded yet.
  GradeEntry? get bestEntry =>
      gradedEntries.isEmpty
          ? null
          : gradedEntries.reduce(
              (a, b) => (a.percentage ?? 0) >= (b.percentage ?? 0) ? a : b);

  /// The lowest-scoring graded entry; null when nothing is graded yet.
  GradeEntry? get worstEntry =>
      gradedEntries.isEmpty
          ? null
          : gradedEntries.reduce(
              (a, b) => (a.percentage ?? 100) <= (b.percentage ?? 100) ? a : b);

  /// Academic level string — each subclass defines this.
  String get level;

  /// Year the student first enrolled — each subclass defines this.
  int get enrolmentYear;
}

// ── UndergraduateStudent (extends Student) ────────────────────────────────────

class UndergraduateStudent extends Student {
  final int yearOfStudy; // 1, 2, 3, or 4
  @override
  final int enrolmentYear;

  UndergraduateStudent({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,    // nullable — inherited from Person via Student
    super.grades,
    required this.yearOfStudy,
    required this.enrolmentYear,
  });

  @override
  String get role  => 'Undergraduate';

  @override
  String get level => 'Year $yearOfStudy Undergraduate (enrolled $enrolmentYear)';

  // Data-class: copyWith
  UndergraduateStudent copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    bool clearEmail = false,
    List<GradeEntry>? grades,
    int? yearOfStudy,
    int? enrolmentYear,
  }) =>
      UndergraduateStudent(
        id:            id            ?? this.id,
        firstName:     firstName     ?? this.firstName,
        lastName:      lastName      ?? this.lastName,
        email:         clearEmail    ? null : (email ?? this.email),
        grades:        grades        ?? this.grades,
        yearOfStudy:   yearOfStudy   ?? this.yearOfStudy,
        enrolmentYear: enrolmentYear ?? this.enrolmentYear,
      );

  @override
  bool operator ==(Object o) => o is UndergraduateStudent && o.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── PostgraduateStudent (extends Student) ─────────────────────────────────────

class PostgraduateStudent extends Student {
  final String researchArea;
  final String? supervisorId; // nullable — may not yet be assigned
  @override
  final int enrolmentYear;

  PostgraduateStudent({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,         // nullable
    super.grades,
    required this.researchArea,
    this.supervisorId,   // nullable
    required this.enrolmentYear,
  });

  @override
  String get role  => 'Postgraduate';

  @override
  String get level => 'Postgraduate — $researchArea (enrolled $enrolmentYear)';

  // Data-class: copyWith
  PostgraduateStudent copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    bool clearEmail = false,
    List<GradeEntry>? grades,
    String? researchArea,
    String? supervisorId,
    bool clearSupervisor = false,
    int? enrolmentYear,
  }) =>
      PostgraduateStudent(
        id:            id              ?? this.id,
        firstName:     firstName       ?? this.firstName,
        lastName:      lastName        ?? this.lastName,
        email:         clearEmail      ? null : (email        ?? this.email),
        grades:        grades          ?? this.grades,
        researchArea:  researchArea    ?? this.researchArea,
        supervisorId:  clearSupervisor ? null : (supervisorId ?? this.supervisorId),
        enrolmentYear: enrolmentYear   ?? this.enrolmentYear,
      );

  @override
  bool operator ==(Object o) => o is PostgraduateStudent && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
