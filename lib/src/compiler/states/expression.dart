import '../expression_parser.dart';
import '../nodes.dart';
import '../parser.dart';

Expression expression(Parser parser) {
  return ExpressionParser().scan(parser.scanner);
}
