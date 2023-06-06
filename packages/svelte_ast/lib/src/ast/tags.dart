part of '../ast.dart';

final class Element extends Node {
  Element({
    required super.start,
    required super.end,
    required this.name,
    required this.body,
  });

  final String name;

  final List<Node> body;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitElement(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Element',
      'name': name,
      if (body.isNotEmpty)
        'body': <Map<String, Object?>>[
          for (var node in body) node.toJson(),
        ],
    };
  }
}
