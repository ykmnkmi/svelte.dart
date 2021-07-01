import 'variable.dart';

/// An abstraction representing a component of a parsed Dart expression.
abstract class Expression {
  const Expression();

  /// Given a [visitor] and optionally a [context], produce a return value [R].
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C> visitor, [CO? context]);
}

/// Represents a "named" expression, i.e. in the format of `name: expression`.
///
/// This format is utilized in Dart for both map-literals and function calls
/// with named arguments.
///
/// ```
/// NamedExpr('foo', LiteralPrimitive('bar')) // foo: 'bar'
/// ```
class Named extends Expression {
  const Named(this.name, this.expression);

  /// Name (identifier) being assigned [expression].
  final String name;

  final Expression? expression;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitNamedExpr(this, context);
  }
}

/// A placeholder expression used when otherwise no expression is parsed/found.
///
/// For example, this might result from parsing `[foo]=""`.
class Empty extends Expression {
  const Empty();

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitEmptyExpr(this, context);
  }
}

/// A reference to a "static" variable or identifier represented by [id].
///
/// In practice, this means a reference to a static member, top-level member, or
/// any other identifier or symbol that can be referenced by a package URL and
/// symbol name, and is mostly a wrapper around [CompileIdentifierMetadata].
///
/// The two ways this is currently produced is by a `@HostBinding()` annotation
/// (where the expression is implicitly reading some static identifier) or by
/// using `@Component(exports: [...])` and referring to a static identifier or
/// function declared within.
///
/// ```
/// StaticRead(AppViewIdentifiers.someField); // appViewUtils.someField
/// ```
class StaticRead extends Expression {
  const StaticRead(this.id);

  final Variable id;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitStaticRead(this, context);
  }
}

/// A reference to a local variable [name].
///
/// In practice, this is used as optimization to change detect an interpolated
/// expression (such as `{{foo}}`) by checking the variable that has already
/// been assigned (e.g. `var currValN = context.foo`) has changed, instead of
/// checking if `interpolate(currValN)` has changed.
///
/// NOTE: One diference between this and [PropertyRead], is [name] is _not_
/// evaluated in context of the [ImplicitReciver].
///
/// ```
/// VariableRead('foo') // foo
/// ```
class VariableRead extends Expression {
  const VariableRead(this.name);

  /// Name of a local variable.
  final String name;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitVariableRead(this, context);
  }
}

/// The "root" expression (the context in which the expression is evaluated).
class ImplicitReceiver extends Expression {
  const ImplicitReceiver();

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
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
/// Conditional(
///   VariableRead('a'),
///   VariableRead('b'),
///   VariableRead('c'),
/// )
/// ```
class Conditional extends Expression {
  const Conditional(this.condition, this.trueExp, this.falseExp);

  final Expression condition;

  final Expression trueExp;

  final Expression falseExp;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitConditional(this, context);
  }
}

/// Represents the "if null" (`??`) operator.
///
/// ```
/// IfNull(VariableRead('a'), VariableRead('b')) // a ?? b
/// ```
class IfNull extends Expression {
  const IfNull(this.condition, this.nullExp);

  /// Condition for the null check and result if it is not null.
  final Expression condition;

  /// Result if the [condition] operand is null.
  final Expression nullExp;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitIfNull(this, context);
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPropertyRead(this, context);
  }

  @override
  String toString() {
    return 'PropertyRead { $receiver, $name }';
  }
}

/// Similar to [PropertyRead], but avoids NPEs by using `?.` instead of `.`.
///
/// ```
/// SafePropertyRead(VariableRead('a'), VariableRead('b')) // a?.b
/// ```
class SafePropertyRead extends Expression {
  const SafePropertyRead(this.receiver, this.name);

  /// Context to read [name] from.
  final Expression receiver;

  /// Name of the field or getter.
  final String name;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitSafePropertyRead(this, context);
  }
}

/// Similar to [PropertyRead], but uses bracket operator `[]` to refer to [key].
///
/// ```
/// KeyedRead(VariableRead('a'), LiteralPrimitive('b')) // a['b']
/// ```
class KeyedRead extends Expression {
  const KeyedRead(this.receiver, this.key);

  /// Context to read [key] from.
  final Expression receiver;

  /// Expression passed to the `[]` operator.
  final Expression key;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitKeyedRead(this, context);
  }
}

/// Writes a property (setter or field) [name] to [receiver].
///
/// ```
/// PropertyWrite(VariableRead('a'), 'b', LiteralPrimitive('c')) // a.b = 'c'
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPropertyWrite(this, context);
  }
}

/// Similar to [PropertyWrite] using bracket operator `[]=` to refer to [key].
///
/// ```
/// // a['b'] = 'c'
/// KeyedWrite(
///   VariableRead('a'),
///   LiteralPrimitive('b'),
///   LiteralPrimitive('c'),
/// )
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitKeyedWrite(this, context);
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPipe(this, context);
  }
}

/// Represents a primitive value (either [number], [String], [bool], or `null`).
///
/// ```
/// // 'a'
/// LiteralPrimitive('a')
///
/// // true
/// LiteralPrimitive(true)
///
/// // 5
/// LiteralPrimitive(5)
/// ```
class LiteralPrimitive extends Expression {
  const LiteralPrimitive(this.value);

  /// Value being parsed.
  ///
  /// This is either [number], [String], [bool], or `null`.
  final Object? value;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitLiteralPrimitive(this, context);
  }
}

/// Represents converting a result or multiple results explicitly to a [String].
///
/// ```
/// // String  Expr   String
/// // i=0     i=0    i=1
/// // v       v      v
/// // Hello {{place}}!
/// Interpolation(
///   ['Hello ', '!'],
///   [VariableRead('place'), EmptyExpr()],
/// )
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    Iterable<Object> iter() sync* {
      final iterator = expressions.iterator;

      for (var string in strings) {
        string = string.replaceAll('\'', '\\\'').replaceAll('\r', '\\r').replaceAll('\n', '\\n');
        yield '\'$string\'';

        if (iterator.moveNext()) {
          yield iterator.current;
        }
      }
    }

    return 'Interpolation { ${iter().join(', ')} }';
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitBinary(this, context);
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
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPrefixNot(this, context);
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

  final Expression expression;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPostfixNotNull(this, context);
  }
}

/// A call to a method.
///
/// ```
/// // a.foo('bar', baz: 123)
/// MethodCall(
///   VariableRead('a'),
///   'foo',
///   [LiteralPrimitive('bar')],
///   [NamedExpr('baz', LiteralPrimitive(123))],
/// )
/// ```
class MethodCall extends Expression {
  const MethodCall(this.receiver, this.name, this.args, [this.namedArgs = const <Named>[]]);

  final Expression receiver;

  final String name;

  final List<Expression> args;

  final List<Named> namedArgs;

  @override
  R visit<R, C, CO extends C>(
    ExpressionVisitor<R, C?> visitor, [
    CO? context,
  ]) =>
      visitor.visitMethodCall(this, context);
}

/// Similar to [MethodCall], but only if the [receiver] is non-null.
class SafeMethodCall extends Expression {
  SafeMethodCall(this.receiver, this.name, this.args, [this.namedArgs = const <Named>[]]);

  final Expression receiver;

  final String name;

  final List<Expression> args;

  final List<Named> namedArgs;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitSafeMethodCall(this, context);
  }
}

/// Similar to [MethodCall], but [target] is callable.
///
/// ```
/// // a('bar', baz: 123)
/// FunctionCall(
///   VariableRead('a'),
///   [LiteralPrimitive('bar')],
///   [NamedExpr('baz', LiteralPrimitive(123))],
/// )
/// ```
class FunctionCall extends Expression {
  const FunctionCall(this.target, this.args, [this.namedArgs = const <Named>[]]);

  final Expression target;

  final List<Expression> args;

  final List<Named> namedArgs;

  @override
  R visit<R, C, CO extends C>(ExpressionVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitFunctionCall(this, context);
  }
}

abstract class ExpressionVisitor<R, C> {
  R visitBinary(Binary node, C context);

  R visitConditional(Conditional node, C context);

  R visitEmptyExpr(Empty node, C context);

  R visitFunctionCall(FunctionCall node, C context);

  R visitIfNull(IfNull node, C context);

  R visitImplicitReceiver(ImplicitReceiver node, C context);

  R visitInterpolation(Interpolation node, C context);

  R visitKeyedRead(KeyedRead node, C context);

  R visitKeyedWrite(KeyedWrite node, C context);

  R visitLiteralPrimitive(LiteralPrimitive node, C context);

  R visitMethodCall(MethodCall node, C context);

  R visitNamedExpr(Named node, C context);

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

class RecursiveAstVisitor<C> implements ExpressionVisitor<void, C> {
  void visitAll(List<Expression?> nodes, C context) {
    for (final node in nodes) {
      node!.visit(this, context);
    }
  }

  @override
  void visitBinary(Binary node, C context) {
    node.left.visit(this, context);
    node.right.visit(this, context);
  }

  @override
  void visitConditional(Conditional node, C context) {
    node.condition.visit(this, context);
    node.trueExp.visit(this, context);
    node.falseExp.visit(this, context);
  }

  @override
  void visitEmptyExpr(Empty node, C context) {}

  @override
  void visitPipe(BindingPipe node, C context) {
    node.exp.visit(this, context);
    visitAll(node.args, context);
  }

  @override
  void visitFunctionCall(FunctionCall node, C context) {
    node.target.visit(this, context);
    visitAll(node.args, context);
    visitAll(node.namedArgs, context);
  }

  @override
  void visitNamedExpr(Named node, C context) {
    node.expression!.visit(this, context);
  }

  @override
  void visitIfNull(IfNull node, C context) {
    node.condition.visit(this, context);
    node.nullExp.visit(this, context);
  }

  @override
  void visitImplicitReceiver(ImplicitReceiver node, C context) {}

  @override
  void visitInterpolation(Interpolation node, C context) {
    visitAll(node.expressions, context);
  }

  @override
  void visitKeyedRead(KeyedRead node, C context) {
    node.receiver.visit(this, context);
    node.key.visit(this, context);
  }

  @override
  void visitKeyedWrite(KeyedWrite node, C context) {
    node.receiver.visit(this, context);
    node.key.visit(this, context);
    node.value.visit(this, context);
  }

  @override
  void visitLiteralPrimitive(LiteralPrimitive node, C context) {}

  @override
  void visitMethodCall(MethodCall node, C context) {
    node.receiver.visit(this, context);
    visitAll(node.args, context);
    visitAll(node.namedArgs, context);
  }

  @override
  void visitPostfixNotNull(PostfixNotNull node, C context) {
    node.expression.visit(this, context);
  }

  @override
  void visitPrefixNot(PrefixNot node, C context) {
    node.expression.visit(this, context);
  }

  @override
  void visitPropertyRead(PropertyRead node, C context) {
    node.receiver.visit(this, context);
  }

  @override
  void visitPropertyWrite(PropertyWrite node, C context) {
    node.receiver.visit(this, context);
    node.value.visit(this, context);
  }

  @override
  void visitSafePropertyRead(SafePropertyRead node, C context) {
    node.receiver.visit(this, context);
  }

  @override
  void visitSafeMethodCall(SafeMethodCall node, C context) {
    node.receiver.visit(this, context);
    visitAll(node.args, context);
    visitAll(node.namedArgs, context);
  }

  @override
  void visitStaticRead(StaticRead node, C context) {}

  @override
  void visitVariableRead(VariableRead node, C context) {}
}
