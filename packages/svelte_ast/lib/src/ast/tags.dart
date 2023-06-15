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
      if (value case bool value? when value) 'value': value,
    };
  }
}

enum DirectiveType {
  action,
  animation,
  binding,
  classDirective,
  styleDirective,
  eventHandler,
  let,
  ref,
  transition,
}

abstract interface class HasName implements Node {
  String get name;
}

abstract base class Tag extends Node {
  Tag({
    super.start,
    super.end,
    required this.attributes,
    required super.children,
  });

  final List<Attribute> attributes;
}

final class Head extends Tag {
  Head({
    super.start,
    super.end,
    required super.attributes,
    super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitHead(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Head',
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

abstract final class Options implements Tag {}

abstract final class Window implements Tag {}

abstract final class Document implements Tag {}

abstract final class Body implements Tag {}

final class InlineComponent extends Tag {
  InlineComponent({
    super.start,
    super.end,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitInlineComponent(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'InlineComponent',
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

final class SlotTemplate extends Tag {
  SlotTemplate({
    super.start,
    super.end,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSlotTemplate(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'SlotTemplate',
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

final class Title extends Tag {
  Title({
    super.start,
    super.end,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitTitle(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Title',
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

final class Slot extends Tag {
  Slot({
    super.start,
    super.end,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSlot(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Slot',
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

final class Element extends Tag implements HasName {
  Element({
    super.start,
    super.end,
    required this.name,
    required super.attributes,
    required super.children,
  });

  @override
  final String name;

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
