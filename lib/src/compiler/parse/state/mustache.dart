import '../../interface.dart';
import '../read/expression.dart';
import '../parse.dart';

extension MustacheParser on Parser {
  void mustache() {
    var start = index;

    expect('{');
    allowWhitespace();

    if (scan('/')) {
      throw UnimplementedError();
    } else if (scan(':else')) {
      throw UnimplementedError();
    } else if (match(':then') || match(':catch')) {
      throw UnimplementedError();
    } else if (scan('#')) {
      throw UnimplementedError();
    } else if (scan('@html')) {
      throw UnimplementedError();
    } else if (scan('@debug')) {
      throw UnimplementedError();
    } else {
      var expression = readExpression();

      allowWhitespace();
      expect('}');

      current.addChild(Node(start: start, end: index, type: 'MustacheTag', source: expression));
    }
  }
}
