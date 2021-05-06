import 'dart:collection';

import 'visitor.dart';

class Attribute extends Node {
  String name;

  Node? value;

  Attribute(this.name, [this.value]);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    if (value == null) {
      return '$name';
    }

    return '$name = $value';
  }
}

class Comment extends Text {
  Comment(String data) : super(data);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitComment(this, context);
  }

  @override
  String toString() {
    return "#'$escaped'";
  }
}

class Element extends Fragment {
  String tag;

  List<Attribute> attributes;

  Element(this.tag, {List<Node>? children})
      : attributes = <Attribute>[],
        super(children: children);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitElement(this, context);
  }

  @override
  String toString() {
    return 'Element.$tag(${attributes.join(', ')}) { ${children.join(', ')} }';
  }
}

abstract class Expression extends Node {}

class Fragment extends NodeList {
  Fragment({List<Node>? children}) : super(children: children);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitFragment(this, context);
  }

  @override
  String toString() {
    return 'Fragment { ${children.join(', ')} }';
  }
}

class Identifier extends Expression {
  String identifier;

  Identifier(this.identifier);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitIdentifier(this, context);
  }

  @override
  String toString() {
    return identifier;
  }
}

class Interpolation extends NodeList {
  Interpolation({List<Node>? children}) : super(children: children);

  static Node orNode(List<Node> nodes) {
    if (nodes.length == 1) {
      return nodes[0];
    }

    return Interpolation(children: nodes);
  }
}

abstract class Node {
  R accept<C, R>(Visitor<C, R> visitor, [C? context]);
}

class NodeList extends Node with ListMixin<Node> {
  List<Node> children;

  NodeList({List<Node>? children}) : children = children == null ? <Node>[] : children.toList();

  @override
  bool get isEmpty {
    return children.isEmpty;
  }

  @override
  bool get isNotEmpty {
    return children.isNotEmpty;
  }

  @override
  int get length {
    return children.length;
  }

  @override
  set length(int length) {
    children.length = length;
  }

  @override
  Node operator [](int index) {
    return children[index];
  }

  @override
  void operator []=(int index, Node node) {
    children[index] = node;
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitNodeList(this, context);
  }

  @override
  void add(Node node) {
    children.add(node);
  }

  @override
  String toString() {
    return '{ ${children.join(', ')} }';
  }
}

class Text extends Node {
  String data;

  Text(this.data);

  String get escaped {
    return data.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n');
  }

  bool get isEmpty {
    return data.isEmpty;
  }

  bool get isNotEmpty {
    return data.isNotEmpty;
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitText(this, context);
  }

  @override
  String toString() {
    return "'$escaped'";
  }
}
