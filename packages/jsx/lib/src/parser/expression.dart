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

    if (!drink('?')) {
      return true;
    }

    whitespace();

    if (!equality()) {
      error(message: 'expected an expression');
    }

    whitespace();
    eat(':');
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
    if (drink('.')) {
      if (!identifier()) {
        error(message: 'expected an identifier');
      }

      final name = pop() as Identifier;
      push(Field(pop() as Expression, name.name));
      return true;
    }

    return false;
  }

  bool calling() {
    eat('(');

    // TODO: positional, named
    if (expression()) {
      final argument = pop() as Expression;
      push(Calling(pop() as Expression, positional: <Expression>[argument]));
    } else {
      push(Calling(pop() as Expression));
    }

    eat(')');
    return true;
  }

  bool primary() {
    if (literal()) {
      return true;
    }

    return identifier();
  }

  bool literal() {
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
      eat(value);
      Primitive('\'${content.replaceAll('\'', '\\\'')}\'', 'String');
      return true;
    }

    value = read('#');

    // TODO: list, set, map literals

    return false;
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
