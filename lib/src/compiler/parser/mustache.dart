part of '../parser.dart';

extension MustacheParser on Parser {
  bool expression() {
    return primary();
  }

  bool primary() {
    return identifier();
  }

  bool identifier() {
    final buffer = StringBuffer();
    final global = eat('@');
    var part = read(RegExp(r'[a-zA-Z_]'));

    while (part != null) {
      buffer.write(part);
      part = read(RegExp(r'[a-zA-Z0-9_]'));
    }

    if (buffer.isEmpty) {
      return false;
    }

    add(Identifier('$buffer', global));
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
