import '../variable.dart';

/// An abstraction representing a component of a parsed Dart expression.
abstract class Expression {
  const Expression();

  /// Given a [visitor] and optionally a [context], produce a return value [R].
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C> visitor, [CO? context]);

  @override
  String toString() {
    return '$runtimeType';
  }
}

/// A placeholder expression used when otherwise no expression is parsed/found.
///
/// For example, this might result from parsing `[foo]=""`.
class Empty extends Expression {
  const Empty();

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitEmptyExpr(this, context);
  }

  @override
  String toString() {
    return 'Empty ';
  }
}

/// A reference to a "static" variable or identifier represented by [id].
///
/// In practice, this means a reference to a static member, top-level member, or
/// any other identifier or symbol that can be referenced by a package URL and
/// symbol name, and is mostly a wrapper around [Variable].
class StaticRead extends Expression {
  const StaticRead(this.id);

  /// The identifier or symbol being referenced.
  final Variable id;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitStaticRead(this, context);
  }

  @override
  String toString() {
    return 'StaticRead($id)';
  }
}

/// A reference to a local variable [name].
///
/// In practice, this is used as optimization to change detect an interpolated
/// expression (such as `{{foo}}`) by checking the variable that has already
/// been assigned (e.g. `var currValN = context.foo`) has changed, instead of
/// checking if `interpolate(currValN)` has changed.
///
/// ```
/// // foo
/// VariableRead('foo')
/// ```
class VariableRead extends Expression {
  const VariableRead(this.name);

  /// Name of a local variable.
  final String name;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitVariableRead(this, context);
  }

  @override
  String toString() {
    return 'VariableRead($name)';
  }
}

/// The "root" expression (the context in which the expression is evaluated).
class ImplicitReceiver extends Expression {
  const ImplicitReceiver();

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitImplicitReceiver(this, context);
  }

  @override
  String toString() {
    return 'ImplicitReceiver';
  }
}

/// A ternary or where [condition] will either pick [trueExpr] or [falseExpr].
///
/// ```
/// // a ? b : c
/// Conditional(VariableRead('a'), VariableRead('b'), VariableRead('c'))
/// ```
class Conditional extends Expression {
  const Conditional(this.condition, this.trueExpression, this.falseExpression);

  /// The condition to evaluate.
  final Expression condition;

  /// The expression to evaluate if the condition is true.
  final Expression trueExpression;

  /// The expression to evaluate if the condition is false.
  final Expression falseExpression;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitConditional(this, context);
  }

  @override
  String toString() {
    return 'Conditional($condition) { $trueExpression, $falseExpression }';
  }
}

/// Represents the "if null" (`??`) operator.
///
/// ```
/// IfNull(VariableRead('a'), VariableRead('b')) // a ?? b
/// ```
class IfNull extends Expression {
  const IfNull(this.condition, this.nullExpression);

  /// Condition for the null check and result if it is not null.
  final Expression condition;

  /// Result if the [condition] operand is null.
  final Expression nullExpression;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitIfNull(this, context);
  }

  @override
  String toString() {
    return 'IfNull { $condition, $nullExpression }';
  }
}

/// Reads a property (getter or field) [name] from [receiver].
///
/// ```
/// PropertyRead(VariableRead('a'), 'b') // a.b
/// ```
class PropertyRead extends Expression {
  const PropertyRead(this.receiver, this.name);

  /// Context to read [name] from.
  final Expression receiver;

  /// Name of the field or getter.
  final String name;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPropertyRead(this, context);
  }

  @override
  String toString() {
    return 'PropertyRead($name) { $receiver }';
  }
}

/// Similar to [PropertyRead], but avoids NPEs by using `?.` instead of `.`.
///
/// ```
/// // a?.b
/// SafePropertyRead(VariableRead('a'), VariableRead('b'))
/// ```
class SafePropertyRead extends Expression {
  const SafePropertyRead(this.receiver, this.name);

  /// Context to read [name] from.
  final Expression receiver;

  /// Name of the field or getter.
  final String name;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitSafePropertyRead(this, context);
  }

  @override
  String toString() {
    return 'SafePropertyRead($name) { $receiver }';
  }
}

/// Similar to [PropertyRead], but uses bracket operator `[]` to refer to [key].
///
/// ```
/// // a['b']
/// KeyedRead(VariableRead('a'), LiteralPrimitive('b'))
/// ```
class KeyedRead extends Expression {
  const KeyedRead(this.receiver, this.key);

  /// Context to read [key] from.
  final Expression receiver;

  /// Expression passed to the `[]` operator.
  final Expression key;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitKeyedRead(this, context);
  }

  @override
  String toString() {
    return 'KeyedRead($key) { $receiver }';
  }
}

/// Writes a property (setter or field) [name] to [receiver].
///
/// ```
/// // a.b = 'c'
/// PropertyWrite(VariableRead('a'), 'b', LiteralPrimitive('c'))
/// ```
class PropertyWrite extends Expression {
  const PropertyWrite(this.receiver, this.name, this.value);

  /// Context to write [name] to.
  final Expression receiver;

  /// Name of the field or setter.
  final String name;

  /// Value to write.
  final Expression value;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPropertyWrite(this, context);
  }

  @override
  String toString() {
    return 'PropertyWrite($name) { $receiver, $value }';
  }
}

/// Similar to [PropertyWrite] using bracket operator `[]=` to refer to [key].
///
/// ```
/// // a['b'] = 'c'
/// KeyedWrite(VariableRead('a'), LiteralPrimitive('b'), LiteralPrimitive('c'))
/// ```
class KeyedWrite extends Expression {
  const KeyedWrite(this.receiver, this.key, this.value);

  /// Context to write [key] to.
  final Expression receiver;

  /// Expression passed to the `[]=` operator.
  final Expression key;

  /// Value to write.
  final Expression value;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitKeyedWrite(this, context);
  }

  @override
  String toString() {
    return 'KeyedWrite($key) { $receiver, $value }';
  }
}

/// A method call that has been interpreted as a specialized "pipe" invocation.
///
/// A pipe call looks (and is parsed) similar to a method call, but is treated
/// differently in terms of how it is evaluated (and converted to Dart code by
/// the generator).
///
/// ```
/// // $pipe.foo('bar', 'baz')
/// BindingPipe(
///   'foo',
///   LiteralPrimitive('bar'),
///   [LiteralPrimitive('baz')],
/// )
/// ```
class BindingPipe extends Expression {
  const BindingPipe(this.exp, this.name, this.args);

  /// Name of the pipe.
  final String name;

  /// First (required) argument passed into the pipe.
  final Expression exp;

  /// Subsequent (often, but not always optional) arguments passed.
  final List<Expression> args;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPipe(this, context);
  }

  @override
  String toString() {
    throw UnimplementedError();
  }
}

/// Represents a primitive value (either [number], [String], [bool], or `null`).
///
/// ```
/// // 'a'
/// Primitive('a')
///
/// // true
/// Primitive(true)
///
/// // 5
/// Primitive(5)
/// ```
class Primitive extends Expression {
  const Primitive(this.value);

  /// Value being parsed.
  ///
  /// This is either [num], [String], [bool], or `null`.
  final Object? value;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPrimitive(this, context);
  }

  @override
  String toString() {
    return 'LiteralPrimitive($value)';
  }
}

/// Represents converting a result or multiple results explicitly to a [String].
///
/// ```
/// // String  Expr   String
/// // i=0     i=0    i=1
/// // v       v      v
/// // Hello {{place}}!
/// Interpolation(['Hello ', '!'], [VariableRead('place'), EmptyExpr()])
/// ```
class Interpolation extends Expression {
  const Interpolation(this.strings, this.expressions);

  /// For a given expression `i`, the preceding string (if any).
  ///
  /// In practice, this is an empty string (`''`) if there is no preceding
  /// string, which is common.
  final List<String> strings;

  /// Expression(s) being converted into a string.
  final List<Expression> expressions;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    final iterator = expressions.iterator;

    for (var string in strings) {
      string = string.replaceAll('\'', '\\\'').replaceAll('\r', '\\r').replaceAll('\n', '\\n');
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write('\'$string\'');
      if (iterator.moveNext()) buffer.write(', ${iterator.current}');
    }

    return 'Interpolation { $buffer }';
  }
}

/// Represents a binary expression, i.e. `left operator right`.
///
/// ```
/// // 2 + 3
/// Binary('+', LiteralPrimitive(2), LiteralPrimitive(3))
/// ```
class Binary extends Expression {
  const Binary(this.operator, this.left, this.right);

  /// A literal result of parsing a binary operator.
  final String operator;

  /// Left-hand expression/
  final Expression left;

  /// Right-hand-expression
  final Expression right;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitBinary(this, context);
  }

  @override
  String toString() {
    return 'Binary($operator) { $left, $right }';
  }
}

/// A unary prefixed "not" expression, i.e. `!expr`.
///
/// ```
/// // !true
/// PrefixNot(LiteralPrimitive(true))
/// ```
class PrefixNot extends Expression {
  const PrefixNot(this.expression);

  /// Expression to negate.
  final Expression expression;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPrefixNot(this, context);
  }

  @override
  String toString() {
    return 'PrefixNot($expression)';
  }
}

/// Coerces `T?` to `T`, throwing if null, i.e. `var!`.
///
/// ```
/// // a!
/// PostfixNotNull(VariableRead('a'))
/// ```
class PostfixNotNull extends Expression {
  const PostfixNotNull(this.expression);

  /// Expression to coerce.
  final Expression expression;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPostfixNotNull(this, context);
  }

  @override
  String toString() {
    return 'PostfixNotNull($expression)';
  }
}

/// Represents a "named" expression, i.e. in the format of `name: expression`.
///
/// This format is utilized in Dart for both map-literals and function calls
/// with named arguments.
///
/// ```
/// // foo: 'bar'
/// NamedExpr('foo', LiteralPrimitive('bar'))
/// ```
class NamedExpression extends Expression {
  const NamedExpression(this.name, this.expression);

  /// Name (identifier) being assigned [expression].
  final String name;

  /// Expression being assigned.
  final Expression? expression;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitNamedArgument(this, context);
  }

  @override
  String toString() {
    if (expression == null) return 'NamedArgument($name)';
    return 'NamedArgument($name) { $expression }';
  }
}

/// A call to a method.
///
/// ```
/// // a.foo('bar', baz: 123)
/// MethodCall(VariableRead('a'), 'foo', [LiteralPrimitive('bar')], [NamedExpr('baz', LiteralPrimitive(123))])
/// ```
class MethodCall extends Expression {
  const MethodCall(this.receiver, this.name, this.positional, [this.named = const <NamedExpression>[]]);

  /// Receiver of the method call.
  final Expression receiver;

  /// Name of the method being called.
  final String name;

  /// Positional arguments to the method.
  final List<Expression> positional;

  /// Named arguments to the method.
  final List<NamedExpression> named;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitMethodCall(this, context);
  }

  @override
  String toString() {
    if (positional.isEmpty && named.isEmpty) return 'MethodCall($receiver, $name)';
    return 'MethodCall($receiver, $name) { ${[...positional, ...named].join(', ')} }';
  }
}

/// Similar to [MethodCall], but only if the [receiver] is non-null.
class SafeMethodCall extends Expression {
  SafeMethodCall(this.receiver, this.name, this.positional, [this.named = const <NamedExpression>[]]);

  /// Receiver of the method call.
  final Expression receiver;

  /// Name of the method being called.
  final String name;

  /// Positional arguments to the method.
  final List<Expression> positional;

  /// Named arguments to the method.
  final List<NamedExpression> named;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitSafeMethodCall(this, context);
  }

  @override
  String toString() {
    if (positional.isEmpty && named.isEmpty) return 'SafeMethodCall($receiver, $name)';
    return 'SafeMethodCall($receiver, $name) { ${[...positional, ...named].join(', ')} }';
  }
}

/// Similar to [MethodCall], but [target] is callable.
///
/// ```
/// // a('bar', baz: 123)
/// FunctionCall(VariableRead('a'), [LiteralPrimitive('bar')], [NamedExpr('baz', LiteralPrimitive(123))],
/// )
/// ```
class FunctionCall extends Expression {
  const FunctionCall(this.target, this.positional, [this.named = const <NamedExpression>[]]);

  final Expression target;

  final List<Expression> positional;

  final List<NamedExpression> named;

  @override
  R accept<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitFunctionCall(this, context);
  }

  @override
  String toString() {
    if (positional.isEmpty && named.isEmpty) return 'FunctionCall($target)';
    return 'FunctionCall($target) { ${[...positional, ...named].join(', ')} }';
  }
}

abstract class ExpressionVisitor<R, C> {
  const ExpressionVisitor();

  R visitBinary(Binary node, C context);

  R visitConditional(Conditional node, C context);

  R visitEmptyExpr(Empty node, C context);

  R visitFunctionCall(FunctionCall node, C context);

  R visitIfNull(IfNull node, C context);

  R visitImplicitReceiver(ImplicitReceiver node, C context);

  R visitInterpolation(Interpolation node, C context);

  R visitKeyedRead(KeyedRead node, C context);

  R visitKeyedWrite(KeyedWrite node, C context);

  R visitPrimitive(Primitive node, C context);

  R visitMethodCall(MethodCall node, C context);

  R visitNamedArgument(NamedExpression node, C context);

  R visitPipe(BindingPipe node, C context);

  R visitPostfixNotNull(PostfixNotNull node, C context);

  R visitPrefixNot(PrefixNot node, C context);

  R visitPropertyRead(PropertyRead node, C context);

  R visitPropertyWrite(PropertyWrite node, C context);

  R visitSafeMethodCall(SafeMethodCall node, C context);

  R visitSafePropertyRead(SafePropertyRead node, C context);

  R visitStaticRead(StaticRead node, C context);

  R visitVariableRead(VariableRead node, C context);
}

class RecursiveExpressionVisitor<C> implements ExpressionVisitor<void, C> {
  const RecursiveExpressionVisitor();

  void visitAll(List<Expression?> nodes, C context) {
    for (final node in nodes) {
      node!.accept(this, context);
    }
  }

  @override
  void visitBinary(Binary node, C context) {
    node.left.accept(this, context);
    node.right.accept(this, context);
  }

  @override
  void visitConditional(Conditional node, C context) {
    node.condition.accept(this, context);
    node.trueExpression.accept(this, context);
    node.falseExpression.accept(this, context);
  }

  @override
  void visitEmptyExpr(Empty node, C context) {}

  @override
  void visitPipe(BindingPipe node, C context) {
    node.exp.accept(this, context);
    visitAll(node.args, context);
  }

  @override
  void visitFunctionCall(FunctionCall node, C context) {
    node.target.accept(this, context);
    visitAll(node.positional, context);
    visitAll(node.named, context);
  }

  @override
  void visitNamedArgument(NamedExpression node, C context) {
    node.expression!.accept(this, context);
  }

  @override
  void visitIfNull(IfNull node, C context) {
    node.condition.accept(this, context);
    node.nullExpression.accept(this, context);
  }

  @override
  void visitImplicitReceiver(ImplicitReceiver node, C context) {}

  @override
  void visitInterpolation(Interpolation node, C context) {
    visitAll(node.expressions, context);
  }

  @override
  void visitKeyedRead(KeyedRead node, C context) {
    node.receiver.accept(this, context);
    node.key.accept(this, context);
  }

  @override
  void visitKeyedWrite(KeyedWrite node, C context) {
    node.receiver.accept(this, context);
    node.key.accept(this, context);
    node.value.accept(this, context);
  }

  @override
  void visitPrimitive(Primitive node, C context) {}

  @override
  void visitMethodCall(MethodCall node, C context) {
    node.receiver.accept(this, context);
    visitAll(node.positional, context);
    visitAll(node.named, context);
  }

  @override
  void visitPostfixNotNull(PostfixNotNull node, C context) {
    node.expression.accept(this, context);
  }

  @override
  void visitPrefixNot(PrefixNot node, C context) {
    node.expression.accept(this, context);
  }

  @override
  void visitPropertyRead(PropertyRead node, C context) {
    node.receiver.accept(this, context);
  }

  @override
  void visitPropertyWrite(PropertyWrite node, C context) {
    node.receiver.accept(this, context);
    node.value.accept(this, context);
  }

  @override
  void visitSafePropertyRead(SafePropertyRead node, C context) {
    node.receiver.accept(this, context);
  }

  @override
  void visitSafeMethodCall(SafeMethodCall node, C context) {
    node.receiver.accept(this, context);
    visitAll(node.positional, context);
    visitAll(node.named, context);
  }

  @override
  void visitStaticRead(StaticRead node, C context) {}

  @override
  void visitVariableRead(VariableRead node, C context) {}
}
