import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';

const String prefix = 'void __expression() => ';
const int offset = prefix.length;

Expression expression(String source) {
  var result = parseString(content: prefix + source, throwIfDiagnostics: false);
  var errors = List<AnalysisError>.of(result.errors);
  errors.sort((a, b) => a.offset.compareTo(b.offset));

  for (var error in errors) {
    print('> ${error.offset - offset} ${error.message}');
  }

  var declarations = result.unit.declarations;

  if (declarations.length != 1) {
    throw 'not a valid expression';
  }

  var function = declarations.first as FunctionDeclaration;
  var body = function.functionExpression.body as ExpressionFunctionBody;
  return body.expression;
}

void main() {
  print(expression('name }!'));
}
