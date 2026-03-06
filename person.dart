// lib/models/person.dart
// =============================================================================
//  PERSON HIERARCHY  (base layer)
//
//  Person       (abstract — shared identity fields)
//    └─ Instructor  (concrete — department, optional office room)
//
//  Student is defined separately in student.dart because it also
//  implements Gradable and owns GradeEntry objects.
// =============================================================================

// ── Person (abstract) ─────────────────────────────────────────────────────────

abstract class Person {
  final String id;
  final String firstName;
  final String lastName;
  final String? email; // nullable — not always provided

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email, // nullable
  });

  String get fullName => '$firstName $lastName';

  /// Role label shown in reports — each subclass defines this.
  String get role;

  @override
  String toString() => '$role[$id] $fullName';
}

// ── Instructor (extends Person) ───────────────────────────────────────────────

class Instructor extends Person {
  final String department;
  final String? officeRoom; // nullable — adjuncts may not have a dedicated room

  Instructor({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,       // nullable
    required this.department,
    this.officeRoom,   // nullable
  });

  @override
  String get role => 'Instructor';

  // Data-class: copyWith
  Instructor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    bool clearEmail = false,
    String? department,
    String? officeRoom,
    bool clearOffice = false,
  }) =>
      Instructor(
        id:         id           ?? this.id,
        firstName:  firstName    ?? this.firstName,
        lastName:   lastName     ?? this.lastName,
        email:      clearEmail   ? null : (email      ?? this.email),
        department: department   ?? this.department,
        officeRoom: clearOffice  ? null : (officeRoom ?? this.officeRoom),
      );

  @override
  bool operator ==(Object o) => o is Instructor && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
