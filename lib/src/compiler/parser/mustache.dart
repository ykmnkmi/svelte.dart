part of '../parser.dart';

extension MustacheParser on Parser {
  void mustache() {
    eat('{', required: true);
    whitespace();

    if (!expression()) {
      error(message: 'expected an expression');
    }

    whitespace();
    eat('}', required: true);
  }
}
