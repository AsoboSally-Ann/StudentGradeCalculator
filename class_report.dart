// lib/reports/class_report.dart
// =============================================================================
//  CLASS REPORT  (extends Reportable)
//
//  Reportable  (interface)   ← lib/interfaces/reportable.dart
//    └─ ClassReport          — summary across all students in a course
//
//  Aggregates per-student data into class-level statistics.
//  Safe calls and Elvis used throughout for nullable fields.
// =============================================================================

import 'package:grade_calculator/interfaces/reportable.dart';
import 'package:grade_calculator/models/course.dart';
import 'package:grade_calculator/models/student.dart';

class ClassReport extends Reportable {
  final Course course;

  ClassReport({required this.course});

  @override
  String buildReport() {
    final sep  = '═' * 62;
    final sep2 = '─' * 62;
    final buf  = StringBuffer();

    buf.writeln('\n$sep');
    buf.writeln('  CLASS REPORT  ·  ${course.name} (${course.code})');
    // Safe calls on nullable instructor and its nullable officeRoom
    buf.writeln('  Instructor  : ${course.instructor?.fullName ?? "TBA"}');
    buf.writeln('  Dept / Room : '
        '${course.instructor?.department ?? "N/A"}  ·  '
        '${course.instructor?.officeRoom ?? "no office"}');
    buf.writeln('  Semester    : ${course.semester}');
    buf.writeln('  Enrolled    : ${course.students.length} student(s)');
    buf.writeln(sep);

    final students = course.students;
    if (students.isEmpty) {
      buf.writeln('  No students enrolled.\n$sep');
      return buf.toString();
    }

    // ── Per-student rows ──────────────────────────────────────────
    for (final s in students) {
      buf.writeln('\n  ${s.role.padRight(14)} ${s.fullName}  [${s.id}]');
      buf.writeln('  ${s.level}');
      buf.writeln('  Email   : ${s.email ?? "not provided"}'); // Elvis

      // Safe call on nullable percentage
      buf.writeln(
          '  Average : ${s.percentage?.toStringAsFixed(2) ?? "N/A"}%'
          '   Grade: ${s.letterGrade}'
          '   GPA: ${s.gpaPoints.toStringAsFixed(1)}');

      // Subclass-specific info
      if (s is PostgraduateStudent) {
        buf.writeln('  Research: ${s.researchArea}  '
            'Supervisor: ${s.supervisorId ?? "not assigned"}'); // Elvis on nullable
      } else if (s is UndergraduateStudent) {
        buf.writeln('  Enrolled: ${s.enrolmentYear}  '
            'Year of Study: ${s.yearOfStudy}');
      }

      final missing = s.missingAssessments;
      if (missing.isNotEmpty) {
        buf.writeln('  Missing : ${missing.join(", ")}');
      }
      buf.writeln(sep2);
    }

    // ── Class-level statistics ────────────────────────────────────
    final graded = students.where((s) => s.percentage != null).toList();

    if (graded.isEmpty) {
      buf.writeln('\n  No graded students yet.');
    } else {
      final classAvg =
          graded.map((s) => s.percentage!).reduce((a, b) => a + b) /
          graded.length;

      final top = graded.reduce((a, b) =>
          (a.percentage ?? 0) >= (b.percentage ?? 0) ? a : b);
      final bottom = graded.reduce((a, b) =>
          (a.percentage ?? 100) <= (b.percentage ?? 100) ? a : b);

      // Grade distribution map
      final dist = <String, int>{};
      for (final s in graded) {
        dist[s.letterGrade] = (dist[s.letterGrade] ?? 0) + 1;
      }

      buf.writeln('\n  STATISTICS');
      buf.writeln('  Class Average  : ${classAvg.toStringAsFixed(2)}%');

      // Safe calls on top/bottom percentage (already filtered, but consistent style)
      buf.writeln('  Top Student    : ${top.fullName}'
          ' (${top.percentage?.toStringAsFixed(1) ?? "N/A"}%)');
      buf.writeln('  Bottom Student : ${bottom.fullName}'
          ' (${bottom.percentage?.toStringAsFixed(1) ?? "N/A"}%)');
      buf.writeln('  Grade Dist.    : '
          '${dist.entries.map((e) => '${e.key}: ${e.value}').join("  ")}');
    }

    buf.writeln(sep);
    return buf.toString();
  }
}
