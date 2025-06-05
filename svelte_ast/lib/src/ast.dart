import 'package:analyzer/dart/ast/ast.dart' as dart;
import 'package:csslib/visitor.dart' as css;
import 'package:svelte_ast/src/visitor.dart';

typedef JsonMapper = Object? Function(Object? object);

extension NodeListToJson on List<Node> {
  List<Map<String, Object?>>? toJson([JsonMapper mapper = toStringMapper]) {
    return map<Map<String, Object?>>((node) => node.toJson(mapper)).toList();
  }
}

extension AstNodeToJson on List<dart.AstNode> {
  List<Object?>? toJson([JsonMapper mapper = toStringMapper]) {
    return map<Object?>(mapper).toList();
  }
}

extension TreeNodeToJson on List<css.TreeNode> {
  List<Object?>? toJson([JsonMapper mapper = toStringMapper]) {
    return map<Object?>(mapper).toList();
  }
}

Object? toStringMapper(Object? object) {
  return object.toString();
}

abstract class Node {
  Node({this.start = -1, this.end = -1});

  int start;

  int end;

  R accept<C, R>(Visitor<C, R> visitor, C context);

  Map<String, Object?> toJson([JsonMapper mapper]);
}

final class Fragment extends Node {
  Fragment({super.start, super.end, List<Node>? children})
    : children = children ?? <Node>[];

  final List<Node> children;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitFragment(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Fragment',
      'children': children.toJson(mapper),
    };
  }
}

final class Root extends Node {
  Root({
    required this.fragment,
    this.instance,
    this.module,
    this.style,
    this.options,
  });

  final Fragment fragment;

  /// The parsed `<script>` element, if exists.
  Script? instance;

  /// The parsed `<script module>` element, if exists.
  Script? module;

  /// The parsed `<style>` element, if exists.
  Style? style;

  /// Inline options provided by `<svelte:options>` — these override options
  /// passed to `compile(...)`.
  Options? options;

  @override
  int get start => fragment.start;

  @override
  set start(int start) {
    fragment.start = start;
  }

  @override
  int get end => fragment.end;

  @override
  set end(int end) {
    fragment.end = end;
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRoot(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Root',
      'fragment': fragment.toJson(mapper),
      'instance': instance?.toJson(mapper),
      'module': module?.toJson(mapper),
      'style': style?.toJson(mapper),
      'options': options?.toJson(mapper),
    };
  }
}

final class Options extends Node {
  Options({
    super.start,
    super.end,
    this.runes,
    this.immutable,
    this.accessors,
    this.preserveWhitespace,
    this.namespace,
    this.css,
    this.attributes = const <Never>[],
  });

  bool? runes;

  bool? immutable;

  bool? accessors;

  bool? preserveWhitespace;

  String? namespace;

  String? css;

  List<AttributeNode> attributes;

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
      'runes': runes,
      'immutable': immutable,
      'accessors': accessors,
      'preserveWhitespace': preserveWhitespace,
      'namespace': namespace,
      'css': css,
      'attributes': attributes.toJson(mapper),
    };
  }
}

/// Static text.
final class Text extends Node {
  Text({super.start, super.end, this.raw = '', this.data = ''});

  /// The original text, with undecoded HTML entities.
  final String raw;

  /// Text with decoded HTML entities.
  String data;

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
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Text',
      'raw': raw,
      'data': data,
    };
  }
}

abstract base class TagNode extends Node {
  TagNode({super.start, super.end});
}

/// A (possibly reactive) template expression — `{...}`.
final class ExpressionTag extends TagNode {
  ExpressionTag({super.start, super.end, required this.expression});

  final dart.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitExpressionTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ExpressionTag',
      'expression': mapper(expression),
    };
  }
}

/// A (possibly reactive) HTML template expression — `{@html ...}`.
final class HtmlTag extends TagNode {
  HtmlTag({super.start, super.end, required this.expression});

  final dart.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitHtmlTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'HtmlTag',
      'expression': mapper(expression),
    };
  }
}

/// An HTML comment.
final class Comment extends Node {
  Comment({super.start, super.end, this.data});

  /// theT contents of the comment.
  final String? data;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitComment(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Comment',
      'data': data,
    };
  }
}

/// A `{@final ...}` tag.
final class FinalTag extends TagNode {
  FinalTag({super.start, super.end, required this.expression});

  final dart.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitFinalTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'FinalTag',
      'expression': mapper(expression),
    };
  }
}

/// A `{@debug ...}` tag.
final class DebugTag extends TagNode {
  DebugTag({super.start, super.end, this.identifiers});

  final List<dart.SimpleIdentifier>? identifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDebugTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'DebugTag',
      'identifiers': identifiers?.toJson(mapper),
    };
  }
}

/// A `{@render foo(...)}` tag.
final class RenderTag extends TagNode {
  RenderTag({super.start, super.end, required this.expression});

  final dart.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRenderTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'RenderTag',
      'expression': mapper(expression),
    };
  }
}

abstract base class DirectiveNode extends NamedAttributeNode {
  DirectiveNode({super.start, super.end, required super.name});
}

/// An `animate:` directive.
final class AnimationDirective extends DirectiveNode {
  AnimationDirective({
    super.start,
    super.end,
    required super.name,
    this.expression,
  });

  /// The 'x' in `animate:x`.
  @override
  String get name => super.name;

  /// The y in `animate:x={y}`.
  final dart.Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAnimationDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'AnimationDirective',
      'name': name,
      'expression': mapper(expression),
    };
  }
}

/// A `bind:` directive.
final class BindDirective extends DirectiveNode
    implements UniqueNamedAttributeNode {
  BindDirective({super.start, super.end, required super.name, this.expression});

  /// The 'x' in `bind:x`.
  @override
  String get name => super.name;

  /// The y in `bind:x={y}`.
  final dart.Expression? expression;

  @override
  String get uniqueName => 'Attribute:$name';

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitBindDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'BindDirective',
      'name': name,
      'expression': mapper(expression),
    };
  }
}

/// A `class:` directive.
final class ClassDirective extends DirectiveNode
    implements UniqueNamedAttributeNode {
  ClassDirective({
    super.start,
    super.end,
    required super.name,
    this.expression,
  });

  /// The 'x' in `class:x`.
  @override
  String get name => super.name;

  /// The y in `class:x={y}`, or the `x` in `class:x`.
  final dart.Expression? expression;

  @override
  String get uniqueName => 'Attribute:$name';

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitClassDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ClassDirective',
      'name': name,
      'expression': mapper(expression),
    };
  }
}

/// A `let:` directive.
final class LetDirective extends DirectiveNode {
  LetDirective({
    super.start,
    super.end,
    required super.name,
    this.expression,
    this.modifiers = const <Never>[],
  });

  /// The 'x' in `let:x`.
  @override
  String get name => super.name;

  /// The y in `let:x={y}`.
  final dart.Expression? expression;

  final List<String> modifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitLetDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'LetDirective',
      'name': name,
      'expression': mapper(expression),
      'modifiers': modifiers,
    };
  }
}

/// A `on:` directive.
final class OnDirective extends DirectiveNode {
  OnDirective({
    super.start,
    super.end,
    required super.name,
    this.expression,
    this.modifiers = const <Never>[],
  });

  /// The 'x' in `on:x`.
  @override
  String get name => super.name;

  /// The y in `on:x={y}`.
  final dart.Expression? expression;

  final List<String> modifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitOnDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'OnDirective',
      'name': name,
      'expression': mapper(expression),
      'modifiers': modifiers,
    };
  }
}

/// A `style:` directive.
final class StyleDirective extends DirectiveNode
    implements UniqueNamedAttributeNode {
  StyleDirective({
    super.start,
    super.end,
    required super.name,
    this.value,
    this.modifiers = const <Never>[],
  });

  /// The 'x' in `style:x`.
  @override
  String get name => super.name;

  /// The y in `style:x={y}`.
  final Object? value;

  // 'important'
  final List<String> modifiers;

  @override
  String get uniqueName => 'Attribute:$name';

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyleDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'StyleDirective',
      'name': name,
      'value': switch (value) {
        null => null,
        ExpressionTag value => value.toJson(mapper),
        List<Node> values => values.toJson(mapper),
        _ => throw TypeError(),
      },
      'modifiers': modifiers,
    };
  }
}

/// A `transition:`, `in:` or `out:` directive.
final class TransitionDirective extends DirectiveNode {
  TransitionDirective({
    super.start,
    super.end,
    required super.name,
    this.expression,
    this.modifiers = const <Never>[],
    required this.intro,
    required this.outro,
  });

  /// The 'x' in `transition:x`.
  @override
  String get name => super.name;

  /// The y in `transition:x={y}`.
  final dart.Expression? expression;

  // 'local', 'global'
  final List<String> modifiers;

  /// `true` if this is a `transition:` or `in:` directive.
  final bool intro;

  /// `true` if this is a `transition:` or `out:` directive.
  final bool outro;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitTransitionDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'TransitionDirective',
      'name': name,
      'expression': mapper(expression),
      'modifiers': modifiers,
      'intro': intro,
      'outro': outro,
    };
  }
}

/// A `use:` directive.
final class UseDirective extends DirectiveNode {
  UseDirective({super.start, super.end, required super.name, this.expression});

  /// The 'x' in `use:x`.
  @override
  String get name => super.name;

  /// The y in `use:x={y}`.
  final dart.Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitUseDirective(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'UseDirective',
      'name': name,
      'expression': mapper(expression),
    };
  }
}

abstract class ElementNode extends Node {
  ElementNode({
    super.start,
    super.end,
    required this.name,
    this.attributes = const <Never>[],
    Fragment? fragment,
  }) : fragment = fragment ?? Fragment();

  final String name;

  final List<AttributeNode> attributes;

  final Fragment fragment;
}

abstract class RenderableElement extends ElementNode {
  RenderableElement({
    super.start,
    super.end,
    required super.name,
    super.attributes,
    super.fragment,
  });
}

final class Component extends RenderableElement {
  Component({
    super.start,
    super.end,
    required super.name,
    super.attributes,
    super.fragment,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitComponent(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Component',
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class TitleElement extends ElementNode {
  TitleElement({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'title');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitTitleElement(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'TitleElement',
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SlotElement extends RenderableElement {
  SlotElement({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'slot');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSlotElement(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SlotElement',
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class RegularElement extends RenderableElement {
  RegularElement({
    super.start,
    super.end,
    required super.name,
    super.attributes,
    super.fragment,
  });

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRegularElement(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'RegularElement',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteBody extends ElementNode {
  SvelteBody({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:body');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteBody(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteBody',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteComponent extends RenderableElement {
  SvelteComponent({
    super.start,
    super.end,
    super.attributes,
    this.expression,
    super.fragment,
  }) : super(name: 'svelte:component');

  dart.Expression? expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteComponent(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteComponent',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'expression': mapper(expression),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteDocument extends ElementNode {
  SvelteDocument({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:document');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteDocument(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteDocument',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteElement extends RenderableElement {
  SvelteElement({
    super.start,
    super.end,
    super.attributes,
    this.tag,
    super.fragment,
  }) : super(name: 'svelte:element');

  dart.Expression? tag;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteElement(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteElement',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'tag': mapper(tag),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteFragment extends RenderableElement {
  SvelteFragment({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:fragment');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteFragment(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteFragment',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteBoundary extends ElementNode {
  SvelteBoundary({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:boundary');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteBoundary(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteBoundary',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteHead extends ElementNode {
  SvelteHead({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:head');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteHead(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteHead',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteOptions extends ElementNode {
  SvelteOptions({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:options');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteOptions(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteOptions',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteSelf extends RenderableElement {
  SvelteSelf({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:self');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteSelf(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteSelf',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

final class SvelteWindow extends ElementNode {
  SvelteWindow({super.start, super.end, super.attributes, super.fragment})
    : super(name: 'svelte:window');

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSvelteWindow(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SvelteWindow',
      'name': name,
      'attributes': attributes.toJson(mapper),
      'fragment': fragment.toJson(mapper),
    };
  }
}

abstract interface class Block implements Node {}

/// An `{#each ...}` block.
final class EachBlock extends Node implements Block {
  EachBlock({
    super.start,
    super.end,
    Fragment? body,
    this.fallback,
    required this.expression,
    required this.context,
    this.index,
    this.key,
  }) : body = body ?? Fragment();

  final dart.Expression expression;

  /// The `entry` in `{#each item as entry}`. `null` if `as` part is omitted.
  final dart.DartPattern context;

  final Fragment body;

  Fragment? fallback;

  final dart.SimpleIdentifier? index;

  final dart.Expression? key;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitEachBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'EachBlock',
      'body': body.toJson(mapper),
      'fallback': fallback?.toJson(mapper),
      'expression': mapper(expression),
      'context': mapper(context),
      'index': mapper(index),
      'key': mapper(key),
    };
  }
}

/// An `{#if ...}` block.
final class IfBlock extends Node implements Block {
  IfBlock({
    super.start,
    super.end,
    this.elseIf = false,
    required this.test,
    Fragment? consequent,
    this.alternate,
  }) : consequent = consequent ?? Fragment();

  final dart.Expression test;

  bool elseIf;

  Fragment consequent;

  Fragment? alternate;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitIfBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'IfBlock',
      'elseIf': elseIf,
      'test': mapper(test),
      'consequent': consequent.toJson(mapper),
      'alternate': alternate?.toJson(mapper),
    };
  }
}

/// An `{#await ...}` block.
final class AwaitBlock extends Node implements Block {
  AwaitBlock({
    super.start,
    super.end,
    required this.expression,
    this.value,
    this.error,
    this.pending,
    this.then,
    this.katch,
  });

  final dart.Expression expression;

  /// The resolved value inside the `then` block.
  dart.DartPattern? value;

  /// The rejection reason inside the `catch` block.
  dart.DartPattern? error;

  Fragment? pending;

  Fragment? then;

  Fragment? katch;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitAwaitBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'AwaitBlock',
      'expession': mapper(expression),
      'value': mapper(value),
      'error': mapper(error),
      'pending': pending?.toJson(mapper),
      'then': then?.toJson(mapper),
      'catch': katch?.toJson(mapper),
    };
  }
}

/// An `{#key ...}` block.
final class KeyBlock extends Node implements Block {
  KeyBlock({
    super.start,
    super.end,
    required this.expression,
    Fragment? fragment,
  }) : fragment = fragment ?? Fragment();

  final dart.Expression expression;

  final Fragment fragment;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitKeyBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'KeyBlock',
      'expression': mapper(expression),
      'fragment': fragment.toJson(mapper),
    };
  }
}

/// An `{#key ...}` block.
final class SnippetBlock extends Node implements Block {
  SnippetBlock({
    super.start,
    super.end,
    required this.expression,
    this.parameters = const <Never>[],
    Fragment? body,
  }) : body = body ?? Fragment();

  final dart.SimpleIdentifier expression;

  final List<dart.FormalParameter> parameters;

  final Fragment body;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSnippetBlock(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SnippetBlock',
      'expression': mapper(expression),
      'parameters': parameters.toJson(mapper),
      'body': body.toJson(mapper),
    };
  }
}

abstract class AttributeNode extends Node {
  AttributeNode({super.start, super.end});
}

abstract class NamedAttributeNode extends AttributeNode {
  NamedAttributeNode({super.start, super.end, required this.name});

  final String name;
}

abstract interface class UniqueNamedAttributeNode
    implements NamedAttributeNode {
  String get uniqueName;
}

final class Attribute extends NamedAttributeNode
    implements UniqueNamedAttributeNode {
  Attribute({
    super.start,
    super.end,
    required super.name,
    this.value,
    this.modifiers = const <Never>[],
  });

  final Object? value;

  final List<String> modifiers;

  @override
  String get uniqueName => 'Attribute:$name';

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
      'value': switch (value) {
        null => null,
        ExpressionTag value => value.toJson(mapper),
        List<Node> values => values.toJson(mapper),
        _ => throw TypeError(),
      },
      'modifiers': modifiers,
    };
  }
}

final class SpreadAttribute extends AttributeNode {
  SpreadAttribute({super.start, super.end, required this.expression});

  final dart.Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitSpreadAttribute(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'SpreadAttribute',
      'expression': mapper(expression),
    };
  }
}

abstract class Script extends Node {
  Script({super.start, super.end, required this.content});

  final ScriptContent content;
}

final class ScriptContent extends Node {
  ScriptContent({super.start, super.end, required this.content});

  final String content;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitScriptBody(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ScriptContent',
      'content': content,
    };
  }
}

final class ModuleScript extends Script {
  ModuleScript({
    super.start,
    super.end,
    required super.content,
    required this.unit,
  });

  final dart.AstNode unit;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitModuleScript(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ModuleScript',
      'content': content.toJson(mapper),
      'unit': mapper(unit),
    };
  }
}

final class InstanceScript extends Script {
  InstanceScript({
    super.start,
    super.end,
    required super.content,
    this.body = const <Never>[],
  });

  final List<dart.AstNode> body;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitInstanceScript(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'InstanceScript',
      'content': content.toJson(mapper),
      'body': body.toJson(mapper),
    };
  }
}

final class Style extends Node {
  Style({
    super.start,
    super.end,
    this.attributes = const <Never>[],
    required this.content,
    required this.children,
  });

  final List<AttributeNode> attributes;

  final StyleBody content;

  final List<css.TreeNode> children;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyle(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Style',
      'attributes': attributes.toJson(mapper),
      'content': content.toJson(mapper),
      'children': children.toJson(mapper),
    };
  }
}

final class StyleBody extends Node {
  StyleBody({super.start, super.end, required this.content});

  final String content;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyleBody(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'StyleBody',
      'content': content,
    };
  }
}
