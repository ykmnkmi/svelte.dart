import 'package:analyzer/dart/ast/ast.dart' show Expression;

class Node {
  Node(
      {required this.type,
      this.name,
      this.start,
      this.end,
      this.data,
      this.expression,
      this.intro,
      this.outro,
      this.attributes,
      this.modifiers,
      List<Node>? children})
      : children = children ?? <Node>[];

  String type;

  String? name;

  int? start;

  int? end;

  String? data;

  Expression? expression;

  List<String>? modifiers;

  List<Node>? attributes;

  List<Node> children;

  bool? intro;

  bool? outro;

  void addAttribute(Node attribute) {
    (attributes ??= <Node>[]).add(attribute);
  }

  void addChild(Node child) {
    children.add(child);
  }

  Map<String, Object?> toJson([bool verbose = true]) {
    var attributes = this.attributes;
    var modifiers = this.modifiers;

    return <String, Object?>{
      if (verbose && start != null) 'start': start,
      if (verbose && end != null) 'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (expression != null) 'expression': expression.toString(),
      if (modifiers != null && modifiers.isNotEmpty) 'modifiers': modifiers,
      if (attributes != null && attributes.isNotEmpty)
        'attributes': attributes.map<Map<String, Object?>>((attribute) => attribute.toJson(verbose)).toList(),
      if (children.isNotEmpty)
        'children': children.map<Map<String, Object?>>((child) => child.toJson(verbose)).toList(),
    };
  }

  @override
  String toString() {
    var buffer = StringBuffer(type);

    if (name != null) {
      buffer.write('.$name');
    }

    var attributes = this.attributes;

    if (attributes != null && attributes.isNotEmpty) {
      buffer.write(' (${attributes.join(', ')})');
    }

    if (data != null) {
      buffer.write(' {$data}');
    } else if (expression != null) {
      buffer.write(' {$expression}');
    } else if (children.isNotEmpty) {
      buffer.write(' {${children.join(', ')}}');
    }

    return buffer.toString();
  }
}

abstract class Visitor {
  void enter(Node node) {}

  void leave(Node node) {}
}
