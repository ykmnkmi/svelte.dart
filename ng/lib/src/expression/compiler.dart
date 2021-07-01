import 'nodes.dart';

class ExpressionCompiler extends ExpressionVisitor<String, String?> {
  const ExpressionCompiler();

  String visit(Expression node, [String? context]) {
    return node.accept(this, context);
  }

  @override
  String visitBinary(Binary node, String? context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    final operator = node.operator;
    return '$left $operator $right';
  }

  @override
  String visitConditional(Conditional node, String? context) {
    final condition = node.condition.accept(this, context);
    final trueExpression = node.trueExpression.accept(this, context);
    final falseExpression = node.falseExpression.accept(this, context);
    return '$condition ? $trueExpression : $falseExpression';
  }

  @override
  String visitEmptyExpr(Empty node, String? context) {
    return '';
  }

  @override
  String visitFunctionCall(FunctionCall node, String? context) {
    throw UnimplementedError('visitFunctionCall');
  }

  @override
  String visitIfNull(IfNull node, String? context) {
    final condition = node.condition.accept(this, context);
    final nullExpression = node.nullExpression.accept(this, context);
    return '$condition ?? $nullExpression';
  }

  @override
  String visitImplicitReceiver(ImplicitReceiver node, String? context) {
    return context ?? 'context';
  }

  @override
  String visitInterpolation(Interpolation node, String? context) {
    final buffer = StringBuffer();
    final iterator = node.expressions.iterator;

    for (var string in node.strings) {
      string = string.replaceAll('\'', '\\\'').replaceAll('\r', '\\r').replaceAll('\n', '\\n');
      buffer.write(string);

      if (iterator.moveNext()) {
        buffer.write(iterator.current);
      }
    }

    return '$buffer';
  }

  @override
  String visitKeyedRead(KeyedRead node, String? context) {
    throw UnimplementedError('visitKeyedRead');
  }

  @override
  String visitKeyedWrite(KeyedWrite node, String? context) {
    throw UnimplementedError('visitKeyedWrite');
  }

  @override
  String visitLiteralPrimitive(LiteralPrimitive node, String? context) {
    final value = node.value;
    if (value == null) return 'null';
    if (value is num) return '$value';
    if (value is String) return '\'${value.replaceAll('\'', '\\\'')}\'';
    throw UnsupportedError('${value.runtimeType}');
  }

  @override
  String visitMethodCall(MethodCall node, String? context) {
    throw UnimplementedError('visitMethodCall');
  }

  @override
  String visitNamedArgument(NamedArgument node, String? context) {
    throw UnimplementedError('visitNamedExpr');
  }

  @override
  String visitPipe(BindingPipe node, String? context) {
    throw UnimplementedError('visitPipe');
  }

  @override
  String visitPostfixNotNull(PostfixNotNull node, String? context) {
    throw UnimplementedError('visitPostfixNotNull');
  }

  @override
  String visitPrefixNot(PrefixNot node, String? context) {
    throw UnimplementedError('visitPrefixNot');
  }

  @override
  String visitPropertyRead(PropertyRead node, String? context) {
    throw UnimplementedError('visitPropertyRead');
  }

  @override
  String visitPropertyWrite(PropertyWrite node, String? context) {
    throw UnimplementedError('visitPropertyWrite');
  }

  @override
  String visitSafeMethodCall(SafeMethodCall node, String? context) {
    throw UnimplementedError('visitSafeMethodCall');
  }

  @override
  String visitSafePropertyRead(SafePropertyRead node, String? context) {
    throw UnimplementedError('visitSafePropertyRead');
  }

  @override
  String visitStaticRead(StaticRead node, String? context) {
    return node.id.value;
  }

  @override
  String visitVariableRead(VariableRead node, String? context) {
    throw UnimplementedError('visitVariableRead');
  }
}
