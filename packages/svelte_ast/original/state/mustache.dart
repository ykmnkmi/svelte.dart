// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart'
    show PatternContext;
import 'package:analyzer/dart/ast/ast.dart'
    show
        AssignmentExpression,
        DartPattern,
        Expression,
        PatternAssignment,
        SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/node.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/trim.dart';

import '../parser.dart';
import '../read/expression.dart';

final RegExp _ifCase = RegExp('(\\s+case|\\s*})');

final RegExp _ifWhen = RegExp('(\\s+when|\\s*})');

final RegExp _eachAs = RegExp('\\s+as');

final RegExp _eachIndexOrKey = RegExp('(\\s*,|\\s*\\(|\\s*})');

final RegExp _eachKey = RegExp('\\s*\\)');

void trimBlock(Node? block, bool before, bool after) {
  if (block == null || block.children.isEmpty) {
    return;
  }

  Node first = block.children.first;

  if (first is Text && before) {
    String data = trimStart(first.data);

    if (data.isEmpty) {
      block.children.removeAt(0);
    } else {
      first.data = data;
    }
  }

  Node last = block.children.last;

  if (last is Text && after) {
    last.data = trimEnd(last.data);

    if (last.data.isEmpty) {
      block.children.removeLast();
    }
  }

  if (block is HasElse) {
    trimBlock(block.elseBlock, before, after);
  }

  if (first is IfBlock && first.elseIf) {
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
        stack.removeLast();
        block = current;
      }

      if (block is ElseBlock) {
        block.end = start;
        stack.removeLast();
        block = current;
      }

      if (block is IfBlock) {
        expected = 'if';
      } else if (block is EachBlock) {
        expected = 'each';
      } else if (block is KeyBlock) {
        expected = 'key';
      } else {
        error(unexpectedBlockClose);
      }

      expect(expected);
      allowSpace();
      expect('}');

      while (block is IfBlock && block.elseIf) {
        block.end = position;
        stack.removeLast();
        block = current;

        if (block case HasElse(elseBlock: ElseBlock elseBlock?)) {
          elseBlock.end = start;
        }
      }

      bool before =
          block.start == 0 || spaceRe.hasMatch(string[block.start - 1]);
      bool after = isDone || spaceRe.hasMatch(string[position]);
      trimBlock(block, before, after);

      block.end = position;
      stack.removeLast();
      block = current;
    } else if (scan(':else')) {
      if (scan('if')) {
        error(invalidElseIf);
      }

      allowSpace();

      if (scan('if')) {
        Node block = current;

        if (block is! IfBlock) {
          for (Node node in stack) {
            if (node is IfBlock) {
              error(invalidElsePlacementUnclosedBlock(nodeToString(block)));
            }
          }

          error(invalidElseIfPlacementOutsideIf);
        }

        allowSpace(required: true);

        var (
          expression,
          casePattern,
          whenExpression,
        ) = _ifRest();

        allowSpace();
        expect('}');

        IfBlock ifBlock = IfBlock(
          start: start,
          expression: expression,
          casePattern: casePattern,
          whenExpression: whenExpression,
          children: <Node>[],
          elseIf: true,
        );

        block.elseBlock = ElseBlock(
          start: position,
          children: <Node>[ifBlock],
        );

        stack.add(ifBlock);
      } else {
        Node block = current;

        if (block is! HasElse) {
          for (Node node in stack) {
            if (node is HasElse) {
              error(invalidElsePlacementUnclosedBlock(nodeToString(block)));
            }
          }

          error(invalidElseIfPlacementOutsideIf);
        }

        allowSpace();
        expect('}');

        ElseBlock elseBlock = ElseBlock(
          start: position,
          children: <Node>[],
        );

        block.elseBlock = elseBlock;
        stack.add(elseBlock);
      }
    } else if (scan('#')) {
      if (match('if')) {
        _ifBlock(start);
      } else if (match('each')) {
        _eachBlock(start);
      } else if (match('key')) {
        _keyBlock(start);
      } else {
        error(expectedBlockType);
      }
    } else if (match('@html')) {
      _html(start);
    } else if (match('@debug')) {
      _debug(start);
    } else if (match('@const')) {
      _const(start);
    } else {
      _expression(start);
    }
  }

  IfRest _ifRest() {
    Expression expression = readExpression(_ifCase);
    allowSpace();

    DartPattern? casePattern;

    if (scan('case')) {
      casePattern = withDartParser<DartPattern>(_ifWhen, (parser, token) {
        return parser.parsePattern(token, PatternContext.matching);
      });
    }

    allowSpace();

    Expression? whenExpression;

    if (scan('when')) {
      whenExpression = withDartParser<Expression>(_ifWhen, (parser, token) {
        return parser.parseExpression(token);
      });
    }

    return (expression, casePattern, whenExpression);
  }

  void _ifBlock(int start) {
    expect('if');
    allowSpace(required: true);

    var (
      expression,
      casePattern,
      whenExpression,
    ) = _ifRest();

    allowSpace();
    expect('}');

    IfBlock ifBlock = IfBlock(
      start: start,
      expression: expression,
      casePattern: casePattern,
      whenExpression: whenExpression,
      children: <Node>[],
    );

    current.children.add(ifBlock);
    stack.add(ifBlock);
  }

  void _eachBlock(int start) {
    expect('each');
    allowSpace(required: true);

    Expression expression = readExpression(_eachAs);
    allowSpace(required: true);
    expect('as');
    allowSpace(required: true);

    DartPattern context = readAssignmentPattern(_eachIndexOrKey);
    allowSpace();

    String? index;

    if (scan(',')) {
      allowSpace();
      index = readIdentifier();

      if (index == null || index.isEmpty) {
        error(expectedName);
      }

      allowSpace();
    }

    Expression? key;

    if (scan('(')) {
      allowSpace();
      key = readExpression(_eachKey);
      allowSpace();
      expect(')');
    }

    allowSpace();
    expect('}');

    EachBlock eachBlock = EachBlock(
      start: start,
      expression: expression,
      context: context,
      index: index,
      key: key,
      children: <Node>[],
    );

    current.children.add(eachBlock);
    stack.add(eachBlock);
  }

  void _keyBlock(int start) {
    expect('key');
    allowSpace(required: true);

    Expression expression = readExpression('}');
    allowSpace();
    expect('}');

    KeyBlock keyBlock = KeyBlock(
      start: start,
      expression: expression,
      children: <Node>[],
    );

    current.children.add(keyBlock);
    stack.add(keyBlock);
  }

  void _html(int start) {
    expect('@html');
    allowSpace(required: true);

    Expression expression = readExpression('}');
    allowSpace();
    expect('}');

    current.children.add(RawMustacheTag(
      start: start,
      end: position,
      expression: expression,
    ));
  }

  void _debug(int start) {
    expect('@debug');
    allowSpace(required: true);

    List<SimpleIdentifier> identifiers;

    if (scan('}')) {
      identifiers = const <SimpleIdentifier>[];
    } else {
      identifiers = withDartParser('}', (parser, token) {
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
  }

  void _const(int start) {
    expect('@const');
    allowSpace(required: true);

    Expression expression = readExpression('}');

    if (!(expression is AssignmentExpression ||
        expression is PatternAssignment)) {
      error(invalidConstArgs, start);
    }

    allowSpace();
    expect('}');

    current.children.add(ConstTag(
      start: start,
      end: position,
      expression: expression,
    ));
  }

  void _expression(int start) {
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
