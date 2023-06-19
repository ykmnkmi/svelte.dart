part of '../ast.dart';

abstract interface class HasElse implements Node {
  abstract ElseBlock? elseBlock;
}

typedef IfRest = (
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
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'IfBlock',
      'expression': expression.accept(dart2Json),
      if (casePattern case DartPattern casePattern?)
        'casePattern': casePattern.accept(dart2Json),
      if (whenExpression case Expression whenExpression?)
        'whenExpression': whenExpression.accept(dart2Json),
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (Node node in children) node.toJson(),
        ],
      if (elseIf) 'elseIf': elseIf,
      if (elseBlock case ElseBlock elseBlock?) 'elseBlock': elseBlock.toJson(),
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
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'EachBlock',
      'expression': expression.accept(dart2Json),
      'context': context.accept(dart2Json),
      if (index case String string?) 'index': string,
      if (key case Expression expression?) 'key': expression.accept(dart2Json),
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (Node node in children) node.toJson(),
        ],
      if (elseBlock case ElseBlock elseBlock?) 'elseBlock': elseBlock.toJson(),
    };
  }
}

final class ElseBlock extends Node {
  ElseBlock({
    super.start,
    super.end,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitElseBlock(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'ElseBlock',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
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
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'AwaitBlock',
      'expession': expession.accept(dart2Json),
      if (value case DartPattern value?) 'value': value.accept(dart2Json),
      if (error case DartPattern error?) 'error': error.accept(dart2Json),
      if (pendingBlock case PendingBlock pendingBlock?)
        'pendingBlock': pendingBlock.toJson(),
      if (thenBlock case ThenBlock thenBlock?) 'thenBlock': thenBlock.toJson(),
      if (catchBlock case CatchBlock catchBlock?)
        'catchBlock': catchBlock.toJson(),
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
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'PendingBlock',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}

final class ThenBlock extends Node {
  ThenBlock({
    super.start,
    super.end,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitThenBlock(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'ThenBlock',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}

final class CatchBlock extends Node {
  CatchBlock({
    super.start,
    super.end,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitCatchBlock(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'CatchBlock',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}

final class KeyBlock extends Node {
  KeyBlock({
    super.start,
    super.end,
    required this.expression,
    super.children,
  });

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitKeyBlock(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': 'KeyBlock',
      'expression': expression.accept(dart2Json),
      'children': <Map<String, Object?>>[
        for (Node node in children) node.toJson()
      ],
    };
  }
}
