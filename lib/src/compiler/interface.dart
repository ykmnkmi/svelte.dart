import 'package:analyzer/dart/ast/ast.dart' show Expression;

abstract class Node {
  List<Node> get children {
    throw UnsupportedError('not supported');
  }

  void add(Node node) {
    children.add(node);
  }
}

class Text extends Node {
  Text(this.data);

  String data;

  @override
  int get hashCode {
    return 0xE ^ data.hashCode;
  }

  @override
  bool operator ==(Object? other) {
    return other is Text && data == other.data;
  }

  @override
  String toString() {
    return 'Text { $data }';
  }
}

class Mustache extends Node {
  Mustache(this.expression);

  Expression expression;

  @override
  String toString() {
    return 'Mustache { $expression }';
  }
}

class Fragment extends Node {
  Fragment() : children = <Node>[];

  @override
  List<Node> children;

  @override
  String toString() {
    return 'Fragment { ${children.join(', ')} }';
  }
}

class Element extends Fragment {
  Element(this.name) : super();

  String name;

  @override
  String toString() {
    return 'Element.$name { ${children.join(', ')} }';
  }
}

abstract class Visitor {
  void enter(Node node) {}

  void leave(Node node) {}
}
