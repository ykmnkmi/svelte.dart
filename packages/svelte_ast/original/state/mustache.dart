import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, Expression, PatternAssignment, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/html.dart';

import '../parser.dart';
import '../patterns.dart';
import '../read/expression.dart';
import '../trim.dart';

void trimBlock(Node block, bool before, bool after) {
  if (block.children.isEmpty) {
    return;
  }

  Node first = block.children.first;

  if (first is Text && before) {
    first.data = trimStart(first.data);

    if (first.data.isEmpty) {
      block.children.removeAt(0);
    }
  }

  Node last = block.children.last;

  if (last is Text && after) {
    last.data = trimStart(last.data);

    if (last.data.isEmpty) {
      block.children.removeLast();
    }
  }

  if (block is HasElse) {
    trimBlock(first, before, after);
  }
}

extension MustacheParser on Parser {
  void mustache() {
    int start = position;
    expect('{');
    allowSpace();

    if (scan('/')) {
      Node block = current;
      String expected;

      if (block is Element && closingTagOmitted(block.name)) {
        block.end = start;
        block = stack.removeLast();
      }

      if (block is KeyBlock) {
        expected = 'key';
      } else {
        error(unexpectedBlockClose);
      }

      expect(expected);
      allowSpace();
      expect('}');

      bool before =
          block.start > 0 && spaceRe.hasMatch(string[block.start - 1]);
      bool after = isNotDone && spaceRe.hasMatch(string[position]);
      trimBlock(block, before, after);

      block.end = position;
      stack.removeLast();
    } else if (scan('#')) {
      if (scan('key')) {
        allowSpace(required: true);

        Expression key = readExpression('}');
        allowSpace();
        expect('}');

        KeyBlock keyBlock = KeyBlock(
          start: start,
          key: key,
          children: <Node>[],
        );

        current.children.add(keyBlock);
        stack.add(keyBlock);
      } else {
        error(expectedBlockType);
      }
    } else if (scan('@html')) {
      allowSpace(required: true);

      Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      current.children.add(RawMustacheTag(
        start: start,
        end: position,
        expression: expression,
      ));
    } else if (scan('@debug')) {
      allowSpace(required: true);

      List<SimpleIdentifier> identifiers;

      if (scan('}')) {
        identifiers = const <SimpleIdentifier>[];
      } else {
        identifiers = withExpressionParser('}', (parser, token) {
          return parser.parseIdentifierList(token);
        });
      }

      allowSpace();
      expect('}');

      current.children.add(DebugTag(
        start: start,
        end: position,
        identifiers: identifiers,
      ));
    } else if (scan('@const')) {
      allowSpace(required: true);

      Expression assign = readExpression('}');

      if (!(assign is AssignmentExpression || assign is PatternAssignment)) {
        error(invalidConstArgs, start);
      }

      allowSpace();
      expect('}');

      current.children.add(ConstTag(
        start: start,
        end: position,
        assign: assign,
      ));
    } else {
      Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      current.children.add(MustacheTag(
        start: start,
        end: position,
        expression: expression,
      ));
    }
  }
}
