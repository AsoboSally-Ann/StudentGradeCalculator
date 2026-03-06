// lib/interfaces/reportable.dart
// =============================================================================
//  REPORTABLE — abstract interface
//  Any class that can build and print a formatted text report implements this.
//  Used by: CourseReport, ClassReport
// =============================================================================

abstract class Reportable {
  /// Builds and returns a formatted multi-line string report.
  String buildReport();

  /// Prints the built report to stdout.
  void printReport() => print(buildReport());
}
