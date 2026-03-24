// ============================================================
//  models.dart
//  Data classes, Generics, and Repository
//  No external imports needed — fully self-contained
// ============================================================

// ─────────────────────────────────────────────────────────────
// GENERIC REPOSITORY  (class generic)
// ─────────────────────────────────────────────────────────────
class Repository<T> {
  final List<T> _items = [];

  void add(T item) => _items.add(item);

  bool remove(bool Function(T) predicate) {
    final index = _items.indexWhere(predicate);
    if (index == -1) return false;
    _items.removeAt(index);
    return true;
  }

  List<T> getAll() => List.unmodifiable(_items);

  T? findOrNull(bool Function(T) predicate) {
    try {
      return _items.firstWhere(predicate);
    } catch (_) {
      return null;
    }
  }

  void updateWhere(bool Function(T) predicate, T Function(T) updater) {
    final index = _items.indexWhere(predicate);
    if (index != -1) _items[index] = updater(_items[index]);
  }

  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
}

// ─────────────────────────────────────────────────────────────
// GENERIC FUNCTIONS
// ─────────────────────────────────────────────────────────────
double? average<T extends num>(List<T?> values) {
  final nonNull = values.whereType<T>().toList();
  if (nonNull.isEmpty) return null;
  return nonNull.reduce((a, b) => (a + b) as T) / nonNull.length;
}

T clampOrDefault<T extends num>(T? value, T min, T max, T defaultValue) {
  if (value == null) return defaultValue;
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

double sanitizeScore(double? raw) =>
    clampOrDefault<double>(raw ?? 0, 0, 100, 0);

// ─────────────────────────────────────────────────────────────
// DATA CLASS — GradeEntry  (immutable)
// ─────────────────────────────────────────────────────────────
class GradeEntry {
  final String subject;
  final double? score;
  final double maxScore;

  const GradeEntry({
    required this.subject,
    this.score,
    this.maxScore = 100.0,
  });

  double get percentage => ((score ?? 0) / maxScore) * 100;
  String get scoreLabel => score?.toStringAsFixed(1) ?? 'N/A';

  GradeEntry copyWith({String? subject, double? score, double? maxScore}) =>
      GradeEntry(
        subject: subject ?? this.subject,
        score: score ?? this.score,
        maxScore: maxScore ?? this.maxScore,
      );

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'score': score,
        'maxScore': maxScore,
      };

  factory GradeEntry.fromJson(Map<String, dynamic> json) => GradeEntry(
        subject: json['subject'] as String,
        score: (json['score'] as num?)?.toDouble(),
        maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
      );

  @override
  bool operator ==(Object other) =>
      other is GradeEntry &&
      subject == other.subject &&
      score == other.score &&
      maxScore == other.maxScore;

  @override
  int get hashCode => Object.hash(subject, score, maxScore);

  @override
  String toString() => 'GradeEntry($subject: $scoreLabel / $maxScore)';
}

// ─────────────────────────────────────────────────────────────
// ABSTRACT BASE CLASS — Person
// ─────────────────────────────────────────────────────────────
abstract class Person {
  final String id;
  final String name;
  final String? email;

  const Person({required this.id, required this.name, this.email});

  String get role;
  String get displayEmail => email?.toLowerCase() ?? 'no email on file';

  @override
  String toString() => '$role[$id]: $name';
}

// ─────────────────────────────────────────────────────────────
// INHERITANCE — Student extends Person
// ─────────────────────────────────────────────────────────────
class Student extends Person {
  final List<GradeEntry> grades;

  Student({
    required super.id,
    required super.name,
    super.email,
    List<GradeEntry>? grades,
  }) : grades = grades ?? [];

  @override
  String get role => 'Student';

  static bool isValidId(String id) =>
      RegExp(r'^ICTU2023\d{3,}$').hasMatch(id);

  List<double> get submittedScores =>
      grades.map((e) => e.score).whereType<double>().toList();

  double? get overallAverage =>
      average(grades.map((e) => e.score).toList());

  String get letterGrade {
    final avg = overallAverage ?? 0;
    if (avg >= 90) return 'A';
    if (avg >= 80) return 'B';
    if (avg >= 70) return 'C';
    if (avg >= 60) return 'D';
    return 'F';
  }

  double get gpa {
    final avg = overallAverage ?? 0;
    if (avg >= 90) return 4.0;
    if (avg >= 80) return 3.0;
    if (avg >= 70) return 2.0;
    if (avg >= 60) return 1.0;
    return 0.0;
  }

  String get status {
    final avg = overallAverage;
    if (avg == null) return 'No Grades';
    return avg >= 60 ? 'Pass' : 'Fail';
  }

  void addGrade(GradeEntry entry) => grades.add(entry);

  void updateGrade(String subject, double newScore) {
    final idx = grades.indexWhere((g) => g.subject == subject);
    if (idx != -1) grades[idx] = grades[idx].copyWith(score: newScore);
  }

  Student copyWith({String? name, String? email, List<GradeEntry>? grades}) =>
      Student(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        grades: grades ?? List.from(this.grades),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'grades': grades.map((g) => g.toJson()).toList(),
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        grades: (json['grades'] as List<dynamic>? ?? [])
            .map((g) => GradeEntry.fromJson(g as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────────────────────
// INHERITANCE — GraduateStudent extends Student
// ─────────────────────────────────────────────────────────────
class GraduateStudent extends Student {
  final String program;
  final String? thesisTitle;

  GraduateStudent({
    required super.id,
    required super.name,
    super.email,
    super.grades,
    required this.program,
    this.thesisTitle,
  });

  @override
  String get role => 'Graduate Student';

  String get thesisInfo =>
      thesisTitle?.trim().toUpperCase() ?? 'THESIS NOT ASSIGNED';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'program': program,
        'thesisTitle': thesisTitle,
        'type': 'graduate',
      };
}

// ─────────────────────────────────────────────────────────────
// INHERITANCE — Instructor extends Person
// ─────────────────────────────────────────────────────────────
class Instructor extends Person {
  final String department;

  Instructor({
    required super.id,
    required super.name,
    required this.department,
  });

  @override
  String get role => 'Instructor';
}
