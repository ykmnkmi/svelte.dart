// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show ScannerConfiguration, Token;
import 'package:_fe_analyzer_shared/src/scanner/token.dart'
    show Token, TokenType;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/error/listener.dart'
    show ErrorReporter, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:source_span/source_span.dart' show SourceFile, SourceSpan;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';

import 'scanner.dart';
import 'state/fragment.dart';

class Parser {
  factory Parser(String string, {String? fullName, Uri? uri}) {
    FeatureSet featureSet = FeatureSet.latestLanguageVersion();
    ScannerConfiguration configuration = dart.Scanner.buildConfig(featureSet);
    SvelteStringScanner scanner =
        SvelteStringScanner(string, configuration: configuration);
    LineInfo lineInfo = LineInfo(scanner.lineStarts);
    StringSource source = StringSource(string, fullName, uri: uri);
    RecordingErrorListener errorListener = RecordingErrorListener();
    ErrorReporter reporter = ErrorReporter(errorListener, source,
        isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable));
    AstBuilder astBuilder =
        AstBuilder(reporter, source.uri, true, featureSet, lineInfo);
    fe.Parser parser = fe.Parser(astBuilder,
        allowPatterns: featureSet.isEnabled(Feature.patterns));
    Token token = scanner.tokenize();
    return Parser.from(string, astBuilder, parser, token);
  }

  Parser.from(this.string, this.astBuilder, this.parser, this.token);

  final String string;

  final AstBuilder astBuilder;

  final fe.Parser parser;

  final List<String> endTagsStack = <String>[];

  Token token;

  int get position {
    return token.offset;
  }

  bool get isDone {
    return token.isEof;
  }

  bool skipToken([int n = 1]) {
    for (int i = 0; i < n; i += 1) {
      if (token.next case Token next when next.type != TokenType.EOF) {
        token = next;
      } else {
        return false;
      }
    }

    return true;
  }

  bool skipNextTokenIf(TokenType type, [String? value]) {
    return nextTokenIf(type, value) != null;
  }

  bool matchToken(TokenType type, [String? value]) {
    return token.type == type && (value == null || token.lexeme == value);
  }

  Token nextToken() {
    Token result = token;
    token = token.next!;
    return result;
  }

  Token? nextTokenIf(TokenType type, [String? value]) {
    if (token.type == type && (value == null || token.lexeme == value)) {
      return nextToken();
    }

    return null;
  }

  Token expectToken(TokenType type, [String? value]) {
    if (nextTokenIf(type, value) case Token token) {
      return token;
    }

    if (isDone) {
      error(unexpectedEOFToken(type.name));
    }

    error(unexpectedToken(type.name));
  }

  Never error(ErrorCode errorCode, [int? position]) {
    SourceFile sourceFile = SourceFile.fromString(string);
    SourceSpan span = sourceFile.span(position ?? token.offset, position);
    throw ParseError(errorCode, span);
  }

  Node parse() {
    List<Node> children = <Node>[];

    while (token.type != TokenType.EOF) {
      if (fragment() case Node node) {
        children.add(node);
      }
    }

    return Fragment(start: 0, end: token.end, children: children);
  }
}
