// bin/main.dart
// =============================================================================
//  ENTRY POINT
//
//  Usage:
//    dart run bin/main.dart            → interactive CLI (starts with demo data)
//    dart run bin/main.dart --demo     → print all class reports and exit
//
//  This file is intentionally minimal — it only wires the pre-built demo
//  GradeBook to the CLI or the report printer.
// =============================================================================

import 'package:grade_calculator/cli/grade_calculator_cli.dart';
import 'package:grade_calculator/services/demo_data.dart';

void main(List<String> args) {
  final book = buildDemo();

  if (args.contains('--demo')) {
    print('\n🎓  Running demo — printing all class reports …\n');
    book.printAllClassReports();
    return;
  }

  GradeCalculatorCLI(book).run();
}
