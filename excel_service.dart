// ============================================================
//  excel_service.dart
//  Excel import / export logic
//  Add to pubspec.yaml:  excel: ^4.0.6
// ============================================================

import 'models.dart';
import 'grade_calculator_service.dart';

// ─────────────────────────────────────────────────────────────
// SUBJECTS — single source of truth
// ─────────────────────────────────────────────────────────────
class ExcelConfig {
  static const List<String> subjects = [
    'Algorithms',
    'Data Structures',
    'OS Concepts',
    'Database',
    'Networks',
  ];

  static const List<String> headers = [
    'Student ID',
    'Full Name',
    'Email',
    'Algorithms',
    'Data Structures',
    'OS Concepts',
    'Database',
    'Networks',
    'Average (%)',
    'Letter Grade',
    'GPA',
    'Status',
  ];
}

// ─────────────────────────────────────────────────────────────
// EXCEL ROW MODEL
// ─────────────────────────────────────────────────────────────
class ExcelRow {
  final String studentId;
  final String name;
  final String? email;
  final Map<String, double?> subjectScores;

  const ExcelRow({
    required this.studentId,
    required this.name,
    this.email,
    required this.subjectScores,
  });

  Student toStudent() => Student(
        id: studentId,
        name: name,
        email: email,
        grades: ExcelConfig.subjects
            .map((s) => GradeEntry(subject: s, score: subjectScores[s]))
            .toList(),
      );

  static ExcelRow fromStudentResult(Student s, GradeResult r) {
    final scoreMap = <String, double?>{};
    for (final subject in ExcelConfig.subjects) {
      final grade = s.grades
          .cast<GradeEntry?>()
          .firstWhere((g) => g?.subject == subject, orElse: () => null);
      scoreMap[subject] = grade?.score;
    }
    return ExcelRow(
      studentId: s.id,
      name: s.name,
      email: s.email,
      subjectScores: scoreMap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// IMPORT SERVICE
// ─────────────────────────────────────────────────────────────
class ExcelImportService {
  static ImportResult parseJsonRows(List<Map<String, dynamic>> rows) {
    final students = <Student>[];
    final errors = <String>[];

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final id = row['Student ID']?.toString().trim() ?? '';
      final name = row['Full Name']?.toString().trim() ?? '';

      if (!Student.isValidId(id)) {
        errors.add('Row ${i + 2}: Invalid ID "$id" — skipped');
        continue;
      }
      if (name.isEmpty) {
        errors.add('Row ${i + 2}: Empty name — skipped');
        continue;
      }

      final grades = <GradeEntry>[];
      for (final subject in ExcelConfig.subjects) {
        final raw = row[subject];
        final score = (raw == null || raw.toString().trim().isEmpty)
            ? null
            : double.tryParse(raw.toString());
        final safe = score != null
            ? clampOrDefault<double>(score, 0, 100, 0)
            : null;
        grades.add(GradeEntry(subject: subject, score: safe));
      }

      final emailRaw = row['Email']?.toString().trim();
      students.add(Student(
        id: id,
        name: name,
        email: (emailRaw != null && emailRaw.isNotEmpty) ? emailRaw : null,
        grades: grades,
      ));
    }

    return ImportResult(students: students, errors: errors);
  }
}

// ─────────────────────────────────────────────────────────────
// EXPORT SERVICE
// ─────────────────────────────────────────────────────────────
class ExcelExportService {
  static List<Map<String, dynamic>> buildExportRows(
    List<Student> students,
    List<GradeResult> results,
  ) {
    final resultMap = {for (final r in results) r.studentId: r};
    final rows = <Map<String, dynamic>>[];

    for (final student in students) {
      final result = resultMap[student.id];
      final row = <String, dynamic>{
        'Student ID': student.id,
        'Full Name': student.name,
        'Email': student.displayEmail,
      };

      for (final subject in ExcelConfig.subjects) {
        final grade = student.grades
            .cast<GradeEntry?>()
            .firstWhere((g) => g?.subject == subject, orElse: () => null);
        row[subject] = grade?.score ?? '';
      }

      row['Average (%)'] = result?.averageLabel ?? 'N/A';
      row['Letter Grade'] = result?.letterGrade ?? 'N/A';
      row['GPA'] = result?.gpa.toStringAsFixed(1) ?? 'N/A';
      row['Status'] = result?.status ?? 'N/A';

      rows.add(row);
    }
    return rows;
  }
}

// ─────────────────────────────────────────────────────────────
// IMPORT RESULT
// ─────────────────────────────────────────────────────────────
class ImportResult {
  final List<Student> students;
  final List<String> errors;

  const ImportResult({required this.students, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => students.length;
}
