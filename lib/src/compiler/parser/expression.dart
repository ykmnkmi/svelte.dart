part of '../parser.dart';

extension ExpressionParser on Parser {
  bool expression() {
    final expression = conditional();

    if (expression == null) {
      return false;
    }

    push(expression);
    return true;
  }

  Expression? conditional() {
    final test = equality();

    if (test == null) {
      return null;
    }

    whitespace();

    if (!eat('?')) {
      return test;
    }

    whitespace();

    final onFalse = equality();

    if (onFalse == null) {
      error(message: 'expected an expression');
    }

    whitespace();
    eat(':', required: true);
    whitespace();

    final onTrue = equality();

    if (onTrue == null) {
      error(message: 'expected an expression');
    }

    return Condition(test, onTrue, onFalse);
  }

  Expression? equality() {
    final left = unary();

    if (left == null) {
      return null;
    }

    whitespace();

    final operator = read('==') ?? read('!=');

    if (operator == null) {
      return left;
    }

    whitespace();

    final right = unary();

    if (right == null) {
      return left;
    }

    return Binary(operator, left, right);
  }

  Expression? unary() {
    var expression = primary();

    if (expression == null) {
      return null;
    }

    return postfix(expression);
  }

  Expression postfix(Expression expression) {
    while (true) {
      if (match('(')) {
        expression = calling(expression);
      } else if (match('..')) {
        throw UnimplementedError();
      } else if (match('.')) {
        expression = field(expression);
      } else if (match('[')) {
        throw UnimplementedError();
      } else {
        break;
      }
    }

    return expression;
  }

  Expression field(Expression expression) {
    if (eat('.')) {
      final name = identifier();

      if (name.isEmpty) {
        // TODO: add error message
        error();
      }

      return Field(name, expression);
    }

    // TODO: add error message
    error();
  }

  Expression calling(Expression expression) {
    // return expression;
    throw UnimplementedError();
  }

  Expression? primary() {
    var value = read('null') ?? read('true') ?? read('false');

    if (value != null) {
      return Primitive(value, value == 'null' ? 'Null' : 'bool');
    }

    // TODO: hex, exponenta

    value = readPattern(RegExp('\\d+'));

    if (value != null) {
      final base = value;
      value = readPattern(RegExp('\\.\\d+'));
      return value == null ? Primitive(base, 'int') : Primitive(base + value, 'double');
    }

    // TODO: interpolation

    value = read('\'') ?? read('"');

    if (value != null) {
      final content = readUntil(value);
      eat(value, required: true);
      return Primitive('\'${content.replaceAll('\'', '\\\'')}\'', 'String');
    }

    // TODO: list, set, map literals

    final name = identifier();

    if (name.isEmpty) {
      return null;
    }

    return Identifier(name);
  }

  String identifier() {
    final buffer = StringBuffer();

    var part = readPattern(RegExp(r'[a-zA-Z_]'));

    while (part != null) {
      buffer.write(part);
      part = readPattern(RegExp(r'[a-zA-Z0-9_]'));
    }

    return '$buffer';
  }
}
