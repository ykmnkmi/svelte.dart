import 'parser.dart';
import 'expression.dart';

void mustache(Parser parser) {
  parser.eat('{', required: true);
  parser.whitespace();
  parser.add(expression(parser));
  parser.whitespace();
  parser.eat('}', required: true);
}
