import 'package:analyzer/dart/ast/ast.dart'
    show
        ArgumentList,
        AstNode,
        CompilationUnit,
        Expression,
        Identifier,
        IntegerLiteral,
        MethodInvocation,
        NamedType,
        PrefixedIdentifier,
        SimpleIdentifier,
        SimpleStringLiteral,
        TopLevelVariableDeclaration,
        VariableDeclaration,
        VariableDeclarationList;
import 'package:analyzer/dart/ast/visitor.dart';

typedef NodeFactory = Node Function({int? start, int? end});

typedef ElementFactory = Element Function({int? start, int? end});

const ToJsonVisitor jsonVisitor = ToJsonVisitor();

abstract class Node {
  Node({this.start, this.end, required this.type});

  int? start;

  int? end;

  String type;

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

mixin ContextNode on Node {
  abstract String context;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['context'] = context;
    return json;
  }
}

mixin ExpressionNode on Node {
  abstract Expression? expression;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (expression != null) {
      json['expression'] = expression!.accept(jsonVisitor);
    }

    return json;
  }
}

mixin ValueNode on Node {
  abstract Expression? value;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    if (value != null) {
      json['value'] = value!.accept(jsonVisitor);
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
  Text({super.start, super.end, required this.data, String? raw})
      : raw = raw ?? data,
        super(type: 'Text');

  @override
  String data;

  String raw;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['raw'] = raw;
    return json;
  }
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
  EachBlock({super.start, super.end, this.expression, this.context, this.key})
      : children = <Node>[],
        super(type: 'EachBlock');

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
      json['context'] = context!.accept(jsonVisitor);
    }

    if (index != null) {
      json['index'] = index!;
    }

    if (key != null) {
      json['key'] = key!.accept(jsonVisitor);
    }

    return json;
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
}

class PendingBlock extends Node with SkipNode, MultiChildNode {
  PendingBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'PendingBlock');

  @override
  bool skip;

  @override
  List<Node> children;
}

class ThenBlock extends Node with SkipNode, MultiChildNode {
  ThenBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'ThenBlock');

  @override
  bool skip;

  @override
  List<Node> children;
}

class CatchBlock extends Node with SkipNode, MultiChildNode {
  CatchBlock({super.start, super.end, this.skip = false})
      : children = <Node>[],
        super(type: 'CatchBlock');

  @override
  bool skip;

  @override
  List<Node> children;
}

class Debug extends Node {
  Debug({super.start, super.end, required this.identifiers}) : super(type: 'Debug');

  List<Identifier> identifiers;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();

    json['identifiers'] = <Map<String, Object?>?>[
      for (var identifier in identifiers) identifier.accept(jsonVisitor),
    ];

    return json;
  }
}

class Script extends Node with ContextNode {
  Script({super.start, super.end, required this.context, required this.content}) : super(type: 'Script');

  @override
  String context;

  CompilationUnit content;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['content'] = content.accept(jsonVisitor);
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

class ToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  const ToJsonVisitor();

  Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }

  @override
  Map<String, Object?> visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'ArgumentList',
      'arguments': <Map<String, Object?>?>[
        for (var argument in node.arguments) argument.accept(this),
      ],
    };
  }

  @override
  Map<String, Object?> visitCompilationUnit(CompilationUnit node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'CompilationUnit',
      'declarations': <Map<String, Object?>?>[
        for (var declaration in node.declarations) declaration.accept(this),
      ],
    };
  }

  @override
  Map<String, Object?> visitIntegerLiteral(IntegerLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'IntegerLiteral',
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitMethodInvocation(MethodInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'MethodInvocation',
      'methodName': node.methodName.accept(this),
      'argumentList': node.argumentList.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNamedType(NamedType node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'NamedType',
      if (node.isDeferred) 'deferred': true,
      'name': node.name.accept(this),
      if (node.typeArguments != null) 'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPrefixedIdentifier(PrefixedIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'PrefixedIdentifier',
      if (node.isDeferred) 'deferred': true,
      'prefix': node.prefix.accept(this),
      'identifier': node.identifier.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'SimpleIdentifier',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'SimpleStringLiteral',
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'TopLevelVariableDeclaration',
      'variables': node.variables.accept(this),
    };
  }

  @override
  Map<String, Object?> visitVariableDeclaration(VariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'VariableDeclaration',
      'name': node.name.accept(this),
      if (node.initializer != null) 'type': node.initializer!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitVariableDeclarationList(VariableDeclarationList node) {
    return <String, Object?>{
      ...getLocation(node),
      '_': 'VariableDeclarationList',
      if (node.isConst) 'const': true,
      if (node.isFinal) 'final': true,
      if (node.isLate) 'late': true,
      if (node.type != null) 'type': node.type!.accept(this),
      'variables': <Map<String, Object?>?>[
        for (var variable in node.variables) variable.accept(this),
      ],
    };
  }
}
