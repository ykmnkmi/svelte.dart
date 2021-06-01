import 'package:piko/compiler.dart';

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

class Interpolation extends Expression {
  Interpolation(this.expressions);

  final List<Expression> expressions;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    return expressions.join();
  }

  static Expression orSingle(Iterable<Expression> expressions) {
    final list = expressions.toList();

    switch (list.length) {
      case 0:
        return Text('');
      case 1:
        return list[0];
      default:
        return Interpolation(list);
    }
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

class EventListener extends Attribute {
  EventListener(String name, this.callback) : super(name);

  Node callback;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitEventListener(this, context);
  }

  @override
  String toString() {
    return 'on:$name={ $callback }';
  }
}

class ValueAttribute extends Attribute {
  ValueAttribute(String name, this.value) : super(name);

  Expression value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitValueAttribute(this, context);
  }

  @override
  String toString() {
    return '$name="$value"';
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
