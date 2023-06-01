// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser, PatternContext;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/dart/ast/ast.dart'
    show
        AsExpression,
        AssignmentExpression,
        AstNode,
        BinaryExpression,
        DartPattern,
        Expression,
        ParenthesizedExpression,
        PrefixedIdentifier,
        RecordLiteral,
        SimpleIdentifier,
        SimpleStringLiteral;
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart' show ThrowingAstVisitor;
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, ErrorReporter, RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:svelte_ast/src/parser.dart';

const int _expressionLookLength = 0x50;

// TODO(expression): add reserved keywords
const Set<String> _reserved = <String>{};

final RegExp _identifierRe = RegExp('[_\$a-zA-Z][_\$a-zA-Z0-9]*');

final FeatureSet _featureSet = FeatureSet.latestLanguageVersion();

void _pattern(fe.Parser parser, Token token) {
  var previousToken = parser.syntheticPreviousToken(token);
  parser.parsePattern(previousToken, fe.PatternContext.assignment);
}

void _expression(fe.Parser parser, Token token) {
  parser.parseExpression(parser.syntheticPreviousToken(token));
}

T _parse<T extends AstNode>(
  int offset,
  String contents,
  AnalysisErrorListener? errorListener,
  void Function(fe.Parser parser, Token token) callback,
) {
  errorListener ??= RecordingErrorListener();

  if (contents.length > _expressionLookLength) {
    contents = contents.substring(0, _expressionLookLength);
  }

  var source = StringSource(contents, null);
  var scanner = Scanner.fasta(source, errorListener, offset: offset);

  scanner.configureFeatures(
    featureSetForOverriding: _featureSet,
    featureSet: _featureSet,
  );

  var token = scanner.tokenize(reportScannerErrors: false);

  var reporter = ErrorReporter(
    errorListener,
    source,
    isNonNullableByDefault: _featureSet.isEnabled(Feature.non_nullable),
  );

  var lineInfo = LineInfo(scanner.lineStarts);

  var astBuilder = AstBuilder(
    reporter,
    source.uri,
    true,
    _featureSet,
    lineInfo,
  );

  var parser = fe.Parser(
    astBuilder,
    allowPatterns: _featureSet.isEnabled(Feature.patterns),
  );

  callback(parser, token);
  return astBuilder.pop() as T;
}

DartPattern _parsePattern(
  int offset,
  String contents, [
  AnalysisErrorListener? errorListener,
]) {
  return _parse<DartPattern>(
    offset,
    contents,
    errorListener,
    _pattern,
  );
}

Expression _parseExpression(
  int offset,
  String contents, [
  AnalysisErrorListener? errorListener,
]) {
  var expression = _parse<Expression>(
    offset,
    contents,
    errorListener,
    _expression,
  );

  return expression.accept(NonSyntetic()) as Expression;
}

extension ExpressionParser on Parser {
  String? identifier({bool allowReserved = false}) {
    var start = position;
    var match = _identifierRe.matchAsPrefix(template, position);

    if (match == null) {
      return null;
    }

    var word = match[0]!;

    if (!allowReserved && _reserved.contains(word)) {
      var error = (
        code: 'unexpected-reserved-word',
        message: "'$word' is a reserved word in Dart and cannot be used here",
      );

      this.error(error, start);
    }

    position = match.end;
    return word;
  }

  DartPattern pattern() {
    var start = position;
    var source = template.substring(start);
    var errorListener = RecordingErrorListener();
    var pattern = _parsePattern(start - 1, source, errorListener);
    position = pattern.end;
    return pattern;
  }

  Expression expression() {
    var start = position;
    var source = template.substring(start);
    var errorListener = RecordingErrorListener();
    var expression = _parseExpression(start - 1, source, errorListener);
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
}

class NonSyntetic extends ThrowingAstVisitor<Expression> {
  const NonSyntetic();

  @override
  Expression? visitAsExpression(AsExpression node) {
    return check(node);
  }

  @override
  Expression? visitAssignmentExpression(AssignmentExpression node) {
    return check(node);
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
  Expression? visitParenthesizedExpression(ParenthesizedExpression node) {
    return check(node);
  }

  @override
  Expression? visitPrefixedIdentifier(PrefixedIdentifier node) {
    return check(node);
  }

  @override
  Expression? visitRecordLiteral(RecordLiteral node) {
    return check(node);
  }

  @override
  Expression? visitSimpleIdentifier(SimpleIdentifier node) {
    return check(node);
  }

  @override
  Expression? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return check(node);
  }

  static Expression? check(Expression expression) {
    if (expression.isSynthetic) {
      return null;
    }

    return expression;
  }
}
