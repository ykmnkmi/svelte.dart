part of '../parser.dart';

extension MustacheParser on Parser {
  Expression mustache() {
    eat('{', required: true);
    whitespace();

    final node = expression();

    if (node == null) {
      error(message: 'expected an expression');
    }

    whitespace();
    eat('}', required: true);

    return node;
  }

  Expression? expression() {
    return conditional();
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
    final left = primary();

    if (left == null) {
      return null;
    }

    whitespace();

    final operator = read('==') ?? read('!=');

    if (operator == null) {
      error(message: 'expected an expression');
    }

    whitespace();

    final right = primary();

    if (right == null) {
      return left;
    }

    return Binary(operator, left, right);
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

    return identifier();
  }

  Identifier? identifier() {
    final buffer = StringBuffer();

    var part = readPattern(RegExp(r'[a-zA-Z_]'));

    while (part != null) {
      buffer.write(part);
      part = readPattern(RegExp(r'[a-zA-Z0-9_]'));
    }

    if (buffer.isNotEmpty) {
      return Identifier('$buffer');
    }
  }
}
