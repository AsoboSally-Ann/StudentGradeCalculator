// ============================================================
//  main.dart  —  Entry point
//
//  HOW TO RUN (terminal in VS Code):
//    dart run main.dart
//
//  DO NOT use the Code Runner extension play button on this file —
//  it creates a tempCodeRunnerFile.dart which breaks multi-file imports.
//  Always run from the terminal with: dart run main.dart
// ============================================================

import 'models.dart';
import 'grade_calculator_service.dart';
import 'student_repository.dart';
import 'excel_service.dart';

void main() {
  final manager = StudentManager();

  // ── 1. Add 20 pre-seeded students with ICTU2023XXX IDs ────
  _section('1. Adding Students');

  final preset = [
    ('Kemi Okonkwo', 'kemi.okonkwo@ict.edu', [90.0, 88.0, 92.0, 85.5, 91.0]),
    ('Liam Otieno', 'liam.otieno@ict.edu', [67.0, 63.5, 71.0, 65.0, 69.0]),
    ('Mercy Banda', 'mercy.banda@ict.edu', [83.0, 85.0, 79.0, 88.0, 82.0]),
    (
      'Nathan Dlamini',
      'nathan.dlamini@ict.edu',
      [57.0, 54.0, 61.0, 58.0, 55.5]
    ),
    ('Olivia Mensah', 'olivia.mensah@ict.edu', [93.5, 90.0, 94.0, 88.5, 92.0]),
    ('Paul Chukwu', 'paul.chukwu@ict.edu', [74.0, 78.0, 72.0, 80.0, 76.0]),
    (
      'Queen Nakamura',
      'queen.nakamura@ict.edu',
      [38.0, 42.0, 36.5, 35.0, 40.0]
    ),
    (
      'Robert Egwuatu',
      'robert.egwuatu@ict.edu',
      [86.0, 84.0, 88.5, 81.0, 87.0]
    ),
    ('Sarah Wanjiku', 'sarah.wanjiku@ict.edu', [69.0, 72.0, 66.0, 71.0, 64.5]),
    ('Tunde Afolabi', 'tunde.afolabi@ict.edu', [77.0, 74.5, 80.0, 72.0, 78.5]),
  ];

  final subjects = ExcelConfig.subjects;
  int idNum = 1;

  for (final (name, email, scores) in preset) {
    final id = 'ICTU2023${idNum.toString().padLeft(3, '0')}';
    idNum++;

    _check(manager.addStudent(id: id, name: name, email: email));

    final grades = <GradeEntry>[
      for (int i = 0; i < subjects.length; i++)
        GradeEntry(subject: subjects[i], score: scores[i]),
    ];
    for (final g in grades) {
      manager.addGradeToStudent(id, g);
    }
  }
  print('Total students added: ${manager.count}');

  // ── 2. Calculate a single student ────────────────────────
  _section('2. Single Student Calculation — Alice Mbeki');
  final result = manager.calculateSingle('ICTU2023001');
  print(result?.toString() ?? 'Student not found');
  print('\nSubject Breakdown:');
  result?.subjectBreakdown.forEach((subj, score) {
    print('  ${subj.padRight(20)} $score');
  });

  // ── 3. Bulk calculate ALL students ───────────────────────
  _section('3. Bulk Calculate All 20 Students');
  final allResults = manager.calculateAll();
  for (final r in allResults) {
    print(r);
  }

  // ── 4. Class statistics ──────────────────────────────────
  _section('4. Class Statistics');
  final stats = manager.getStatistics();
  print('Total students : ${stats.totalStudents}');
  print('With grades    : ${stats.submittedCount}');
  print('Class average  : ${stats.classAverageLabel}%');
  print('Pass / Fail    : ${stats.passCount} / ${stats.failCount}');
  print('\nGrade Distribution:');
  stats.gradeDistribution.forEach((grade, cnt) {
    final bar = '█' * cnt;
    print('  $grade  $bar ($cnt)');
  });

  // ── 5. Add a new student manually ───────────────────────
  _section('5. Add New Student');
  _check(manager.addStudent(
    name: 'Zara Mensah',
    email: 'zara.mensah@ict.edu',
  ));
  final zara = manager.findById('ICTU2023021');
  print('Auto-generated ID: ${zara?.id ?? 'not found'}');

  // ── 6. Delete a student ──────────────────────────────────
  _section('6. Delete Student (Bob Tshuma - ICTU2023002)');
  final deleted = manager.deleteStudent('ICTU2023002');
  print('Deleted: $deleted  |  Remaining: ${manager.count}');

  // ── 7. Excel export preview ──────────────────────────────
  _section('7. Excel Export Row Preview');
  final exportRows = ExcelExportService.buildExportRows(
    manager.getAllStudents().take(5).toList(),
    allResults,
  );
  for (final row in exportRows) {
    print('  ${row['Student ID']} | ${row['Full Name']} | '
        'Avg: ${row['Average (%)']}% | ${row['Letter Grade']} | ${row['Status']}');
  }

  // ── 8. Excel import simulation ───────────────────────────
  _section('8. Excel Import Simulation');
  final importResult = ExcelImportService.parseJsonRows([
    {
      'Student ID': 'ICTU2023099',
      'Full Name': 'Diana Prince',
      'Email': 'diana@ict.edu',
      'Algorithms': '80',
      'Data Structures': '75',
      'OS Concepts': '85',
      'Database': '90',
      'Networks': '78',
    },
    {
      'Student ID': 'BADID123', // invalid — should be rejected
      'Full Name': 'Ghost User',
    },
  ]);
  print('Imported: ${importResult.successCount} student(s)');
  if (importResult.hasErrors) {
    for (final e in importResult.errors) print('  ⚠  $e');
  }
  manager.loadFromJsonList(
    importResult.students.map((s) => s.toJson()).toList(),
  );
  print('Manager total after import: ${manager.count}');
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────
void _section(String title) {
  print('\n${'═' * 60}');
  print('  $title');
  print('${'═' * 60}');
}

void _check(String? error) {
  if (error != null) {
    print('  ⚠  $error');
  } else {
    print('  ✓  OK');
  }
}
