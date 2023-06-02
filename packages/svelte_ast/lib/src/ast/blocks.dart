part of '../ast.dart';

final class IfBlock extends Node {
  IfBlock({
    required super.start,
    required super.end,
    required this.test,
    this.case_,
    this.when_,
    required this.body,
    this.orElse,
  });

  final Expression test;

  final DartPattern? case_;

  final Expression? when_;

  final List<Node> body;

  final List<Node>? orElse;

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
      'test': test.accept(dart2Json),
      if (case_ case DartPattern pattern?) 'case': pattern.toString(),
      if (when_ case Expression expression?)
        'when': expression.accept(dart2Json),
      if (body.isNotEmpty)
        'body': <Map<String, Object?>>[
          for (Node node in body) node.toJson(),
        ],
      if (orElse case List<Node> orElse? when orElse.isNotEmpty)
        'orElse': <Map<String, Object?>>[
          for (Node node in orElse) node.toJson(),
        ],
    };
  }
}

final class EachBlock extends Node {
  EachBlock({
    required super.start,
    required super.end,
    required this.context,
    required this.iterable,
    this.index,
    this.key,
    required this.body,
    this.orElse,
  });

  final DartPattern context;

  final Expression iterable;

  final List<Node> body;

  String? index;

  final Expression? key;

  final List<Node>? orElse;

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
      'context': context.toSource(),
      'iterable': iterable.accept(dart2Json),
      if (index case String string?) 'index': string,
      if (key case Expression expression?) 'key': expression.accept(dart2Json),
      if (body.isNotEmpty)
        'body': <Map<String, Object?>>[
          for (Node node in body) node.toJson(),
        ],
      if (orElse case List<Node> orElse? when orElse.isNotEmpty)
        'orElse': <Map<String, Object?>>[
          for (Node node in orElse) node.toJson(),
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
    required super.start,
    required super.end,
    required this.key,
    required this.body,
  });

  final Expression key;

  final List<Node> body;

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
      'key': key.accept(dart2Json),
      'body': <Map<String, Object?>>[for (Node node in body) node.toJson()],
    };
  }
}
