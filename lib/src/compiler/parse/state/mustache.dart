import 'package:analyzer/dart/ast/ast.dart' show Expression, Identifier;
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/read/context.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';
import 'package:piko/src/compiler/utils/html.dart';

extension MustacheParser on Parser {
  static final RegExp mustacheEndRe = RegExp('\\s*}');

  static void trimWhitespace(Node block, bool trimBefore, bool trimAfter) {
    var node = block;

    if (node is! MultiChildNode || node.children.isEmpty) {
      return;
    }

    var children = node.children;
    var first = children.first;
    var last = children.last;

    if (trimBefore && first is Text) {
      var data = first.data.trimLeft();

      if (data.isEmpty) {
        children.removeAt(0);
      } else {
        first.data = data;
      }
    }

    if (trimAfter && last is Text) {
      var data = last.data.trimRight();

      if (data.isEmpty) {
        children.removeLast();
      } else {
        last.data = data;
      }
    }

    var maybeElse = block;

    if (maybeElse is ElseNode && maybeElse.elseNode != null) {
      trimWhitespace(maybeElse.elseNode!, trimBefore, trimAfter);
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

      if (block is ElseBlock || block is PendingBlock || block is ThenBlock || block is CatchBlock) {
        block.end = start;
        stack.removeLast();
        block = current;
        expected = 'await';
      }

      if (block is IfBlock) {
        expected = 'if';
      } else if (block is EachBlock) {
        expected = 'each';
      } else if (block is AwaitBlock) {
        expected = 'await';
      } else if (block is KeyBlock) {
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

      var whitespace = RegExp('\\s');
      var trimBefore = block.start! == 0 || block.start! > 0 && whitespace.hasMatch(template[block.start! - 1]);
      var trimAfter = index == length || index < length && whitespace.hasMatch(template[index]);
      trimWhitespace(block, trimBefore, trimAfter);
      block.end = index;
      stack.removeLast();
    } else if (scan(':else')) {
      if (scan('if')) {
        invalidElseIf();
      }

      allowWhitespace();

      var block = current;

      if (scan('if')) {
        if (block is! IfBlock) {
          if (stack.any((block) => block is IfBlock)) {
            invalidElseIfPlacementUnclosedBlock(block.toString());
          }

          invalidElseIfPlacementOutsideIf();
        }

        allowWhitespace(require: true);

        var expression = readExpression();
        allowWhitespace();
        expect('}');

        var ifNode = IfBlock(start: index, expression: expression, elseIf: true);
        block.elseNode = ElseBlock(start: index, children: <Node>[ifNode]);
        stack.add(ifNode);
      } else {
        if (block is! IfBlock || block is! EachBlock) {
          if (stack.any((block) => block is IfBlock || block is EachBlock)) {
            invalidElseIfPlacementUnclosedBlock(block.toString());
          }

          invalidElseIfPlacementOutsideIf();
        }

        allowWhitespace();
        expect('}');

        var elseNode = ElseBlock(start: index);
        block.elseNode = elseNode;
        stack.add(elseNode);
      }
    } else if (match(':then') || match(':catch')) {
      var block = current;
      var isThen = scan(':then') || !scan(':catch');

      if (isThen) {
        if (block is! PendingBlock) {
          if (stack.any((block) => block is PendingBlock)) {
            invalidThenPlacementUnclosedBlock(block.toString());
          }

          invalidThenPlacementWithoutAwait();
        }
      } else {
        if (block is! ThenBlock && block is! PendingBlock) {
          if (stack.any((block) => block is ThenBlock || block is PendingBlock)) {
            invalidThenPlacementUnclosedBlock(block.toString());
          }

          invalidThenPlacementWithoutAwait();
        }
      }

      block.end = start;
      stack.removeLast();

      var awaitBlock = current as AwaitBlock;

      if (!scan('}')) {
        allowWhitespace(require: true);

        var context = readContext();

        if (isThen) {
          awaitBlock.value = context;
        } else {
          awaitBlock.error = context;
        }

        allowWhitespace();
        scan('}');
      }

      Node newBlock;

      if (isThen) {
        awaitBlock.thenNode = newBlock = ThenBlock(start: start, skip: false);
      } else {
        awaitBlock.catchNode = newBlock = CatchBlock(start: start, skip: false);
      }

      stack.add(newBlock);
    } else if (scan('#')) {
      Node Function({int? start, int? end, Expression? expression}) factory;

      if (scan('if')) {
        factory = IfBlock.new;
      } else if (scan('each')) {
        factory = EachBlock.new;
      } else if (scan('await')) {
        factory = AwaitBlock.new;
      } else if (scan('key')) {
        factory = KeyBlock.new;
      } else {
        expectedBlockType();
      }

      allowWhitespace(require: true);

      var expression = readExpression(primary: true);
      var block = factory(start: start, expression: expression);

      if (block is AwaitBlock) {
        block
          ..pendingNode = PendingBlock(skip: true)
          ..thenNode = ThenBlock(skip: true)
          ..catchNode = CatchBlock(skip: true);
      }

      allowWhitespace();

      if (block is EachBlock) {
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

      var isThen = false, isCatch = false;

      if (block is AwaitBlock) {
        if (scan('then')) {
          isThen = true;

          if (match(mustacheEndRe)) {
            allowWhitespace();
          } else {
            allowWhitespace(require: true);
            block.value = readContext();
            allowWhitespace();
          }
        } else if (scan('catch')) {
          isCatch = true;

          if (match(mustacheEndRe)) {
            allowWhitespace();
          } else {
            allowWhitespace(require: true);
            block.error = readContext();
            allowWhitespace();
          }
        }
      }

      expect('}');
      addNode(block);
      stack.add(block);

      if (block is AwaitBlock) {
        SkipNode childBlock;

        if (isThen) {
          childBlock = block.thenNode!;
        } else if (isCatch) {
          childBlock = block.catchNode!;
        } else {
          childBlock = block.pendingNode!;
        }

        childBlock
          ..start = index
          ..skip = false;

        stack.add(childBlock);
      }
    } else if (scan('@html')) {
      allowWhitespace(require: true);

      var expression = readExpression();
      allowWhitespace();
      expect('}');
      addNode(RawMustache(start: start, end: index, expression: expression));
    } else if (scan('@debug')) {
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

      addNode(Debug(start: start, end: index, identifiers: identifiers));
    } else {
      var expression = readExpression();
      allowWhitespace();
      expect('}');
      addNode(Mustache(start: start, end: index, expression: expression));
    }
  }
}
