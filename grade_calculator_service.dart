// ============================================================
//  grade_calculator_service.dart
//  Business logic: grade calculation, validation, bulk ops
// ============================================================

import 'models.dart';

// ─────────────────────────────────────────────────────────────
// GRADE VALIDATOR
// ─────────────────────────────────────────────────────────────
class GradeValidator {
  static const double minScore = 0.0;
  static const double maxScore = 100.0;

  static String? validateScore(double? score) {
    if (score == null) return null;
    if (score < minScore) return 'Score cannot be below 0';
    if (score > maxScore) return 'Score cannot exceed 100';
    return null;
  }

  static String? validateStudentId(String id) {
    if (id.isEmpty) return 'ID cannot be empty';
    if (!Student.isValidId(id)) {
      return 'ID must start with ICTU2023 followed by digits (e.g. ICTU2023001)';
    }
    return null;
  }

  static String? validateName(String name) {
    if (name.trim().isEmpty) return 'Name cannot be empty';
    if (name.trim().length < 2) return 'Name must have at least 2 characters';
    return null;
  }

  // Safe call + Elvis demo
  static String describeScore(double? score) =>
      score?.toStringAsFixed(1) ?? 'Not submitted';
}

// ─────────────────────────────────────────────────────────────
// DATA CLASS — GradeResult  (immutable result record)
// ─────────────────────────────────────────────────────────────
class GradeResult {
  final String studentId;
  final String studentName;
  final double? average;
  final String letterGrade;
  final double gpa;
  final String status;
  final Map<String, String> subjectBreakdown;

  const GradeResult({
    required this.studentId,
    required this.studentName,
    this.average,
    required this.letterGrade,
    required this.gpa,
    required this.status,
    required this.subjectBreakdown,
  });

  // Safe call + Elvis
  String get averageLabel => average?.toStringAsFixed(2) ?? 'N/A';

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'studentName': studentName,
        'average': average,
        'letterGrade': letterGrade,
        'gpa': gpa,
        'status': status,
        'subjectBreakdown': subjectBreakdown,
      };

  @override
  String toString() =>
      'GradeResult($studentId | $studentName | '
      'Avg: $averageLabel% | Grade: $letterGrade | '
      'GPA: ${gpa.toStringAsFixed(1)} | $status)';
}

// ─────────────────────────────────────────────────────────────
// SINGLE STUDENT CALCULATOR
// ─────────────────────────────────────────────────────────────
class StudentGradeCalculator {
  static GradeResult calculate(Student student) {
    final scores = student.grades.map((g) => g.score).toList();
    final avg = average(scores);

    return GradeResult(
      studentId: student.id,
      studentName: student.name,
      average: avg,
      letterGrade: student.letterGrade,
      gpa: student.gpa,
      status: student.status,
      subjectBreakdown: {
        for (final g in student.grades)
          g.subject: GradeValidator.describeScore(g.score),
      },
    );
  }

  // Generic function over Student subclasses
  static List<GradeResult> calculateAll<T extends Student>(List<T> students) =>
      students.map(calculate).toList();
}

// ─────────────────────────────────────────────────────────────
// CLASS STATISTICS
// ─────────────────────────────────────────────────────────────
class ClassStatistics {
  final int totalStudents;
  final int submittedCount;
  final double? classAverage;
  final Map<String, int> gradeDistribution;
  final int passCount;
  final int failCount;

  const ClassStatistics({
    required this.totalStudents,
    required this.submittedCount,
    this.classAverage,
    required this.gradeDistribution,
    required this.passCount,
    required this.failCount,
  });

  String get classAverageLabel => classAverage?.toStringAsFixed(2) ?? 'N/A';

  static ClassStatistics from(List<GradeResult> results) {
    final withGrades = results.where((r) => r.average != null).toList();
    final allAvg = withGrades.isEmpty
        ? null
        : withGrades.map((r) => r.average!).reduce((a, b) => a + b) /
            withGrades.length;

    final dist = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
    for (final r in results) {
      dist[r.letterGrade] = (dist[r.letterGrade] ?? 0) + 1;
    }

    return ClassStatistics(
      totalStudents: results.length,
      submittedCount: withGrades.length,
      classAverage: allAvg,
      gradeDistribution: dist,
      passCount: results.where((r) => r.status == 'Pass').length,
      failCount: results.where((r) => r.status == 'Fail').length,
    );
  }
}
