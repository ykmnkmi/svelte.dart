import 'package:analyzer/dart/ast/ast.dart';
import 'package:piko/src/compiler/script_to_json.dart';

typedef NodeFactory = Node Function({int? start, int? end});

typedef ElementFactory = Element Function({int? start, int? end});

const ScriptToJsonVisitor scriptToJsonVisitor = ScriptToJsonVisitor();

abstract class Node {
  Node({this.start, this.end, required this.type});

  int? start;

  int? end;

  String type;

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

mixin NamedNode on Node {
  abstract String name;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['name'] = name;
    return json;
  }

  @override
  String toString() {
    if (name.isEmpty) {
      return type;
    }

    return '$type.$name';
  }
}

mixin DataNode on Node {
  abstract String data;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['data'] = data;
    return json;
  }
}

mixin ExpressionNode on Node {
  abstract Expression? expression;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (expression != null) {
      json['expression'] = expression!.accept(scriptToJsonVisitor);
    }

    return json;
  }
}

mixin ContextNode<T> on Node {
  abstract T context;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['context'] = context;
    return json;
  }
}

mixin ValueNode on Node {
  abstract Expression? value;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (value != null) {
      json['value'] = value!.accept(scriptToJsonVisitor);
    }

    return json;
  }
}

mixin IndexNode on Node {
  abstract String? index;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (index != null) {
      json['index'] = index;
    }

    return json;
  }
}

mixin KeyNode on Node {
  abstract Expression? key;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (key != null) {
      json['key'] = key!.accept(scriptToJsonVisitor);
    }

    return json;
  }
}

mixin SkipNode on Node {
  abstract bool skip;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (skip) {
      json['skip'] = skip;
    }

    return json;
  }
}

mixin ElseIfNode on Node {
  abstract bool elseIf;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (elseIf) {
      json['elseIf'] = elseIf;
    }

    return json;
  }
}

mixin ElseNode on Node {
  abstract Node? elseNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (elseNode != null) {
      json['else'] = elseNode!.toJson();
    }

    return json;
  }
}

mixin PendingNode on Node {
  abstract PendingBlock? pendingNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (pendingNode != null) {
      json['pending'] = pendingNode!.toJson();
    }

    return json;
  }
}

mixin ThenNode on Node {
  abstract ThenBlock? thenNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (thenNode != null) {
      json['then'] = thenNode!.toJson();
    }

    return json;
  }
}

mixin CatchNode on Node {
  abstract CatchBlock? catchNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (catchNode != null) {
      json['catch'] = catchNode!.toJson();
    }

    return json;
  }
}

mixin ErrorNode on Node {
  abstract Expression? error;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (error != null) {
      json['error'] = error!.accept(scriptToJsonVisitor);
    }

    return json;
  }
}

mixin IgnoresNode on Node {
  abstract List<String>? ignores;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (ignores != null && ignores!.isNotEmpty) {
      json['ignores'] = ignores;
    }

    return json;
  }
}

mixin MultiAttributeNode on Node {
  abstract List<Attribute> attributes;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (attributes.isNotEmpty) {
      json['attributes'] = <Map<String, Object?>?>[
        for (var attribute in attributes) attribute.toJson(),
      ];
    }

    return json;
  }
}

mixin MultiDirectiveNode on Node {
  abstract List<Directive> directives;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (directives.isNotEmpty) {
      json['directives'] = <Map<String, Object?>?>[
        for (var directive in directives) directive.toJson(),
      ];
    }

    return json;
  }
}

mixin MultiChildNode on Node {
  abstract List<Node> children;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    json['children'] = <Map<String, Object?>?>[
      for (var child in children) child.toJson(),
    ];

    return json;
  }

  @override
  String toString() {
    return '${super.toString()} { ${children.join(', ')} }';
  }
}

class Text extends Node with DataNode {
  Text({super.start, super.end, required this.data}) : super(type: 'Text');

  @override
  String data;
}

class Comment extends Node with DataNode, IgnoresNode {
  Comment({super.start, super.end, required this.data, this.ignores}) : super(type: 'Comment');

  @override
  String data;

  @override
  List<String>? ignores;
}

class RawMustache extends Node with ExpressionNode {
  RawMustache({super.start, super.end, this.expression}) : super(type: 'RawMustacheTag');

  @override
  Expression? expression;

  @override
  String describe() {
    return '{@html} block';
  }
}

class Mustache extends Node with ExpressionNode {
  Mustache({super.start, super.end, this.expression}) : super(type: 'MustacheTag');

  @override
  Expression? expression;
}

class Fragment extends Node with MultiChildNode {
  Fragment({super.start, super.end})
      : children = <Node>[],
        super(type: 'Fragment');

  @override
  List<Node> children;
}

class Attribute extends Node with NamedNode, MultiChildNode {
  Attribute({super.start, super.end, super.type = 'Attribute', this.name = '', List<Node>? children})
      : children = children ?? <Node>[];

  @override
  String name;

  @override
  List<Node> children;
}

class Spread extends Attribute with ExpressionNode {
  Spread({super.start, super.end, this.expression}) : super(type: 'Spread');

  @override
  Expression? expression;
}

class AttributeShorthand extends Node with ExpressionNode {
  AttributeShorthand({super.start, super.end, this.expression}) : super(type: 'AttributeShorthand');

  @override
  Expression? expression;
}

class Directive extends Node with NamedNode, ExpressionNode {
  Directive({super.start, super.end, super.type = 'Directive', required this.name, this.expression, this.modifiers})
      : intro = false,
        outro = false;

  @override
  String name;

  bool intro;

  bool outro;

  @override
  Expression? expression;

  List<String>? modifiers;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (intro) {
      json['intro'] = intro;
    }

    if (outro) {
      json['outro'] = outro;
    }

    if (modifiers != null && modifiers!.isNotEmpty) {
      json['modifiers'] = modifiers;
    }

    return json;
  }
}

class Element extends Node with NamedNode, MultiAttributeNode, MultiDirectiveNode, MultiChildNode {
  Element({super.start, super.end, super.type = 'Element', this.name = ''})
      : attributes = <Attribute>[],
        directives = <Directive>[],
        children = <Node>[];

  @override
  String name;

  @override
  List<Attribute> attributes;

  @override
  List<Directive> directives;

  @override
  List<Node> children;

  @override
  String describe() {
    return '<$name> tag';
  }
}

class InlineComponent extends Node
    with NamedNode, ExpressionNode, MultiAttributeNode, MultiDirectiveNode, MultiChildNode
    implements Element {
  InlineComponent({super.start, super.end, required this.name})
      : attributes = <Attribute>[],
        directives = <Directive>[],
        children = <Node>[],
        super(type: 'InlineComponent');

  @override
  String name;

  @override
  Expression? expression;

  @override
  List<Attribute> attributes;

  @override
  List<Directive> directives;

  @override
  List<Node> children;

  @override
  String describe() {
    return '<$name}> tag';
  }
}

// TODO(ast): change to Node with mixins
class SlotTemplate extends Element {
  SlotTemplate({super.start, super.end}) : super(type: 'SlotTemplate');
}

// TODO(ast): change to Node with mixins
class Title extends Element {
  Title({super.start, super.end}) : super(type: 'Title');

  @override
  String describe() {
    return '<$name}> tag';
  }
}

// TODO(ast): change to Node with mixins
class Slot extends Element {
  Slot({super.start, super.end}) : super(type: 'Slot');

  @override
  String describe() {
    return '<$name}> tag';
  }
}

// TODO(ast): change to Node with mixins
class Head extends Element {
  Head({super.start, super.end}) : super(type: 'Head');
}

// TODO(ast): change to Node with mixins
class Options extends Element {
  Options({super.start, super.end}) : super(type: 'Options');
}

class Window extends Element {
  Window({super.start, super.end}) : super(type: 'Window');
}

// TODO(ast): change to Node with mixins
class Body extends Element {
  Body({super.start, super.end}) : super(type: 'Body');
}

class IfBlock extends Node with ElseIfNode, ExpressionNode, MultiChildNode, ElseNode {
  IfBlock({super.start, super.end, this.elseIf = false, this.expression, this.elseNode})
      : children = <Node>[],
        super(type: 'IfBlock');

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

class EachBlock extends Node
    with ExpressionNode, ContextNode<Expression?>, IndexNode, KeyNode, MultiChildNode, ElseIfNode, ElseNode {
  EachBlock(
      {super.start, super.end, this.context, this.expression, this.index, this.key, this.elseIf = false, this.elseNode})
      : children = <Node>[],
        super(type: 'EachBlock');

  @override
  Expression? context;

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

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (context != null) {
      json['context'] = context!.accept(scriptToJsonVisitor);
    }

    if (index != null) {
      json['index'] = index!;
    }

    if (key != null) {
      json['key'] = key!.accept(scriptToJsonVisitor);
    }

    return json;
  }
}

class ElseBlock extends Node with MultiChildNode {
  ElseBlock({super.start, super.end})
      : children = <Node>[],
        super(type: 'ElseBlock');

  @override
  List<Node> children;

  @override
  String describe() {
    return '{:else} block';
  }
}

class KeyBlock extends Node with ExpressionNode {
  KeyBlock({super.start, super.end, this.expression}) : super(type: 'KeyBlock');

  @override
  Expression? expression;
}

class AwaitBlock extends Node with ExpressionNode, ValueNode, ErrorNode, PendingNode, ThenNode, CatchNode {
  AwaitBlock({super.start, super.end, this.expression, this.value, this.pendingNode, this.thenNode, this.catchNode})
      : super(type: 'AwaitBlock');

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

class PendingBlock extends Node with SkipNode, MultiChildNode {
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

class ThenBlock extends Node with SkipNode, MultiChildNode {
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

class CatchBlock extends Node with SkipNode, MultiChildNode {
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

class Debug extends Node {
  Debug({super.start, super.end, required this.identifiers}) : super(type: 'Debug');

  List<Identifier> identifiers;

  @override
  String describe() {
    return '{@debug} block';
  }

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    json['identifiers'] = <Map<String, Object?>?>[
      for (var identifier in identifiers) identifier.accept(scriptToJsonVisitor),
    ];

    return json;
  }
}

class Script extends Node with ContextNode<String> {
  Script({super.start, super.end, required this.context, required this.content}) : super(type: 'Script');

  @override
  String context;

  CompilationUnit content;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['content'] = content.accept(scriptToJsonVisitor);
    return json;
  }
}

class Style extends Node with DataNode {
  Style({super.start, super.end, required this.data}) : super(type: 'Style');

  @override
  String data;
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
