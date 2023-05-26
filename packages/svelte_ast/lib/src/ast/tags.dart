part of '../ast.dart';

final class MustacheTag extends Node {
  const MustacheTag({
    required super.start,
    required super.end,
    required this.expression,
  });

  final Expression expression;

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

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitConstTag(this, context);
  }
}

final class DebugTag extends Node {
  const DebugTag({
    required super.start,
    required super.end,
    this.identifiers = const <SimpleIdentifier>[],
  });

  final List<SimpleIdentifier> identifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDebugTag(this, context);
  }
}
