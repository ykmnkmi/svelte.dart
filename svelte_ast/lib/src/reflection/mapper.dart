import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:csslib/visitor.dart';
import 'package:svelte_ast/src/reflection/css.dart';
import 'package:svelte_ast/src/reflection/dart.dart';

Object? mapper(Object? node) {
  if (node == null) {
    return null;
  }

  if (node is AstNode) {
    return dart(node);
  }

  if (node is TreeNode) {
    return css(node);
  }

  var instanceMirror = reflect(node);
  var symbol = instanceMirror.type.simpleName;
  throw UnimplementedError(MirrorSystem.getName(symbol));
}
