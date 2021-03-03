import 'nodes.dart';
import 'parser.dart';

Expression expression(Parser parser) {
  return parser.expression();
}

extension on Parser {
  Expression expression() {
    final temp = read(RegExp('([a-zA-Z][a-zA-Z0-9]*)'));

    Expression node;

    if (temp != null) {
      node = Identifier(temp);
    } else {
      error(message: 'primary expression expected');
    }

    return node;
  }
}
