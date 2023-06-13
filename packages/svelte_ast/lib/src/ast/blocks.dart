part of '../ast.dart';

abstract final class HasElse implements Node {
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

  final bool elseIf;

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
      '_': 'IfBlock',
      'expression': expression.accept(dart2Json),
      if (casePattern case DartPattern casePattern?)
        'casePattern': casePattern.toString(),
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
      '_': 'EachBlock',
      'expression': expression.accept(dart2Json),
      'context': context.toSource(),
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
    super.children,
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
      '_': 'ElseBlock',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}

final class AwaitBlock extends Node {
  AwaitBlock({
    required super.start,
    required super.end,
    required this.future,
    this.futureBody,
    this.then_,
    this.thenBody,
    this.catch_,
    this.catchBody,
  });

  final Expression future;

  final List<Node>? futureBody;

  final String? then_;

  final List<Node>? thenBody;

  final String? catch_;

  final List<Node>? catchBody;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAwaitBlock(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'AwaitBlock',
      'future': future.accept(dart2Json),
      if (futureBody case List<Node> nodes?)
        'futureBody': <Map<String, Object?>>[
          for (Node node in nodes) node.toJson(),
        ],
      if (then_ case String string?) 'then': string,
      if (thenBody case List<Node> nodes?)
        'thenBody': <Map<String, Object?>>[
          for (Node node in nodes) node.toJson(),
        ],
      if (catch_ case String string?) 'catch': string,
      if (catchBody case List<Node> nodes?)
        'catchBody': <Map<String, Object?>>[
          for (Node node in nodes) node.toJson(),
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
      '_': 'KeyBlock',
      'expression': expression.accept(dart2Json),
      'children': <Map<String, Object?>>[
        for (Node node in children) node.toJson()
      ],
    };
  }
}

abstract final class InlineComponent implements Node {}
