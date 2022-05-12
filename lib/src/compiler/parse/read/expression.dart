import 'dart:math' show min;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart' as AST;
import 'package:analyzer/src/string_source.dart';
import 'package:piko/src/compiler/parse/parse.dart';

extension MustacheParser on Parser {
  Expression readExpression() {
    var source = template.substring(index, length);
    var errorListener = RecordingErrorListener();
    var result = parseExpression(source, errorListener);
    var errors = errorListener.errors;

    if (errors.isNotEmpty) {
      Error.throwWithStackTrace(errorListener.errors.first, StackTrace.current);
    }

    // TODO: check syntax errors
    // var analysisError = errors.removeAt(0);
    // var offset = sourceFile.getColumn(index);

    // if (analysisError.offset - offset < 0) {
    //   error('parse-error', 'expression expected');
    // }

    // if (analysisError.message != 'Expected to find \';\'.') {
    //   error('parse-error', analysisError.message);
    // }

    index += result.end;
    return result;
  }

  static Expression parseExpression(String expression, [AnalysisErrorListener? errorListener]) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(expression, '<expression>');
    var scanner = Scanner.fasta(source, errorListener);
    scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);
    var parser = AST.Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);
    return parser.parseExpression(token);
  }
}
