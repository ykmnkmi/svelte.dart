import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit, Expression, Identifier;

class Node {
  Node({
    this.start,
    this.end,
    required this.type,
    this.name,
    this.data,
    this.library,
    this.expression,
    this.error,
    this.intro,
    this.outro,
    this.elseIf,
    this.elseNode,
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
    this.ignores,
    this.children,
  });

  int? start;

  int? end;

  String type;

  String? name;

  String? data;

  CompilationUnit? library;
  Expression? expression;
  Expression? error;

  bool? intro;
  bool? outro;

  bool? elseIf;
  Node? elseNode;

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
  List<Node>? children;

  void addAttribute(Node attribute) {
    var attributes = this.attributes ??= <Node>[];
    attributes.add(attribute);
  }

  Map<String, Object?> toJson([bool verbose = true]) {
    return <String, Object?>{
      if (verbose && start != null) 'start': start,
      if (verbose && end != null) 'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (library != null) 'library': library.toString(),
      if (expression != null) 'expression': expression.toString(),
      if (error != null) 'error': error.toString(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (elseIf != null) 'elseif': elseIf,
      if (elseNode != null) 'else': elseNode!.toJson(verbose),
      if (index != null) 'index': index,
      if (key != null) 'key': key.toString(),
      if (context != null) 'context': context.toString(),
      if (pendingNode != null) 'pending': pendingNode!.toJson(verbose),
      if (thenNode != null) 'then': thenNode!.toJson(verbose),
      if (catchNode != null) 'catch': catchNode!.toJson(verbose),
      if (skip != null) 'skip': skip,
      if (modifiers != null && modifiers!.isNotEmpty) 'modifiers': modifiers,
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.map<Map<String, Object?>>((attribute) => attribute.toJson(verbose)).toList(),
      if (identifiers != null && identifiers!.isNotEmpty)
        'identifiers': identifiers!.map<String>((identifier) => identifier.toString()).toList(),
      if (ignores != null && ignores!.isNotEmpty) 'ignores': ignores,
      if (children != null && children!.isNotEmpty)
        'children': children!.map<Map<String, Object?>>((child) => child.toJson(verbose)).toList(),
    };
  }

  @override
  String toString() {
    var buffer = StringBuffer(type);
    // TODO: implement Node.toString()
    return buffer.toString();
  }
}

class AST {
  AST(this.html);

  Node html;

  Node? instance;

  Node? module;

  Node? style;

  Map<String, Object?> toJson([bool verbose = true]) {
    return <String, Object?>{
      'html': html.toJson(verbose),
      if (instance != null) 'instance': instance!.toJson(verbose),
      if (module != null) 'module': module!.toJson(verbose),
      if (style != null) 'style': style!.toJson(verbose),
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
