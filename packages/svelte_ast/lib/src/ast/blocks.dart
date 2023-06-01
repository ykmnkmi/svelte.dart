part of '../ast.dart';

final class IfBlock extends Node {
  IfBlock({
    required super.start,
    required super.end,
    required this.test,
    this.case_,
    this.when_,
    required this.body,
    this.orElse = const <Node>[],
  });

  final Expression test;

  final DartPattern? case_;

  final Expression? when_;

  final List<Node> body;

  final List<Node> orElse;

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
      'case': case_?.toString(),
      'when': when_?.accept(dart2Json),
      'body': <Map<String, Object?>>[for (var node in body) node.toJson()],
      'orElse': <Map<String, Object?>>[for (var node in orElse) node.toJson()],
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
    this.orElse = const <Node>[],
  });

  final DartPattern context;

  final Expression iterable;

  final List<Node> body;

  final String? index;

  final Expression? key;

  final List<Node> orElse;

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
      'index': index,
      'key': key?.accept(dart2Json),
      'body': <Map<String, Object?>>[for (var node in body) node.toJson()],
      'orElse': <Map<String, Object?>>[for (var node in orElse) node.toJson()],
    };
  }
}
