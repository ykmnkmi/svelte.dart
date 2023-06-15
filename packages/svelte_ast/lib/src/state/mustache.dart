// ignore_for_file: depend_on_referenced_packages, directives_ordering, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart'
    show PatternContext;
import 'package:_fe_analyzer_shared/src/scanner/token.dart'
    show Token, TokenType, Keyword;
import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/scanner.dart';
import 'package:svelte_ast/src/state/text.dart';
import 'package:svelte_ast/src/trim.dart';

bool _isElse(Token token) {
  return token.type == TokenType.COLON && token.next!.type == Keyword.ELSE;
}

bool _isEndIf(Token token) {
  return token.type == TokenType.SLASH && token.next!.type == Keyword.IF;
}

bool _isEndEach(Token token) {
  return token.type == TokenType.SLASH &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'each';
}

bool _isThen(Token token) {
  return token.type == TokenType.COLON &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'then';
}

bool _isCatch(Token token) {
  return token.type == TokenType.COLON && token.next!.type == Keyword.CATCH;
}

bool _isEndAwait(Token token) {
  return token.type == TokenType.SLASH && token.next!.type == Keyword.AWAIT;
}

bool _isEndKey(Token token) {
  return token.type == TokenType.SLASH &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'key';
}

extension MustacheParser on Parser {
  Node mustache() {
    Token open = expectToken(TokenType.OPEN_CURLY_BRACKET);
    return switch (token.type) {
      TokenType.HASH => _block(open),
      TokenType.AT => _at(open),
      _ => _expression(open),
    };
  }

  Node _block(Token start) {
    expectToken(TokenType.HASH);

    Node block = switch (token.type) {
      Keyword.IF => _ifBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'each' => _eachBlock(start),
      Keyword.AWAIT => _awaitBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'key' => _keyBlock(start),
      _ => throw StateError(token.type.name),
    };

    bool before = block.start == 0 || spaceRe.hasMatch(string[block.start - 1]);
    bool after = isDone || spaceRe.hasMatch(string[position]);
    trimBlock(block, before, after);
    return block;
  }

  IfRest _ifRest() {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression expression = astBuilder.pop() as Expression;
    nextToken();

    DartPattern? casePattern;

    if (skipNextTokenIf(Keyword.CASE)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, PatternContext.matching);
      casePattern = astBuilder.pop() as DartPattern;
      nextToken();
    }

    Expression? whenExpression;

    if (skipNextTokenIf(Keyword.WHEN)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      whenExpression = astBuilder.pop() as Expression;
      nextToken();
    }

    return (expression, casePattern, whenExpression);
  }

  IfBlock _ifBlock(Token open) {
    expectToken(Keyword.IF);

    var (
      expression,
      casePattern,
      whenExpression,
    ) = _ifRest();

    IfBlock ifBlock = IfBlock(
      start: open.offset,
      expression: expression,
      casePattern: casePattern,
      whenExpression: whenExpression,
      children: _body('if', (token) {
        return _isElse(token) || _isEndIf(token);
      }),
    );

    open = nextToken();

    IfBlock currentIfBlock = ifBlock;
    List<Node> blocks = <Node>[];

    while (skipNextTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);

      if (matchToken(TokenType.CLOSE_CURLY_BRACKET)) {
        List<Node> children = _body('ifElse', _isEndIf);

        ElseBlock elseBlock = ElseBlock(
          start: open.offset,
          children: children,
        );

        blocks.add(elseBlock);
        currentIfBlock.elseBlock = elseBlock;
        open = nextToken();
        break;
      }

      expectToken(Keyword.IF);

      var (
        expression,
        casePattern,
        whenExpression,
      ) = _ifRest();

      List<Node> children = _body('if', (token) {
        return _isElse(token) || _isEndIf(token);
      });

      IfBlock elseIfBlock = IfBlock(
        start: open.offset,
        expression: expression,
        casePattern: casePattern,
        whenExpression: whenExpression,
        children: children,
        elseIf: true,
      );

      ElseBlock elseBlock = ElseBlock(
        start: open.offset,
        children: <Node>[elseIfBlock],
      );

      blocks.add(elseBlock);
      blocks.add(elseIfBlock);
      currentIfBlock.elseBlock = elseBlock;
      currentIfBlock = elseIfBlock;
      open = nextToken();
    }

    for (Node block in blocks) {
      block.end = open.offset;
    }

    expectToken(TokenType.SLASH);
    expectToken(Keyword.IF);
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    ifBlock.end = token.end;
    return ifBlock;
  }

  EachBlock _eachBlock(Token open) {
    expectToken(TokenType.IDENTIFIER, 'each');

    token = parser.syntheticPreviousToken(token);
    token = parser.parsePattern(token, PatternContext.assignment);
    DartPattern context = astBuilder.pop() as DartPattern;
    nextToken();

    expectToken(Keyword.IN);

    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression expression = astBuilder.pop() as Expression;
    nextToken();

    String? index;

    if (skipNextTokenIf(TokenType.COMMA)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      index = identifierToken.lexeme;
    }

    Expression? key;

    if (skipNextTokenIf(TokenType.OPEN_PAREN)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      key = astBuilder.pop() as Expression;
      nextToken();
      expectToken(TokenType.CLOSE_PAREN);
    }

    EachBlock eachBlock = EachBlock(
      start: open.offset,
      expression: expression,
      context: context,
      index: index,
      key: key,
      children: _body('each', (token) {
        return _isElse(token) || _isEndEach(token);
      }),
    );

    open = nextToken();

    if (skipNextTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);

      List<Node> children = _body('eachElse', _isEndEach);
      Token close = nextToken();
      eachBlock.elseBlock = ElseBlock(
        start: open.offset,
        end: close.offset,
        children: children,
      );
    }

    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'each');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    eachBlock.end = token.end;
    return eachBlock;
  }

  AwaitBlock _awaitBlock(Token open) {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression expression = astBuilder.pop() as Expression;
    nextToken();

    AwaitBlock awaitBlock = AwaitBlock(
      start: open.offset,
      expession: expression,
    );

    if (token.type == TokenType.CLOSE_CURLY_BRACKET) {
      List<Node> children = _body('awaitFuture', (token) {
        return _isThen(token) || _isCatch(token) || _isEndAwait(token);
      });

      awaitBlock.pendingBlock = PendingBlock(
        start: open.offset,
        end: token.offset,
        children: children,
      );

      open = nextToken();
    }

    if (skipNextTokenIf(TokenType.IDENTIFIER, 'then') ||
        _isThen(token) && skipToken(2)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, PatternContext.assignment);
      awaitBlock.value = astBuilder.pop() as DartPattern;
      nextToken();
    }

    if (awaitBlock.value != null) {
      List<Node> children = _body('awaitThen', (token) {
        return _isCatch(token) || _isEndAwait(token);
      });

      awaitBlock.thenBlock = ThenBlock(
        start: open.offset,
        end: token.offset,
        children: children,
      );

      open = nextToken();
    }

    if (skipNextTokenIf(Keyword.CATCH) || _isCatch(token) && skipToken(2)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, PatternContext.assignment);
      awaitBlock.error = astBuilder.pop() as DartPattern;
      nextToken();
    }

    if (awaitBlock.error != null) {
      List<Node> children = _body('awaitCatch', _isEndAwait);

      awaitBlock.catchBlock = CatchBlock(
        start: open.offset,
        end: token.offset,
        children: children,
      );

      nextToken();
    }

    expectToken(TokenType.SLASH);
    expectToken(Keyword.AWAIT);
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    awaitBlock.end = token.offset;
    return awaitBlock;
  }

  KeyBlock _keyBlock(Token open) {
    expectToken(TokenType.IDENTIFIER, 'key');

    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression key = astBuilder.pop() as Expression;
    nextToken();

    List<Node> children = _body('key', _isEndKey);
    nextToken();
    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'key');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return KeyBlock(
      start: open.offset,
      end: token.end,
      expression: key,
      children: children,
    );
  }

  List<Node> _body(String tag, bool Function(Token token) end) {
    expectToken(TokenType.CLOSE_CURLY_BRACKET);

    List<Node> nodes = <Node>[];
    String endTag = '$tag-${token.offset}';
    endTagsStack.add(endTag);

    outer:
    while (token.type != TokenType.EOF) {
      if (token.type == TokenType.OPEN_CURLY_BRACKET) {
        if (token.next case Token next? when end(next)) {
          break outer;
        }

        nodes.add(mustache());
      } else if (token.type == SvelteToken.DATA) {
        nodes.add(text());
      }
    }

    if (endTagsStack.isEmpty || endTagsStack.removeLast() != endTag) {
      throw StateError('Expected token type $tag, got $token.');
    }

    if (token.type == TokenType.EOF) {
      throw StateError('EOF');
    }

    return nodes;
  }

  Node _at(Token open) {
    expectToken(TokenType.AT);
    return switch (token.type) {
      TokenType.IDENTIFIER when token.lexeme == 'html' => _html(open),
      TokenType.IDENTIFIER when token.lexeme == 'debug' => _debug(open),
      Keyword.CONST => _const(open),
      _ => throw StateError(token.type.name),
    };
  }

  RawMustacheTag _html(Token open) {
    expectToken(TokenType.IDENTIFIER, 'html');
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return RawMustacheTag(
        start: open.offset, end: close.end, expression: value);
  }

  DebugTag _debug(Token open) {
    expectToken(TokenType.IDENTIFIER, 'debug');

    List<SimpleIdentifier>? identifiers;

    if (!skipNextTokenIf(TokenType.CLOSE_CURLY_BRACKET)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseIdentifierList(token);
      nextToken();
      identifiers = astBuilder.pop() as List<SimpleIdentifier>;
    }

    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return DebugTag(
        start: open.offset, end: close.end, identifiers: identifiers);
  }

  ConstTag _const(Token open) {
    expectToken(Keyword.CONST);
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Object? assign = astBuilder.pop();

    if (assign is! AssignmentExpression) {
      error(invalidConstArgs, open.offset);
    }

    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return ConstTag(start: open.offset, end: close.end, expression: assign);
  }

  MustacheTag _expression(Token open) {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return MustacheTag(start: open.offset, end: close.end, expression: value);
  }
}
