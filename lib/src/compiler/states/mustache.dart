import '../nodes.dart';
import '../parser.dart';
import 'expression.dart';

void mustache(Parser parser) {
  parser.eat('{', required: true);
  parser.whitespace();
  parser.add(Mustache(expression(parser)));
  parser.whitespace();
  parser.eat('}', required: true);
}
