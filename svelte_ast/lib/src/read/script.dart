// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/ast.dart' hide Directive;
import 'package:analyzer/src/dart/ast/ast.dart' as dart show Directive;
import 'package:analyzer/src/fasta/ast_builder.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read/expression.dart';
import 'package:svelte_ast/src/read/script_parser.dart' as script_parser;

final RegExp _scriptCloseTag = RegExp('<\\/script\\s*>');

extension ScriptParser on Parser {
  String _getContext(int start, List<Node> nodes) {
    Attribute? attribute;

    for (Node node in nodes) {
      if (node is Attribute && node.name == 'context') {
        attribute = node;
      }
    }

    if (attribute == null) {
      return 'default';
    }

    List<Node> values = attribute.values;

    if (values.length == 1) {
      Node text = values.first;

      if (text is Text && text.data == 'module') {
        return 'module';
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

    List<dart.Directive> directives = <dart.Directive>[];
    List<VariableDeclarationStatement> properties =
        <VariableDeclarationStatement>[];
    List<AstNode> nodes = <AstNode>[];

    void scriptParser(script_parser.ScriptParser parser, Token token) {
      AstBuilder builder = parser.builder;

      if (context == 'default') {
        builder.beginCompilationUnit(token);

        Token previousToken = parser.syntheticPreviousToken(token);
        Token next = previousToken.next!;

        while (!next.isEof) {
          next = parser.parseMetadataStar(next);

          if (next.type == Keyword.LIBRARY) {
            next = parser.parseLibraryName(next);
            directives.add(builder.pop() as dart.Directive);
            next = next.next!;
          } else if (next.type == Keyword.IMPORT) {
            next = parser.parseImport(next);
            directives.add(builder.directives.removeLast());
            next = next.next!;
          } else if (next.type == Keyword.EXPORT || next.type == Keyword.PART) {
            throw UnimplementedError();
          } else if (next.type == Keyword.EXTERNAL) {
            next = next.next!;
            next = parser.parseStatement(next.previous!);

            var declaration = builder.pop() as VariableDeclarationStatement;

            if (declaration.variables.variables.length != 1) {
              // TODO(ast): Change exception type.
              throw StateError('Expected a single variable declaration.');
            }

            properties.add(declaration);

            if (builder.pop() != null) {
              throw StateError('Expected a null value.');
            }

            next = next.next!;
          } else {
            next = parser.parseStatement(next.previous!);

            var pop = builder.pop() as AstNode;

            if (pop is! Statement) {
              // TODO(ast): Change exception type.
              throw StateError('Expected a statement.');
            }

            nodes.add(pop);
            next = next.next!;
          }
        }
      } else {
        parser.parseUnit(token);

        CompilationUnit unit = builder.pop() as CompilationUnit;
        directives.addAll(unit.directives);
        nodes.addAll(unit.declarations);
      }
    }

    withScriptParserRun(dataStart, _scriptCloseTag, scriptParser);

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
