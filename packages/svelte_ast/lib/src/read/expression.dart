// ignore_for_file: depend_on_referenced_packages, implementation_imports, unnecessary_import

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser, PatternContext;
import 'package:_fe_analyzer_shared/src/scanner/characters.dart' show $EOF;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show ScannerConfiguration, StringScanner, Token;
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart'
    show StringTokenImpl;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/ast.dart'
    show DartPattern, Expression, SimpleIdentifier;
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart'
    show ErrorReporter, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/ast/ast.dart' show SimpleIdentifierImpl;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;

import '../parser.dart';

typedef DartParserCallback = Token Function(fe.Parser parser, Token token);

final RegExp _identifierRe = RegExp('[_\$A-Za-z][_\$A-Za-z0-9]*');

extension ExpressionParser on Parser {
  String? readIdentifier() {
    return read(_identifierRe);
  }

  DartPattern readAssignmentPattern(Pattern end) {
    return readPattern(end, fe.PatternContext.assignment);
  }

  DartPattern readPattern(Pattern end, fe.PatternContext context) {
    return withDartParser<DartPattern>(end, (parser, token) {
      return parser.parsePattern(token, context);
    });
  }

  Expression readExpression(Pattern end) {
    return withDartParser<Expression>(end, (parser, token) {
      return parser.parseExpression(token);
    });
  }

  T withDartParser<T>(Pattern end, DartParserCallback callback) {
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

  SimpleIdentifier simpleIdentifier(int start, String name) {
    Token token = StringTokenImpl.fromString(TokenType.IDENTIFIER, name, start);
    return SimpleIdentifierImpl(token);
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
      if (groupingStack.isEmpty && string.startsWith(end, scanOffset)) {
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
