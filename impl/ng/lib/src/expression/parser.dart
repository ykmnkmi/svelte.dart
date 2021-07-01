import '../variable.dart';
import '../utilty.dart';
import 'analyzer_parser.dart';
import 'nodes.dart' show Expression;

late final RegExp findInterpolation = RegExp(r'{{([\s\S]*?)}}');

class ParseException extends Error {
  ParseException(String message, String? input, [Object? contextLocation])
      : message = 'Parser Error: $message [$input] in $contextLocation';

  final String message;

  @override
  String toString() {
    return message;
  }
}

abstract class ExpressionParser {
  const factory ExpressionParser() = AnalyzerExpressionParser;

  const ExpressionParser.forInheritence();

  /// Parses an event binding (historically called an "action").
  ///
  /// ```
  /// // <div (click)="doThing()">
  /// parseAction('doThing()', ...)
  /// ```
  Expression parseAction(String input, List<Variable> exports);

  /// Parses an input, property, or attribute binding.
  ///
  /// ```
  /// // <div [title]="renderTitle">
  /// parseBinding('renderTitle', ...)
  /// ```
  Expression parseBinding(String input, List<Variable> exports);

  /// Parses a text interpolation.
  ///
  /// ```
  /// // Hello {{place}}!
  /// parseInterpolation('place', ...)
  /// ```
  ///
  /// Returns `null` if there were no interpolations in [input].
  Expression? parseInterpolation(String input, List<Variable> exports);

  /// Helper method for implementing [parseInterpolation].
  ///
  /// Splits a longer multi-expression interpolation into [SplitInterpolation].
  SplitInterpolation? splitInterpolation(String input) {
    final parts = jsSplit(input, findInterpolation);

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
        throw ParseException('blank expressions are not allowed in interpolated strings', input,
            'at column ${findInterpolationErrorColumn(parts, i)}');
      }
    }

    return SplitInterpolation(strings, expressions);
  }

  void checkNoInterpolation(String input) {
    final parts = jsSplit(input, findInterpolation);

    if (parts.length > 1) {
      throw ParseException('got interpolation where expression was expected', input,
          'at column ${findInterpolationErrorColumn(parts, 1)}');
    }
  }

  static int findInterpolationErrorColumn(List<String> parts, int partInErrIdx) {
    var errorLocation = '';

    for (var j = 0; j < partInErrIdx; j++) {
      errorLocation += j.isEven ? parts[j] : '{{${parts[j]}}}';
    }

    return errorLocation.length;
  }
}

/// Splits a longer interpolation expression into [strings] and [expressions].
class SplitInterpolation {
  SplitInterpolation(this.strings, this.expressions);

  final List<String> strings;

  final List<String> expressions;
}
