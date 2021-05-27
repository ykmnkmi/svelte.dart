import 'nodes.dart';

String interpolate(Node node, [String context = 'context']) {
  return const Interpolator().visit(node, context);
}

class Interpolator extends Visitor<String?, String> {
  const Interpolator();

  @override
  String visit(Node node, [String? context]) {
    return node.accept(this, context);
  }

  @override
  String visitBinary(Binary node, [String? context]) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    return '$left ${node.operator} $right';
  }

  @override
  String visitCondition(Condition node, [String? context]) {
    final test = node.test.accept(this, context);
    final onTrue = node.onTrue.accept(this, context);
    final onFalse = node.onFalse.accept(this, context);
    return '$test ? $onTrue : $onFalse';
  }

  @override
  String visitIdentifier(Identifier node, [String? context]) {
    return '$context.${node.name}';
  }

  @override
  String visitPrimitive(Primitive node, [String? context]) {
    return node.value;
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

  R visitPrimitive(Primitive node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }
}
