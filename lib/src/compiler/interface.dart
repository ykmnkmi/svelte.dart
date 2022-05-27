import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:piko/src/compiler/dart_to_json.dart';

const DartToJsonVisitor dartToJson = DartToJsonVisitor();

abstract class Node {
  Node({
    this.start,
    this.end,
    required this.type,
  });

  int? start;

  int? end;

  String type;

  List<Node> get children;

  String describe() {
    return type;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      '_': type,
    };
  }

  @override
  String toString() {
    return type;
  }
}

mixin ChildrenNode on Node {
  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (children.isNotEmpty) 'children': children,
    };
  }
}

mixin NoChildrenNode on Node {
  @override
  List<Node> get children {
    return const <Node>[];
  }
}

class Fragment extends Node with ChildrenNode {
  Fragment({
    super.start,
    super.end,
    super.type = 'Fragment',
    List<Node>? children,
  }) : children = children ?? <Node>[];

  @override
  List<Node> children;
}

mixin RawNode on Node {
  abstract String raw;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'raw': raw,
    };
  }
}

mixin DataNode on Node {
  abstract String data;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'data': data,
    };
  }
}

class Text extends Node with RawNode, DataNode, NoChildrenNode {
  Text({
    super.start,
    super.end,
    super.type = 'Text',
    required this.raw,
    required this.data,
  });

  @override
  String raw;

  @override
  String data;
}

mixin ExpressionNode on Node {
  abstract Expression? expression;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (expression != null) 'expression': expression!.accept(dartToJson),
    };
  }
}

class RawMustache extends Node with ExpressionNode, NoChildrenNode {
  RawMustache({
    super.start,
    super.end,
    super.type = 'RawMustacheTag',
    this.expression,
  });

  @override
  Expression? expression;

  @override
  String describe() {
    return '{@html} block';
  }
}

class Mustache extends Node with ExpressionNode, NoChildrenNode {
  Mustache({
    super.start,
    super.end,
    super.type = 'MustacheTag',
    this.expression,
  });

  @override
  Expression? expression;
}

mixin IgnoresNode on Node {
  abstract List<String>? ignores;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (ignores != null && ignores!.isNotEmpty) 'ignores': ignores,
    };
  }
}

class Comment extends Node with DataNode, IgnoresNode, NoChildrenNode {
  Comment({
    super.start,
    super.end,
    super.type = 'Comment',
    required this.data,
    this.ignores,
  });

  @override
  String data;

  @override
  List<String>? ignores;
}

mixin IdentifiersNode on Node {
  abstract List<Identifier> identifiers;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (identifiers.isNotEmpty) 'ignores': dartToJson.visitAll(identifiers),
    };
  }
}

class Debug extends Node with IdentifiersNode, NoChildrenNode {
  Debug({
    super.start,
    super.end,
    super.type = 'Debug',
    required this.identifiers,
  });

  @override
  List<Identifier> identifiers;

  @override
  String describe() {
    return '{@debug} block';
  }
}

mixin NamedNode on Node {
  abstract String name;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'name': name,
    };
  }
}

mixin ModifiersNode on Node {
  abstract List<String>? modifiers;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (modifiers != null && modifiers!.isNotEmpty) 'ignores': modifiers,
    };
  }
}

mixin TransitionNode on Node {
  abstract bool intro;

  abstract bool outro;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (intro) 'intro': intro,
      if (outro) 'outro': outro,
    };
  }
}

class Directive extends Node with NamedNode, ModifiersNode, ExpressionNode, TransitionNode, ChildrenNode {
  Directive({
    super.start,
    super.end,
    super.type = 'Directive',
    required this.name,
    this.modifiers,
    this.expression,
    this.intro = false,
    this.outro = false,
    List<Node>? children,
  })  : assert(isDirective(type)),
        children = children ?? <Node>[];

  @override
  String name;

  @override
  List<String>? modifiers;

  @override
  Expression? expression;

  @override
  bool intro;

  @override
  bool outro;

  @override
  List<Node> children;

  static bool isDirective(String type) {
    return type == 'Action' ||
        type == 'Animation' ||
        type == 'Binding' ||
        type == 'Class' ||
        type == 'StyleDirective' ||
        type == 'EventHandler' ||
        type == 'Let' ||
        type == 'Ref' ||
        type == 'Transition';
  }
}

class Attribute extends Node with NamedNode, ExpressionNode, ChildrenNode {
  Attribute({
    super.start,
    super.end,
    super.type = 'Attribute',
    required this.name,
    this.expression,
    List<Node>? children,
  }) : children = children ?? <Node>[];

  @override
  String name;

  @override
  Expression? expression;

  @override
  List<Node> children;
}

class Shorthand extends Node with ExpressionNode, NoChildrenNode {
  Shorthand({
    super.start,
    super.end,
    super.type = 'Shorthand',
    this.expression,
  });

  @override
  Expression? expression;
}

class Spread extends Node with ExpressionNode, NoChildrenNode {
  Spread({
    super.start,
    super.end,
    super.type = 'Spread',
    this.expression,
  });

  @override
  Expression? expression;
}

mixin AttributesNode on Node {
  abstract List<Node> attributes;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (attributes.isNotEmpty) 'attributes': attributes,
    };
  }
}

mixin TagNode on Node {
  abstract Object? tag;

  @override
  Map<String, Object?> toJson() {
    var tag = this.tag;

    return <String, Object?>{
      ...super.toJson(),
      if (tag is Expression) 'tag': tag.accept(dartToJson),
      if (tag is String) 'tag': tag,
    };
  }
}

class Element extends Node with NamedNode, AttributesNode, ChildrenNode, TagNode {
  Element({
    super.start,
    super.end,
    super.type = 'Element',
    required this.name,
    List<Node>? attributes,
    List<Node>? children,
    this.tag,
  })  : assert(isElement(type)),
        attributes = attributes ?? <Node>[],
        children = children ?? <Node>[];

  @override
  String name;

  @override
  List<Node> attributes;

  @override
  List<Node> children;

  @override
  Object? tag;

  @override
  String describe() {
    return '<$name> tag';
  }

  static bool isElement(String type) {
    return type == 'InlineComponent' ||
        type == 'SlotTemplate' ||
        type == 'Title' ||
        type == 'Slot' ||
        type == 'Element' ||
        type == 'Head' ||
        type == 'Options' ||
        type == 'Window' ||
        type == 'Body';
  }
}

class Script extends Node with NoChildrenNode {
  Script({
    super.start,
    super.end,
    super.type = 'Script',
    required this.context,
    required this.content,
    this.errors,
  });

  String context;

  CompilationUnit content;

  List<AnalysisError>? errors;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'context': context,
      'content': content.accept(dartToJson),
    };
  }
}

class Style extends Node with NoChildrenNode {
  Style({
    super.start,
    super.end,
    super.type = 'Style',
    required this.content,
  });

  String content;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'content': content,
    };
  }
}

class AST {
  AST(this.html);

  Node html;

  Node? instance;

  Script? module;

  Style? style;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html.toJson(),
      if (instance != null) 'instance': instance!.toJson(),
      if (module != null) 'module': module!.toJson(),
      if (style != null) 'style': style!.toJson(),
    };
  }

  @override
  String toString() {
    var buffer = StringBuffer('AST { $html');

    if (instance != null) {
      buffer.write(', $instance');
    }

    if (module != null) {
      buffer.write(', $module');
    }

    if (style != null) {
      buffer.write(', $style');
    }

    buffer.write(' }');
    return buffer.toString();
  }
}

abstract class Visitor {
  void enter(Node node) {}

  void leave(Node node) {}
}

mixin ElseIfNode on Node {
  abstract bool elseIf;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (elseIf) 'elseIf': elseIf,
    };
  }
}

mixin ElseNode on Node {
  abstract Node? elseNode;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (elseNode != null) 'else': elseNode,
    };
  }
}

class IfBlock extends Node with ElseIfNode, ExpressionNode, ChildrenNode, ElseNode {
  IfBlock({
    super.start,
    super.end,
    super.type = 'IfBlock',
    this.elseIf = false,
    this.expression,
    List<Node>? children,
    this.elseNode,
  }) : children = children ?? <Node>[];

  @override
  bool elseIf;

  @override
  Expression? expression;

  @override
  List<Node> children;

  @override
  Node? elseNode;

  @override
  String describe() {
    return '{#if} block';
  }
}

mixin IterableNode on Node {
  abstract Expression? iterable;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (iterable != null) 'iterable': iterable!.accept(dartToJson),
    };
  }
}

mixin IndexNode on Node {
  abstract String? index;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (index != null) 'index': index,
    };
  }
}

mixin KeyNode on Node {
  abstract Expression? key;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (key != null) 'key': key!.accept(dartToJson),
    };
  }
}

class EachBlock extends Node with ExpressionNode, IterableNode, IndexNode, KeyNode, ChildrenNode, ElseIfNode, ElseNode {
  EachBlock({
    super.start,
    super.end,
    super.type = 'EachBlock',
    this.iterable,
    this.expression,
    this.index,
    this.key,
    List<Node>? children,
    this.elseIf = false,
    this.elseNode,
  }) : children = children ?? <Node>[];

  @override
  Expression? iterable;

  @override
  Expression? expression;

  @override
  String? index;

  @override
  Expression? key;

  @override
  List<Node> children;

  @override
  bool elseIf;

  @override
  Node? elseNode;

  @override
  String describe() {
    return '{#each} block';
  }
}

class ElseBlock extends Node with ChildrenNode {
  ElseBlock({
    super.start,
    super.end,
    super.type = 'ElseBlock',
    List<Node>? children,
  }) : children = children ?? <Node>[];

  @override
  List<Node> children;

  @override
  String describe() {
    return '{:else} block';
  }
}

class AwaitBlock extends Node
    with ExpressionNode, ValueNode, ErrorNode, PendingNode, ThenNode, CatchNode, NoChildrenNode {
  AwaitBlock({
    super.start,
    super.end,
    super.type = 'AwaitBlock',
    this.expression,
    this.value,
    this.pendingNode,
    this.thenNode,
    this.catchNode,
  });

  @override
  Expression? expression;

  @override
  Expression? value;

  @override
  PendingBlock? pendingNode;

  @override
  ThenBlock? thenNode;

  @override
  CatchBlock? catchNode;

  @override
  Expression? error;

  @override
  String describe() {
    return '{#await} block';
  }
}

mixin ContextNode on Node {
  abstract String context;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      'context': context,
    };
  }
}

mixin ValueNode on Node {
  abstract Expression? value;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (value != null) 'value': value!.accept(dartToJson),
    };
  }
}

mixin SkipNode on Node {
  abstract bool skip;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (skip) 'skip': skip,
    };
  }
}

mixin PendingNode on Node {
  abstract PendingBlock? pendingNode;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (pendingNode != null) 'pending': pendingNode,
    };
  }
}

mixin ThenNode on Node {
  abstract ThenBlock? thenNode;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (thenNode != null) 'then': thenNode,
    };
  }
}

mixin CatchNode on Node {
  abstract CatchBlock? catchNode;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (catchNode != null) 'catch': catchNode,
    };
  }
}

mixin ErrorNode on Node {
  abstract Expression? error;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      ...super.toJson(),
      if (error != null) 'error': error!.accept(dartToJson),
    };
  }
}

class KeyBlock extends Node with ExpressionNode, NoChildrenNode {
  KeyBlock({super.start, super.end, this.expression}) : super(type: 'KeyBlock');

  @override
  Expression? expression;
}

class PendingBlock extends Node with SkipNode, ChildrenNode {
  PendingBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'PendingBlock');

  @override
  bool skip;

  @override
  List<Node> children;

  @override
  String describe() {
    return '{#await} block';
  }
}

class ThenBlock extends Node with SkipNode, ChildrenNode {
  ThenBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'ThenBlock');

  @override
  bool skip;

  @override
  List<Node> children;

  @override
  String describe() {
    return '{:then} block';
  }
}

class CatchBlock extends Node with SkipNode, ChildrenNode {
  CatchBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'CatchBlock');

  @override
  bool skip;

  @override
  List<Node> children;

  @override
  String describe() {
    return '{:catch} block';
  }
}
