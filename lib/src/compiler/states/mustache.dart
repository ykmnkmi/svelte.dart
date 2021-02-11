part of '../states.dart';

void mustache(Parser parser) {
  parser.eat('{', required: true);
  parser.whitespace();
  parser.add(Mustache(ExpressionParser().scan(parser.scanner)));
  parser.whitespace();
  parser.eat('}', required: true);
}
