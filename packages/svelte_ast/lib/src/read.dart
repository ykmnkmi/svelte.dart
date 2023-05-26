// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/ast.dart'
    show
        AssignmentExpression,
        BinaryExpression,
        Expression,
        PrefixedIdentifier,
        SimpleIdentifier,
        SimpleStringLiteral;
import 'package:analyzer/dart/ast/visitor.dart' show ThrowingAstVisitor;
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, ErrorReporter, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:svelte_ast/src/parser.dart';

extension ExpressionParser on Parser {
  Expression readExpression() {
    var start = position;
    var source = template.substring(start);
    var errorListener = RecordingErrorListener();
    var expression = parseExpression(start - 1, source, errorListener);
    var errors = errorListener.errors;

    for (var analysisError in errors) {
      if (start + analysisError.offset <= expression.end) {
        error(
          (code: 'parse-error', message: analysisError.message),
          analysisError.offset,
        );
      }
    }

    position = expression.end;
    return expression;
  }

  static Expression parseExpression(
    int offset,
    String contents, [
    AnalysisErrorListener? errorListener,
  ]) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(contents, null);
    var scanner = Scanner.fasta(source, errorListener, offset: offset);

    scanner.configureFeatures(
      featureSetForOverriding: featureSet,
      featureSet: featureSet,
    );

    var token = scanner.tokenize(reportScannerErrors: false);

    var reporter = ErrorReporter(
      errorListener,
      source,
      isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable),
    );

    var lineInfo = LineInfo(scanner.lineStarts);

    var astBuilder = AstBuilder(
      reporter,
      source.uri,
      true,
      featureSet,
      lineInfo,
    );

    var parser = fe.Parser(
      astBuilder,
      allowPatterns: featureSet.isEnabled(Feature.patterns),
    );

    parser.parseExpression(parser.syntheticPreviousToken(token));

    var expression = astBuilder.pop() as Expression;
    return expression.accept(NonSyntetic()) as Expression;
  }
}

class NonSyntetic extends ThrowingAstVisitor<Expression> {
  const NonSyntetic();

  @override
  Expression? visitAssignmentExpression(AssignmentExpression node) {
    if (node.isSynthetic) {
      return null;
    }

    return node;
  }

  @override
  Expression? visitBinaryExpression(BinaryExpression node) {
    if (node.isSynthetic) {
      return null;
    }

    if (node.rightOperand.isSynthetic) {
      return node.leftOperand.accept(this);
    }

    return node;
  }

  @override
  Expression? visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.isSynthetic) {
      return null;
    }

    return node;
  }

  @override
  Expression? visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.isSynthetic) {
      return null;
    }

    return node;
  }

  @override
  Expression? visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.isSynthetic) {
      return null;
    }

    return node;
  }
}
