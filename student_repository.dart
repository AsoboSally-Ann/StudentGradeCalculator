// ============================================================
//  student_repository.dart
//  CRUD operations and ID generation for students
// ============================================================

import 'models.dart';
import 'grade_calculator_service.dart';

// ─────────────────────────────────────────────────────────────
// STUDENT MANAGER — uses Repository<Student>
// ─────────────────────────────────────────────────────────────
class StudentManager {
  final Repository<Student> _repo = Repository<Student>();
  int _idCounter = 1;

  // ── ID generation: ICTU2023XXX ─────────────────────────────
  String generateId() {
    _syncCounter();
    final seq = _idCounter.toString().padLeft(3, '0');
    _idCounter++;
    return 'ICTU2023$seq';
  }

  void _syncCounter() {
    for (final s in _repo.getAll()) {
      final suffix = s.id.replaceFirst('ICTU2023', '');
      final n = int.tryParse(suffix);
      if (n != null && n >= _idCounter) _idCounter = n + 1;
    }
  }

  // ── ADD ────────────────────────────────────────────────────
  String? addStudent({
    String? id,
    required String name,
    String? email,
    List<GradeEntry>? grades,
  }) {
    final studentId = (id != null && id.trim().isNotEmpty) ? id.trim() : generateId();

    final idError = GradeValidator.validateStudentId(studentId);
    if (idError != null) return idError;

    final nameError = GradeValidator.validateName(name);
    if (nameError != null) return nameError;

    final exists = _repo.findOrNull((s) => s.id == studentId);
    if (exists != null) return 'Student $studentId already exists';

    final trimmedEmail = email?.trim();
    _repo.add(Student(
      id: studentId,
      name: name.trim(),
      email: (trimmedEmail != null && trimmedEmail.isNotEmpty) ? trimmedEmail : null,
      grades: grades,
    ));
    return null;
  }

  // ── DELETE ─────────────────────────────────────────────────
  bool deleteStudent(String id) => _repo.remove((s) => s.id == id);

  // ── READ ───────────────────────────────────────────────────
  List<Student> getAllStudents() => _repo.getAll();

  Student? findById(String id) => _repo.findOrNull((s) => s.id == id);

  int get count => _repo.count;

  // ── ADD GRADE TO STUDENT ───────────────────────────────────
  String? addGradeToStudent(String studentId, GradeEntry entry) {
    final student = findById(studentId);
    if (student == null) return 'Student $studentId not found';
    final scoreError = GradeValidator.validateScore(entry.score);
    if (scoreError != null) return scoreError;
    student.addGrade(entry);
    return null;
  }

  // ── CALCULATE SINGLE ───────────────────────────────────────
  GradeResult? calculateSingle(String studentId) {
    final student = findById(studentId);
    return student != null ? StudentGradeCalculator.calculate(student) : null;
  }

  // ── CALCULATE ALL ──────────────────────────────────────────
  List<GradeResult> calculateAll() =>
      StudentGradeCalculator.calculateAll(_repo.getAll());

  // ── STATISTICS ─────────────────────────────────────────────
  ClassStatistics getStatistics() => ClassStatistics.from(calculateAll());

  // ── LOAD from JSON list ────────────────────────────────────
  void loadFromJsonList(List<Map<String, dynamic>> jsonList) {
    for (final json in jsonList) {
      try {
        final student = Student.fromJson(json);
        if (Student.isValidId(student.id) && findById(student.id) == null) {
          _repo.add(student);
        }
      } catch (_) {
        // skip malformed entries
      }
    }
    _syncCounter();
  }

  // ── EXPORT to JSON list ────────────────────────────────────
  List<Map<String, dynamic>> exportToJsonList() =>
      getAllStudents().map((s) => s.toJson()).toList();
}
