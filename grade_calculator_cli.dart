// lib/cli/grade_calculator_cli.dart
// =============================================================================
//  GRADE CALCULATOR CLI
//
//  Interactive terminal UI that drives the GradeBook service.
//  Demonstrates:
//    · Safe calls (?.) on nullable lookups (findStudent, findCourse)
//    · Elvis (??) to convert blank input to null (nullable email, score, etc.)
//    · Subclass branching when creating UG vs PG students
// =============================================================================

import 'dart:io';

import 'package:grade_calculator/models/assessment.dart';
import 'package:grade_calculator/models/course.dart';
import 'package:grade_calculator/models/grade_entry.dart';
import 'package:grade_calculator/models/student.dart';
import 'package:grade_calculator/services/grade_book.dart';

class GradeCalculatorCLI {
  final GradeBook gradeBook;

  GradeCalculatorCLI(this.gradeBook);

  // ── I/O helpers ───────────────────────────────────────────────────

  String _prompt(String msg) {
    stdout.write(msg);
    return stdin.readLineSync()?.trim() ?? '';
  }

  double? _promptDouble(String msg, {bool nullable = false}) {
    while (true) {
      final raw = _prompt(msg);
      if (raw.isEmpty && nullable) return null; // Elvis: blank → null
      final v = double.tryParse(raw);
      if (v != null && v >= 0) return v;
      print('  ⚠  Enter a valid non-negative number'
          '${nullable ? " (or blank to skip)" : ""}.');
    }
  }

  int _promptInt(String msg, {int min = 1, int max = 100}) {
    while (true) {
      final raw = _prompt(msg);
      final v = int.tryParse(raw);
      if (v != null && v >= min && v <= max) return v;
      print('  ⚠  Enter an integer between $min and $max.');
    }
  }

  // ── Main loop ──────────────────────────────────────────────────────

  void run() {
    _banner();
    while (true) {
      _menu();
      switch (_prompt('Choice: ')) {
        case '1': _addCourse();    break;
        case '2': _addStudent();   break;
        case '3': _updateGrade();  break;
        case '4': _viewStudent();  break;
        case '5': _printReports(); break;
        case '6': print('\nGoodbye! 👋\n'); return;
        default:  print('  ⚠  Invalid choice.\n');
      }
    }
  }

  // ── UI chrome ──────────────────────────────────────────────────────

  void _banner() => print('''
╔══════════════════════════════════════════════════════════════╗
║   STUDENT GRADE CALCULATOR  ·  Dart Multi-File Edition       ║
║   Classes & Subclasses · Nullable · Elvis · Safe Calls       ║
╚══════════════════════════════════════════════════════════════╝
''');

  void _menu() => print('''
  ┌─ MENU ──────────────────────────────────┐
  │  1. Add course                          │
  │  2. Add student (UG or PG)              │
  │  3. Update a grade                      │
  │  4. View student report                 │
  │  5. Print all class reports             │
  │  6. Exit                                │
  └─────────────────────────────────────────┘''');

  // ── Option: Add Course ─────────────────────────────────────────────

  void _addCourse() {
    print('\n── Add Course ──────────────────────────────────');
    final code     = _prompt('  Course code   : ');
    final name     = _prompt('  Course name   : ');
    final semester = _prompt('  Semester      : ');
    if (code.isEmpty || name.isEmpty) {
      print('  ⚠  Code and name are required.\n'); return;
    }

    final assessments = <Assessment>[];
    print('  Add assessments (blank title to finish):');

    while (true) {
      final title = _prompt('    Title                       : ');
      if (title.isEmpty) break;

      final type  = _prompt('    Type (w=written, p=practical): ').toLowerCase();
      final max   = _promptDouble('    Max score                  : ') ?? 100.0;
      final wt    = _promptDouble('    Weight (e.g. 0.30)         : ') ?? 0.25;

      if (type == 'p') {
        final grp = _prompt('    Group work? (y/n)           : ').toLowerCase() == 'y';
        assessments.add(
            PracticalAssessment(title: title, maxScore: max, weight: wt, isGroupWork: grp));
      } else {
        final exam = _prompt('    Exam(y) or Quiz(n)?         : ').toLowerCase() == 'y';
        assessments.add(
            WrittenAssessment(title: title, maxScore: max, weight: wt, isExam: exam));
      }
      print('    ✓  Assessment added.');
    }

    gradeBook.registerCourse(
        Course(code: code, name: name, semester: semester, assessments: assessments));
    print('  ✓  Course "$name" registered.\n');
  }

  // ── Option: Add Student ────────────────────────────────────────────

  void _addStudent() {
    print('\n── Add Student ─────────────────────────────────');
    if (gradeBook.courses.isEmpty) {
      print('  ⚠  Add a course first.\n'); return;
    }

    final type  = _prompt('  (u)ndergraduate or (p)ostgraduate? ').toLowerCase();
    final id    = _prompt('  Student ID      : ');
    final first = _prompt('  First name      : ');
    final last  = _prompt('  Last name       : ');
    final email = _prompt('  Email (blank=null): ');
    // Elvis: blank input → null (nullable email)
    final String? emailVal = email.isEmpty ? null : email;

    print('\n  Available courses:');
    for (final c in gradeBook.courses) print('    ${c.code}  ${c.name}');

    final cCode  = _prompt('  Enrol in course : ');
    final course = gradeBook.findCourse(cCode); // returns null on miss

    if (course == null) { // safe call: guard against null course
      print('  ⚠  Course not found.\n'); return;
    }

    // Build GradeEntry list from the course's assessment blueprints
    final grades = <GradeEntry>[];
    print('\n  Enter scores (blank = not yet graded / null):');
    for (final a in course.assessments) {
      print('    ${a.category}: "${a.title}" (max ${a.maxScore})');
      // nullable: blank input maps to null via Elvis
      final score = _promptDouble('    Score: ', nullable: true);
      grades.add(GradeEntry(assessment: a, score: score));
    }

    late Student student;
    if (type == 'p') {
      final area  = _prompt('  Research area        : ');
      final supId = _prompt('  Supervisor ID (blank=null): ');
      final enrol = _promptInt('  Enrolment year       : ', min: 2000, max: 2099);
      student = PostgraduateStudent(
        id: id, firstName: first, lastName: last, email: emailVal,
        grades: grades, researchArea: area,
        supervisorId: supId.isEmpty ? null : supId, // Elvis: blank → null
        enrolmentYear: enrol,
      );
    } else {
      final year  = _promptInt('  Year of study (1-4)  : ', min: 1, max: 4);
      final enrol = _promptInt('  Enrolment year       : ', min: 2000, max: 2099);
      student = UndergraduateStudent(
        id: id, firstName: first, lastName: last, email: emailVal,
        grades: grades, yearOfStudy: year, enrolmentYear: enrol,
      );
    }

    gradeBook.registerStudent(student);
    print('  ✓  ${student.role} "${student.fullName}" registered.\n');
  }

  // ── Option: Update Grade ────────────────────────────────────────────

  void _updateGrade() {
    print('\n── Update Grade ────────────────────────────────');
    final sid   = _prompt('  Student ID          : ');
    final title = _prompt('  Assessment title    : ');
    // nullable: blank → null (clears the grade)
    final score = _promptDouble('  New score (blank=null/clear): ', nullable: true);
    gradeBook.updateGrade(studentId: sid, assessmentTitle: title, newScore: score);
    print('');
  }

  // ── Option: View Student Report ─────────────────────────────────────

  void _viewStudent() {
    print('\n── Student Report ──────────────────────────────');
    final sid = _prompt('  Student ID: ');
    final s   = gradeBook.findStudent(sid); // returns null on miss

    if (s == null) { // safe call guard
      print('  ⚠  Student not found.\n'); return;
    }

    // Find which course this student belongs to (safe call + Elvis orElse)
    final course = gradeBook.courses.cast<Course?>().firstWhere(
      (c) => c!.students.any((st) => st.id == sid),
      orElse: () => null,
    );

    // Elvis: if no course found, build a temporary shell
    final reportCourse = course ??
        Course(code: 'N/A', name: 'Unassigned', semester: '-', students: [s]);

    reportCourse.reportFor(s).printReport();
  }

  // ── Option: Print All Reports ───────────────────────────────────────

  void _printReports() => gradeBook.printAllClassReports();
}
