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
      'class': 'Attribute',
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
      'class': 'AttributeShorthand',
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
      'class': 'Spread',
      'expression': expression.accept(dart2Json),
    };
  }
}

enum DirectiveType {
  action('Action'),
  animation('Animation'),
  binding('Binding'),
  classDirective('Class'),
  styleDirective('StyleDirective'),
  eventHandler('EventHandler'),
  let('Let'),
  ref('Ret'),
  transition('Transition');

  const DirectiveType(this.name);

  final String name;
}

abstract base class Directive extends Node {
  Directive({
    required super.start,
    required super.end,
    required this.type,
    required this.name,
    this.modifiers = const <String>[],
  });

  final DirectiveType type;

  final String name;

  final List<String> modifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type.name,
      'name': name,
      'modifiers': modifiers,
    };
  }
}

final class Action extends Directive {
  Action({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.action);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAction(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class Animation extends Directive {
  Animation({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.animation);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAnimation(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class Binding extends Directive {
  Binding({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.binding);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitBinding(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class ClassDirective extends Directive {
  ClassDirective({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.classDirective);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitClassDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class StyleDirective extends Directive {
  StyleDirective({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.value,
  }) : super(type: DirectiveType.styleDirective);

  final Object? value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyleDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (value case bool value? when value)
        'value': value
      else if (value case List<Node> values? when values.isNotEmpty)
        'value': <Map<String, Object?>>[
          for (Node value in values) value.toJson(),
        ],
    };
  }
}

final class EventHandler extends Directive {
  EventHandler({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.eventHandler);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitEventHandler(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class Let extends Directive {
  Let({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.let);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitLet(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class Ref extends Directive {
  Ref({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.ref);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRef(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'expression': expression?.accept(dart2Json),
    };
  }
}

final class TransitionDirective extends Directive {
  TransitionDirective({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.intro = false,
    this.outro = false,
    this.expression,
  }) : super(type: DirectiveType.transition);

  final bool intro;

  final bool outro;

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitTransitionDirective(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (intro) 'intro': intro,
      if (outro) 'outro': outro,
      'expression': expression?.accept(dart2Json),
    };
  }
}

abstract interface class HasName implements Node {
  String get name;
}

abstract base class Tag extends Node implements HasName {
  Tag({
    super.start,
    super.end,
    required this.name,
    this.attributes = const <Node>[],
    super.children,
  });

  @override
  final String name;

  final List<Node> attributes;
}

final class Head extends Tag {
  Head({
    super.start,
    super.end,
    required super.name,
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
      'class': 'Head',
      'name': name,
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
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
    required super.name,
    this.expression,
    required super.attributes,
    required super.children,
  });

  Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitInlineComponent(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'InlineComponent',
      'name': name,
      if (expression case Expression expression?)
        'expression': expression.accept(dart2Json),
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
      'children': <Map<String, Object?>>[
        for (Node node in children) node.toJson(),
      ],
    };
  }
}

final class InlineElement extends Tag {
  InlineElement({
    super.start,
    super.end,
    required super.name,
    this.tag,
    required super.attributes,
    required super.children,
  });

  Object? tag;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitInlineElement(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'InlineElement',
      'name': name,
      if (tag case String tag)
        'tag': tag
      else if (tag case Expression tag?)
        'tag': tag.accept(dart2Json),
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
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
    required super.name,
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
      'class': 'SlotTemplate',
      'name': name,
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
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
    required super.name,
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
      'class': 'Title',
      'name': name,
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
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
    required super.name,
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
      'class': 'Slot',
      'name': name,
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
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
    required super.name,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitElement(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Element',
      'name': name,
      if (attributes.isNotEmpty)
        'attributes': <Map<String, Object?>>[
          for (Node attribute in attributes) attribute.toJson(),
        ],
      'children': <Map<String, Object?>>[
        for (Node node in children) node.toJson(),
      ],
    };
  }
}
