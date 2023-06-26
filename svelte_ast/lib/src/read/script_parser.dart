// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:_fe_analyzer_shared/src/scanner/abstract_scanner.dart';
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/token.dart' show Keyword, Token;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart' show ErrorReporter;
import 'package:analyzer/error/listener.dart' show AnalysisErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:svelte_ast/src/read/script_scanner.dart';

final class ThrowingErrorListener extends AnalysisErrorListener {
  @override
  void onError(AnalysisError error) {
    throw error;
  }
}

typedef ScriptParserCallback = void Function(ScriptParser parser, Token token);

final class ScriptParser extends fe.Parser {
  factory ScriptParser.fromString({
    required String string,
    int offset = 0,
    String? fileName,
    Uri? uri,
  }) {
    FeatureSet featureSet = FeatureSet.latestLanguageVersion();
    ScannerConfiguration configuration = dart.Scanner.buildConfig(featureSet);

    ScriptScanner scanner = ScriptScanner(
      string: string,
      offset: offset,
      configuration: configuration,
    );

    StringSource source = StringSource(string, fileName, uri: uri);
    return ScriptParser(
      scanner: scanner,
      builder: AstBuilder(
        ErrorReporter(
          ThrowingErrorListener(),
          source,
          isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable),
        ),
        source.uri,
        true,
        featureSet,
        LineInfo(scanner.lineStarts),
      ),
      allowPatterns: featureSet.isEnabled(Feature.patterns),
    );
  }

  ScriptParser({
    required this.scanner,
    required this.builder,
    super.allowPatterns,
  }) : super(builder) {
    builder.parser = this;
  }

  final ScriptScanner scanner;

  final AstBuilder builder;

  List<Object?> parse(Pattern end) {
    Token token = scanner.scan(end);
    Token previousToken = syntheticPreviousToken(token);
    Token next = previousToken.next!;

    while (!next.isEof) {
      if (next case Token(type: Keyword.IMPORT)) {
        next = parseMetadataStar(next);
        next = parseImport(next);
        next = next.next!;
      } else if (next case Token(type: Keyword.EXTERNAL)) {
        next = parseMetadataStar(next);
        next = parseTopLevelMember(next);
      } else {
        next = parseStatement(next.previous!);
        next = next.next!;
      }
    }

    return [
      builder.directives.toList(growable: false),
      builder.declarations.toList(growable: false),
      builder.stack.values.skip(1).toList(growable: false),
    ];
  }
}
