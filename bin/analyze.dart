import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';

void main() {
  final source = File('bin/app.dart').readAsStringSync();
  final result = parseString(content: source);
  print(result.unit);
}
