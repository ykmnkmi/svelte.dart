// ignore_for_file: depend_on_referenced_packages, unnecessary_import

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:_fe_analyzer_shared/src/scanner/characters.dart' show $EOF;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show ScannerConfiguration, StringScanner, Token;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/ast.dart' show Expression;
import 'package:analyzer/error/listener.dart'
    show ErrorReporter, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;

import '../parser.dart';

extension ExpressionParser on Parser {
  T withExpressionParser<T>(
      Pattern end, Token Function(fe.Parser parser, Token token) callback) {
    FeatureSet featureSet = FeatureSet.latestLanguageVersion();
    ScannerConfiguration configuration = dart.Scanner.buildConfig(featureSet);
    ExpressionScanner scanner = ExpressionScanner(string, position - 1, end,
        configuration: configuration);
    LineInfo lineInfo = LineInfo(scanner.lineStarts);
    StringSource source = StringSource(string, fileName, uri: uri);
    RecordingErrorListener errorListener = RecordingErrorListener();
    ErrorReporter reporter = ErrorReporter(errorListener, source,
        isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable));
    AstBuilder astBuilder =
        AstBuilder(reporter, source.uri, true, featureSet, lineInfo);
    fe.Parser parser = fe.Parser(astBuilder,
        allowPatterns: featureSet.isEnabled(Feature.patterns));
    astBuilder.parser = parser;

    Token token = scanner.tokenize();
    token = parser.syntheticPreviousToken(token);
    token = callback(parser, token);
    position = token.end;
    return astBuilder.pop() as T;
  }

  Expression readExpression(Pattern end) {
    return withExpressionParser(end, (parser, token) {
      return parser.parseExpression(token);
    });
  }
}

class ExpressionScanner extends StringScanner {
  ExpressionScanner(super.string, int offset, this.end, {super.configuration})
      : super(includeComments: true) {
    scanOffset = offset;
  }

  final Pattern end;

  @override
  Token tokenize() {
    int next = advance();

    while (true) {
      if (groupingStack.isEmpty &&
          end.matchAsPrefix(string, scanOffset) != null) {
        break;
      }

      if (identical(next, $EOF)) {
        break;
      }

      next = bigSwitch(next);
    }

    appendEofToken();
    return firstToken();
  }
}
