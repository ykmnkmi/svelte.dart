import 'dart:collection';

import 'visitor.dart';

abstract class Node {
  R accept<C, R>(Visitor<C, R> visitor, [C? context]);
}

abstract class Expression extends Node {}

class Text extends Expression {
  Text(this.data);

  String data;

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

class Primitive extends Expression {
  Primitive(this.value, this.type);

  String value;

  String type;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitPrimitive(this, context);
  }

  @override
  String toString() {
    return '$type#$value';
  }
}

class Identifier extends Expression {
  Identifier(this.name, [this.global = false]);

  String name;

  bool global;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitIdentifier(this, context);
  }

  @override
  String toString() {
    return name;
  }
}

class NodeList<T extends Node> extends Node with ListMixin<T> {
  NodeList() : children = <T>[];

  List<T> children;

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
  T operator [](int index) {
    return children[index];
  }

  @override
  void operator []=(int index, T value) {
    children[index] = value;
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitNodeList(this, context);
  }

  @override
  void add(T element) {
    children.add(element);
  }

  @override
  T removeAt(int index) {
    return children.removeAt(index);
  }

  @override
  T removeLast() {
    return children.removeLast();
  }

  @override
  String toString() {
    return '{ ${children.join(', ')} }';
  }
}

class Attribute extends NodeList<Node> {
  Attribute(this.name);

  String name;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    if (children.isEmpty) {
      return '$name';
    }

    return '$name: ${Interpolator.visitAll(children)}';
  }
}

class Element extends NodeList<Node> {
  Element(this.tag) : attributes = NodeList<Attribute>();

  String tag;

  NodeList<Attribute> attributes;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitElement(this, context);
  }

  @override
  String toString() {
    var prefix = 'Element.$tag';

    if (attributes.isNotEmpty) {
      prefix = '$prefix$attributes';
    }

    return '$prefix { ${children.join(', ')} }';
  }
}
