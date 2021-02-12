import 'visitor.dart';

abstract class Node {
  Node({this.children = const <Node>[]});

  List<Node> children;

  bool get isLeaf {
    return children.isEmpty;
  }

  bool get isNotLeaf {
    return children.isNotEmpty;
  }

  R accpet<C, R>(Visitor<C, R> visitor) {
    throw UnimplementedError();
  }
}

class Text extends Node {
  Text(this.data);

  String data;

  String get escaped {
    return data.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n');
  }

  @override
  String toString() {
    return "'$escaped'";
  }
}

class Comment extends Text {
  Comment(String data) : super(data);

  @override
  String toString() {
    return "#'$escaped'";
  }
}

abstract class Expression extends Node {}

class Identifier extends Expression {
  Identifier(this.identifier);

  String identifier;

  @override
  String toString() {
    return identifier;
  }
}

class Fragment extends Node {
  Fragment({List<Node>? children}) : super(children: children ?? <Node>[]);

  @override
  String toString() {
    return 'Fragment(${children.join(', ')})';
  }
}

class Element extends Fragment {
  Element(this.tag, {List<Node>? children}) : super(children: children);

  String tag;

  @override
  String toString() {
    return 'Element.$tag(${children.join(', ')})';
  }
}

class Meta extends Fragment {
  Meta({required this.tag, List<Node>? children}) : super(children: children);

  String tag;

  @override
  String toString() {
    return 'Meta.$tag(${children.join()})';
  }
}

class Title extends Node {
  Title({this.title});

  String? title;

  @override
  String toString() {
    return 'Title(${title ?? ''})';
  }
}

class Slot extends Fragment {
  Slot({this.name, List<Node>? children}) : super(children: children);

  String? name;

  @override
  String toString() {
    return 'Slot${name == null ? '' : '.' + name!}(${children.join(', ')})';
  }
}

class InlineComponent extends Fragment {
  InlineComponent({required String tag, List<Node>? children})
      : type = tag.startsWith('svelte:') ? tag.substring(7) : tag,
        super(children: children);

  final String type;

  @override
  String toString() {
    return 'InlineComponent.$type(${children.join(', ')})';
  }
}

abstract class Block extends Node {}

abstract class IfBlock extends Block {}

abstract class EachBlock extends Block {}

class Style extends Node {
  @override
  String toString() {
    return 'Style()';
  }
}

class Script extends Node {
  Script({this.module = false, this.content = ''});

  bool module;

  String content;

  @override
  String toString() {
    return 'Script()';
  }
}
