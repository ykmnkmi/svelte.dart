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

abstract final interface class HasName implements Node {
  String get name;
}

final class Element extends Node implements HasName {
  Element({
    super.start,
    super.end,
    required this.name,
    required this.attributes,
    required super.children,
  });

  final String name;

  final List<Attribute> attributes;

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
          for (Attribute attribute in attributes) attribute.toJson(),
        ],
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (Node node in children) node.toJson(),
        ],
    };
  }
}
