import 'visitor.dart';

class Attribute extends NodeList {
  String name;

  Attribute(this.name);

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

  Attribute attribute(String name) {
    final attribute = Attribute(name);
    attributes.add(attribute);
    return attribute;
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
  String name;

  Identifier(this.name);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitIdentifier(this, context);
  }

  @override
  String toString() {
    return name;
  }
}

abstract class Node {
  R accept<C, R>(Visitor<C, R> visitor, [C? context]);
}

abstract class NodeList extends Node {
  List<Node> children;

  NodeList({List<Node>? children}) : children = children == null ? <Node>[] : children.toList();

  bool get isEmpty {
    return children.isEmpty;
  }

  bool get isNotEmpty {
    return children.isNotEmpty;
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
