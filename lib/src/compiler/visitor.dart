import 'package:piko/compiler.dart';

import 'nodes.dart';

String interpolate(Node node, {String context = 'context', bool wrap = true}) {
  return Interpolator(wrap).visit(node, context);
}

class Interpolator extends Visitor<String?, String> {
  Interpolator([this.wrap = true]);

  bool wrap;

  @override
  String visit(Node node, [String? context]) {
    return node.accept(this, context);
  }

  @override
  String visitBinary(Binary node, [String? context]) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    final result = '$left ${node.operator} $right';
    return wrap ? '\${$result}' : result;
  }

  @override
  String visitCondition(Condition node, [String? context]) {
    final test = node.test.accept(this, context);
    final onTrue = node.onTrue.accept(this, context);
    final onFalse = node.onFalse.accept(this, context);
    final result = '$test ? $onTrue : $onFalse';
    return wrap ? '\${$result}' : result;
  }

  @override
  String visitIdentifier(Identifier node, [String? context]) {
    final result = '$context.${node.name}';
    return wrap ? '\${$result}' : result;
  }

  @override
  String visitInterpolation(Interpolation node, [String? context]) {
    return node.expressions.map<String>((expression) => expression.accept(this, context)).join();
  }

  @override
  String visitPrimitive(Primitive node, [String? context]) {
    return wrap ? '\${${node.value}}' : node.value;
  }

  @override
  String visitText(Text node, [String? context]) {
    return node.escaped;
  }
}

abstract class Visitor<C, R> {
  const Visitor();

  R visit(Node node, [C? context]) {
    throw UnimplementedError();
  }

  R visitAttribute(Attribute node, [C? context]) {
    throw UnimplementedError();
  }

  R visitBinary(Binary node, [C? context]) {
    throw UnimplementedError();
  }

  R visitCondition(Condition node, [C? context]) {
    throw UnimplementedError();
  }

  R visitElement(Element node, [C? context]) {
    throw UnimplementedError();
  }

  R visitEventListener(EventListener node, [C? context]) {
    throw UnimplementedError();
  }

  R visitIdentifier(Identifier node, [C? context]) {
    throw UnimplementedError();
  }

  R visitInterpolation(Interpolation node, [C? context]) {
    throw UnimplementedError();
  }

  R visitPrimitive(Primitive node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }

  R visitValueAttribute(ValueAttribute node, [C? context]) {
    throw UnimplementedError();
  }
}
