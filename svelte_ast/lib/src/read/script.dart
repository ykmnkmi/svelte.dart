// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/fasta/ast_builder.dart';
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

    if (attribute.value case <Node>[Text(data: String data)]?) {
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

    List<AstNode> directives = <AstNode>[];
    List<AstNode> properties = <AstNode>[];
    List<AstNode> nodes = <AstNode>[];

    withScriptParserRun(dataStart, _scriptCloseTag, (parser, token) {
      AstBuilder builder = parser.builder;

      if (context == 'default') {
        builder.beginCompilationUnit(token);

        Token previousToken = parser.syntheticPreviousToken(token);
        Token next = previousToken.next!;

        while (!next.isEof) {
          next = parser.parseMetadataStar(next);

          if (next case Token(type: Keyword.LIBRARY)) {
            next = parser.parseLibraryName(next);
            directives.add(builder.pop() as AstNode);
            next = next.next!;
          } else if (next case Token(type: Keyword.IMPORT)) {
            next = parser.parseImport(next);
            directives.add(builder.pop() as AstNode);
            next = next.next!;
          } else if (next case Token(type: Keyword.EXPORT || Keyword.PART)) {
            throw UnimplementedError();
          } else if (next case Token(type: Keyword.EXTERNAL)) {
            next = next.next!;
            next = parser.parseStatement(next.previous!);
            properties.add(builder.pop() as AstNode);
            next = next.next!;
          } else {
            next = parser.parseStatement(next.previous!);
            nodes.add(builder.pop() as AstNode);
            next = next.next!;
          }
        }
      } else {
        parser.parseUnit(token);

        CompilationUnit unit = builder.pop() as CompilationUnit;
        directives.addAll(unit.directives);
        nodes.addAll(unit.declarations);
      }
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
      body: (
        directives: directives,
        properties: properties,
        nodes: nodes,
      ),
    ));
  }
}
