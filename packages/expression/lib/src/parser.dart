import 'package:expression/variable.dart';

import 'nodes.dart' show Expression;

class ParseException extends Error {
  ParseException(String message, String? input, [Object? contextLocation])
      : message = 'Parser Error: $message [$input] in $contextLocation';

  final String message;

  @override
  String toString() {
    return 'ParseException: $message';
  }
}

abstract class ExpressionParser {
  const ExpressionParser();

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
  /// // Hello {{ place }}!
  /// parseInterpolation('Hello {{ place }}', ...)
  /// ```
  ///
  /// Returns `null` if there were no interpolations in [input].
  Expression? parseInterpolation(String input, List<Variable> exports);
}
