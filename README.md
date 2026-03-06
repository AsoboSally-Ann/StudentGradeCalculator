# Student Grade Calculator — Dart Multi-File Edition

A fully structured Dart desktop application demonstrating:
- **Abstract classes & concrete subclasses** linked across multiple files
- **Nullable types** (`double?`, `String?`) with Elvis (`??`) and safe calls (`?.`)
- **Data-class pattern** (`copyWith` / `==` / `hashCode`) on every leaf class
- **Interface abstraction** via abstract classes (`Gradable`, `Reportable`)

---

## Project Structure

```
grade_calculator/
├── pubspec.yaml
├── bin/
│   └── main.dart                      ← Entry point
└── lib/
    ├── interfaces/
    │   ├── gradable.dart              ← Abstract interface: percentage, letterGrade, gpaPoints
    │   └── reportable.dart            ← Abstract interface: buildReport(), printReport()
    ├── models/
    │   ├── assessment.dart            ← Assessment (abstract) → WrittenAssessment | PracticalAssessment
    │   ├── grade_entry.dart           ← GradeEntry (implements Gradable, wraps Assessment + nullable score)
    │   ├── person.dart                ← Person (abstract) → Instructor
    │   ├── student.dart               ← Student (abstract) → UndergraduateStudent | PostgraduateStudent
    │   └── course.dart                ← Course (links Instructor + Students + Assessments)
    ├── reports/
    │   ├── course_report.dart         ← CourseReport (implements Reportable) — one student
    │   └── class_report.dart          ← ClassReport  (implements Reportable) — whole class
    ├── services/
    │   ├── grade_book.dart            ← GradeBook — top-level service (owns all entities)
    │   └── demo_data.dart             ← Pre-built demo GradeBook factory
    └── cli/
        └── grade_calculator_cli.dart  ← Interactive terminal UI
```

---

## Class Hierarchy

```
Gradable  (abstract interface — lib/interfaces/gradable.dart)
  ├─ Assessment  (abstract — lib/models/assessment.dart)
  │    ├─ WrittenAssessment      isExam: bool
  │    └─ PracticalAssessment    isGroupWork: bool
  ├─ GradeEntry                  (lib/models/grade_entry.dart)
  │    score: double?   ← nullable
  └─ Student  (abstract — lib/models/student.dart)
       ├─ UndergraduateStudent   yearOfStudy, enrolmentYear
       └─ PostgraduateStudent    researchArea, supervisorId?  ← nullable

Person  (abstract — lib/models/person.dart)
  ├─ Student   (see above)
  └─ Instructor                  department, officeRoom?  ← nullable

Reportable  (abstract interface — lib/interfaces/reportable.dart)
  ├─ CourseReport                (lib/reports/course_report.dart)
  └─ ClassReport                 (lib/reports/class_report.dart)

Course         (lib/models/course.dart)       — links Instructor? + Students + Assessments
GradeBook      (lib/services/grade_book.dart) — top-level service
GradeCalculatorCLI  (lib/cli/grade_calculator_cli.dart)
```

---

## How to Run

```bash
# Interactive CLI (starts with pre-loaded demo data)
dart run bin/main.dart

# Non-interactive: print all class reports and exit
dart run bin/main.dart --demo
```

---

## Key Dart Features Demonstrated

| Feature | Where |
|---|---|
| `double? score` — nullable field | `GradeEntry`, `Student` subclasses |
| `score?.toStringAsFixed(1) ?? 'N/A'` — safe call + Elvis | `GradeEntry.toString()` |
| `email ?? "not provided"` — Elvis fallback | Every report class |
| `supervisorId: supId.isEmpty ? null : supId` — Elvis assignment | CLI & demo data |
| Abstract class as interface | `Gradable`, `Reportable` |
| `implements` across class trees | `Student implements Gradable` |
| `copyWith` data-class pattern | All leaf classes |
| Subclass runtime check (`is`) | `CourseReport`, `ClassReport`, `GradeBook` |
| Subclass-specific `copyWith` routing | `GradeBook.updateGrade()` |
