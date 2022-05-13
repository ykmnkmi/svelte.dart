import 'package:analyzer/dart/ast/ast.dart'
    show
        ArgumentList,
        AstNode,
        CompilationUnit,
        Expression,
        Identifier,
        MethodInvocation,
        SimpleIdentifier,
        SimpleStringLiteral;
import 'package:analyzer/dart/ast/visitor.dart';

typedef NodeFactory = Node Function({int? start, int? end});

typedef ElementFactory = Element Function({int? start, int? end});

abstract class Node {
  Node({this.start, this.end, required this.type});

  int? start;

  int? end;

  String type;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      'type': type,
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

    if (name.isNotEmpty) {
      json['name'] = name;
    }

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

    if (data.isNotEmpty) {
      json['data'] = data;
    }

    return json;
  }
}

mixin ExpressionNode on Node {
  abstract Expression? expression;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    // TODO(json): convert
    if (expression != null) {
      json['expression'] = expression!.accept(const ToJsonVisitor());
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

mixin ElseNode on Node {
  abstract bool elseIf;

  abstract Node? elseNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (elseIf) {
      json['elseIf'] = elseIf;
    }

    if (elseNode != null) {
      json['elseNode'] = elseNode!.toJson();
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
      json['pendingNode'] = pendingNode!.toJson();
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
      json['thenNode'] = thenNode!.toJson();
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
      json['catchNode'] = catchNode!.toJson();
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
      json['error'] = error!.accept(const ToJsonVisitor());
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
      json['attributes'] = attributes.map<Map<String, Object?>>((attribute) => attribute.toJson()).toList();
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
      json['directives'] = directives.map<Map<String, Object?>>((directive) => directive.toJson()).toList();
    }

    return json;
  }
}

mixin MultiChildNode on Node {
  abstract List<Node> children;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['children'] = children.map<Map<String, Object?>>((child) => child.toJson()).toList();
    return json;
  }

  @override
  String toString() {
    return '$type { ${children.join(', ')} }';
  }
}

class Text extends Node with DataNode {
  Text({super.start, super.end, required this.data, this.raw}) : super(type: 'Text');

  @override
  String data;

  String? raw;
}

class Comment extends Node with DataNode {
  Comment({super.start, super.end, required this.data, this.ignores}) : super(type: 'Comment');

  @override
  String data;

  List<String>? ignores;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (ignores != null && ignores!.isNotEmpty) {
      json['ignores'] = ignores;
    }

    return json;
  }
}

class RawMustache extends Node with ExpressionNode {
  RawMustache({super.start, super.end, this.expression}) : super(type: 'RawMustacheTag');

  @override
  Expression? expression;
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

class Attribute extends Node with NamedNode, DataNode, MultiChildNode {
  Attribute({super.start, super.end, super.type = 'Attribute', this.name = '', this.data = '', List<Node>? children})
      : children = children ?? <Node>[];

  @override
  String name;

  @override
  String data;

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
}

class InlineComponent extends Element {
  InlineComponent({super.start, super.end}) : super(type: 'InlineComponent');
}

class SlotTemplate extends Element {
  SlotTemplate({super.start, super.end}) : super(type: 'SlotTemplate');
}

class Title extends Element {
  Title({super.start, super.end}) : super(type: 'Title');
}

class Slot extends Element {
  Slot({super.start, super.end}) : super(type: 'Slot');
}

class Head extends Element {
  Head({super.start, super.end}) : super(type: 'Head');
}

class Options extends Element {
  Options({super.start, super.end}) : super(type: 'Options');
}

class Window extends Element {
  Window({super.start, super.end}) : super(type: 'Window');
}

class Body extends Element {
  Body({super.start, super.end}) : super(type: 'Body');
}

class IfBlock extends Node with ExpressionNode, ElseNode {
  IfBlock({super.start, super.end, this.expression, this.elseIf = false, this.elseNode}) : super(type: 'IfBlock');

  @override
  Expression? expression;

  @override
  bool elseIf;

  @override
  Node? elseNode;
}

class ElseBlock extends Node with MultiChildNode {
  ElseBlock({super.start, super.end, List<Node>? children})
      : children = children ?? <Node>[],
        super(type: 'ElseBlock');

  @override
  List<Node> children;
}

class EachBlock extends Node with ExpressionNode, MultiChildNode {
  EachBlock({super.start, super.end, this.expression, this.context, this.key}) : children = <Node>[], super(type: 'EachBlock');

  @override
  Expression? expression;

  Expression? context;

  String? index;

  Expression? key;

  @override
  List<Node> children;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (context != null) {
      json['context'] = context!.accept(const ToJsonVisitor());
    }

    if (index != null) {
      json['index'] = index!;
    }

    if (key != null) {
      json['key'] = key!.accept(const ToJsonVisitor());
    }

    return json;
  }
}

class KeyBlock extends Node with ExpressionNode {
  KeyBlock({super.start, super.end, this.expression}) : super(type: 'KeyBlock');

  @override
  Expression? expression;
}

class AwaitBlock extends Node with ExpressionNode, PendingNode, ThenNode, CatchNode, ErrorNode {
  AwaitBlock({super.start, super.end, this.expression, this.pendingNode, this.thenNode, this.catchNode})
      : super(type: 'AwaitBlock');

  @override
  Expression? expression;

  @override
  PendingBlock? pendingNode;

  @override
  ThenBlock? thenNode;

  @override
  CatchBlock? catchNode;

  @override
  Expression? error;
}

class PendingBlock extends Node with SkipNode {
  PendingBlock({super.start, super.end, this.skip = false}) : super(type: 'PendingBlock');

  @override
  bool skip;
}

class ThenBlock extends Node with SkipNode {
  ThenBlock({super.start, super.end, this.skip = false}) : super(type: 'ThenBlock');

  @override
  bool skip;
}

class CatchBlock extends Node with SkipNode {
  CatchBlock({super.start, super.end, this.skip = false}) : super(type: 'CatchBlock');

  @override
  bool skip;
}

class Debug extends Node {
  Debug({super.start, super.end, required this.identifiers}) : super(type: 'Debug');

  List<Identifier> identifiers;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['identifiers'] =
        identifiers.map<Map<String, Object?>?>((identifier) => identifier.accept(const ToJsonVisitor())).toList();
    return json;
  }
}

class Script extends Node with DataNode {
  Script({super.start, super.end, required this.data, required this.library}) : super(type: 'Script');

  @override
  String data;

  CompilationUnit library;
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

class ToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  const ToJsonVisitor();

  Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }

  @override
  Map<String, Object?>? visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      'type': 'ArgumentList',
      ...getLocation(node),
      'arguments': <Map<String, Object?>?>[for (var argument in node.arguments) argument.accept(this)],
    };
  }

  @override
  Map<String, Object?> visitMethodInvocation(MethodInvocation node) {
    return <String, Object?>{
      'type': 'MethodInvocation',
      ...getLocation(node),
      'methodName': node.methodName.accept(this),
      'argumentList': node.argumentList.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      'type': 'SimpleIdentifier',
      ...getLocation(node),
      'name': node.name,
    };
  }

  @override
  Map<String, Object?>? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      'type': 'SimpleStringLiteral',
      ...getLocation(node),
      'value': node.value,
    };
  }
}
