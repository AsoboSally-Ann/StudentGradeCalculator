// lib/models/course.dart
// =============================================================================
//  COURSE
//
//  Links together:
//    · Instructor?         (nullable — may not yet be assigned)
//    · List<Student>       (enrolled students)
//    · List<Assessment>    (the assessment blueprint for this course)
//
//  Course is the central hub that connects the Person hierarchy,
//  the Assessment hierarchy, and the Report hierarchy.
//  It exposes factory methods to generate Reportable objects.
// =============================================================================

import 'package:grade_calculator/reports/class_report.dart';
import 'package:grade_calculator/reports/course_report.dart';
import 'package:grade_calculator/models/assessment.dart';
import 'package:grade_calculator/models/person.dart';
import 'package:grade_calculator/models/student.dart';

class Course {
  final String code;
  final String name;
  final String semester;
  final Instructor? instructor; // nullable — may not be assigned yet
  final List<Student> students;
  final List<Assessment> assessments;

  Course({
    required this.code,
    required this.name,
    required this.semester,
    this.instructor,          // nullable
    this.students    = const [],
    this.assessments = const [],
  });

  // Data-class: copyWith
  Course copyWith({
    String? code,
    String? name,
    String? semester,
    Instructor? instructor,
    bool clearInstructor = false,
    List<Student>? students,
    List<Assessment>? assessments,
  }) =>
      Course(
        code:        code             ?? this.code,
        name:        name             ?? this.name,
        semester:    semester         ?? this.semester,
        instructor:  clearInstructor  ? null : (instructor ?? this.instructor),
        students:    students         ?? this.students,
        assessments: assessments      ?? this.assessments,
      );

  /// Factory: build an individual CourseReport for one student.
  CourseReport reportFor(Student student) =>
      CourseReport(student: student, course: this);

  /// Factory: build the full ClassReport for this course.
  ClassReport classReport() => ClassReport(course: this);

  @override
  bool operator ==(Object o) =>
      o is Course && o.code == code && o.semester == semester;

  @override
  int get hashCode => Object.hash(code, semester);

  @override
  String toString() => 'Course[$code] $name ($semester)';
}
