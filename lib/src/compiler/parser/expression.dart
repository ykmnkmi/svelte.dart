part of '../parser.dart';

extension ExpressionParser on Parser {
  bool expression() {
    return conditional();
  }

  bool conditional() {
    if (!equality()) {
      return false;
    }

    whitespace();

    if (!eat('?')) {
      return true;
    }

    whitespace();

    if (!equality()) {
      error(message: 'expected an expression');
    }

    whitespace();
    eat(':', required: true);
    whitespace();

    if (!equality()) {
      error(message: 'expected an expression');
    }

    final onFalse = pop() as Expression;
    final onTrue = pop() as Expression;
    push(Condition(pop() as Expression, onTrue, onFalse));
    return true;
  }

  bool equality() {
    if (!unary()) {
      return false;
    }

    whitespace();

    final operator = read('==') ?? read('!=');

    if (operator == null) {
      return true;
    }

    whitespace();

    if (!unary()) {
      error(message: 'expected an expression');
    }

    final right = pop() as Expression;
    push(Binary(operator, pop() as Expression, right));
    return true;
  }

  bool unary() {
    if (!primary()) {
      return false;
    }

    if (postfix()) {
      while (postfix()) {
        // ...
      }

      return true;
    }

    return true;
  }

  bool postfix() {
    if (match('(')) {
      return calling();
    }

    if (match('..')) {
      throw UnimplementedError();
    }

    if (match('.')) {
      return field();
    }

    if (match('[')) {
      throw UnimplementedError();
    }

    return false;
  }

  bool field() {
    if (eat('.')) {
      if (!identifier()) {
        // TODO: add error message
        error();
      }

      final name = pop() as Identifier;
      push(Field(pop() as Expression, name.name));
      return true;
    }

    // TODO: add error message
    error();
  }

  bool calling() {
    eat('(', required: true);

    // TODO: positional, named
    if (expression()) {
      final argument = pop() as Expression;
      push(Calling(pop() as Expression, positional: <Expression>[argument]));
    } else {
      push(Calling(pop() as Expression));
    }

    eat(')', required: true);
    return true;
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
      push(value == null ? Primitive(base, 'int') : Primitive(base + value, 'double'));
      return true;
    }

    // TODO: interpolation

    value = read('\'') ?? read('"');

    if (value != null) {
      final content = readUntil(value);
      eat(value, required: true);
      Primitive('\'${content.replaceAll('\'', '\\\'')}\'', 'String');
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
}
