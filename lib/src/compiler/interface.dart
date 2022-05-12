import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit, Expression, Identifier;

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
  abstract String? name;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['name'] = name;
    return json;
  }

  @override
  String toString() {
    return name == null ? super.toString() : '${super}.$name';
  }
}

mixin DataNode on Node {
  abstract String? data;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['data'] = data;
    return json;
  }

  @override
  String toString() {
    return data == null ? '${super} \'\'' : '${super} \'${data!.replaceAll('\'', '\\\'')} \'';
  }
}

mixin ElseNode on Node {
  abstract bool? elseIf;

  abstract Node? elseNode;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['elseIf'] = elseIf;
    json['elseNode'] = elseNode;
    return json;
  }
}

mixin MultiChildNode on Node {
  abstract List<Node> children;

  @override
  Map<String, Object?> toJson() {
    var json = super.toJson();
    json['children'] = children;
    return json;
  }

  @override
  String toString() {
    return children.isEmpty ? super.toString() : '${super} { ${children.join(', ')} }';
  }
}

class Text extends Node with DataNode {
  Text({super.start, super.end, this.data, this.raw}) : super(type: 'Text');

  @override
  String? data;

  String? raw;
}

class Comment extends Node with DataNode {
  Comment({super.start, super.end, this.data, this.ignores}) : super(type: 'Comment');

  @override
  String? data;

  List<String>? ignores;
}

class Fragment extends Node with MultiChildNode {
  Fragment({super.start, super.end, required this.children}) : super(type: 'Fragment');

  @override
  List<Node> children;
}

class Script extends Node with DataNode {
  Script({super.start, super.end, this.data, required this.library}) : super(type: 'Script');

  @override
  String? data;

  CompilationUnit library;
}

class Style extends Node with DataNode {
  Style({super.start, super.end, this.data}) : super(type: 'Style');

  @override
  String? data;
}

class AST {
  AST(this.html);

  Node html;

  Node? instance;

  Node? module;

  Node? style;

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

class CommonNode {
  CommonNode(
      {this.name,
      this.library,
      this.expression,
      this.error,
      this.intro,
      this.outro,
      this.index,
      this.key,
      this.context,
      this.pendingNode,
      this.thenNode,
      this.catchNode,
      this.skip,
      this.modifiers,
      this.attributes,
      this.identifiers,
      this.ignores});

  String? name;

  CompilationUnit? library;
  Expression? expression;
  Expression? error;

  bool? intro;
  bool? outro;

  String? index;
  Expression? key;
  Identifier? context;
  Node? pendingNode;
  Node? thenNode;
  Node? catchNode;

  bool? skip;

  List<String>? modifiers;
  List<Node>? attributes;
  List<Identifier>? identifiers;
  List<String>? ignores;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (name != null) 'name': name,
      if (library != null) 'library': library.toString(),
      if (expression != null) 'expression': expression.toString(),
      if (error != null) 'error': error.toString(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (index != null) 'index': index,
      if (key != null) 'key': key.toString(),
      if (context != null) 'context': context.toString(),
      if (pendingNode != null) 'pending': pendingNode!.toJson(),
      if (thenNode != null) 'then': thenNode!.toJson(),
      if (catchNode != null) 'catch': catchNode!.toJson(),
      if (skip != null) 'skip': skip,
      if (modifiers != null) 'modifiers': modifiers,
      if (attributes != null)
        'attributes': attributes!.map<Map<String, Object?>>((attribute) => attribute.toJson()).toList(),
      if (identifiers != null) 'identifiers': identifiers!.map<String>((identifier) => identifier.toString()).toList(),
      if (ignores != null) 'ignores': ignores,
    };
  }
}
