// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/ast.dart' show AstNode;
import 'package:analyzer/dart/ast/token.dart' show Keyword, Token;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read/expression.dart';

final RegExp _scriptCloseTag = RegExp('<\\/script\\s*>');

extension ScriptParser on Parser {
  String _getContext(int start, List<Node> nodes) {
    Attribute? attribute;

    for (Node node in nodes) {
      if (node case Attribute(name: 'context')) {
        attribute = node;
      }
    }

    if (attribute == null) {
      return 'default';
    }

    if (attribute.value case <Node>[Text(data: String data)]) {
      if (data == 'module') {
        return data;
      }

      error(invalidScriptContextValue, start);
    }

    error(invalidScriptContextAttribute, start);
  }

  void readScript(int start, List<Node> attributes) {
    expect('>');

    String context = _getContext(start, attributes);

    int dataStart = position;
    String data = readUntil(_scriptCloseTag, unclosedScript);

    if (isDone) {
      error(unclosedScript);
    }

    int dataEnd = position;
    expect(_scriptCloseTag);

    if (context == 'default') {
      List<AstNode> body = <AstNode>[];

      withScriptParserRun(dataStart, _scriptCloseTag, (parser, token) {
        AstBuilder builder = parser.builder;

        Token previousToken = parser.syntheticPreviousToken(token);
        Token next = previousToken.next!;

        while (!next.isEof) {
          if (next case Token(type: Keyword.IMPORT)) {
            next = parser.parseMetadataStar(next);
            next = parser.parseImport(next);
            next = next.next!;
          } else if (next case Token(type: Keyword.EXTERNAL)) {
            next = parser.parseMetadataStar(next);
            next = parser.parseTopLevelMember(next);
          } else {
            next = parser.parseStatement(next.previous!);
            next = next.next!;
          }
        }

        body.addAll(builder.directives);
        body.addAll(builder.declarations);
        body.addAll(builder.stack.values.whereType<AstNode>());
      });

      scripts.add(Script(
        start: start,
        end: position,
        context: context,
        content: (
          start: dataStart,
          end: dataEnd,
          data: data,
        ),
        body: body,
      ));
    } else {
      throw UnimplementedError('module script');
    }
  }
}
