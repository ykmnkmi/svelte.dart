import 'package:analyzer/dart/ast/ast.dart' show AsExpression, Expression, Identifier, NamedType;
import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parse/errors.dart';
import 'package:nutty/src/compiler/parse/html.dart';
import 'package:nutty/src/compiler/parse/parse.dart';
import 'package:nutty/src/compiler/parse/patterns.dart';
import 'package:nutty/src/compiler/parse/read/context.dart';
import 'package:nutty/src/compiler/parse/read/expression.dart';

extension MustacheParser on Parser {
  static final RegExp mustacheEndRe = RegExp('\\s*}');

  static void trimSpace(Node block, bool trimBefore, bool trimAfter) {
    var children = block.children;

    if (children.isEmpty) {
      return;
    }

    var first = children.first;

    if (trimBefore && first is Text) {
      first.data = first.data.trimLeft();

      if (first.data.isEmpty) {
        children.removeAt(0);
      }
    }

    if (children.isNotEmpty) {
      var last = children.last;

      if (trimAfter && last is Text) {
        last.data = last.data.trimRight();

        if (last.data.isEmpty) {
          children.removeLast();
        }
      }
    }

    if (block is ElseNode && block.elseNode != null) {
      trimSpace(block.elseNode!, trimBefore, trimAfter);
    }

    if (first is ElseIfNode && first.elseIf) {
      trimSpace(first, trimBefore, trimAfter);
    }
  }

  void mustache() {
    var start = index;
    expect('{');
    allowSpace();

    if (scan('/')) {
      var block = current;

      String expected;

      if (block is NamedNode && closingTagOmitted(block.name)) {
        block.end = start;
        stack.removeLast();
        block = current;
      }

      if (block.type == 'ElseBlock' ||
          block.type == 'PendingBlock' ||
          block.type == 'ThenBlock' ||
          block.type == 'CatchBlock') {
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
      allowSpace();
      expect('}');

      while (block is ElseIfNode && block.elseIf) {
        block.end = index;
        stack.removeLast();
        block = current;

        if (block is ElseNode && block.elseNode != null) {
          block.elseNode!.end = start;
        }
      }

      var trimBefore = block.start == 0 || block.start! > 0 && whitespaceRe.hasMatch(template[block.start! - 1]);
      var trimAfter = index == length || index < length && whitespaceRe.hasMatch(template[index]);
      trimSpace(block, trimBefore, trimAfter);
      block.end = index;
      stack.removeLast();
    } else if (scan(':else')) {
      if (scan('if')) {
        invalidElseIf();
      }

      allowSpace();

      if (scan('if')) {
        var block = current;

        if (block is! IfBlock) {
          for (var node in stack) {
            if (node.type != 'IfBlock') {
              invalidElseIfPlacementUnclosedBlock(block.describe());
            }
          }

          invalidElseIfPlacementOutsideIf();
        }

        allowSpace(require: true);

        var expression = readExpression();
        allowSpace();
        expect('}');

        var ifNode = IfBlock(start: index, expression: expression, elseIf: true);
        block.elseNode = ElseBlock(start: index, children: <Node>[ifNode]);
        stack.add(ifNode);
      } else {
        var block = current;

        if (block.type != 'IfBlock' && block.type != 'EachBlock') {
          for (var node in stack) {
            if (node.type == 'IfBlock' || node.type == 'EachBlock') {
              invalidElsePlacementUnclosedBlock(block.describe());
            }
          }

          invalidElsePlacementOutsideIf();
        }

        allowSpace();
        expect('}');

        var elseNode = block as ElseNode;
        var elseBlock = ElseBlock(start: index);
        elseNode.elseNode = elseBlock;
        stack.add(elseBlock);
      }
    } else if (match(':then') || match(':catch')) {
      var block = current;
      var isThen = scan(':then') || !scan(':catch');

      if (isThen) {
        if (block.type != 'PendingBlock') {
          for (var node in stack) {
            if (node.type == 'PendingBlock') {
              invalidThenPlacementUnclosedBlock(block.describe());
            }
          }

          invalidThenPlacementWithoutAwait();
        }
      } else {
        if (block.type != 'ThenBlock' && block.type != 'PendingBlock') {
          for (var node in stack) {
            if (node.type == 'ThenBlock' || node.type == 'PendingBlock') {
              invalidCatchPlacementUnclosedBlock(block.describe());
            }
          }

          invalidCatchPlacementWithoutAwait();
        }
      }

      block.end = start;
      stack.removeLast();

      var awaitBlock = current as AwaitBlock;

      if (!scan('}')) {
        allowSpace(require: true);

        var context = readContext();

        if (isThen) {
          awaitBlock.value = context;
        } else {
          awaitBlock.error = context;
        }

        allowSpace();
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

      allowSpace(require: true);

      var expression = readExpression();
      var block = factory(start: start, expression: expression);

      if (block is AwaitBlock) {
        block
          ..pendingNode = PendingBlock(skip: true)
          ..thenNode = ThenBlock(skip: true)
          ..catchNode = CatchBlock(skip: true);
      }

      allowSpace();

      if (block is EachBlock) {
        // TODO(parser): unreachable code?
        if (scan('as')) {
          allowSpace(require: true);
          block.iterable = readContext();
          allowSpace();
        } else {
          var asExpression = block.expression;

          if (asExpression is! AsExpression) {
            if (canParse) {
              unexpectedToken('as', index);
            }

            unexpectedEOFToken('as');
          }

          block.expression = asExpression.expression;

          // TODO(error): wrap
          var context = asExpression.type as NamedType;
          block.iterable = context.name;
        }

        if (scan(',')) {
          allowSpace();

          var index = readIdentifier();

          if (index == null) {
            expectedName();
          }

          block.index = index;
          allowSpace();
        }

        if (scan('(')) {
          allowSpace();
          block.key = readExpression();
          allowSpace();
          expect(')');
          allowSpace();
        }
      }

      var isThen = scan('then'), isCatch = !isThen && scan('catch');

      if (block is AwaitBlock) {
        if (isThen) {
          if (match(mustacheEndRe)) {
            allowSpace();
          } else {
            allowSpace(require: true);
            block.value = readContext();
            allowSpace();
          }
        } else if (isCatch) {
          if (match(mustacheEndRe)) {
            allowSpace();
          } else {
            allowSpace(require: true);
            block.error = readContext();
            allowSpace();
          }
        }
      }

      expect('}');
      current.children.add(block);
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
      allowSpace(require: true);

      var expression = readExpression();

      allowSpace();
      expect('}');
      current.children.add(RawMustache(start: start, end: index, expression: expression));
    } else if (scan('@debug')) {
      allowSpace();

      var identifiers = <Identifier>[];

      if (scan('}')) {
        // do nothing
      } else {
        do {
          var expression = readExpression();

          if (expression is! Identifier) {
            invalidDebugArgs(start);
          }

          identifiers.add(expression);
        } while (scan(','));

        allowSpace();
        expect('}');
      }

      current.children.add(Debug(start: start, end: index, identifiers: identifiers));
    } else {
      var expression = readExpression();
      allowSpace();
      expect('}');
      current.children.add(Mustache(start: start, end: index, expression: expression));
    }
  }
}
