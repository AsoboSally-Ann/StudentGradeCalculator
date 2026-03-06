// lib/reports/course_report.dart
// =============================================================================
//  COURSE REPORT  (extends Reportable)
//
//  Reportable  (interface)   ← lib/interfaces/reportable.dart
//    └─ CourseReport         — one student's performance in one course
//
//  Uses safe calls (?.) and Elvis (??) extensively for nullable fields.
//  Uses runtime subclass checks to display UG- or PG-specific details.
// =============================================================================

import 'package:grade_calculator/interfaces/reportable.dart';
import 'package:grade_calculator/models/course.dart';
import 'package:grade_calculator/models/student.dart';

class CourseReport extends Reportable {
  final Student student;
  final Course course;

  CourseReport({required this.student, required this.course});

  @override
  String buildReport() {
    final sep = '─' * 60;
    final buf = StringBuffer();

    buf.writeln('\n$sep');
    buf.writeln('  INDIVIDUAL COURSE REPORT');
    buf.writeln('  Course     : ${course.name} (${course.code})');
    // Safe call: instructor is nullable — use ?. then ?? for fallback
    buf.writeln('  Instructor : ${course.instructor?.fullName ?? "TBA"}');
    buf.writeln('  Semester   : ${course.semester}');
    buf.writeln('  Student    : ${student.fullName}  [${student.id}]');
    buf.writeln('  Level      : ${student.level}');
    // Elvis: email may be null
    buf.writeln('  Email      : ${student.email ?? "not provided"}');

    // Subclass-specific details via runtime type check
    if (student is PostgraduateStudent) {
      final pg = student as PostgraduateStudent;
      buf.writeln('  Research   : ${pg.researchArea}');
      // Safe call + Elvis: supervisorId is nullable
      buf.writeln('  Supervisor : ${pg.supervisorId ?? "not yet assigned"}');
    } else if (student is UndergraduateStudent) {
      final ug = student as UndergraduateStudent;
      buf.writeln('  Year       : Year ${ug.yearOfStudy} of study');
      buf.writeln('  Enrolled   : ${ug.enrolmentYear}');
    }

    buf.writeln(sep);

    if (student.grades.isEmpty) {
      buf.writeln('  No assessments recorded.');
    } else {
      for (final g in student.grades) {
        buf.writeln('  $g');
      }
      buf.writeln(sep);

      // Safe calls on all nullable computed properties
      buf.writeln(
          '  Weighted Average : ${student.percentage?.toStringAsFixed(2) ?? "N/A"}%');
      buf.writeln('  Letter Grade     : ${student.letterGrade}');
      buf.writeln('  GPA Points       : ${student.gpaPoints.toStringAsFixed(1)}');

      final missing = student.missingAssessments;
      if (missing.isNotEmpty) {
        buf.writeln('  Missing          : ${missing.join(", ")}');
      }

      // Safe calls: bestEntry and worstEntry are nullable GradeEntry?
      buf.writeln(
          '  Best Assessment  : ${student.bestEntry?.assessment.title ?? "N/A"}');
      buf.writeln(
          '  Weakest          : ${student.worstEntry?.assessment.title ?? "N/A"}');
    }

    buf.writeln(sep);
    return buf.toString();
  }
}
