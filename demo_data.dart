// lib/services/demo_data.dart
// =============================================================================
//  DEMO DATA FACTORY
//
//  Builds a pre-populated GradeBook with:
//    · 2 Instructors  (one with nullable email and office, one fully filled)
//    · 4 Students     (2 Undergraduate, 2 Postgraduate)
//    · 2 Courses      (CS101 and MTH201)
//    · Intentional null scores and null fields to demonstrate nullable handling
// =============================================================================

import 'package:grade_calculator/models/assessment.dart';
import 'package:grade_calculator/models/course.dart';
import 'package:grade_calculator/models/grade_entry.dart';
import 'package:grade_calculator/models/person.dart';
import 'package:grade_calculator/models/student.dart';
import 'package:grade_calculator/services/grade_book.dart';

GradeBook buildDemo() {
  final book = GradeBook();

  // ── Instructors ────────────────────────────────────────────────────
  final drAdeyemi = Instructor(
    id: 'I001',
    firstName: 'Kofi',
    lastName: 'Adeyemi',
    email: 'k.adeyemi@univ.cm',
    department: 'Computer Science',
    officeRoom: 'B204',
  );
  final drNwosu = Instructor(
    id: 'I002',
    firstName: 'Amaka',
    lastName: 'Nwosu',
    email: null,         // nullable — adjunct with no official email
    department: 'Mathematics',
    officeRoom: null,    // nullable — no dedicated office
  );
  book.registerInstructor(drAdeyemi);
  book.registerInstructor(drNwosu);

  // ── Assessment blueprints ──────────────────────────────────────────
  final csAssessments = <Assessment>[
    WrittenAssessment(title: 'Midterm Exam', maxScore: 100, weight: 0.30, isExam: true),
    WrittenAssessment(title: 'Quiz 1',       maxScore: 50,  weight: 0.10, isExam: false),
    PracticalAssessment(title: 'Lab Project',maxScore: 100, weight: 0.35, isGroupWork: true),
    WrittenAssessment(title: 'Final Exam',   maxScore: 100, weight: 0.25, isExam: true),
  ];
  final mathAssessments = <Assessment>[
    WrittenAssessment(title: 'Assignment 1', maxScore: 40,  weight: 0.20, isExam: false),
    WrittenAssessment(title: 'Midterm',      maxScore: 100, weight: 0.35, isExam: true),
    PracticalAssessment(title: 'Coursework', maxScore: 60,  weight: 0.20, isGroupWork: false),
    WrittenAssessment(title: 'Final Exam',   maxScore: 100, weight: 0.25, isExam: true),
  ];

  // ── Students ───────────────────────────────────────────────────────

  // UG — Alice: 3 graded, 1 null (Lab not yet submitted)
  final alice = UndergraduateStudent(
    id: 'S001', firstName: 'Alice', lastName: 'Kamara',
    email: 'alice@univ.cm', yearOfStudy: 2, enrolmentYear: 2023,
    grades: [
      GradeEntry(assessment: csAssessments[0], score: 88),
      GradeEntry(assessment: csAssessments[1], score: 44),
      GradeEntry(assessment: csAssessments[2], score: null), // nullable — not submitted
      GradeEntry(assessment: csAssessments[3], score: 91),
    ],
  );

  // UG — Bob: nullable email, 1 null score (Final Exam pending)
  final bob = UndergraduateStudent(
    id: 'S002', firstName: 'Bob', lastName: 'Nkemdirim',
    email: null,          // nullable
    yearOfStudy: 1, enrolmentYear: 2024,
    grades: [
      GradeEntry(assessment: csAssessments[0], score: 52),
      GradeEntry(assessment: csAssessments[1], score: 28),
      GradeEntry(assessment: csAssessments[2], score: 65),
      GradeEntry(assessment: csAssessments[3], score: null), // nullable — pending
    ],
  );

  // PG — Clara: has supervisor, 1 null score
  final clara = PostgraduateStudent(
    id: 'S003', firstName: 'Clara', lastName: 'Osei',
    email: 'clara@univ.cm', researchArea: 'Distributed Systems',
    supervisorId: 'I001', enrolmentYear: 2022,
    grades: [
      GradeEntry(assessment: mathAssessments[0], score: 38),
      GradeEntry(assessment: mathAssessments[1], score: 92),
      GradeEntry(assessment: mathAssessments[2], score: null), // nullable
      GradeEntry(assessment: mathAssessments[3], score: 89),
    ],
  );

  // PG — David: nullable email, nullable supervisorId, ALL scores null
  final david = PostgraduateStudent(
    id: 'S004', firstName: 'David', lastName: 'Fofana',
    email: null,           // nullable
    researchArea: 'AI & Neural Networks',
    supervisorId: null,    // nullable — not yet assigned
    enrolmentYear: 2024,
    grades: [
      GradeEntry(assessment: mathAssessments[0], score: null),
      GradeEntry(assessment: mathAssessments[1], score: null),
      GradeEntry(assessment: mathAssessments[2], score: null),
      GradeEntry(assessment: mathAssessments[3], score: null),
    ],
  );

  book.registerStudent(alice);
  book.registerStudent(bob);
  book.registerStudent(clara);
  book.registerStudent(david);

  // ── Courses ────────────────────────────────────────────────────────
  book.registerCourse(Course(
    code: 'CS101', name: 'Introduction to Programming',
    semester: '2025/S1', instructor: drAdeyemi,
    students: [alice, bob], assessments: csAssessments,
  ));
  book.registerCourse(Course(
    code: 'MTH201', name: 'Advanced Mathematics',
    semester: '2025/S1', instructor: drNwosu,
    students: [clara, david], assessments: mathAssessments,
  ));

  return book;
}
