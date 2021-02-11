abstract class Node {
  Node() : children = <Node>[];

  List<Node> children;

  String toShortString();
}

class Text extends Node {
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

abstract class Expression extends Node {}

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

class Mustache extends Node {
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

class Fragment extends Node {
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
