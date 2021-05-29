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
    return value;
  }
}

class Identifier extends Expression {
  Identifier(this.name);

  String name;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitIdentifier(this, context);
  }

  @override
  String toString() {
    return name;
  }
}

class Binary extends Expression {
  Binary(this.operator, this.left, this.right);

  String operator;

  Expression left;

  Expression right;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitBinary(this, context);
  }

  @override
  String toString() {
    return '$left $operator $right';
  }
}

class Condition extends Expression {
  Condition(this.test, this.onTrue, this.onFalse);

  Expression test;

  Expression onTrue;

  Expression onFalse;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitCondition(this, context);
  }

  @override
  String toString() {
    return '$test ? $onTrue : $onFalse';
  }
}

class Attribute extends Node {
  Attribute(this.name);

  String name;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    return name;
  }
}

class EventListener extends Node implements Attribute {
  EventListener(this.name, this.callback);

  @override
  String name;

  Node callback;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitEventListener(this, context);
  }

  @override
  String toString() {
    return 'on:$name="$callback"';
  }
}

class Fragment extends Node {
  Fragment() : children = <Node>[];

  List<Node> children;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    return children.join(', ');
  }
}

class Element extends Fragment {
  Element(this.tag)
      : attributes = <Attribute>[],
        super();

  String tag;

  List<Attribute> attributes;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitElement(this, context);
  }

  @override
  String toString() {
    var prefix = 'Element.$tag';

    if (attributes.isNotEmpty) {
      prefix = '$prefix( ${attributes.join(', ')} )';
    }

    return '$prefix { ${children.join(', ')} }';
  }
}
