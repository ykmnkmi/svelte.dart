import 'dart:io';
import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';

void main() {
  var mirrorSystem = currentMirrorSystem();
  var ast = mirrorSystem.libraries[Uri(scheme: 'package', path: 'analyzer/dart/ast/ast.dart')];

  if (ast == null) {
    exit(1);
  }

  var klasses = ast.declarations.values.whereType<ClassMirror>().toList(growable: false);

  klasses.sort((left, right) {
    return MirrorSystem.getName(left.simpleName).compareTo(MirrorSystem.getName(right.simpleName));
  });

  var astNode = reflectType(AstNode);

  bool isAstNode(TypeMirror klass) {
    return klass.isSubtypeOf(astNode);
  }

  var nodeList = reflectType(NodeList);

  bool isNodeList(TypeMirror klass) {
    return klass.isSubtypeOf(nodeList);
  }

  for (var klass in klasses) {
    if (isAstNode(klass)) {
      var name = MirrorSystem.getName(klass.simpleName);

      stdout
        ..write('Map<String, Object?> visit$name($name node) {\n')
        ..write('  return <Map<String, Object?>>{\n')
        ..write('    ...getLocation(node),\n')
        ..write('    \'_\': \'$name\'');

      for (var member in klass.declarations.values) {
        if (member is MethodMirror && member.isGetter && isAstNode(member.returnType)) {
          var name = MirrorSystem.getName(member.simpleName);
          stdout.write('\n    \'$name\': \'${member.returnType.typeVariables}\'');

          // if (isNodeList(member.returnType)) {
          //   stdout.write('null');
          // } else {
          //   stdout.write('$name.accept(this)');
          // }
        }
      }

      stdout
        ..write('\n  }\n')
        ..write('}\n')
        ..write('\n');
    }
  }
}

// ignore_for_file: unused_import