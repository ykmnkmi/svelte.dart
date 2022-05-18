import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart' as AST;
import 'package:analyzer/src/string_source.dart';
import 'package:piko/src/compiler/parse/parse.dart';

extension MustacheParser on Parser {
  Expression readExpression({bool primary = false}) {
    var source = template.substring(index);
    var errorListener = RecordingErrorListener();
    var result = parseExpression(index, source, primary: primary, errorListener: errorListener);
    var errors = errorListener.errors;

    for (var analysisError in errors) {
      if (index + analysisError.offset <= result.end) {
        error('parse-error', analysisError.message, start: analysisError.offset);
      }
    }

    index = result.end;
    print([result.beginToken.offset, result.beginToken.end]);
    print([result.endToken.offset, result.endToken.end]);
    return result;
  }

  static Expression parseExpression(int offset, String expression, //
      {bool primary = false,
      AnalysisErrorListener? errorListener}) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(expression, '<expression>');
    var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
    scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);
    var parser = AST.Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);

    if (primary) {
      parser.currentToken = token;
      return parser.parsePrimaryExpression();
    }

    return parser.parseExpression(token);
  }
}
