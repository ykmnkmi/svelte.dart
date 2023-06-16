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
      if (value case List<Node> values? when values.isNotEmpty)
        'value': <Map<String, Object?>>[
          for (Node value in values) value.toJson(),
        ],
    };
  }
}

final class AttributeShorthand extends Node {
  AttributeShorthand({
    required super.start,
    required super.end,
    required this.expression,
  });

  final SimpleIdentifier expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAttributeShorthand(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'AttributeShorthand',
      'expression': expression.accept(dart2Json),
    };
  }
}

final class Spread extends Node {
  Spread({
    super.start,
    super.end,
    required this.expression,
  });

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSpread(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Spread',
      'expression': expression.accept(dart2Json),
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

final class Directive extends Node {
  Directive({
    required super.start,
    required super.end,
    required this.type,
    required this.name,
    this.modifiers = const <String>[],
    this.expression,
  });

  final DirectiveType type;

  final String name;

  final List<String> modifiers;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Directive',
      'type': type.name,
      'name': name,
      'modifiers': modifiers,
      if (expression case Expression expression?)
        'expression': expression.accept(dart2Json),
    };
  }
}

final class StyleDirective extends Node {
  StyleDirective({
    required super.start,
    required super.end,
    required this.name,
    this.modifiers = const <String>[],
    this.value,
  });

  final DirectiveType type = DirectiveType.styleDirective;

  final String name;

  final List<String> modifiers;

  final Object? value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyleDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'StyleDirective',
      'type': type.name,
      'name': name,
      'modifiers': modifiers,
      if (value case bool value? when value)
        'value': value
      else if (value case List<Node> values? when values.isNotEmpty)
        'value': <Map<String, Object?>>[
          for (Node value in values) value.toJson(),
        ],
    };
  }
}

final class TransitionDirective extends Node {
  TransitionDirective({
    required super.start,
    required super.end,
    required this.name,
    this.modifiers = const <String>[],
    this.intro = false,
    this.outro = false,
    this.expression,
  });

  final DirectiveType type = DirectiveType.transition;

  final String name;

  final bool intro;

  final bool outro;

  final List<String> modifiers;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitTransitionDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'TransitionDirective',
      'type': type.name,
      'name': name,
      if (intro) 'intro': intro,
      if (outro) 'outro': outro,
      'modifiers': modifiers,
      if (expression case Expression expression?)
        'expression': expression.accept(dart2Json),
    };
  }
}

abstract interface class HasName implements Node {
  String get name;
}

abstract base class Tag extends Node {
  Tag({
    super.start,
    super.end,
    this.attributes = const <Node>[],
    super.children,
  });

  final List<Node> attributes;
}

final class Head extends Tag {
  Head({
    super.start,
    super.end,
    required super.attributes,
    required super.children,
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
          for (Node attribute in attributes) attribute.toJson(),
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
          for (Node attribute in attributes) attribute.toJson(),
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
          for (Node attribute in attributes) attribute.toJson(),
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
          for (Node attribute in attributes) attribute.toJson(),
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
          for (Node attribute in attributes) attribute.toJson(),
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
          for (Node attribute in attributes) attribute.toJson(),
        ],
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (Node node in children) node.toJson(),
        ],
    };
  }
}
