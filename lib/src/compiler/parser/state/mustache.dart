import 'package:analyzer/dart/ast/ast.dart'
    show AsExpression, AssignmentExpression, SimpleIdentifier;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/html.dart';
import 'package:svelte/src/compiler/parser/parser.dart';
import 'package:svelte/src/compiler/parser/read/context.dart';
import 'package:svelte/src/compiler/parser/read/expression.dart';

final RegExp comma = RegExp('\\s*,\\s*');

final RegExp spaceStartRe = RegExp('^[ \t\r\n]*');

final RegExp spaceEndRe = RegExp('[ \t\r\n]*\$');

void trimSpace(TemplateNode block, bool before, bool after) {
  var children = block.children;

  if (children == null || children.isEmpty) {
    return;
  }

  if (before) {
    var first = children.first;

    if (first.type == 'Text') {
      var data = first.data!.replaceAll(spaceStartRe, '');

      if (data.isEmpty) {
        children.removeAt(0);
      } else {
        first.data = data;
      }
    }

    if (first.ifElseIf == true) {
      trimSpace(first, before, after);
    }
  }

  if (after && children.isNotEmpty) {
    var last = children.last;

    if (last.type == 'Text') {
      var data = last.data!.replaceFirst(spaceEndRe, '');

      if (data.isEmpty) {
        children.removeLast();
      } else {
        last.data = data;
      }
    }
  }

  if (block.ifElse != null) {
    trimSpace(block.ifElse!, before, after);
  }
}

extension MustacheParser on Parser {
  void mustache() {
    var start = position;
    expect('{');
    allowSpace();

    if (scan('/')) {
      var block = current;
      String expected;

      if (closingTagOmitted(block.name)) {
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

      while (block.ifElseIf == true) {
        block.end = position;
        stack.removeLast();
        block = current;

        if (block.ifElse != null) {
          block.ifElse!.end = start;
        }
      }

      start = block.start!;

      var before = start == 0 || spaceRe.hasMatch(template[start - 1]);
      var after = isDone || spaceRe.hasMatch(template[position]);
      trimSpace(block, before, after);
      block.end = position;
      stack.removeLast();
    } else if (scan(':else')) {
      if (scan('if')) {
        invalidElseIf();
      }

      allowSpace();

      if (scan('if')) {
        var block = current;

        if (block.type != 'IfBlock') {
          for (var node in stack) {
            if (node.type == 'IfBlock') {
              invalidElseIfPlacementUnclosedBlock(block.toString());
            }
          }

          invalidElseIfPlacementOutsideIf();
        }

        allowSpace(required: true);

        var expression = readExpression();
        allowSpace();
        expect('}');

        var node = TemplateNode(
          start: position,
          type: 'IfBlock',
          ifElseIf: true,
          expression: expression,
          children: <TemplateNode>[],
        );

        block.ifElse = TemplateNode(
          start: position,
          type: 'ElseBlock',
          children: <TemplateNode>[node],
        );

        stack.add(node);
      } else {
        var block = current;

        if (block.type != 'IfBlock' && block.type != 'EachBlock') {
          for (var node in stack) {
            if (node.type == 'IfBlock' || node.type == 'EachBlock') {
              invalidElsePlacementUnclosedBlock(block.toString());
            }
          }

          invalidElsePlacementOutsideIf();
        }

        allowSpace();
        expect('}');

        var node = TemplateNode(
          start: position,
          type: 'ElseBlock',
          children: <TemplateNode>[],
        );

        block.ifElse = node;
        stack.add(node);
      }
    } else if (match(':then') || match(':catch')) {
      var block = current;
      var isThen = scan(':then') || !scan(':catch');

      if (isThen) {
        if (block.type != 'PendingBlock') {
          for (var node in stack) {
            if (node.type == 'PendingBlock') {
              invalidThenPlacementUnclosedBlock(block.toString());
            }
          }

          invalidThenPlacementWithoutAwait();
        }
      } else {
        if (block.type != 'ThenBlock' && block.type != 'PendingBlock') {
          for (var node in stack) {
            if (node.type == 'ThenBlock' || node.type == 'PendingBlock') {
              invalidCatchPlacementUnclosedBlock(block.toString());
            }
          }

          invalidCatchPlacementWithoutAwait();
        }
      }

      block.end = start;
      stack.removeLast();

      var awaitBlock = current;

      if (!scan('}')) {
        allowSpace(required: true);

        if (isThen) {
          awaitBlock.awaitValue = readContext();
        } else {
          awaitBlock.awaitError = readContext();
        }

        allowSpace();
        expect('}');
      }

      var newBlock = TemplateNode(
        start: start,
        type: isThen ? 'ThenBlock' : 'CatchBlock',
        children: <TemplateNode>[],
      );

      if (isThen) {
        awaitBlock.awaitThen = newBlock;
      } else {
        awaitBlock.awaitCatch = newBlock;
      }

      stack.add(newBlock);
    } else if (scan('#')) {
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

      allowSpace(required: true);

      var expression = readExpression();

      if (expression is AsExpression) {
        expression = expression.expression;
        position = expression.end;
      }

      var block = TemplateNode(
        start: start,
        type: type,
        expression: expression,
        children: <TemplateNode>[],
      );

      allowSpace();

      if (type == 'EachBlock') {
        expect('as');
        allowSpace(required: true);
        block.eachContext = readContext();
        allowSpace();

        if (scan(',')) {
          allowSpace();

          var index = readIdentifier();

          if (index == null) {
            expectedName();
          }

          block.eachIndex = index;
          allowSpace();
        }

        if (scan('(')) {
          allowSpace();
          block.eachKey = readExpression();
          allowSpace();
          expect(')');
          allowSpace();
        }
      }

      TemplateNode? child;

      if (type == 'AwaitBlock') {
        if (scan('then')) {
          if (match(closeCurlRe)) {
            allowSpace();
          } else {
            allowSpace(required: true);
            block.awaitValue = readContext();
            allowSpace();

            child = TemplateNode(
              type: 'ThenBlock',
              children: <TemplateNode>[],
            );

            block.awaitThen = child;
          }
        } else if (scan('catch')) {
          if (match(closeCurlRe)) {
            allowSpace();
          } else {
            allowSpace(required: true);
            block.awaitError = readContext();
            allowSpace();

            child = TemplateNode(
              type: 'CatchBlock',
              children: <TemplateNode>[],
            );

            block.awaitCatch = child;
          }
        } else {
          child = TemplateNode(
            type: 'PendingBlock',
            children: <TemplateNode>[],
          );

          block.awaitPending = child;
        }
      }

      expect('}');
      current.children!.add(block);
      stack.add(block);

      if (child != null) {
        child.start = position;
        stack.add(child);
      }
    } else if (scan('@html')) {
      allowSpace(required: true);

      var expression = readExpression();
      allowSpace();
      expect('}');

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'RawMustacheTag',
        expression: expression,
      ));
    } else if (scan('@debug')) {
      var identifiers = <SimpleIdentifier>[];

      if (!scan(closeCurlRe)) {
        allowSpace(required: true);

        do {
          var expression = readExpression();

          if (expression is! SimpleIdentifier) {
            invalidDebugArgs(start);
          }

          identifiers.add(expression);
        } while (scan(comma));

        allowSpace();
        expect('}');
      }

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'DebugTag',
        identifiers: identifiers,
      ));
    } else if (scan('@const')) {
      allowSpace(required: true);

      var expression = readExpression();

      if (expression is! AssignmentExpression ||
          expression.operator.lexeme != '=') {
        error(
          code: 'invalid-const-args',
          message: '{@const ...} must be an assignment',
          position: start,
        );
      }

      allowSpace();
      expect('}');

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'ConstTag',
        expression: expression,
      ));
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
