import 'package:analyzer/dart/ast/ast.dart' show AstNode;

class Node {
  Node(
      {this.start,
      this.end,
      required this.type,
      this.name,
      this.data,
      this.source,
      this.intro,
      this.outro,
      this.attributes,
      this.modifiers,
      List<Node>? children})
      : children = children ?? <Node>[];

  int? start;
  int? end;
  String type;
  String? name;

  String? data;
  AstNode? source;

  List<String>? modifiers;
  List<Node>? attributes;

  List<Node> children;

  bool? intro;
  bool? outro;

  bool? elseIf;
  Node? elseNode;

  void addAttribute(Node attribute) {
    final attributes = this.attributes ??= <Node>[];
    attributes.add(attribute);
  }

  void addChild(Node child) {
    children.add(child);
  }

  Map<String, Object?> toJson([bool verbose = true]) {
    return <String, Object?>{
      if (verbose && start != null) 'start': start,
      if (verbose && end != null) 'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (source != null) 'expression': source.toString(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (modifiers != null && modifiers!.isNotEmpty) 'modifiers': modifiers,
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.map<Map<String, Object?>>((attribute) => attribute.toJson(verbose)).toList(),
      if (children.isNotEmpty)
        'children': children.map<Map<String, Object?>>((child) => child.toJson(verbose)).toList(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer(type);

    if (name != null) {
      buffer.write('.$name');
    }

    final attributes = this.attributes;

    if (attributes != null && attributes.isNotEmpty) {
      buffer.write(' ( ${attributes.join(', ')} )');
    }

    if (data != null) {
      buffer.write(' { ${data!.replaceAll('\n', r'\n')} }');
    } else if (source != null) {
      buffer.write(' { ${source.toString().replaceAll('\n', r'\n')} }');
    } else if (children.isNotEmpty) {
      buffer.write(' { ${children.join(', ')} }');
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
    final buffer = StringBuffer('AST { $html');

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
