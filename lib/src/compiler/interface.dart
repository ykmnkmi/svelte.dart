import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit, Expression, Identifier;

class Node {
  factory Node.text({int? start, int? end, String data = '', String? raw}) {
    return Node(start: start, end: end, type: 'Text', data: data, raw: raw ?? data);
  }

  Node({
    this.start,
    this.end,
    required this.type,
    this.name,
    this.data,
    this.raw,
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
  String? raw;

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

  Map<String, Object?> toJson([bool includePosition = true]) {
    return <String, Object?>{
      if (includePosition && start != null) 'start': start,
      if (includePosition && end != null) 'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (data != null) 'raw': raw,
      if (library != null) 'library': library.toString(),
      if (expression != null) 'expression': expression.toString(),
      if (error != null) 'error': error.toString(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (elseIf != null) 'elseif': elseIf,
      if (elseNode != null) 'else': elseNode!.toJson(includePosition),
      if (index != null) 'index': index,
      if (key != null) 'key': key.toString(),
      if (context != null) 'context': context.toString(),
      if (pendingNode != null) 'pending': pendingNode!.toJson(includePosition),
      if (thenNode != null) 'then': thenNode!.toJson(includePosition),
      if (catchNode != null) 'catch': catchNode!.toJson(includePosition),
      if (skip != null) 'skip': skip,
      if (modifiers != null) 'modifiers': modifiers,
      if (attributes != null)
        'attributes': attributes!.map<Map<String, Object?>>((attribute) => attribute.toJson(includePosition)).toList(),
      if (identifiers != null) 'identifiers': identifiers!.map<String>((identifier) => identifier.toString()).toList(),
      if (ignores != null) 'ignores': ignores,
      if (children != null)
        'children': children!.map<Map<String, Object?>>((child) => child.toJson(includePosition)).toList(),
    };
  }

  @override
  String toString() {
    var buffer = StringBuffer(type);

    if (data != null && data!.isNotEmpty) {
      buffer
        ..write(' \'')
        ..write(data!.replaceAll('\'', '\\\''))
        ..write('\'');
    } else if (expression != null) {
      buffer
        ..write(' { ')
        ..write(expression)
        ..write(' }');
    } else if (children != null && children!.isNotEmpty) {
      buffer
        ..write(' { ')
        ..writeAll(children!, ', ')
        ..write(' }');
    }

    return buffer.toString();
  }
}

class AST {
  AST(this.html);

  Node html;

  Node? instance;

  Node? module;

  Node? style;

  Map<String, Object?> toJson([bool includePosition = true]) {
    return <String, Object?>{
      'html': html.toJson(includePosition),
      if (instance != null) 'instance': instance!.toJson(includePosition),
      if (module != null) 'module': module!.toJson(includePosition),
      if (style != null) 'style': style!.toJson(includePosition),
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
