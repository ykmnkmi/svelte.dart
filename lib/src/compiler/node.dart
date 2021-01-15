import '../utils.dart';

abstract class Node {
  Node(this.name) : children = <Node>[];

  final String name;

  final List<Node> children;
}

class Text extends Node {
  Text(String name, this.value) : super(name);

  final String value;
}

class Interpolation extends Node {
  Interpolation(String name, this.expression)
      : isIdentifier = expression.isIdentifier,
        super(name);

  final String expression;

  final bool isIdentifier;
}
