import 'visitor.dart';

abstract class Node {
  List<Node> get children;

  set children(List<Node> children);

  bool get isLeaf;

  bool get isNotLeaf;

  R accpet<C, R>(Visitor<C, R> visitor);

  String toShortString();
}

abstract class EmptyNode implements Node {
  @override
  List<Node> get children {
    throw UnsupportedError('leaf node');
  }

  @override
  set children(List<Node> children) {
    throw UnsupportedError('leaf node');
  }

  @override
  bool get isLeaf {
    return true;
  }

  @override
  bool get isNotLeaf {
    return false;
  }

  @override
  R accpet<C, R>(Visitor<C, R> visitor) {
    throw UnimplementedError();
  }
}

class Text extends EmptyNode {
  Text(this.data);

  final String data;

  @override
  String toShortString() {
    return "'${data.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n')}'";
  }

  @override
  String toString() {
    return 'Text ${toShortString()}';
  }
}

class Comment extends Text {
  Comment(String data) : super(data);

  @override
  String toString() {
    return 'Comment ${toShortString()}';
  }
}

abstract class BaseNode implements Node {
  BaseNode() : children = <Node>[];

  @override
  List<Node> children;

  @override
  bool get isLeaf {
    return children.isEmpty;
  }

  @override
  bool get isNotLeaf {
    return children.isNotEmpty;
  }

  @override
  R accpet<C, R>(Visitor<C, R> visitor) {
    throw UnimplementedError();
  }
}

abstract class Expression extends BaseNode {}

class Identifier extends Expression {
  Identifier(this.identifier);

  final String identifier;

  @override
  String toShortString() {
    return identifier;
  }

  @override
  String toString() {
    return 'Identifier ${toShortString()}';
  }
}

class Mustache extends BaseNode {
  Mustache(this.expression);

  final Expression expression;

  @override
  String toShortString() {
    return expression.toShortString();
  }

  @override
  String toString() {
    return 'Mustache { ${toShortString()} }';
  }
}

class Fragment extends BaseNode {
  Fragment({List<Node>? children}) {
    if (children != null) {
      this.children.addAll(children);
    }
  }

  @override
  String toShortString() {
    return children.join(', ');
  }

  @override
  String toString() {
    return 'Fragment { ${toShortString()} }';
  }
}

class Element extends Fragment {
  Element(this.tag, {List<Node>? children}) : super(children: children);

  final String tag;

  @override
  String toShortString() {
    return '$tag { ${super.toShortString()} }';
  }

  @override
  String toString() {
    return 'Element.${toShortString()}';
  }
}

abstract class Meta extends Fragment {
  Meta(this.tag, {List<Node>? children}) : super(children: children);

  factory Meta.tag(String tag, {List<Node>? children}) {
    switch (tag) {
      case 'Head':
        return Head();
      case 'Options':
        return Options();
      case 'Window':
        return Window();
      case 'Body':
        return Body();
      default:
        throw ArgumentError.value(tag, 'tag');
    }
  }

  final String tag;

  @override
  String toShortString() {
    return '$tag { ${super.toShortString()} }';
  }

  @override
  String toString() {
    return 'Meta.${toShortString()}';
  }
}

class Head extends Meta {
  Head({List<Node>? children}) : super('Head', children: children);
}

class Options extends Meta {
  Options({List<Node>? children}) : super('Options', children: children);
}

class Window extends Meta {
  Window({List<Node>? children}) : super('Window', children: children);
}

class Body extends Meta {
  Body({List<Node>? children}) : super('Body', children: children);
}

class Title extends EmptyNode {
  Title({this.title});

  String? title;

  @override
  String toShortString() {
    return title == null ? '{ #title }' : '{ $title }';
  }

  @override
  String toString() {
    return 'Title ${toShortString()}';
  }
}

class Slot extends Fragment {
  Slot({List<Node>? children}) : super(children: children);

  @override
  String toString() {
    return 'Slot { ${toShortString()} }';
  }
}

class InlineComponent extends Fragment {
  InlineComponent(String tag, {List<Node>? children})
      : type = tag.startsWith('svelte:') ? tag.substring(7) : tag,
        super(children: children);

  final String type;

  @override
  String toShortString() {
    return '$type { ${super.toShortString()} }';
  }

  @override
  String toString() {
    return 'InlineComponent.${toShortString()}';
  }
}
