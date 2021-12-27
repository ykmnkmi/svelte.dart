import 'package:analyzer/dart/ast/ast.dart' show Expression;

import '../../interface.dart';
import '../../parse/errors.dart';
import '../../utils/cast.dart';
import '../../utils/html.dart';
import '../read/expression.dart';
import '../parse.dart';

extension MustacheParser on Parser {
  void mustache() {
    final start = index;
    expect('{');
    allowWhitespace();

    if (scan('/')) {
      var block = current;
      String? expected;

      if (closingTagOmitted(block.name)) {
        block.end = start;
        stack.removeLast();
        block = current;
      }

      final type = block.type;

      if (type == 'ElseBlock' || type == 'PendingBlock' || type == 'ThenBlock' || type == 'CatchBlock') {
        block.end = start;
        stack.removeLast();
        block = current;
        expected = 'await';
      }

      if (block.type == 'IfBlock') {
        expected = 'if';
      } else if (block.type == 'EachBlock') {
        expected = 'each';
      } else if (block.type == 'AwaitBlock') {
        expected = 'await';
      } else if (block.type == 'KeyBlock') {
        expected = 'key';
      } else {
        unexpectedBlockClose();
      }

      expect(expected);
      allowWhitespace();
      expect('}');

      while (block.elseIf == true) {
        block.end = index;
        stack.removeLast();
        block = current;
        block.elseNode?.end = start;
      }

      template[unsafeCast<int>(block.start) - 1];

      block.end = index;
      stack.removeLast();
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
      final expression = readExpression();
      allowWhitespace();
      expect('}');
      current.addChild(Node(start: start, end: index, type: 'MustacheTag', source: expression));
    }
  }
}
