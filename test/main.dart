import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';

void main() {
  var expression = MustacheParser.parseExpression(0, 't(\'tooltip msg\')');
  var invocation = expression as MethodInvocation;
  var json = invocation.accept(ToJsonVisitor());
  print(const JsonEncoder.withIndent('  ').convert(json));
}

class ToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  static Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }

  const ToJsonVisitor({this.offset = 0});

  final int offset;

  @override
  Map<String, Object?>? visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      'type': 'ArgumentList',
      ...getLocation(node),
      'arguments': <Map<String, Object?>?>[for (var argument in node.arguments) argument.accept(this)],
    };
  }

  @override
  Map<String, Object?> visitMethodInvocation(MethodInvocation node) {
    return <String, Object?>{
      'type': 'MethodInvocation',
      ...getLocation(node),
      'methodName': node.methodName.accept(this),
      'argumentList': node.argumentList.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      'type': 'SimpleIdentifier',
      ...getLocation(node),
      'name': node.name,
    };
  }

  @override
  Map<String, Object?>? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      'type': 'SimpleStringLiteral',
      ...getLocation(node),
      'value': node.value,
    };
  }
}
