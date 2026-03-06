// lib/services/grade_book.dart
// =============================================================================
//  GRADEBOOK  — top-level service
//
//  Owns all Courses, Students, and Instructors in the system.
//  Provides registration, safe lookups (returning null on miss),
//  grade updates (routing through correct subclass copyWith),
//  and report printing.
// =============================================================================

import 'package:grade_calculator/models/assessment.dart';
import 'package:grade_calculator/models/course.dart';
import 'package:grade_calculator/models/grade_entry.dart';
import 'package:grade_calculator/models/person.dart';
import 'package:grade_calculator/models/student.dart';

class GradeBook {
  final List<Course>     _courses     = [];
  final List<Student>    _students    = [];
  final List<Instructor> _instructors = [];

  // ── Registration ──────────────────────────────────────────────────

  void registerCourse(Course course)        => _courses.add(course);
  void registerStudent(Student student)     => _students.add(student);
  void registerInstructor(Instructor instr) => _instructors.add(instr);

  // ── Safe lookups (return null on miss) ────────────────────────────
  // Callers use safe calls (?.) on the returned nullable value.

  Course? findCourse(String code) {
    try { return _courses.firstWhere((c) => c.code == code); }
    catch (_) { return null; }
  }

  Student? findStudent(String id) {
    try { return _students.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }

  Instructor? findInstructor(String id) {
    try { return _instructors.firstWhere((i) => i.id == id); }
    catch (_) { return null; }
  }

  // ── Grade update ───────────────────────────────────────────────────

  /// Sets (or clears via null) a student's score on a named assessment.
  /// Returns true on success, false when student or assessment is not found.
  bool updateGrade({
    required String studentId,
    required String assessmentTitle,
    required double? newScore, // nullable: null = clear / unsubmit the grade
  }) {
    final sIdx = _students.indexWhere((s) => s.id == studentId);
    if (sIdx == -1) {
      print('⚠  Student "$studentId" not found.');
      return false;
    }

    final s = _students[sIdx];
    final gIdx = s.grades.indexWhere(
        (g) => g.assessment.title.toLowerCase() == assessmentTitle.toLowerCase());

    if (gIdx == -1) {
      print('⚠  Assessment "$assessmentTitle" not found for ${s.fullName}.');
      return false;
    }

    // Build updated GradeEntry using data-class copyWith
    final updated = s.grades[gIdx].copyWith(
      score: newScore,
      clearScore: newScore == null,
    );
    final updatedList = List<GradeEntry>.from(s.grades)..[gIdx] = updated;

    // Route to the correct subclass copyWith to preserve subclass fields
    if (s is UndergraduateStudent) {
      _students[sIdx] = s.copyWith(grades: updatedList);
    } else if (s is PostgraduateStudent) {
      _students[sIdx] = s.copyWith(grades: updatedList);
    }

    print('✓  ${s.fullName} — "$assessmentTitle": '
        '${newScore?.toStringAsFixed(1) ?? "cleared (null)"}');
    return true;
  }

  // ── Reporting shortcuts ────────────────────────────────────────────

  void printAllClassReports() {
    if (_courses.isEmpty) { print('No courses in GradeBook.'); return; }
    for (final c in _courses) {
      c.classReport().printReport();
    }
  }

  // ── Read-only accessors ────────────────────────────────────────────

  List<Course>     get courses     => List.unmodifiable(_courses);
  List<Student>    get students    => List.unmodifiable(_students);
  List<Instructor> get instructors => List.unmodifiable(_instructors);
}
