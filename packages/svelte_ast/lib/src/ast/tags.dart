part of '../ast.dart';

final class Attribute extends Node {
  Attribute({
    required super.start,
    required super.end,
    required this.name,
    this.value,
  });

  final String name;

  final Object? value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAttribute(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Attribute',
      'name': name,
      if (value case Object value?)
        'value': switch (value) {
          Expression expression => expression.accept(dart2Json),
          _ => value,
        },
    };
  }
}

final class Element extends Node {
  Element({
    required super.start,
    required super.end,
    required this.name,
    this.attributes = const <Attribute>[],
    required this.body,
  });

  final String name;

  final List<Attribute> attributes;

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
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (var attribute in attributes) attribute.toJson(),
        ],
      if (body.isNotEmpty)
        'body': <Map<String, Object?>>[
          for (var node in body) node.toJson(),
        ],
    };
  }
}
