// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/dart/ast/ast.dart'
    show AstNode, BinaryExpression, Expression;
import 'package:analyzer/dart/ast/visitor.dart' show UnifyingAstVisitor;
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/generated/parser.dart' as ast show Parser;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:nutty/src/compiler/parser/parse.dart';

extension MustacheParser on Parser {
  Expression readExpression() {
    var source = template.substring(index);
    var errorListener = RecordingErrorListener();
    var result = parseExpression(index, source, errorListener);
    var errors = errorListener.errors;

    var nonSynthetic = result.accept(NonSynthetic(this));

    if (nonSynthetic == null) {
      error('parse-error', 'expression expected.');
    }

    for (var analysisError in errors) {
      if (index + analysisError.offset <= nonSynthetic.end) {
        error('parse-error', analysisError.message,
            start: analysisError.offset);
      }
    }

    return nonSynthetic;
  }

  static Expression parseExpression(int offset, String expression,
      [AnalysisErrorListener? errorListener]) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(expression, null);
    var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
    scanner.configureFeatures(
        featureSetForOverriding: featureSet, featureSet: featureSet);

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);
    var parser = ast.Parser(source, errorListener,
        featureSet: scanner.featureSet, lineInfo: lineInfo);
    return parser.parseExpression(token);
  }
}

// TODO(parser): remove and update tests if https://github.com/dart-lang/sdk/issues/49057 solved
class NonSynthetic extends UnifyingAstVisitor<Expression> {
  NonSynthetic(this.parser);

  final Parser parser;

  @override
  Expression? visitNode(AstNode node) {
    if (node is! Expression) {
      throw UnsupportedError('${node.runtimeType}');
    }

    if (node.isSynthetic) {
      throw UnimplementedError('${node.runtimeType}');
    }

    parser.index = node.end;
    return node;
  }

  @override
  Expression? visitBinaryExpression(BinaryExpression node) {
    if (node.isSynthetic) {
      return null;
    }

    if (node.rightOperand.isSynthetic) {
      if (node.leftOperand.isSynthetic) {
        return null;
      }

      parser.index = node.operator.offset;
      return node.leftOperand;
    }

    parser.index = node.end;
    return node;
  }
}
