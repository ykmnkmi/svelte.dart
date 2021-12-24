import 'dart:math' show min;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';

import '../parse.dart';

extension MustacheParser on Parser {
  static const String prefix = 'void __expression() => ';

  Expression readExpression() {
    int found = template.indexOf('}', index);
    // is there expressions with length longer than 32 characters?
    String source = found == -1 ? rest : template.substring(index, min(found + 32, length));
    ParseStringResult result = parseString(content: prefix + source, throwIfDiagnostics: false);

    List<AnalysisError> errors = List<AnalysisError>.of(result.errors);
    errors.sort((a, b) => a.offset.compareTo(b.offset));

    AnalysisError analysisError = errors.removeAt(0);
    int offset = sourceFile.getColumn(index);

    if (analysisError.offset - offset < 0) {
      error('parse-error', 'expression expected');
    }

    if (analysisError.message != 'Expected to find \';\'.') {
      error('parse-error', analysisError.message);
    }

    NodeList<CompilationUnitMember> declarations = result.unit.declarations;

    for (AnalysisError error in errors) {
      switch (error.message) {
        case "Expected to find ';'.":
        case 'Expected a method, getter, setter or operator declaration.':
        case "Variables must be declared using the keywords 'const', 'final', 'var' or a type name.":
          continue;
        default:
          throw error;
      }
    }

    FunctionDeclaration function = declarations.first as FunctionDeclaration;
    ExpressionFunctionBody body = function.functionExpression.body as ExpressionFunctionBody;
    Expression expression = body.expression;
    index += expression.end - prefix.length;
    return expression;
  }
}
