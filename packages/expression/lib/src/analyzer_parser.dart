import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/dart/ast/ast.dart' as Dart;
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/dart/ast/visitor.dart' show GeneralizingAstVisitor;
import 'package:expression/variable.dart';

import 'nodes.dart';
import 'parser.dart';

/// Implements [ExpressionParser] using `package:analyzer`'s AST parser.
class AnalyzerExpressionParser extends ExpressionParser {
  const AnalyzerExpressionParser() : super.forInheritence();

  Expression convertAndValididateExpression(Dart.Expression node, String input,
      {bool? allowAssignments, bool? allowPipes, List<Variable>? exports}) {
    try {
      return node.accept(SubsetVisitor(allowAssignments: allowAssignments, allowPipes: allowPipes, exports: exports))!;
    } on SubsetException catch (error) {
      throw ParseException(error.reason, input, error.node.toSource());
    }
  }

  @override
  Expression parseAction(String input, List<Variable> exports) {
    return parseExpression(input, allowAssignments: true, allowPipes: false, exports: exports);
  }

  @override
  Expression parseBinding(String input, List<Variable> exports) {
    return parseExpression(input, allowAssignments: false, exports: exports);
  }

  Expression parseExpression(String input, {bool? allowAssignments, bool? allowPipes, List<Variable>? exports}) {
    if (input.isEmpty) {
      return const Empty();
    }

    // This is a hack; currently analyzer can only accept valid compilation
    // units into `parseString`, which means we need something valid at the
    // top-level of a Dart file.
    final wrapper = 'void __EXPRESSION__() => $input;';
    final result = parseString(content: wrapper, throwIfDiagnostics: false);

    if (result.errors.isNotEmpty) {
      throw ParseException(result.errors.map<String>((error) => error.message).join('\n'), input);
    }

    final declared = result.unit.declarations;

    if (declared.length != 1) {
      throw ParseException('Not a valid expression', input);
    }

    final function = declared.first as Dart.FunctionDeclaration;
    final innerBody = function.functionExpression.body;
    final innerAst = (innerBody as Dart.ExpressionFunctionBody).expression;
    return convertAndValididateExpression(innerAst, input,
        allowAssignments: allowAssignments, allowPipes: allowPipes, exports: exports);
  }

  @override
  Expression? parseInterpolation(String input, List<Variable> exports) {
    final split = splitInterpolation(input);

    if (split == null) {
      return null;
    }

    final expressions = split.expressions
        .map<Expression>((expression) => parseExpression(expression, allowAssignments: false, exports: exports))
        .toList();
    return Interpolation(split.strings, expressions);
  }
}

class SubsetException implements Exception {
  SubsetException(this.reason, this.node);

  final String reason;

  final Dart.AstNode node;
}

/// A visitor that throws [SubsetException] on an "unknown" [AstNode].
///
/// By default, all [AstNode]s flow through [visitNode] (as-per the contract of
/// [GeneralizingAstVisitor]), so unless a more specialized method is overriden
/// we consider the node invalid - which means that as the language adds new
/// node type we reject it by default.
///
/// In order to support an [AstNode], we implement the visit method as a no-op:
/// ```
/// @override
/// void visitBooleanLiteal(BooleanLiteral astNode) {
///   // Allow.
/// }
/// ```
class SubsetVisitor extends GeneralizingAstVisitor<Expression> {
  SubsetVisitor({bool? allowAssignments, bool? allowPipes, List<Variable>? exports})
      : allowAssignments = allowAssignments ?? false,
        allowPipes = allowPipes ?? true,
        unprefixedExports = indexUnprefixed(exports ?? const <Variable>[]),
        prefixedExports = indexPrefixed(exports ?? const <Variable>[]);

  /// Whether to allow limited use of the assignment (`=`) operator.
  ///
  /// While otherwise a valid expression, only "actions" (event bindings) allow:
  /// ```html
  /// <!-- Invalid -->
  /// <button [disabled]="disabled = true" />
  ///
  /// <!-- Valid -->
  /// <button (click)="clicked = true" />
  ///
  /// <!-- Valid -->
  /// <button (click)="onClick(clicked = true)" />
  /// ```
  final bool allowAssignments;

  /// Whether or not to allow pipes (`$pipe.foo(...)`) to be parsed.
  final bool allowPipes;

  /// Static identifiers that are in scope.
  ///
  /// If the left-most expression is an identifier, and it does not match one
  /// of these named exported identifiers, we assume that the it uses the
  /// "implicit receiver", or root expression context.
  ///
  /// See [matchExport].
  final Map<String, Variable> unprefixedExports;

  /// Exports that have a `prefix`.
  final Map<String, Map<String, Variable>> prefixedExports;

  Expression createFunctionCall(Dart.InvocationExpression call,
      {bool? allowPipes, required Expression receiver, required String? methodName}) {
    allowPipes ??= this.allowPipes;

    if (call.typeArguments != null) {
      return notSupported('Generic type arguments not supported.', call);
    }

    final allArgs = call.argumentList.arguments;
    final posArgs = <Dart.Expression>[];
    final namedArgs = <Dart.NamedExpression>[];

    for (final arg in allArgs) {
      if (arg is Dart.NamedExpression) {
        namedArgs.add(arg);
      } else {
        posArgs.add(arg);
      }
    }

    if (receiver is PropertyRead && receiver.name == r'$pipe') {
      return createPipeOrThrow(call as Dart.MethodInvocation, receiver, posArgs, namedArgs);
    }

    final callPos = posArgs.map<Expression?>((arg) => arg.accept(this)).whereType<Expression>().toList();
    final callNamed =
        namedArgs.map<NamedArgument>((arg) => NamedArgument(arg.name.label.name, arg.expression.accept(this))).toList();

    if (methodName != null) {
      if (isNullAwareCall(call)) {
        return SafeMethodCall(receiver, methodName, callPos, callNamed);
      }

      return MethodCall(receiver, methodName, callPos, callNamed);
    } else {
      return FunctionCall(receiver, callPos, callNamed);
    }
  }

  BindingPipe createPipeOrThrow(Dart.MethodInvocation node, PropertyRead receiver, List<Dart.Expression> posArgs,
      List<Dart.NamedExpression> namedArgs) {
    if (!allowPipes) {
      return notSupported('Pipes are not allowed in this context', node);
    }

    if (namedArgs.isNotEmpty) {
      return notSupported('Pipes may only contain positional, not named, arguments', node);
    }
    if (posArgs.isEmpty) {
      return notSupported('Pipes must contain at least one positional argument', node);
    }

    return createPipeUsage(node.methodName.name, posArgs);
  }

  BindingPipe createPipeUsage(String name, List<Dart.Expression> posArgs) {
    return BindingPipe(
        posArgs.first.accept(this)!,
        name,
        posArgs.length > 1
            ? posArgs.skip(1).map<Expression?>((expression) => expression.accept(this)).whereType<Expression>().toList()
            : const <Expression>[]);
  }

  /// Returns [Expression] if a name or prefix is registered and matches a symbol.
  Expression? matchExport(String prefixOrUnprefixedName, [String? nameOrNullIfNotPrefixed]) {
    final unprefixed = unprefixedExports[prefixOrUnprefixedName];

    if (unprefixed != null) {
      Expression result = StaticRead(unprefixed);

      if (nameOrNullIfNotPrefixed != null) {
        result = PropertyRead(result, nameOrNullIfNotPrefixed);
      }

      return result;
    }

    final exports = prefixedExports[prefixOrUnprefixedName];

    if (exports != null) {
      // It is invalid at this point _not_ to have the second part of the name.
      // This comes up as a result of incorrect parsing/visiting, and not
      // intentionally.
      ArgumentError.checkNotNull(nameOrNullIfNotPrefixed, 'nameOrNullIfNotPrefixed');
      final prefixed = exports[nameOrNullIfNotPrefixed];

      if (prefixed != null) {
        return StaticRead(prefixed);
      }
    }

    return null;
  }

  // TODO(b/161262984): Reduce the amount of branching if able.
  @override
  Expression visitAssignmentExpression(Dart.AssignmentExpression node) {
    if (!allowAssignments) {
      return notSupported('assignment (x = y) expressions are only valid in an event binding.', node);
    }

    final leftHandSide = node.leftHandSide;
    final rightHandSide = node.rightHandSide;

    // TODO(b/159912942): Allow this once we are off the legacy parser.
    if (leftHandSide is Dart.PropertyAccess && leftHandSide.isNullAware) {
      return notSupported('null-aware property assignment is not supported', node);
    }

    Expression receiver;
    String property;

    if (leftHandSide is Dart.PropertyAccess) {
      receiver = leftHandSide.target!.accept(this)!;
      property = leftHandSide.propertyName.name;
    } else if (leftHandSide is Dart.PrefixedIdentifier) {
      receiver = leftHandSide.prefix.accept(this)!;
      property = leftHandSide.identifier.name;
    } else if (leftHandSide is Dart.SimpleIdentifier) {
      receiver = ImplicitReceiver();
      property = leftHandSide.name;
    } else if (leftHandSide is Dart.IndexExpression) {
      return KeyedWrite(
          leftHandSide.target!.accept(this)!, leftHandSide.index.accept(this)!, rightHandSide.accept(this)!);
    } else {
      return notSupported('unsupported assignment (${leftHandSide.runtimeType})', node);
    }

    final expression = rightHandSide.accept(this)!;
    return PropertyWrite(receiver, property, expression);
  }

  @override
  Expression visitBinaryExpression(Dart.BinaryExpression node) {
    switch (node.operator.type) {
      case TokenType.PLUS:
      case TokenType.MINUS:
      case TokenType.STAR:
      case TokenType.SLASH:
      case TokenType.EQ_EQ:
      case TokenType.BANG_EQ:
      case TokenType.AMPERSAND_AMPERSAND:
      case TokenType.BAR_BAR:
      case TokenType.PERCENT:
      case TokenType.LT:
      case TokenType.LT_EQ:
      case TokenType.GT:
      case TokenType.GT_EQ:
        return Binary(node.operator.lexeme, node.leftOperand.accept(this)!, node.rightOperand.accept(this)!);
      case TokenType.QUESTION_QUESTION:
        return IfNull(node.leftOperand.accept(this)!, node.rightOperand.accept(this)!);
      default:
        return super.visitBinaryExpression(node)!;
    }
  }

  @override
  Expression visitBooleanLiteral(Dart.BooleanLiteral node) {
    return Primitive(node.value);
  }

  @override
  Expression visitConditionalExpression(Dart.ConditionalExpression node) {
    return Conditional(
        node.condition.accept(this)!, node.thenExpression.accept(this)!, node.elseExpression.accept(this)!);
  }

  @override
  Expression visitDoubleLiteral(Dart.DoubleLiteral node) {
    return Primitive(node.value);
  }

  /// Like [visitNode], but with a error message for unsupported expressions.
  @override
  Expression visitExpression(Dart.Expression node) {
    return notSupported('${node.runtimeType}: Not a subset of supported Dart expressions.', node);
  }

  @override
  Expression visitFunctionExpressionInvocation(Dart.FunctionExpressionInvocation node) {
    // Something like "b()()"
    // Prohibit pipes from appearing in nested function calls.
    // I.e. foo.bar.$pipe.
    return createFunctionCall(node, allowPipes: false, methodName: null, receiver: node.function.accept(this)!);
  }

  @override
  Expression visitIndexExpression(Dart.IndexExpression node) {
    return KeyedRead(node.target!.accept(this)!, node.index.accept(this)!);
  }

  @override
  Expression visitIntegerLiteral(Dart.IntegerLiteral node) {
    return Primitive(node.value);
  }

  @override
  Expression visitMethodInvocation(Dart.MethodInvocation node) {
    final target = node.target;

    if (target != null) {
      if (target is Dart.SimpleIdentifier) {
        // <identifier>.<identifier>(callExpression)
        final prefix = target.name;
        final method = (node.function as Dart.SimpleIdentifier).name;
        final receiver = matchExport(prefix, method);

        if (receiver != null) {
          return createFunctionCall(node, receiver: receiver, methodName: null);
        }
      }

      // <identifier>.<identifier>.<method>(callExpression)
      final receiver = target.accept(this)!;
      return createFunctionCall(node, receiver: receiver, methodName: (node.function as Dart.Identifier).name);
    } else {
      final method = node.function.accept(this);

      if (method is StaticRead) {
        return createFunctionCall(node, receiver: method, methodName: null);
      } else {
        return createFunctionCall(node, receiver: ImplicitReceiver(), methodName: node.methodName.name);
      }
    }
  }

  /// Reject all node types that call into to this method.
  ///
  /// See [GeneralizingAstVisitor] for details.
  @override
  Expression visitNode(Dart.AstNode node) {
    return notSupported('${node.runtimeType}: Only expressions are supported.', node);
  }

  @override
  Expression visitNullLiteral(Dart.NullLiteral node) {
    return Primitive(null);
  }

  @override
  Expression visitParenthesizedExpression(Dart.ParenthesizedExpression node) {
    // TODO(b/159912942): Parse correctly.
    return node.expression.accept(this)!;
  }

  @override
  Expression visitPostfixExpression(Dart.PostfixExpression node) {
    final expression = node.operand.accept(this)!;

    switch (node.operator.type) {
      case TokenType.BANG:
        return PostfixNotNull(expression);
      default:
        return notSupported('only ! is a supported postfix operator', node);
    }
  }

  @override
  Expression visitPrefixedIdentifier(Dart.PrefixedIdentifier node) {
    // TODO(b/159167156): Resolve exports in a consistent place.
    final export = matchExport(node.prefix.name, node.identifier.name);
    return export ?? PropertyRead(readFromContext(node.prefix), node.identifier.name);
  }

  @override
  Expression visitPrefixExpression(Dart.PrefixExpression node) {
    final expression = node.operand.accept(this)!;

    switch (node.operator.type) {
      case TokenType.BANG:
        return PrefixNot(expression);
      case TokenType.MINUS:
        // TODO(b/159912942): Just parse as -1.
        return Binary('-', Primitive(0), expression);
      default:
        return notSupported('only !, +, or - are supported prefix operators', node);
    }
  }

  @override
  Expression visitPropertyAccess(Dart.PropertyAccess node) {
    if (node.isCascaded) {
      return notSupported('cascade operator is not supported.', node);
    }

    final receiver = node.target!.accept(this)!;
    final property = node.propertyName.name;

    if (node.isNullAware) {
      return SafePropertyRead(receiver, property);
    }

    return PropertyRead(receiver, property);
  }

  @override
  Expression visitSimpleIdentifier(Dart.SimpleIdentifier node) {
    // TODO(b/159167156): Resolve exports in a consistent place.
    final export = matchExport(node.name);
    return export ?? readFromContext(node);
  }

  @override
  Expression visitSimpleStringLiteral(Dart.SimpleStringLiteral node) {
    return Primitive(node.stringValue);
  }

  /// Indexes `List<Identifier>` by `prefix` and `name`.
  static Map<String, Map<String, Variable>> indexPrefixed(List<Variable> exports) {
    final result = <String, Map<String, Variable>>{};

    for (final export in exports) {
      final prefix = export.prefix;

      if (prefix != null) {
        (result[prefix] ??= <String, Variable>{})[export.name] = export;
      }
    }

    return result;
  }

  /// Indexes `List<Identifier>` by the `name`.
  static Map<String, Variable> indexUnprefixed(List<Variable> exports) {
    return <String, Variable>{
      for (final export in exports)
        if (export.prefix == null) export.name: export
    };
  }

  static bool isNullAwareCall(Dart.InvocationExpression call) {
    return call is Dart.MethodInvocation && call.isNullAware;
  }

  static Never notSupported(String reason, Dart.AstNode node) {
    throw SubsetException(reason, node);
  }

  static Expression readFromContext(Dart.SimpleIdentifier node) {
    return PropertyRead(ImplicitReceiver(), node.name);
  }
}
