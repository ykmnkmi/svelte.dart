// ignore_for_file: implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as dart;
import 'package:analyzer/dart/ast/token.dart' as dart;
import 'package:analyzer/src/dart/ast/ast.dart' as dart;
import 'package:analyzer/src/fasta/ast_builder.dart' as dart;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/read/dart/parser.dart' as dart;

const Set<String> _reservedAttributes = <String>{
  'server',
  'client',
  'worker',
  'test',
  'default',
};

const Set<String> _allowedAttributes = <String>{
  'context',
  'generics',
  'module',
};

extension ScriptParser on Parser {
  String _readContext(List<AttributeNode> attributes) {
    for (AttributeNode attribute in attributes) {
      if (attribute is! Attribute) {
        scriptUnknownAttribute(attribute.start, attribute.end);
      }

      if (_reservedAttributes.contains(attribute.name)) {
        scriptReservedAttribute(attribute.name, attribute.start, attribute.end);
      }

      if (!_allowedAttributes.contains(attribute.name)) {
        scriptUnknownAttribute(attribute.start, attribute.end);
      }

      if (attribute.name == 'module') {
        if (attribute.value != null) {
          scriptInvalidAttributeValue(
            attribute.name,
            attribute.start,
            attribute.end,
          );
        }

        return 'module';
      }

      if (attribute.name == 'context') {
        Object? value = attribute.value;

        if (value is Text && value.data == 'module') {
          return 'module';
        }

        scriptInvalidContext(attribute.start, attribute.end);
      }
    }

    return 'default';
  }

  Script readScript(int start, List<AttributeNode> attributes) {
    String context = _readContext(attributes);

    int contentStart = position;
    String content = readUntil(closingScriptTagRe);

    if (isDone) {
      elementUnclosed('script', length);
    }

    int contentEnd = position;
    expect(closingScriptTagRe);

    if (context == 'module') {
      dart.CompilationUnit unit = dart.parseString<dart.CompilationUnit>(
        string: template,
        offset: contentStart,
        end: contentEnd,
        closingPattern: closingScriptTagRe,
        fileName: fileName,
        uri: uri,
        parse: (token, parser) => parser.parseCompilationUnit(token),
      );

      return ModuleScript(
        start: start,
        end: position,
        content: ScriptContent(
          start: contentStart,
          end: contentEnd,
          content: content,
        ),
        unit: unit,
      );
    }

    List<dart.AstNode> body = dart.parseString<List<dart.AstNode>>(
      offset: contentStart,
      end: contentEnd,
      string: template,
      closingPattern: closingScriptTagRe,
      parse: (token, parser) {
        dart.AstBuilder astBuilder = parser.astBuilder;
        dart.Parser fastaParser = parser.fastaParser;

        dart.Token previousToken = fastaParser.syntheticPreviousToken(token);
        dart.Token next = previousToken.next!;

        List<dart.AstNode> nodes = <dart.AstNode>[];

        while (!next.isEof) {
          next = fastaParser.parseMetadataStar(next);

          if (next.type == dart.Keyword.LIBRARY) {
            dartError("'library' is not supported.", next.offset, next.end);
          } else if (next.type == dart.Keyword.IMPORT) {
            next = fastaParser.parseTopLevelDeclaration(next);
            nodes.add(astBuilder.directives.removeLast());

            Object? object = astBuilder.pop();
            assert(object == null);
          } else if (next.type == dart.Keyword.EXPORT) {
            dartError("'export' is not supported.", next.offset, next.end);
          } else if (next.type == dart.Keyword.PART) {
            dartError("'part' is not supported.", next.offset, next.end);
          } else if (next.type == dart.Keyword.EXTERNAL) {
            next = next.next!;
            next = fastaParser.parseTopLevelMember(next);
            nodes.add(astBuilder.declarations.removeLast());

            Object? object = astBuilder.pop();
            assert(object == null);
          } else {
            dart.Token previous = next.previous!;
            next = fastaParser.parseStatement(previous);

            Object? statement = astBuilder.pop();

            if (statement is! dart.Statement) {
              dartError('Expected a statement.', previous.end, 0);
            }

            nodes.add(statement);
            next = next.next!;
          }
        }

        return nodes;
      },
    );

    return InstanceScript(
      start: start,
      end: position,
      content: ScriptContent(
        start: contentStart,
        end: contentEnd,
        content: content,
      ),
      body: body,
    );
  }
}
