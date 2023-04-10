// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/dart/ast/ast.dart' show AstNode, Expression;
import 'package:analyzer/dart/ast/visitor.dart' show UnifyingAstVisitor;
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/generated/parser.dart' as analyzer show Parser;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:svelte/src/compiler/parser/parser.dart';

extension ExpressionParser on Parser {
  Expression readExpression() {
    var source = template.substring(position);
    var errorListener = RecordingErrorListener();
    var result = parseExpression(position - 1, source, errorListener);
    var errors = errorListener.errors;

    for (var analysisError in errors) {
      if (position + analysisError.offset <= result.end) {
        error(
          (code: 'parse-error', message: analysisError.message),
          analysisError.offset,
        );
      }
    }

    result.accept<void>(Synthetic(this));
    position = result.end;
    return result;
  }

  static Expression parseExpression(
    int offset,
    String expression, [
    AnalysisErrorListener? errorListener,
  ]) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(expression, null);
    var scanner = Scanner.fasta(source, errorListener, offset: offset);

    scanner.configureFeatures(
      featureSetForOverriding: featureSet,
      featureSet: featureSet,
    );

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);

    var parser = analyzer.Parser(
      source,
      errorListener,
      featureSet: scanner.featureSet,
      lineInfo: lineInfo,
    );

    return parser.parseExpression(token);
  }
}

class Synthetic extends UnifyingAstVisitor<void> {
  Synthetic(this.parser);

  final Parser parser;

  @override
  void visitNode(AstNode node) {
    if (node.isSynthetic) {
      parser.error(
        (code: 'parse-error', message: 'Synthetic expression'),
        node.offset,
      );
    }

    node.visitChildren(this);
  }
}
