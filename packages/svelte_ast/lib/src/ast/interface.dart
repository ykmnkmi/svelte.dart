part of '../ast.dart';

abstract final class Node {
  const Node({required this.start, required this.end});

  final int start;

  final int end;

  R accept<C, R>(Visitor<C, R> visitor, C context);

  Map<String, Object?> toJson();
}

final class Text extends Node {
  const Text({
    required super.start,
    required super.end,
    this.raw = '',
    this.data = '',
  });

  final String raw;

  final String data;

  bool get isLeaf {
    return trimmed.isEmpty;
  }

  String get literal {
    return "'${data.replaceAll("'", r"\'").replaceAll('\r\n', r'\n').replaceAll('\n', r'\n')}'";
  }

  String get trimmed {
    return data.trim();
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitText(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Text',
      'raw': raw,
      'data': data,
    };
  }
}

final class Fragment extends Node {
  const Fragment({
    required super.start,
    required super.end,
    this.nodes = const <Node>[],
  });

  final List<Node> nodes;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitFragment(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Fragment',
      'nodes': <Map<String, Object?>>[for (var node in nodes) node.toJson()],
    };
  }
}
