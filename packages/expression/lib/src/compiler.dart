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
    final target = node.target.accept(this, context);
    final args = node.positional.followedBy(node.named).map<String>((arg) => arg.accept(this, context)).join(', ');
    return '$target($args)';
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
        final current = iterator.current.accept(this, context);
        buffer.write('\${$current}');
      }
    }

    return '\'$buffer\'';
  }

  @override
  String visitKeyedRead(KeyedRead node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final key = node.key.accept(this, context);
    return '$receiver[$key]';
  }

  @override
  String visitKeyedWrite(KeyedWrite node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final key = node.key.accept(this, context);
    final value = node.value.accept(this, context);
    return '$receiver[$key] = $value';
  }

  @override
  String visitMethodCall(MethodCall node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final method = node.name;
    final args = node.positional.followedBy(node.named).map<String>((arg) => arg.accept(this, context)).join(', ');
    return '$receiver$method($args)';
  }

  @override
  String visitNamedArgument(NamedArgument node, String? context) {
    final name = node.name;
    final expression = node.expression;
    if (expression == null) return '$name: null';
    final value = expression.accept(this, context);
    return '$name: $value';
  }

  @override
  String visitPipe(BindingPipe node, String? context) {
    throw UnimplementedError('visitPipe');
  }

  @override
  String visitPostfixNotNull(PostfixNotNull node, String? context) {
    final value = node.expression.accept(this, context);
    return '$value!';
  }

  @override
  String visitPrefixNot(PrefixNot node, String? context) {
    final value = node.expression.accept(this, context);
    return '!$value';
  }

  @override
  String visitPrimitive(Primitive node, String? context) {
    final value = node.value;
    if (value == null) return 'null';
    if (value is num) return '$value';
    if (value is String) return '\'${value.replaceAll('\'', '\\\'')}\'';
    throw UnsupportedError('${value.runtimeType}');
  }

  @override
  String visitPropertyRead(PropertyRead node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final property = node.name;
    return '$receiver.$property';
  }

  @override
  String visitPropertyWrite(PropertyWrite node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final property = node.name;
    final value = node.value.accept(this, context);
    return '$receiver.$property = $value';
  }

  @override
  String visitSafeMethodCall(SafeMethodCall node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final method = node.name;
    final args = node.positional.followedBy(node.named).map<String>((arg) => arg.accept(this, context)).join(', ');
    return '$receiver$method($args)';
  }

  @override
  String visitSafePropertyRead(SafePropertyRead node, String? context) {
    final receiver = node.receiver.accept(this, context);
    final property = node.name;
    return '$receiver?.$property';
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
