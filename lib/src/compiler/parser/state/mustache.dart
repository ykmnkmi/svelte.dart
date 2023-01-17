import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/parser.dart';
import 'package:svelte/src/compiler/parser/read/expression.dart';

extension MustacheParser on Parser {
  void mustache() {
    var start = position;

    expect('{');
    allowSpace();

    if (scan('/')) {
      throw UnimplementedError();
    } else if (scan(':')) {
      throw UnimplementedError();
    } else if (scan('#')) {
      throw UnimplementedError();
    } else if (scan('@')) {
      throw UnimplementedError();
    } else {
      var expression = readExpression();

      allowSpace();
      expect('}');

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'MustacheTag',
        expression: expression,
      ));
    }
  }
}
