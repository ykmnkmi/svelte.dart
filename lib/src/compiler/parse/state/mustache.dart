import 'package:analyzer/dart/ast/ast.dart' show Identifier;
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/read/context.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';
import 'package:piko/src/compiler/utils/html.dart';

extension MustacheParser on Parser {
  static void trimWhitespace(Node block, bool trimBefore, bool trimAfter) {
    if (block is! MultiChildNode || block.children.isEmpty) {
      return;
    }

    var children = block.children;
    var first = children.first;
    var last = children.last;

    if (trimBefore && first is Text) {
      var data = (first.data as String).trimLeft();

      if (data.isEmpty) {
        children.removeAt(0);
      } else {
        first.data = data;
      }
    }

    if (trimAfter && last is Text) {
      var data = (last.data as String).trimRight();

      if (data.isEmpty) {
        children.removeLast();
      } else {
        last.data = data;
      }
    }

    if (block is ElseNode && block.elseNode != null) {
      trimWhitespace(block.elseNode!, trimBefore, trimAfter);
    }

    if (first is ElseNode && first.elseIf == true) {
      trimWhitespace(first, trimBefore, trimAfter);
    }
  }

  void mustache() {
    var start = index;
    expect('{');
    allowWhitespace();

    if (scan('/')) {
      var block = current;

      String? expected;

      if (block is NamedNode && closingTagOmitted(block.name)) {
        block.end = start;
        stack.removeLast();
        block = current;
      }

      var type = block.type;

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

      while (block is ElseNode && block.elseIf == true) {
        var current = stack.removeLast();

        if (current is ElseNode && current.elseNode != null) {
          current.elseNode!.end = start;
        }

        block.end = index;
        block = current;
      }

      // TODO: check range
      var charBefore = template[block.start! - 1];
      var charAfter = template[index];
      var whitespace = RegExp('\\s');
      var trimBefore = whitespace.hasMatch(charBefore);
      var trimAfter = whitespace.hasMatch(charAfter);
      trimWhitespace(block, trimBefore, trimAfter);
      block.end = index;
      stack.removeLast();
      return;
    }

    if (scan(':else')) {
      if (scan('if')) {
        invalidElseIf();
      }

      allowWhitespace();

      var block = current;

      if (scan('if')) {
        if (block.type != 'IfBlock') {
          if (stack.any((block) => block.type == 'IfBlock')) {
            invalidElseIfPlacementUnclosedBlock(block.toString());
          }

          invalidElseIfPlacementOutsideIf();
        }

        allowWhitespace(require: true);

        var expression = readExpression();
        allowWhitespace();
        expect('}');

        var ifNode = Node(start: index, type: 'IfBlock', expression: expression, elseIf: true);
        block.elseNode = Node(start: index, type: 'ElseBlock', children: <Node>[ifNode]);
        stack.add(ifNode);
        return;
      }

      if (block.type != 'IfBlock' || block.type != 'EachBlock') {
        if (stack.any((block) => block.type == 'IfBlock' || block.type == 'EachBlock')) {
          invalidElseIfPlacementUnclosedBlock(block.toString());
        }

        invalidElseIfPlacementOutsideIf();
      }

      allowWhitespace();
      expect('}');

      var elseNode = Node(start: index, type: 'ElseBlock');
      block.elseNode = elseNode;
      stack.add(elseNode);
    }

    if (match(':then') || match(':catch')) {
      var block = current;
      var isThen = scan(':then') || !scan(':catch');

      if (isThen) {
        if (block.type != 'PendingBlock') {
          if (stack.any((block) => block.type == 'PendingBlock')) {
            invalidThenPlacementUnclosedBlock(block.toString());
          }

          invalidThenPlacementWithoutAwait();
        }
      } else {
        if (block.type != 'ThenBlock' || block.type != 'PendingBlock') {
          if (stack.any((block) => block.type == 'ThenBlock' || block.type == 'PendingBlock')) {
            invalidThenPlacementUnclosedBlock(block.toString());
          }

          invalidThenPlacementWithoutAwait();
        }
      }

      block.end = start;
      stack.removeLast();

      var awaitBlock = current;

      if (!scan('}')) {
        allowWhitespace(require: true);

        var context = readContext();

        if (isThen) {
          awaitBlock.expression = context;
        } else {
          awaitBlock.error = context;
        }

        allowWhitespace();
        scan('}');
      }

      var newBlock = Node(start: start, type: isThen ? 'THenBlock' : 'CatchBlock', skip: false);

      if (isThen) {
        awaitBlock.thenNode = newBlock;
      } else {
        awaitBlock.catchNode = newBlock;
      }

      stack.add(newBlock);
      return;
    }

    if (scan('#')) {
      String type;

      if (scan('if')) {
        type = 'IfBlock';
      } else if (scan('each')) {
        type = 'EachBlock';
      } else if (scan('await')) {
        type = 'AwaitBlock';
      } else if (scan('key')) {
        type = 'KeyBlock';
      } else {
        expectedBlockType();
      }

      allowWhitespace(require: true);

      var expression = readExpression();
      var block = Node(start: start, type: type, expression: expression);

      if (type == 'AwaitBlock') {
        block
          ..pendingNode = Node(type: 'PendingBlock', skip: true)
          ..thenNode = Node(type: 'ThenBlock', skip: true)
          ..catchNode = Node(type: 'ThenBlock', skip: true);
      }

      allowWhitespace();

      if (type == 'EachBlock') {
        expect('as');
        allowWhitespace(require: true);
        block.context = readContext();
        allowWhitespace();

        if (scan(',')) {
          allowWhitespace();

          var index = readIdentifier();

          if (index == null) {
            expectedName();
          }

          block.index = index;
        }

        if (scan('(')) {
          allowWhitespace();
          block.key = readExpression();
          expect(')');
          allowWhitespace();
        }
      }

      var awaitThenBlockShorthand = type == 'AwaitBlock' && scan('then');

      if (awaitThenBlockShorthand) {
        if (match(RegExp('\\s*}'))) {
          allowWhitespace();
        } else {
          allowWhitespace(require: true);
          block.error = readContext();
          allowWhitespace();
        }
      }

      var awaitBlockCatchShorthand = type == 'AwaitBlock' && scan('then');

      if (awaitThenBlockShorthand) {
        if (match(RegExp('\\s*}'))) {
          allowWhitespace();
        } else {
          allowWhitespace(require: true);
          block.error = readContext();
          allowWhitespace();
        }
      }

      expect('}');
      current.children!.add(block);
      stack.add(block);

      if (type == 'AwaitBlock') {
        Node childBlock;

        if (awaitThenBlockShorthand) {
          childBlock = block.thenNode!;
        } else if (awaitBlockCatchShorthand) {
          childBlock = block.catchNode!;
        } else {
          childBlock = block.pendingNode!;
        }

        stack.add(childBlock);
        childBlock
          ..start = index
          ..skip = false;
      }

      return;
    }

    if (scan('@html')) {
      allowWhitespace(require: true);

      var expression = readExpression();
      allowWhitespace();
      expect('}');

      var node = Node(start: start, end: index, type: 'RawMustacheTag', expression: expression);
      current.children!.add(node);
      return;
    }

    if (scan('@debug')) {
      allowWhitespace();

      List<Identifier> identifiers;

      if (scan('}')) {
        identifiers = <Identifier>[];
      } else {
        var expression = readExpression();

        if (expression is! Identifier) {
          invalidDebugArgs(start);
        }

        identifiers = <Identifier>[expression];
        allowWhitespace();
        expect('}');
      }

      var node = Node(start: start, end: index, type: 'DebugTag', identifiers: identifiers);
      current.children!.add(node);
      return;
    }

    var expression = readExpression();
    allowWhitespace();
    expect('}');

    var node = Node(start: start, end: index, type: 'MustacheTag', expression: expression);
    current.children!.add(node);
  }
}