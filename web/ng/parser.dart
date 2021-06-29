import 'package:meta/meta.dart';

import 'ast.dart' show AST, ASTWithSource;
import 'variable.dart';
import 'src/analyzer_parser.dart';
import 'src/utilty.dart';

late final RegExp findInterpolation = RegExp(r'{{([\s\S]*?)}}');

class ParseException extends Error {
  ParseException(String message, String? input, String errLocation, [Object? ctxLocation])
      : message = 'Parser Error: $message $errLocation [$input] in $ctxLocation';

  final String message;

  @override
  String toString() {
    return message;
  }
}

abstract class ExpressionParser {
  factory ExpressionParser() = AnalyzerExpressionParser;

  @protected
  const ExpressionParser.forInheritence();

  /// Parses an event binding (historically called an "action").
  ///
  /// ```
  /// // <div (click)="doThing()">
  /// parseAction('doThing()', ...)
  /// ```
  ASTWithSource parseAction(String? input, String location, List<Variable> exports) {
    if (input == null) {
      throw ParseException('Blank expressions are not allowed in event bindings.', input, location);
    }

    checkNoInterpolation(input, location);
    return ASTWithSource(parseActionImpl(input, location, exports), input, location);
  }

  /// Parses an input, property, or attribute binding.
  ///
  /// ```
  /// // <div [title]="renderTitle">
  /// parseBinding('renderTitle', ...)
  /// ```
  ASTWithSource parseBinding(String input, String location, List<Variable> exports) {
    checkNoInterpolation(input, location);
    return ASTWithSource(parseBindingImpl(input, location, exports), input, location);
  }

  /// Parses a text interpolation.
  ///
  /// ```
  /// // Hello {{place}}!
  /// parseInterpolation('place', ...)
  /// ```
  ///
  /// Returns `null` if there were no interpolations in [input].
  ASTWithSource? parseInterpolation(String input, String location, List<Variable> exports) {
    final result = parseInterpolationImpl(input, location, exports);

    if (result == null) {
      return null;
    }

    return ASTWithSource(result, input, location);
  }

  /// Override to implement [parseAction].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @visibleForOverriding
  AST parseActionImpl(String input, String location, List<Variable> exports);

  /// Override to implement [parseBinding].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @visibleForOverriding
  AST parseBindingImpl(String input, String location, List<Variable> exports);

  /// Override to implement [parseInterpolation].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @visibleForOverriding
  AST? parseInterpolationImpl(String input, String location, List<Variable> exports);

  /// Helper method for implementing [parseInterpolation].
  ///
  /// Splits a longer multi-expression interpolation into [SplitInterpolation].
  SplitInterpolation? splitInterpolation(String input, String location) {
    final parts = jsSplit(input, findInterpolation);
    print(parts);

    if (parts.length <= 1) {
      return null;
    }

    var strings = <String>[];
    var expressions = <String>[];

    for (var i = 0; i < parts.length; i++) {
      var part = parts[i];

      if (i.isEven) {
        // fixed string
        strings.add(part);
      } else if (part.trim().isNotEmpty) {
        expressions.add(part);
      } else {
        throw ParseException('Blank expressions are not allowed in interpolated strings', input,
            'at column ${findInterpolationErrorColumn(parts, i)} in', location);
      }
    }

    return SplitInterpolation(strings, expressions);
  }

  void checkNoInterpolation(String input, String location) {
    final parts = jsSplit(input, findInterpolation);

    if (parts.length > 1) {
      throw ParseException('Got interpolation ({{}}) where expression was expected', input,
          'at column ${findInterpolationErrorColumn(parts, 1)} in', location);
    }
  }

  static int findInterpolationErrorColumn(List<String> parts, int partInErrIdx) {
    var errLocation = '';

    for (var j = 0; j < partInErrIdx; j++) {
      errLocation += j.isEven ? parts[j] : '{{${parts[j]}}}';
    }

    return errLocation.length;
  }
}

/// Splits a longer interpolation expression into [strings] and [expressions].
class SplitInterpolation {
  SplitInterpolation(this.strings, this.expressions);

  final List<String> strings;

  final List<String> expressions;
}
