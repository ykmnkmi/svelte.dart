import 'nodes.dart';
import 'parser.dart';

Expression expression(Parser parser) {
  return parser.expression();
}

extension on Parser {
  static String? temp;

  Expression expression() {
    Expression node;

    if ((temp = read(RegExp('([a-zA-Z][a-zA-Z0-9]*)'))) != null) {
      node = Identifier(temp!);
    } else {
      error(message: 'primary expression expected');
    }

    temp = null;
    return node;
  }
}
