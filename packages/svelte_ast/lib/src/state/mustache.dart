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

void _trimBlock(Node? block, bool before, bool after) {
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
    _trimBlock(block.elseBlock, before, after);
  }

  if (first is IfBlock && first.elseIf) {
    _trimBlock(first, before, after);
  }
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
    return switch (token.type) {
      Keyword.IF => _ifBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'each' => _eachBlock(start),
      Keyword.AWAIT => _awaitBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'key' => _keyBlock(start),
      _ => throw StateError(token.type.name),
    };
  }

  IfBlock _ifBlock(Token open, [bool elseIf = false]) {
    expectToken(Keyword.IF);

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

    IfBlock ifBlock = IfBlock(
      start: open.offset,
      expression: expression,
      casePattern: casePattern,
      whenExpression: whenExpression,
      children: _body('if', (token) {
        return _isElse(token) || _isEndIf(token);
      }),
      elseIf: elseIf,
    );

    open = token.previous!;

    if (skipNextTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);

      if (matchToken(TokenType.CLOSE_CURLY_BRACKET)) {
        List<Node> children = _body('ifElse', _isEndIf);
        expectToken(TokenType.SLASH);
        expectToken(Keyword.IF);
        expectToken(TokenType.CLOSE_CURLY_BRACKET);
        ifBlock.elseBlock = ElseBlock(
          start: open.offset,
          end: token.end,
          children: children,
        );
      } else {
        IfBlock elseIfBlock = _ifBlock(token, true);
        ifBlock.elseBlock = ElseBlock(
          start: open.offset,
          end: token.end,
          children: <Node>[elseIfBlock],
        );
      }
    } else {
      expectToken(TokenType.SLASH);
      expectToken(Keyword.IF);
      expectToken(TokenType.CLOSE_CURLY_BRACKET);
    }

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

    if (skipNextTokenIf(TokenType.COLON)) {
      Token elseToken = expectToken(Keyword.ELSE);
      List<Node> children = _body('eachElse', _isEndEach);
      eachBlock.elseBlock = ElseBlock(
        start: elseToken.offset,
        end: token.end,
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
    Expression future = astBuilder.pop() as Expression;
    nextToken();

    List<Node>? futureBody;

    if (token.type == TokenType.CLOSE_CURLY_BRACKET) {
      futureBody = _body('awaitFuture', (token) {
        return _isThen(token) || _isCatch(token) || _isEndAwait(token);
      });
    }

    String? then_;
    List<Node>? thenBody;

    if (skipNextTokenIf(TokenType.IDENTIFIER, 'then') ||
        _isThen(token) && skipToken(2)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      then_ = identifierToken.lexeme;
    }

    if (then_ != null) {
      thenBody = _body('awaitThen', (token) {
        return _isCatch(token) || _isEndAwait(token);
      });
    }

    String? catch_;
    List<Node>? catchBody;

    if (skipNextTokenIf(Keyword.CATCH) || _isCatch(token) && skipToken(2)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      catch_ = identifierToken.lexeme;
    }

    if (catch_ != null) {
      catchBody = _body('awaitCatch', _isEndAwait);
    }

    expectToken(TokenType.SLASH);
    expectToken(Keyword.AWAIT);
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return AwaitBlock(
        start: open.offset,
        end: token.end,
        future: future,
        futureBody: futureBody,
        then_: then_,
        thenBody: thenBody,
        catch_: catch_,
        catchBody: catchBody);
  }

  KeyBlock _keyBlock(Token open) {
    expectToken(TokenType.IDENTIFIER, 'key');

    token = parser.syntheticPreviousToken(token);
    token = parser.parsePattern(token, PatternContext.assignment);
    Expression key = astBuilder.pop() as Expression;
    nextToken();

    List<Node> body = _body('key', _isEndKey);
    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'key');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return KeyBlock(
      start: open.offset,
      end: token.end,
      expression: key,
      children: body,
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
        Token next = token.next!;

        if (end(next)) {
          token = next;
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
