abstract class Node {
  String toShortString();
}

class Fragment implements Node {
  Fragment([List<Node>? children]) : children = children ?? <Node>[];

  List<Node> children;

  @override
  String toShortString() {
    return children.join(', ');
  }

  @override
  String toString() {
    return 'Fragment { ' + toShortString() + ' }';
  }
}

class Text implements Node {
  Text(this.text);

  final String text;

  @override
  String toShortString() {
    return text.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n');
  }

  @override
  String toString() {
    return "Text '" + toShortString() + "'";
  }
}

abstract class Expression implements Node {}

class Identifier implements Expression {
  Identifier(this.identifier);

  final String identifier;

  @override
  String toShortString() {
    return identifier;
  }

  @override
  String toString() {
    return 'Identifier ' + toShortString();
  }
}

class Mustache implements Node {
  Mustache(this.expression);

  final Expression expression;

  @override
  String toShortString() {
    return expression.toShortString();
  }

  @override
  String toString() {
    return 'Mustache { ' + toShortString() + ' }';
  }
}
