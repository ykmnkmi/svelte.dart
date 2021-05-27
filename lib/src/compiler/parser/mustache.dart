part of '../parser.dart';

extension MustacheParser on Parser {
  bool expression() {
    return conditional();
  }

  bool conditional() {
    if (equality()) {
      whitespace();

      if (eat('?')) {
        whitespace();

        if (!primary()) {
          error(message: 'expected an expression');
        }

        whitespace();
        eat(':', required: true);
        whitespace();

        if (!primary()) {
          error(message: 'expected an expression');
        }

        final onFalse = pop() as Expression;
        final onTrue = pop() as Expression;
        push(Condition(pop() as Expression, onTrue, onFalse));
        return true;
      }

      return true;
    }

    return false;
  }

  bool equality() {
    if (primary()) {
      whitespace();

      final operator = read('==') ?? read('!=');

      if (operator != null) {
        whitespace();

        if (primary()) {
          final right = pop() as Expression;
          push(Binary(operator, pop() as Expression, right));
          return true;
        }

        error(message: 'expected an expression');
      }

      return true;
    }

    return false;
  }

  bool primary() {
    var value = read('null') ?? read('true') ?? read('false');

    if (value != null) {
      push(Primitive(value, value == 'null' ? 'Null' : 'bool'));
      return true;
    }

    // TODO: hex, exponenta
    value = readPattern(RegExp('\\d+'));

    if (value != null) {
      final base = value;
      value = readPattern(RegExp('\\.\\d+'));

      if (value == null) {
        push(Primitive(base, 'int'));
      } else {
        push(Primitive(base + value, 'double'));
      }

      return true;
    }

    // TODO: interpolation
    value = read('\'') ?? read('"');

    if (value != null) {
      final content = readUntil(value);
      eat(value, required: true);
      push(Primitive('\'${content.replaceAll('\'', '\\\'')}\'', 'String'));
      return true;
    }

    // TODO: list, set, map literals

    return identifier();
  }

  bool identifier() {
    final buffer = StringBuffer();
    var part = readPattern(RegExp(r'[a-zA-Z_]'));

    while (part != null) {
      buffer.write(part);
      part = readPattern(RegExp(r'[a-zA-Z0-9_]'));
    }

    if (buffer.isEmpty) {
      return false;
    }

    push(Identifier('$buffer'));
    return true;
  }

  void mustache() {
    eat('{', required: true);
    whitespace();

    if (!expression()) {
      error(message: 'primary expression expected');
    }

    whitespace();
    eat('}', required: true);
  }
}
