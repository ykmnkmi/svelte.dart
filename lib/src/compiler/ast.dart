import 'package:nutty/src/compiler/parser/ast/attributes.dart';

abstract class Node {
  Node({this.start, this.end, required this.type});

  int? start;

  int? end;

  final String type;
}

class Text extends Node {
  Text({
    super.start,
    super.end,
    super.type = 'Text',
    required this.text,
  });

  final String text;
}

class Comment extends Node {
  Comment({
    super.start,
    super.end,
    super.type = 'Comment',
    required this.text,
  });

  final String text;
}

class Element extends Node {
  Element({
    super.start,
    super.end,
    super.type = 'Element',
    this.name,
    List<Attribute>? attributes,
    List<Node>? children,
  })  : arttributes = <Attribute>[...?attributes],
        children = <Node>[...?children];

  final String? name;

  final List<Attribute> arttributes;

  final List<Node> children;
}
