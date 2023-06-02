// ignore_for_file: depend_on_referenced_packages

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
import 'package:source_span/source_span.dart' show SourceFile;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';

import 'scanner.dart';
import 'state/fragment.dart';

Node parse(String source, {String? fullName, Uri? uri}) {
  return Parser(source, fullName: fullName, uri: uri).parse();
}

class Parser {
  factory Parser(String string, {String? fullName, Uri? uri}) {
    SourceFile sourceFile = SourceFile.fromString(string, url: uri);
    FeatureSet featureSet = FeatureSet.latestLanguageVersion();
    ScannerConfiguration configuration = dart.Scanner.buildConfig(featureSet);
    SvelteStringScanner scanner =
        SvelteStringScanner(string, configuration: configuration);
    Token token = scanner.tokenize();
    LineInfo lineInfo = LineInfo(scanner.lineStarts);
    StringSource source = StringSource(string, fullName, uri: uri);
    RecordingErrorListener errorListener = RecordingErrorListener();
    ErrorReporter reporter = ErrorReporter(errorListener, source,
        isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable));
    AstBuilder astBuilder =
        AstBuilder(reporter, source.uri, true, featureSet, lineInfo);
    fe.Parser parser = fe.Parser(astBuilder,
        allowPatterns: featureSet.isEnabled(Feature.patterns));
    return Parser.from(sourceFile, astBuilder, parser, token);
  }

  Parser.from(this.sourceFile, this.astBuilder, this.parser, this.token);

  final SourceFile sourceFile;

  final AstBuilder astBuilder;

  final fe.Parser parser;

  final List<String> endTagsStack = <String>[];

  Token token;

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

    if (token.isEof) {
      throw StateError('Expected $type.');
    }

    throw StateError('Expected token type ${type.name}, got "$token".');
  }

  Never error(ErrorCode errorCode, [int? position]) {
    var span = sourceFile.span(position ?? token.offset, position);
    throw ParseError(errorCode, span);
  }

  Node parse() {
    List<Node> nodes = <Node>[];

    while (token.type != TokenType.EOF) {
      if (fragment() case Node node) {
        nodes.add(node);
      }
    }

    return Fragment(start: 0, end: token.end, nodes: nodes);
  }
}
