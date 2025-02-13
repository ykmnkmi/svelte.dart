part of '../ast.dart';

abstract interface class HasElse implements Node {
  abstract ElseBlock? elseBlock;
}

typedef IfRest =
    (
      Expression expression,
      DartPattern? casePattern,
      Expression? whenExpression,
    );

final class IfBlock extends Node implements HasElse {
  IfBlock({
    super.start,
    super.end,
    required this.expression,
    this.casePattern,
    this.whenExpression,
    required super.children,
    this.elseIf = false,
    this.elseBlock,
  });

  final Expression expression;

  final DartPattern? casePattern;

  final Expression? whenExpression;

  bool elseIf;

  @override
  ElseBlock? elseBlock;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitIfBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'IfBlock',
      'expression': mapper(expression),
      'casePattern': mapper(casePattern),
      'whenExpression': mapper(whenExpression),
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
      'elseIf': elseIf,
      'elseBlock': elseBlock?.toJson(mapper),
    };
  }
}

final class EachBlock extends Node implements HasElse {
  EachBlock({
    super.start,
    super.end,
    required this.expression,
    required this.context,
    this.index,
    this.key,
    required super.children,
    this.elseBlock,
  });

  final Expression expression;

  final DartPattern context;

  String? index;

  final Expression? key;

  @override
  ElseBlock? elseBlock;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitEachBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'EachBlock',
      'expression': mapper(expression),
      'context': mapper(context),
      'index': index,
      'key': mapper(key),
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
      'elseBlock': elseBlock?.toJson(mapper),
    };
  }
}

final class ElseBlock extends Node {
  ElseBlock({super.start, super.end, required super.children});

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitElseBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ElseBlock',
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class AwaitBlock extends Node {
  AwaitBlock({
    super.start,
    super.end,
    required this.expession,
    this.value,
    this.error,
    this.pendingBlock,
    this.thenBlock,
    this.catchBlock,
  });

  final Expression expession;

  DartPattern? value;

  DartPattern? error;

  PendingBlock? pendingBlock;

  ThenBlock? thenBlock;

  CatchBlock? catchBlock;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAwaitBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'AwaitBlock',
      'expession': mapper(expession),
      'value': mapper(value),
      'error': mapper(error),
      'pendingBlock': pendingBlock?.toJson(mapper),
      'thenBlock': thenBlock?.toJson(mapper),
      'catchBlock': catchBlock?.toJson(mapper),
    };
  }
}

final class PendingBlock extends Node {
  PendingBlock({
    super.start,
    super.end,
    required super.children,
    this.skip = false,
  });

  bool skip;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitPendingBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'PendingBlock',
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class ThenBlock extends Node {
  ThenBlock({super.start, super.end, required super.children});

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitThenBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ThenBlock',
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class CatchBlock extends Node {
  CatchBlock({super.start, super.end, required super.children});

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitCatchBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'CatchBlock',
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class KeyBlock extends Node {
  KeyBlock({super.start, super.end, required this.expression, super.children});

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitKeyBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'KeyBlock',
      'expression': mapper(expression),
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}
