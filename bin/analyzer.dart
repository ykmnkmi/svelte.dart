import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

void main() {
  final result = parseFile(path: 'bin/main.dart', featureSet: FeatureSet.latestLanguageVersion());

  final visitor = DartXParser();
  final unit = result.unit;
  print(unit.scriptTag);
  visitor.visitCompilationUnit(unit);
}

class DartXParser extends /* SimpleAstVisitor */ ThrowingAstVisitor<void> {
  const DartXParser();
}
