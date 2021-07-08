import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/dart/ast/ast.dart' show Declaration, FunctionDeclaration, TopLevelVariableDeclaration;
import 'package:expression/variable.dart';

List<DeclaredVariable> detect(String source, {String? prefix}) {
  final result = parseString(content: source);
  final variables = <DeclaredVariable>[];

  for (final declaration in result.unit.declarations) {
    if (declaration is TopLevelVariableDeclaration) {
      for (final variable in declaration.variables.variables) {
        variables.add(DeclaredVariable(variable.name.name, variable, prefix: prefix));
      }

      continue;
    }

    if (declaration is FunctionDeclaration) {
      variables.add(DeclaredVariable(declaration.name.name, declaration, prefix: prefix));
    }
  }

  return variables;
}

class DeclaredVariable extends Variable {
  DeclaredVariable(String name, this.declaration, {String? prefix}) : super(name, prefix: prefix);

  final Declaration declaration;

  @override
  String toString() {
    return '$full($declaration)';
  }
}
