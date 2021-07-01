import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:meta/meta.dart';

import 'ast.dart' as ast;
import 'parser.dart';
import 'variable.dart';

/// Implements [ExpressionParser] using `package:analyzer`'s AST parser.
class AnalyzerExpressionParser extends ExpressionParser {
  const AnalyzerExpressionParser() : super.forInheritence();

  ast.AST convertAndValididateExpression(Expression ast, String input, String location,
      {bool? allowAssignments, bool? allowPipes, List<Variable>? exports}) {
    try {
      return ast.accept(SubsetVisitor(allowAssignments: allowAssignments, allowPipes: allowPipes, exports: exports))!;
    } on SubsetException catch (error) {
      throw ParseException(error.reason, input, location, error.astNode.toSource());
    }
  }

  @override
  ast.AST parseActionImpl(String input, String location, List<Variable> exports) {
    return parseExpression(input, location, allowAssignments: true, allowPipes: false, exports: exports);
  }

  @override
  ast.AST parseBindingImpl(String input, String location, List<Variable> exports) {
    return parseExpression(input, location, allowAssignments: false, exports: exports);
  }

  @visibleForTesting
  ast.AST parseExpression(String input, String location,
      {bool? allowAssignments, bool? allowPipes, List<Variable>? exports}) {
    if (input.isEmpty) {
      return ast.EmptyExpr();
    }

    // This is a hack; currently analyzer can only accept valid compilation
    // units into `parseString`, which means we need something valid at the
    // top-level of a Dart file.
    final wrapper = 'void __EXPRESSION__() => $input;';
    final featureSet = FeatureSet.latestLanguageVersion();
    final result = parseString(content: wrapper, path: location, throwIfDiagnostics: false, featureSet: featureSet);

    if (result.errors.isNotEmpty) {
      throw ParseException(result.errors.map<String>((error) => error.message).join('\n'), input, location);
    }

    final declared = result.unit.declarations;

    if (declared.length != 1) {
      throw ParseException('Not a valid expression', input, location);
    }

    final function = declared.first as FunctionDeclaration;
    final innerBody = function.functionExpression.body;

    final innerAst = (innerBody as ExpressionFunctionBody).expression;
    return convertAndValididateExpression(innerAst, input, location,
        allowAssignments: allowAssignments, allowPipes: allowPipes, exports: exports);
  }

  @override
  ast.AST? parseInterpolationImpl(String input, String location, List<Variable> exports) {
    final split = splitInterpolation(input, location);

    if (split == null) {
      return null;
    }

    final expressions = split.expressions
        .map<ast.AST>((expression) => parseExpression(expression, location, allowAssignments: false, exports: exports))
        .toList();
    return ast.Interpolation(split.strings, expressions);
  }
}

class SubsetException implements Exception {
  SubsetException(this.reason, this.astNode);

  final String reason;

  final AstNode astNode;
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
class SubsetVisitor extends GeneralizingAstVisitor<ast.AST> {
  SubsetVisitor({bool? allowAssignments, bool? allowPipes, List<Variable>? exports})
      : allowAssignments = allowAssignments ?? false,
        allowPipes = allowPipes ?? true,
        unprefixedExports = indexUnprefixed(exports ?? const []),
        prefixedExports = indexPrefixed(exports ?? const []);

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

  ast.AST createFunctionCall(InvocationExpression call,
      {bool? allowPipes, required ast.AST receiver, required String? methodName}) {
    allowPipes ??= this.allowPipes;

    if (call.typeArguments != null) {
      return notSupported('Generic type arguments not supported.', call);
    }

    final allArgs = call.argumentList.arguments;
    final posArgs = <Expression>[];
    final namedArgs = <NamedExpression>[];

    for (final arg in allArgs) {
      if (arg is NamedExpression) {
        namedArgs.add(arg);
      } else {
        posArgs.add(arg);
      }
    }

    if (receiver is ast.PropertyRead && receiver.name == r'$pipe') {
      return createPipeOrThrow(call as MethodInvocation, receiver, posArgs, namedArgs);
    }

    final callPos = posArgs.map<ast.AST?>((arg) => arg.accept(this)).whereType<ast.AST>().toList();
    final callNamed =
        namedArgs.map<ast.NamedExpr>((arg) => ast.NamedExpr(arg.name.label.name, arg.expression.accept(this))).toList();

    if (methodName != null) {
      if (isNullAwareCall(call)) {
        return ast.SafeMethodCall(receiver, methodName, callPos, callNamed);
      }

      return ast.MethodCall(receiver, methodName, callPos, callNamed);
    } else {
      return ast.FunctionCall(receiver, callPos, callNamed);
    }
  }

  ast.BindingPipe createPipeOrThrow(
      MethodInvocation astNode, ast.PropertyRead receiver, List<Expression> posArgs, List<NamedExpression> namedArgs) {
    if (!allowPipes) {
      return notSupported('Pipes are not allowed in this context', astNode);
    }

    if (namedArgs.isNotEmpty) {
      return notSupported('Pipes may only contain positional, not named, arguments', astNode);
    }
    if (posArgs.isEmpty) {
      return notSupported('Pipes must contain at least one positional argument', astNode);
    }

    return createPipeUsage(astNode.methodName.name, posArgs);
  }

  ast.BindingPipe createPipeUsage(String name, List<Expression> posArgs) {
    return ast.BindingPipe(
        posArgs.first.accept(this)!,
        name,
        posArgs.length > 1
            ? posArgs.skip(1).map<ast.AST?>((expression) => expression.accept(this)).whereType<ast.AST>().toList()
            : const <ast.AST>[]);
  }

  /// Returns [ast.AST] if a name or prefix is registered and matches a symbol.
  ast.AST? matchExport(String prefixOrUnprefixedName, [String? nameOrNullIfNotPrefixed]) {
    final unprefixed = unprefixedExports[prefixOrUnprefixedName];

    if (unprefixed != null) {
      ast.AST result = ast.StaticRead(unprefixed);

      if (nameOrNullIfNotPrefixed != null) {
        result = ast.PropertyRead(result, nameOrNullIfNotPrefixed);
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
        return ast.StaticRead(prefixed);
      }
    }

    return null;
  }

  // TODO(b/161262984): Reduce the amount of branching if able.
  @override
  ast.AST visitAssignmentExpression(AssignmentExpression node) {
    if (!allowAssignments) {
      return notSupported('assignment (x = y) expressions are only valid in an event binding.', node);
    }

    final leftHandSide = node.leftHandSide;
    final rightHandSide = node.rightHandSide;

    // TODO(b/159912942): Allow this once we are off the legacy parser.
    if (leftHandSide is PropertyAccess && leftHandSide.isNullAware) {
      return notSupported('null-aware property assignment is not supported', node);
    }

    ast.AST receiver;
    String property;

    if (leftHandSide is PropertyAccess) {
      receiver = leftHandSide.target!.accept(this)!;
      property = leftHandSide.propertyName.name;
    } else if (leftHandSide is PrefixedIdentifier) {
      receiver = leftHandSide.prefix.accept(this)!;
      property = leftHandSide.identifier.name;
    } else if (leftHandSide is SimpleIdentifier) {
      receiver = ast.ImplicitReceiver();
      property = leftHandSide.name;
    } else if (leftHandSide is IndexExpression) {
      return ast.KeyedWrite(
          leftHandSide.target!.accept(this)!, leftHandSide.index.accept(this)!, rightHandSide.accept(this)!);
    } else {
      return notSupported('unsupported assignment (${leftHandSide.runtimeType})', node);
    }

    final expression = rightHandSide.accept(this)!;
    return ast.PropertyWrite(receiver, property, expression);
  }

  @override
  ast.AST visitBinaryExpression(BinaryExpression node) {
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
        return ast.Binary(node.operator.lexeme, node.leftOperand.accept(this)!, node.rightOperand.accept(this)!);
      case TokenType.QUESTION_QUESTION:
        return ast.IfNull(node.leftOperand.accept(this)!, node.rightOperand.accept(this)!);
      default:
        return super.visitBinaryExpression(node)!;
    }
  }

  @override
  ast.AST visitBooleanLiteral(BooleanLiteral node) {
    return ast.LiteralPrimitive(node.value);
  }

  @override
  ast.AST visitConditionalExpression(ConditionalExpression node) {
    return ast.Conditional(
        node.condition.accept(this)!, node.thenExpression.accept(this)!, node.elseExpression.accept(this)!);
  }

  @override
  ast.AST visitDoubleLiteral(DoubleLiteral node) {
    return ast.LiteralPrimitive(node.value);
  }

  /// Like [visitNode], but with a error message for unsupported expressions.
  @override
  ast.AST visitExpression(Expression astNode) {
    return notSupported('${astNode.runtimeType}: Not a subset of supported Dart expressions.', astNode);
  }

  @override
  ast.AST visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // Something like "b()()"
    // Prohibit pipes from appearing in nested function calls.
    // I.e. foo.bar.$pipe.
    return createFunctionCall(node, allowPipes: false, methodName: null, receiver: node.function.accept(this)!);
  }

  @override
  ast.AST visitIndexExpression(IndexExpression node) {
    return ast.KeyedRead(node.target!.accept(this)!, node.index.accept(this)!);
  }

  @override
  ast.AST visitIntegerLiteral(IntegerLiteral node) {
    return ast.LiteralPrimitive(node.value);
  }

  @override
  ast.AST visitMethodInvocation(MethodInvocation node) {
    final target = node.target;

    if (target != null) {
      if (target is SimpleIdentifier) {
        // <identifier>.<identifier>(callExpression)
        final prefix = target.name;
        final method = (node.function as SimpleIdentifier).name;
        final receiver = matchExport(prefix, method);

        if (receiver != null) {
          return createFunctionCall(node, receiver: receiver, methodName: null);
        }
      }

      // <identifier>.<identifier>.<method>(callExpression)
      final receiver = target.accept(this)!;
      return createFunctionCall(node, receiver: receiver, methodName: (node.function as Identifier).name);
    } else {
      final method = node.function.accept(this);

      if (method is ast.StaticRead) {
        return createFunctionCall(node, receiver: method, methodName: null);
      } else {
        return createFunctionCall(node, receiver: ast.ImplicitReceiver(), methodName: node.methodName.name);
      }
    }
  }

  /// Reject all node types that call into to this method.
  ///
  /// See [GeneralizingAstVisitor] for details.
  @override
  ast.AST visitNode(AstNode astNode) {
    return notSupported('${astNode.runtimeType}: Only expressions are supported.', astNode);
  }

  @override
  ast.AST visitNullLiteral(NullLiteral node) {
    return ast.LiteralPrimitive(null);
  }

  @override
  ast.AST visitParenthesizedExpression(ParenthesizedExpression node) {
    // TODO(b/159912942): Parse correctly.
    return node.expression.accept(this)!;
  }

  @override
  ast.AST visitPostfixExpression(PostfixExpression node) {
    final expression = node.operand.accept(this)!;

    switch (node.operator.type) {
      case TokenType.BANG:
        return ast.PostfixNotNull(expression);
      default:
        return notSupported('only ! is a supported postfix operator', node);
    }
  }

  @override
  ast.AST visitPrefixedIdentifier(PrefixedIdentifier node) {
    // TODO(b/159167156): Resolve exports in a consistent place.
    final export = matchExport(node.prefix.name, node.identifier.name);
    return export ?? ast.PropertyRead(readFromContext(node.prefix), node.identifier.name);
  }

  @override
  ast.AST visitPrefixExpression(PrefixExpression node) {
    final expression = node.operand.accept(this)!;

    switch (node.operator.type) {
      case TokenType.BANG:
        return ast.PrefixNot(expression);
      case TokenType.MINUS:
        // TODO(b/159912942): Just parse as -1.
        return ast.Binary('-', ast.LiteralPrimitive(0), expression);
      default:
        return notSupported('only !, +, or - are supported prefix operators', node);
    }
  }

  @override
  ast.AST visitPropertyAccess(PropertyAccess node) {
    if (node.isCascaded) {
      return notSupported('cascade operator is not supported.', node);
    }

    final receiver = node.target!.accept(this)!;
    final property = node.propertyName.name;

    if (node.isNullAware) {
      return ast.SafePropertyRead(receiver, property);
    }

    return ast.PropertyRead(receiver, property);
  }

  @override
  ast.AST visitSimpleIdentifier(SimpleIdentifier node) {
    // TODO(b/159167156): Resolve exports in a consistent place.
    final export = matchExport(node.name);
    return export ?? readFromContext(node);
  }

  @override
  ast.AST visitSimpleStringLiteral(SimpleStringLiteral node) {
    return ast.LiteralPrimitive(node.stringValue);
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

  static bool isNullAwareCall(InvocationExpression call) {
    return call is MethodInvocation && call.isNullAware;
  }

  static Never notSupported(String reason, AstNode astNode) {
    throw SubsetException(reason, astNode);
  }

  static ast.AST readFromContext(SimpleIdentifier astNode) {
    return ast.PropertyRead(ast.ImplicitReceiver(), astNode.name);
  }
}
