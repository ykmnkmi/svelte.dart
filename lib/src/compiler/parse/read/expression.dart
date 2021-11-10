import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';

import '../parse.dart';

const String prefix = 'void __expression() => ';

extension MustacheParser on Parser {
  Expression readExpression() {
    var result = parseString(content: prefix + rest, throwIfDiagnostics: false);
    var errors = List<AnalysisError>.of(result.errors);
    errors.sort((a, b) => a.offset.compareTo(b.offset));

    var analysisError = errors.first;

    if (analysisError.offset - index < 0) {
      error('parse-error', 'expression expected');
    }

    if (analysisError.message != 'Expected to find \';\'.') {
      error('parse-error', analysisError.message);
    }

    var declarations = result.unit.declarations;

    if (declarations.length != 1) {
      error('parse-error', 'not a valid expression');
    }

    var function = declarations.first as FunctionDeclaration;
    var body = function.functionExpression.body as ExpressionFunctionBody;
    var expression = body.expression;
    index += expression.end - prefix.length;
    return expression;
  }
}
