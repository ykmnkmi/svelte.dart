import 'variable.dart';

/// An abstraction representing a component of a parsed Dart expression.
abstract class AST {
  /// Given a [visitor] and optionally a [context], produce a return value [R].
  R visit<R, C, CO extends C>(AstVisitor<R, C> visitor, [CO? context]);
}

/// Represents a "named" expression, i.e. in the format of `name: expression`.
///
/// This format is utilized in Dart for both map-literals and function calls
/// with named arguments.
///
/// ```
/// NamedExpr('foo', LiteralPrimitive('bar')) // foo: 'bar'
/// ```
class NamedExpr extends AST {
  NamedExpr(this.name, this.expression);

  /// Name (identifier) being assigned [expression].
  final String name;

  final AST? expression;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitNamedExpr(this, context);
  }
}

/// A placeholder expression used when otherwise no expression is parsed/found.
///
/// For example, this might result from parsing `[foo]=""`.
class EmptyExpr extends AST {
  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class StaticRead extends AST {
  StaticRead(this.id);

  final Variable id;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class VariableRead extends AST {
  VariableRead(this.name);

  /// Name of a local variable.
  final String name;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitVariableRead(this, context);
  }
}

/// The "root" expression (the context in which the expression is evaluated).
class ImplicitReceiver extends AST {
  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitImplicitReceiver(this, context);
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
class Conditional extends AST {
  Conditional(this.condition, this.trueExp, this.falseExp);

  final AST condition;

  final AST trueExp;

  final AST falseExp;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitConditional(this, context);
  }
}

/// Represents the "if null" (`??`) operator.
///
/// ```
/// IfNull(VariableRead('a'), VariableRead('b')) // a ?? b
/// ```
class IfNull extends AST {
  IfNull(this.condition, this.nullExp);

  /// Condition for the null check and result if it is not null.
  final AST condition;

  /// Result if the [condition] operand is null.
  final AST nullExp;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitIfNull(this, context);
  }
}

/// Reads a property (getter or field) [name] from [receiver].
///
/// ```
/// PropertyRead(VariableRead('a'), 'b') // a.b
/// ```
class PropertyRead extends AST {
  PropertyRead(this.receiver, this.name);

  /// Context to read [name] from.
  final AST receiver;

  /// Name of the field or getter.
  final String name;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPropertyRead(this, context);
  }
}

/// Similar to [PropertyRead], but avoids NPEs by using `?.` instead of `.`.
///
/// ```
/// SafePropertyRead(VariableRead('a'), VariableRead('b')) // a?.b
/// ```
class SafePropertyRead extends AST {
  SafePropertyRead(this.receiver, this.name);

  /// Context to read [name] from.
  final AST receiver;

  /// Name of the field or getter.
  final String name;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitSafePropertyRead(this, context);
  }
}

/// Similar to [PropertyRead], but uses bracket operator `[]` to refer to [key].
///
/// ```
/// KeyedRead(VariableRead('a'), LiteralPrimitive('b')) // a['b']
/// ```
class KeyedRead extends AST {
  KeyedRead(this.receiver, this.key);

  /// Context to read [key] from.
  final AST receiver;

  /// Expression passed to the `[]` operator.
  final AST key;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitKeyedRead(this, context);
  }
}

/// Writes a property (setter or field) [name] to [receiver].
///
/// ```
/// PropertyWrite(VariableRead('a'), 'b', LiteralPrimitive('c')) // a.b = 'c'
/// ```
class PropertyWrite extends AST {
  PropertyWrite(this.receiver, this.name, this.value);

  /// Context to write [name] to.
  final AST receiver;

  /// Name of the field or setter.
  final String name;

  /// Value to write.
  final AST value;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class KeyedWrite extends AST {
  KeyedWrite(this.receiver, this.key, this.value);

  /// Context to write [key] to.
  final AST receiver;

  /// Expression passed to the `[]=` operator.
  final AST key;

  /// Value to write.
  final AST value;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class BindingPipe extends AST {
  BindingPipe(this.exp, this.name, this.args);

  /// Name of the pipe.
  final String name;

  /// First (required) argument passed into the pipe.
  final AST exp;

  /// Subsequent (often, but not always optional) arguments passed.
  final List<AST> args;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class LiteralPrimitive extends AST {
  LiteralPrimitive(this.value);

  /// Value being parsed.
  ///
  /// This is either [number], [String], [bool], or `null`.
  final Object? value;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class Interpolation extends AST {
  Interpolation(this.strings, this.expressions);

  /// For a given expression `i`, the preceding string (if any).
  ///
  /// In practice, this is an empty string (`''`) if there is no preceding
  /// string, which is common.
  final List<String> strings;

  /// Expression(s) being converted into a string.
  final List<AST> expressions;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitInterpolation(this, context);
  }
}

/// Represents a binary expression, i.e. `left operator right`.
///
/// ```
/// // 2 + 3
/// Binary('+', LiteralPrimitive(2), LiteralPrimitive(3))
/// ```
class Binary extends AST {
  Binary(this.operator, this.left, this.right);

  /// A literal result of parsing a binary operator.
  final String operator;

  /// Left-hand expression/
  final AST left;

  /// Right-hand-expression
  final AST right;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitBinary(this, context);
  }
}

/// A unary prefixed "not" expression, i.e. `!expr`.
///
/// ```
/// // !true
/// PrefixNot(LiteralPrimitive(true))
/// ```
class PrefixNot extends AST {
  PrefixNot(this.expression);

  /// Expression to negate.
  final AST expression;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitPrefixNot(this, context);
  }
}

/// Coerces `T?` to `T`, throwing if null, i.e. `var!`.
///
/// ```
/// // a!
/// PostfixNotNull(VariableRead('a'))
/// ```
class PostfixNotNull extends AST {
  PostfixNotNull(this.expression);

  final AST expression;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class MethodCall extends AST {
  MethodCall(this.receiver, this.name, this.args, [this.namedArgs = const <NamedExpr>[]]);

  final AST receiver;

  final String name;

  final List<AST> args;

  final List<NamedExpr> namedArgs;

  @override
  R visit<R, C, CO extends C>(
    AstVisitor<R, C?> visitor, [
    CO? context,
  ]) =>
      visitor.visitMethodCall(this, context);
}

/// Similar to [MethodCall], but only if the [receiver] is non-null.
class SafeMethodCall extends AST {
  SafeMethodCall(this.receiver, this.name, this.args, [this.namedArgs = const <NamedExpr>[]]);

  final AST receiver;

  final String name;

  final List<AST> args;

  final List<NamedExpr> namedArgs;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
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
class FunctionCall extends AST {
  FunctionCall(this.target, this.args, [this.namedArgs = const <NamedExpr>[]]);

  final AST target;

  final List<AST> args;

  final List<NamedExpr> namedArgs;

  @override
  R visit<R, C, CO extends C>(AstVisitor<R, C?> visitor, [CO? context]) {
    return visitor.visitFunctionCall(this, context);
  }
}

/// Wraps an [AST] with [source] and [location] information.
class ASTWithSource {
  /// Wraps [ast] with [source] and [location] information (for debugging).
  ASTWithSource(this.ast, this.source, this.location);

  /// Replaces the perceived AST structure of [original] with [transform].
  ///
  /// However, the [source] and [location] remains the same (for debugging).
  ASTWithSource.from(ASTWithSource original, AST transformed) : this(transformed, original.source, original.location);

  /// Represents an [AST] without any source information.
  ASTWithSource.missingSource(AST ast) : this(ast, null, null);

  final AST ast;

  final String? source;

  final String? location;

  @override
  String toString() {
    return '$source in $location';
  }
}

abstract class AstVisitor<R, C> {
  R visitBinary(Binary ast, C context);

  R visitConditional(Conditional ast, C context);

  R visitEmptyExpr(EmptyExpr ast, C context);

  R visitFunctionCall(FunctionCall ast, C context);

  R visitIfNull(IfNull ast, C context);

  R visitImplicitReceiver(ImplicitReceiver ast, C context);

  R visitInterpolation(Interpolation ast, C context);

  R visitKeyedRead(KeyedRead ast, C context);

  R visitKeyedWrite(KeyedWrite ast, C context);

  R visitLiteralPrimitive(LiteralPrimitive ast, C context);

  R visitMethodCall(MethodCall ast, C context);

  R visitNamedExpr(NamedExpr ast, C context);

  R visitPipe(BindingPipe ast, C context);

  R visitPostfixNotNull(PostfixNotNull ast, C context);

  R visitPrefixNot(PrefixNot ast, C context);

  R visitPropertyRead(PropertyRead ast, C context);

  R visitPropertyWrite(PropertyWrite ast, C context);

  R visitSafeMethodCall(SafeMethodCall ast, C context);

  R visitSafePropertyRead(SafePropertyRead ast, C context);

  R visitStaticRead(StaticRead ast, C context);

  R visitVariableRead(VariableRead ast, C context);
}

class RecursiveAstVisitor<C> implements AstVisitor<void, C> {
  @override
  void visitBinary(Binary ast, C context) {
    ast.left.visit(this, context);
    ast.right.visit(this, context);
  }

  @override
  void visitConditional(Conditional ast, C context) {
    ast.condition.visit(this, context);
    ast.trueExp.visit(this, context);
    ast.falseExp.visit(this, context);
  }

  @override
  void visitEmptyExpr(EmptyExpr ast, C context) {}

  @override
  void visitPipe(BindingPipe ast, C context) {
    ast.exp.visit(this, context);
    visitAll(ast.args, context);
  }

  @override
  void visitFunctionCall(FunctionCall ast, C context) {
    ast.target.visit(this, context);
    visitAll(ast.args, context);
    visitAll(ast.namedArgs, context);
  }

  @override
  void visitNamedExpr(NamedExpr ast, C context) {
    ast.expression!.visit(this, context);
  }

  @override
  void visitIfNull(IfNull ast, C context) {
    ast.condition.visit(this, context);
    ast.nullExp.visit(this, context);
  }

  @override
  void visitImplicitReceiver(ImplicitReceiver ast, C context) {}

  @override
  void visitInterpolation(Interpolation ast, C context) {
    visitAll(ast.expressions, context);
  }

  @override
  void visitKeyedRead(KeyedRead ast, C context) {
    ast.receiver.visit(this, context);
    ast.key.visit(this, context);
  }

  @override
  void visitKeyedWrite(KeyedWrite ast, C context) {
    ast.receiver.visit(this, context);
    ast.key.visit(this, context);
    ast.value.visit(this, context);
  }

  @override
  void visitLiteralPrimitive(LiteralPrimitive ast, C context) {}

  @override
  void visitMethodCall(MethodCall ast, C context) {
    ast.receiver.visit(this, context);
    visitAll(ast.args, context);
    visitAll(ast.namedArgs, context);
  }

  @override
  void visitPostfixNotNull(PostfixNotNull ast, C context) {
    ast.expression.visit(this, context);
  }

  @override
  void visitPrefixNot(PrefixNot ast, C context) {
    ast.expression.visit(this, context);
  }

  @override
  void visitPropertyRead(PropertyRead ast, C context) {
    ast.receiver.visit(this, context);
  }

  @override
  void visitPropertyWrite(PropertyWrite ast, C context) {
    ast.receiver.visit(this, context);
    ast.value.visit(this, context);
  }

  @override
  void visitSafePropertyRead(SafePropertyRead ast, C context) {
    ast.receiver.visit(this, context);
  }

  @override
  void visitSafeMethodCall(SafeMethodCall ast, C context) {
    ast.receiver.visit(this, context);
    visitAll(ast.args, context);
    visitAll(ast.namedArgs, context);
  }

  @override
  void visitStaticRead(StaticRead ast, C context) {}

  @override
  void visitVariableRead(VariableRead ast, C context) {}

  void visitAll(List<AST?> asts, C context) {
    for (final ast in asts) {
      ast!.visit(this, context);
    }
  }
}

class AstTransformer implements AstVisitor<AST, void> {
  @override
  AST visitImplicitReceiver(ImplicitReceiver ast, _) {
    return ast;
  }

  @override
  AST visitStaticRead(StaticRead ast, _) {
    return ast;
  }

  @override
  AST visitVariableRead(VariableRead ast, _) {
    return ast;
  }

  @override
  AST visitInterpolation(Interpolation ast, _) {
    return Interpolation(ast.strings, _visitAll(ast.expressions));
  }

  @override
  AST visitLiteralPrimitive(LiteralPrimitive ast, _) {
    return LiteralPrimitive(ast.value);
  }

  @override
  AST visitPropertyRead(PropertyRead ast, _) {
    return PropertyRead(ast.receiver.visit(this), ast.name);
  }

  @override
  AST visitPropertyWrite(PropertyWrite ast, _) {
    return PropertyWrite(ast.receiver.visit(this), ast.name, ast.value);
  }

  @override
  AST visitSafePropertyRead(SafePropertyRead ast, _) {
    return SafePropertyRead(ast.receiver.visit(this), ast.name);
  }

  @override
  AST visitMethodCall(MethodCall ast, _) {
    return MethodCall(ast.receiver.visit(this), ast.name, _visitAll(ast.args), _visitAll(ast.namedArgs));
  }

  @override
  AST visitSafeMethodCall(SafeMethodCall ast, _) {
    return SafeMethodCall(ast.receiver.visit(this), ast.name, _visitAll(ast.args), _visitAll(ast.namedArgs));
  }

  @override
  AST visitFunctionCall(FunctionCall ast, _) {
    return FunctionCall(ast.target.visit(this), _visitAll(ast.args), _visitAll(ast.namedArgs));
  }

  @override
  AST visitNamedExpr(NamedExpr ast, _) {
    return ast;
  }

  @override
  AST visitBinary(Binary ast, _) {
    return Binary(ast.operator, ast.left.visit(this), ast.right.visit(this));
  }

  @override
  AST visitPostfixNotNull(PostfixNotNull ast, _) {
    return PostfixNotNull(ast.expression.visit(this));
  }

  @override
  AST visitPrefixNot(PrefixNot ast, _) {
    return PrefixNot(ast.expression.visit(this));
  }

  @override
  AST visitConditional(Conditional ast, _) {
    return Conditional(ast.condition.visit(this), ast.trueExp.visit(this), ast.falseExp.visit(this));
  }

  @override
  AST visitIfNull(IfNull ast, _) {
    return IfNull(ast.condition.visit(this), ast.nullExp.visit(this));
  }

  @override
  AST visitPipe(BindingPipe ast, _) {
    return BindingPipe(ast.exp.visit(this), ast.name, _visitAll(ast.args));
  }

  @override
  AST visitKeyedRead(KeyedRead ast, _) {
    return KeyedRead(ast.receiver.visit(this), ast.key.visit(this));
  }

  @override
  AST visitKeyedWrite(KeyedWrite ast, _) {
    return KeyedWrite(ast.receiver.visit(this), ast.key.visit(this), ast.value.visit(this));
  }

  @override
  AST visitEmptyExpr(EmptyExpr ast, _) {
    return EmptyExpr();
  }

  List<R> _visitAll<R extends AST>(List<AST> asts) {
    final res = <R>[];

    for (var i = 0; i < asts.length; ++i) {
      final ast = asts[i];
      final result = ast.visit(this);
      res.add(result as R);
    }

    return res;
  }
}
