// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show StringScanner, Token;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, ErrorReporter;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;

const String string = r'''
import 'package:svelte/svelte.dart';

export String count = 0;

$: doubled = count * 2;

void increment([int value = 1]) {
  count += value;
}
''';

void main() {
  var featureSet = FeatureSet.latestLanguageVersion();
  var configuration = dart.Scanner.buildConfig(featureSet);
  var scanner = StringScanner(string, configuration: configuration);
  // scanner.scanOffset = -1;

  var token = scanner.tokenize();

  var lineInfo = LineInfo(scanner.lineStarts);
  var source = StringSource(string, 'main.dart');
  var errorListener = ThrowingErrorListener();
  var reporter = ErrorReporter(errorListener, source,
      isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable));
  var astBuilder = AstBuilder(reporter, source.uri, true, featureSet, lineInfo);

  var parser = SvelteScriptParser(astBuilder,
      allowPatterns: featureSet.isEnabled(Feature.patterns));

  var result = parser.parse(token);
  print(result);
}

final class ThrowingErrorListener extends AnalysisErrorListener {
  @override
  void onError(AnalysisError error) {
    throw error;
  }
}

final class SvelteScriptParser extends fe.Parser {
  SvelteScriptParser(AstBuilder astBuilder, {super.allowPatterns})
      : super(astBuilder) {
    astBuilder.parser = this;
  }

  @override
  Token parseExport(Token exportKeyword) {
    return switch (exportKeyword.next) {
      Token(type: TokenType.STRING) => super.parseExport(exportKeyword),
      Token next => parseTopLevelDeclaration(next),
      _ => throw AssertionError('unreachable'),
    };
  }

  @override
  Token parseTopLevelDeclaration(Token token, [bool export = false]) {
    if (export) {
      print(token.next);
    }

    return super.parseTopLevelDeclaration(token);
  }

  Object? parse(Token token) {
    return parseUnit(token);
  }
}
