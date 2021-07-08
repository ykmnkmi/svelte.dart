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

class Calling extends Expression {
  Calling(this.expression, {List<Expression>? positional, Map<String, Expression>? named})
      : positional = positional ?? <Expression>[],
        named = named ?? <String, Expression>{};

  Expression expression;

  List<Expression> positional;

  Map<String, Expression> named;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitCalling(this, context);
  }

  @override
  String toString() {
    if (positional.isEmpty && named.isEmpty) {
      return '$expression()';
    }

    final buffer = StringBuffer('$expression(');
    buffer.writeAll(positional, ', ');

    if (named.isNotEmpty) {
      if (positional.isNotEmpty) {
        buffer.write(',');
      }

      buffer.writeAll(named.entries.map<String>((entry) => '${entry.key}: ${entry.key}'), ', ');
    }

    buffer.write(')');
    return '$buffer';
  }
}

class Field extends Expression {
  Field(this.expression, this.field);

  Expression expression;

  String field;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitField(this, context);
  }

  @override
  String toString() {
    return '$expression.$field';
  }
}

class Interpolation extends Expression {
  Interpolation(this.expressions);

  List<Expression> expressions;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    return interpolate(this);
  }

  static Expression orSingle(List<Expression> expressions) {
    switch (expressions.length) {
      case 0:
        return Text('');
      case 1:
        return expressions[0];
      default:
        return Interpolation(expressions);
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

class Attribute extends Node implements Comparable<Attribute> {
  Attribute(this.name);

  String name;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  int compareTo(Attribute other) {
    if (other is EventListener) {
      return 1;
    }

    return name.compareTo(other.name);
  }

  @override
  String toString() {
    return name;
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
    final node = value;
    return node is Identifier && node.name == name ? '{$name}' : '$name="${interpolate(value)}"';
  }
}

class Style extends ValueAttribute {
  Style(Expression value) : super('style', value);

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitStyle(this, context);
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
  int compareTo(Attribute other) {
    if (other is EventListener) {
      return name.compareTo(other.name);
    }

    return -1;
  }

  @override
  String toString() {
    return 'on:$name={ $callback }';
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
      prefix = '$prefix(${attributes.join(', ')})';
    }

    return children.isEmpty ? prefix : '$prefix { ${children.join(', ')} }';
  }
}

class Inline extends Element {
  Inline(this.name, [this.sub = '']) : super('component');

  String name;

  String sub;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    return visitor.visitInline(this, context);
  }

  @override
  String toString() {
    final buffer = StringBuffer(name);

    if (sub.isNotEmpty) {
      buffer.write('.$sub');
    }

    if (attributes.isNotEmpty) {
      buffer
        ..write('(')
        ..writeAll(attributes, ', ')
        ..write(')');
    }

    if (children.isNotEmpty) {
      buffer
        ..write(' { ')
        ..writeAll(children, ', ')
        ..write(' }');
    }

    return '$buffer';
  }
}

class Library extends Node {
  Library(this.name, this.fragment);

  String name;

  Fragment fragment;

  @override
  R accept<C, R>(Visitor<C, R> visitor, [C? context]) {
    throw UnimplementedError();
  }
}
