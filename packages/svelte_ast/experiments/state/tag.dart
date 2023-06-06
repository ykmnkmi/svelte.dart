// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/scanner/token.dart'
    show Token, TokenType;
import 'package:svelte_ast/src/ast.dart';

import '../parser.dart';
import '../scanner.dart';
import 'mustache.dart';
import 'text.dart';

extension TagParser on Parser {
  Node? tag() {
    Token open = expectToken(SvelteToken.OPEN_TAG_START);
    Token tagNameToken = expectToken(SvelteToken.TAG_NAME);
    String tagName = tagNameToken.lexeme;

    skipNextTokenIf(SvelteToken.TAG_SPACE);

    List<Node> body = _body(tagName, (token) {
      return token.type == SvelteToken.TAG_NAME && token.lexeme == tagName;
    });

    skipNextTokenIf(SvelteToken.TAG_SPACE);
    Token close = expectToken(SvelteToken.TAG_END);
    return Element(
        start: open.offset, end: close.end, name: tagName, body: body);
  }

  List<Node> _body(String tag, bool Function(Token token) end) {
    expectToken(SvelteToken.TAG_END);

    List<Node> nodes = <Node>[];
    String endTag = '$tag-${token.offset}';
    endTagsStack.add(endTag);

    outer:
    while (token.type != TokenType.EOF) {
      if (token.type == SvelteToken.CLOSE_TAG_START) {
        Token next = token.next!;

        if (end(next)) {
          token = next.next!;
          break outer;
        }
      } else if (token.type == TokenType.OPEN_CURLY_BRACKET) {
        nodes.add(mustache());
      } else if (text() case var node?) {
        nodes.add(node);
      }
    }

    if (endTagsStack.isEmpty || endTagsStack.last != endTag) {
      throw StateError('Expected token type $tag, got ${token.lexeme}.');
    } else {
      endTagsStack.removeLast();
    }

    if (token.type == TokenType.EOF) {
      throw StateError('EOF');
    }

    return nodes;
  }
}
