import 'package:piko/compiler.dart';

import 'nodes.dart';

String interpolate(Node node, {String context = 'context', bool wrap = true}) {
  return Interpolator(wrap).visit(node, context);
}

class Interpolator extends Visitor<String?, String> {
  Interpolator([this.wrap = true]);

  bool wrap;

  String apply(bool value, String Function() callback) {
    final current = wrap;
    wrap = value;
    final result = callback();
    wrap = current;
    return result;
  }

  @override
  String visit(Node node, [String? context]) {
    return node.accept(this, context);
  }

  @override
  String visitBinary(Binary node, [String? context]) {
    final result = apply(false, () {
      final left = node.left.accept(this, context);
      final right = node.right.accept(this, context);
      return '$left ${node.operator} $right';
    });

    return wrap ? '\${$result}' : result;
  }

  @override
  String visitCalling(Calling node, [String? context]) {
    final result = apply(false, () {
      final expression = node.expression.accept(this, context);
      return '$expression()';
    });

    return wrap ? '\${$result}' : result;
  }

  @override
  String visitCondition(Condition node, [String? context]) {
    final result = apply(false, () {
      final test = node.test.accept(this, context);
      final onTrue = node.onTrue.accept(this, context);
      final onFalse = node.onFalse.accept(this, context);
      return '$test ? $onTrue : $onFalse';
    });

    return wrap ? '\${$result}' : result;
  }

  @override
  String visitField(Field node, [String? context]) {
    final result = apply(false, () {
      final expression = node.expression.accept(this, context);
      return '$expression.${node.field}';
    });

    return wrap ? '\${$result}' : result;
  }

  @override
  String visitIdentifier(Identifier node, [String? context]) {
    final result = context == null ? node.name : '$context.${node.name}';
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
  String visitStyle(Style node, [String? context]) {
    return visitValueAttribute(node, context);
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

  R visitCalling(Calling node, [C? context]) {
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

  R visitField(Field node, [C? context]) {
    throw UnimplementedError();
  }

  R visitIdentifier(Identifier node, [C? context]) {
    throw UnimplementedError();
  }

  R visitInline(Inline node, [C? context]) {
    throw UnimplementedError();
  }

  R visitInterpolation(Interpolation node, [C? context]) {
    throw UnimplementedError();
  }

  R visitPrimitive(Primitive node, [C? context]) {
    throw UnimplementedError();
  }

  R visitStyle(Style node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }

  R visitValueAttribute(ValueAttribute node, [C? context]) {
    throw UnimplementedError();
  }
}
