import 'package:analyzer/dart/ast/ast.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/node.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/read/expression.dart';
import 'package:svelte_ast/src/trim.dart';

final RegExp _ifCase = RegExp('(\\s+case|\\s*})');

final RegExp _ifWhen = RegExp('(\\s+when|\\s*})');

final RegExp _eachAs = RegExp('\\s+as');

final RegExp _eachIndexOrKeyStart = RegExp('(\\s*,|\\s*\\(|\\s*})');

final RegExp _awaitThen = RegExp('(\\s+then|\\s+catch|\\s*})');

final RegExp _awaitCatch = RegExp('(\\s+catch|\\s*})');

extension MustacheParser on Parser {
  void mustache(int start) {
    allowSpace();

    if (scan('/')) {
      _close(start);
    } else if (scan(':else')) {
      _else(start);
    } else if (match(':then') || match(':catch')) {
      _thenCatch(start);
    } else if (scan('#')) {
      _open(start);
    } else if (scan('@html')) {
      _html(start);
    } else if (scan('@debug')) {
      _debug(start);
    } else if (scan('@const')) {
      _const(start);
    } else {
      _expression(start);
    }
  }

  void _close(int start) {
    Node block = current;
    String expected;

    if (block is Element && closingTagOmitted(block.name)) {
      block.end = start;
      stack.removeLast();
      block = current;
    }

    if (block is ElseBlock ||
        block is PendingBlock ||
        block is ThenBlock ||
        block is CatchBlock) {
      block.end = start;
      stack.removeLast();
      block = current;
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
      error(unexpectedBlockClose);
    }

    expect(expected);
    allowSpace();
    expect('}');

    while (block is IfBlock && block.elseIf) {
      block.end = start;
      stack.removeLast();
      block = current;

      if (block is HasElse) {
        block.elseBlock?.end = start;
      }
    }

    bool before = block.start == 0 || spaceRe.hasMatch(string[block.start - 1]);
    bool after = isDone || spaceRe.hasMatch(string[position]);
    trimBlock(block, before, after);

    block.end = position;
    stack.removeLast();
    block = current;
  }

  void _else(int start) {
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
        Expression expression,
        DartPattern? casePattern,
        Expression? whenExpression,
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
        start: start,
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
        start: start,
        children: <Node>[],
      );

      block.elseBlock = elseBlock;
      stack.add(elseBlock);
    }
  }

  void _thenCatch(int start) {
    Node block = current;
    bool isThen = scan(':then') || !scan(':catch');

    if (isThen) {
      if (block is! PendingBlock) {
        for (Node node in stack) {
          if (node is PendingBlock) {
            error(invalidThenPlacementUnclosedBlock(nodeToString(block)));
          }
        }

        error(invalidThenPlacementWithoutAwait);
      }
    } else {
      if (block is! ThenBlock && block is! PendingBlock) {
        for (Node node in stack) {
          if (node is ThenBlock || node is PendingBlock) {
            error(invalidCatchPlacementUnclosedBlock(nodeToString(block)));
          }
        }

        error(invalidCatchPlacementWithoutAwait);
      }
    }

    block.end = start;
    stack.removeLast();

    AwaitBlock awaitBlock = current as AwaitBlock;

    if (!scan(closingCurlyRe)) {
      allowSpace(required: true);

      if (isThen) {
        awaitBlock.value = readAssignmentPattern(_awaitCatch);
      } else {
        awaitBlock.error = readAssignmentPattern(closingCurlyRe);
      }

      allowSpace();
      expect('}');
    }

    Node childBlock;

    if (isThen) {
      childBlock = awaitBlock.thenBlock = ThenBlock(
        start: start,
        children: <Node>[],
      );
    } else {
      childBlock = awaitBlock.catchBlock = CatchBlock(
        start: start,
        children: <Node>[],
      );
    }

    stack.add(childBlock);
  }

  void _open(int start) {
    if (scan('if')) {
      _ifBlock(start);
    } else if (scan('each')) {
      _eachBlock(start);
    } else if (scan('await')) {
      _awaitBlock(start);
    } else if (scan('key')) {
      _keyBlock(start);
    } else {
      error(expectedBlockType);
    }
  }

  IfRest _ifRest() {
    Expression expression = readExpression(_ifCase);
    allowSpace();

    DartPattern? casePattern;

    if (scan('case')) {
      casePattern = readAssignmentPattern(_ifWhen);
    }

    allowSpace();

    Expression? whenExpression;

    if (scan('when')) {
      whenExpression = readExpression(closingCurlyRe);
    }

    return (expression, casePattern, whenExpression);
  }

  void _ifBlock(int start) {
    allowSpace(required: true);

    var (
      Expression expression,
      DartPattern? casePattern,
      Expression? whenExpression,
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
    allowSpace(required: true);

    Expression expression = readExpression(_eachAs);
    allowSpace(required: true);
    expect('as');
    allowSpace(required: true);

    DartPattern context = readAssignmentPattern(_eachIndexOrKeyStart);
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

    if (scan(openingParenRe)) {
      key = readExpression(closingParenRe);
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

  void _awaitBlock(int start) {
    allowSpace(required: true);

    Expression expression = readExpression(_awaitThen);

    AwaitBlock awaitBlock = AwaitBlock(
      start: start,
      expession: expression,
    );

    allowSpace();

    bool awaitBlockThenShorthand = scan('then');

    if (awaitBlockThenShorthand) {
      if (!scan(closingCurlyRe)) {
        allowSpace(required: true);
        awaitBlock.value = readAssignmentPattern(_awaitCatch);
        allowSpace();
      }
    }

    bool awaitBlockCatchShorthand = !awaitBlockThenShorthand && scan('catch');

    if (awaitBlockCatchShorthand) {
      if (!scan(closingCurlyRe)) {
        allowSpace(required: true);
        awaitBlock.error = readAssignmentPattern(closingCurlyRe);
        allowSpace();
      }
    }

    expect('}');

    current.children.add(awaitBlock);
    stack.add(awaitBlock);

    Node childBlock;

    if (awaitBlockThenShorthand) {
      childBlock = awaitBlock.thenBlock = ThenBlock(
        children: <Node>[],
      );
    } else if (awaitBlockCatchShorthand) {
      childBlock = awaitBlock.catchBlock = CatchBlock(
        children: <Node>[],
      );
    } else {
      childBlock = awaitBlock.pendingBlock = PendingBlock(
        children: <Node>[],
      );
    }

    childBlock.start = start;
    stack.add(childBlock);
  }

  void _keyBlock(int start) {
    allowSpace(required: true);

    Expression expression = readExpression(closingCurlyRe);
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
    allowSpace(required: true);

    Expression expression = readExpression(closingCurlyRe);
    allowSpace();
    expect('}');

    current.children.add(RawMustacheTag(
      start: start,
      end: position,
      expression: expression,
    ));
  }

  void _debug(int start) {
    List<SimpleIdentifier> identifiers;

    if (scan(closingCurlyRe)) {
      identifiers = const <SimpleIdentifier>[];
    } else {
      allowSpace();

      identifiers = withScriptParser(position, closingCurlyRe, (parser, token) {
        token = parser.syntheticPreviousToken(token);
        parser.parseIdentifierList(token);
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
    allowSpace(required: true);

    Expression expression = readExpression(closingCurlyRe);

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
    Expression expression = readExpression(closingCurlyRe);
    allowSpace();
    expect('}');

    current.children.add(MustacheTag(
      start: start,
      end: position,
      expression: expression,
    ));
  }
}
