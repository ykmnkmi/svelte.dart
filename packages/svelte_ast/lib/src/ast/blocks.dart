part of '../ast.dart';

final class IfBlock extends Node {
  IfBlock({
    required super.start,
    required super.end,
    required this.test,
    required this.body,
    this.orElse = const <Node>[],
  });

  final Expression test;

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
    required this.value,
    this.index,
    this.key,
    required this.body,
    this.orElse = const <Node>[],
  });

  final DartPattern context;

  final Expression value;

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
      'context': '$context',
      'value': value.accept(dart2Json),
      'index': index,
      'key': key?.accept(dart2Json),
      'body': <Map<String, Object?>>[for (var node in body) node.toJson()],
      'orElse': <Map<String, Object?>>[for (var node in orElse) node.toJson()],
    };
  }
}
