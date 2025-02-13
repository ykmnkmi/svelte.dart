part of '../ast.dart';

final class Attribute extends Node {
  Attribute({
    required super.start,
    required super.end,
    required this.name,
    required this.values,
  });

  final String name;

  final List<Node> values;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAttribute(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Attribute',
      'name': name,
      'values': <Object?>[for (Node value in values) value.toJson(mapper)],
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'AttributeShorthand',
      'expression': mapper(expression),
    };
  }
}

final class Spread extends Node {
  Spread({super.start, super.end, required this.expression});

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSpread(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Spread',
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
    };
  }
}

final class StyleDirective extends Directive {
  StyleDirective({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    required this.values,
  }) : super(type: DirectiveType.styleDirective);

  final List<Node> values;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyleDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'values': <Object?>[for (Node value in values) value.toJson(mapper)],
    };
  }
}

final class EventHandler extends Directive {
  EventHandler({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.expression,
  }) : super(type: DirectiveType.eventHandler);

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitEventHandler(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
    };
  }
}

final class Let extends Directive {
  Let({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.expression,
  }) : super(type: DirectiveType.let);

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitLet(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
    };
  }
}

final class Ref extends Directive {
  Ref({
    required super.start,
    required super.end,
    required super.name,
    super.modifiers,
    this.expression,
  }) : super(type: DirectiveType.ref);

  final Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRef(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      ...super.toJson(mapper),
      'intro': intro,
      'outro': outro,
      'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Head',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class Options extends Tag {
  Options({
    super.start,
    super.end,
    required super.name,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitOptions(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Options',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class Window extends Tag {
  Window({
    super.start,
    super.end,
    required super.name,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitWindow(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Window',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class Document extends Tag {
  Document({
    super.start,
    super.end,
    required super.name,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDocument(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Document',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

final class Body extends Tag {
  Body({
    super.start,
    super.end,
    required super.name,
    required super.attributes,
    required super.children,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitBody(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Body',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}

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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'InlineComponent',
      'name': name,
      'expression': mapper(expression),
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
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

  Node? tag;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitInlineElement(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'InlineElement',
      'name': tag?.toJson(mapper),
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SlotTemplate',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Title',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Slot',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Element',
      'name': name,
      'attributes': <Object?>[
        for (Node attribute in attributes) attribute.toJson(mapper),
      ],
      'children': <Object?>[for (Node child in children) child.toJson(mapper)],
    };
  }
}
