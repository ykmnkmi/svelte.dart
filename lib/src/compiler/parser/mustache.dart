part of '../parser.dart';

extension MustacheParser on Parser {
  void expression() {
    if (identifier()) {
      return;
    }

    error(message: 'primary expression expected');
  }

  bool identifier() {
    final buffer = StringBuffer();
    var part = read(RegExp(r'[a-zA-Z_]'));

    while (part != null) {
      buffer.write(part);
      part = read(RegExp(r'[a-zA-Z0-9_]'));
    }

    if (buffer.isEmpty) {
      return false;
    }

    add(Identifier('$buffer'));
    return true;
  }

  void mustache() {
    eat('{', required: true);
    whitespace();
    expression();
    whitespace();
    eat('}', required: true);
  }
}
