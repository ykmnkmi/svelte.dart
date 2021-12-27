import 'dart:math' show min;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/cast.dart';
import '../parse.dart';

extension MustacheParser on Parser {
  static const String prefix = 'void __expression() => ';

  Expression readExpression() {
    final found = template.indexOf('}', index);
    // is there expressions with length longer than 32 characters?
    final source = found == -1 ? rest : template.substring(index, min(found + 32, length));
    final result = parseString(content: prefix + source, throwIfDiagnostics: false);

    final errors = List<AnalysisError>.of(result.errors);
    errors.sort((a, b) => a.offset.compareTo(b.offset));

    final analysisError = errors.removeAt(0);
    final offset = sourceFile.getColumn(index);

    if (analysisError.offset - offset < 0) {
      error('parse-error', 'expression expected');
    }

    if (analysisError.message != 'Expected to find \';\'.') {
      error('parse-error', analysisError.message);
    }

    final declarations = result.unit.declarations;

    for (final error in errors) {
      switch (error.message) {
        case "Expected to find ';'.":
        case 'Expected a method, getter, setter or operator declaration.':
        case "Variables must be declared using the keywords 'const', 'final', 'var' or a type name.":
          continue;
        default:
          throw error;
      }
    }

    final function = unsafeCast<FunctionDeclaration>(declarations.first);
    final body = unsafeCast<ExpressionFunctionBody>(function.functionExpression.body);
    final expression = body.expression;
    index += expression.end - prefix.length;
    return expression;
  }
}
