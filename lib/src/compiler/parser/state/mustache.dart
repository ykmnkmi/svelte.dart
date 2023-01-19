import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, SimpleIdentifier;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/html.dart';
import 'package:svelte/src/compiler/parser/parser.dart';
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

    if (first.elseIf == true) {
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

  if (block.elseNode != null) {
    trimSpace(block.elseNode!, before, after);
  }
}

extension MustacheParser on Parser {
  void mustache() {
    var start = position;
    expect(openCurlRe);

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
      expect(openCurlRe);

      while (block.elseIf == true) {
        block.end = position;
        stack.removeLast();
        block = current;

        if (block.elseNode != null) {
          block.elseNode!.end = start;
        }
      }

      start = block.start!;

      var before = start != 0 && spaceRe.hasMatch(template[start - 1]);
      var after = isNotDone && spaceRe.hasMatch(template[position]);
      trimSpace(block, before, after);
      block.end = position;
      stack.removeLast();
    } else if (scan(':else')) {
      if (scan('if')) {
        invalidElseIf();
      }

      allowSpace(require: true);

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

        allowSpace(require: true);

        var expression = readExpression();
        expect(closeCurlRe);

        var node = TemplateNode(
          start: position,
          type: 'IfBlock',
          elseIf: true,
          expression: expression,
          children: <TemplateNode>[],
        );

        block.elseNode = TemplateNode(
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

        expect(closeCurlRe);

        var node = TemplateNode(
          start: position,
          type: 'ElseBlock',
          children: <TemplateNode>[],
        );

        block.elseNode = node;
        stack.add(node);
      }
    } else if (match('#')) {
      throw UnimplementedError();
    } else if (scan('@html')) {
      allowSpace(require: true);

      var expression = readExpression();
      expect(closeCurlRe);

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'RawMustacheTag',
        expression: expression,
      ));
    } else if (scan('@debug')) {
      var identifiers = <SimpleIdentifier>[];

      if (!scan(closeCurlRe)) {
        allowSpace(require: true);

        do {
          var expression = readExpression();

          if (expression is! SimpleIdentifier) {
            invalidDebugArgs(start);
          }

          identifiers.add(expression);
        } while (scan(comma));

        expect(closeCurlRe);
      }

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'DebugTag',
        identifiers: identifiers,
      ));
    } else if (scan('@const')) {
      allowSpace(require: true);

      var expression = readExpression();

      if (expression is! AssignmentExpression ||
          expression.operator.lexeme != '=') {
        error(
          code: 'invalid-const-args',
          message: '{@const ...} must be an assignment',
          position: start,
        );
      }

      expect(closeCurlRe);

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'ConstTag',
        expression: expression,
      ));
    } else {
      var expression = readExpression();
      expect(closeCurlRe);

      current.children!.add(TemplateNode(
        start: start,
        end: position,
        type: 'MustacheTag',
        expression: expression,
      ));
    }
  }
}
