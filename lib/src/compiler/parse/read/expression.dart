import 'dart:math' show min;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';

import '../parse.dart';

const String prefix = 'void __expression() => ';

extension MustacheParser on Parser {
  Expression readExpression() {
    var found = template.indexOf('}', index);
    // is there expressions with length longer than 32 characters?
    var source = found == -1 ? rest : template.substring(index, min(found + 32, length));
    var result = parseString(content: prefix + source, throwIfDiagnostics: false);

    var errors = List<AnalysisError>.of(result.errors);
    errors.sort((a, b) => a.offset.compareTo(b.offset));

    var analysisError = errors.removeAt(0);
    var offset = sourceFile.getColumn(index);

    if (analysisError.offset - offset < 0) {
      error('parse-error', 'expression expected');
    }

    if (analysisError.message != 'Expected to find \';\'.') {
      error('parse-error', analysisError.message);
    }

    var declarations = result.unit.declarations;

    for (var error in errors) {
      switch (error.message) {
        case "Expected to find ';'.":
        case 'Expected a method, getter, setter or operator declaration.':
        case "Variables must be declared using the keywords 'const', 'final', 'var' or a type name.":
          continue;
        default:
          throw error;
      }
    }

    var function = declarations.first as FunctionDeclaration;
    var body = function.functionExpression.body as ExpressionFunctionBody;
    var expression = body.expression;
    index += expression.end - prefix.length;
    return expression;
  }
}
