part of '../ast.dart';

final class MustacheTag extends Node {
  const MustacheTag({
    required super.start,
    required super.end,
    required this.expression,
  });

  final dart_ast.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitMustacheTag(this, context);
  }
}

final class ConstTag extends Node {
  const ConstTag({
    required super.start,
    required super.end,
    required this.expression,
  });

  final dart_ast.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitConstTag(this, context);
  }
}
