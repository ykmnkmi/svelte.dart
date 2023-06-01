import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'shared/utils.dart';

// TODO(dart2json): serialize Token, ...
Future<void> main() async {
  var analyzerRoot = await getRoot('analyzer');

  var includedPaths = <String>[analyzerRoot.path];
  var collection = AnalysisContextCollection(includedPaths: includedPaths);

  var context = collection.contextFor(analyzerRoot.path);
  var session = context.currentSession;

  var astUri = Uri(path: 'lib/dart/ast/ast.dart');
  astUri = analyzerRoot.uri.resolveUri(astUri);

  var astlibrary = await getLibrary(session, astUri);

  var typeSystem = astlibrary.typeSystem;

  var astNodeClass = getClass(astlibrary, 'AstNode');
  var throwingAstVisitorClass = getClass(astlibrary, 'AstVisitor');

  var astNodeType = typeSystem.instantiateInterfaceToBounds(
    element: astNodeClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  bool isBool(DartType type) {
    return type.isDartCoreBool;
  }

  bool isEnum(DartType type) {
    return type.isDartCoreEnum;
  }

  bool isNum(DartType type) {
    return type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum;
  }

  bool isString(DartType type) {
    return type.isDartCoreString;
  }

  bool isAstNode(DartType type) {
    return type is! InvalidType && typeSystem.isSubtypeOf(type, astNodeType);
  }

  bool isNodeList(DartType type) {
    return type is InterfaceType &&
        type.typeArguments.length == 1 &&
        isAstNode(type.typeArguments.first);
  }

  var file = File('lib/src/dart_to_json.dart');
  var sink = file.openWrite();
  sink.write(header);

  void writeFields(InterfaceElement interface, Set<String> writed) {
    for (var accessor in interface.accessors) {
      if (accessor.hasDeprecated || accessor.isPrivate || accessor.isStatic) {
        continue;
      }

      var name = accessor.name;

      if (writed.contains(accessor.name)) {
        continue;
      }

      if (accessor.isGetter) {
        var returnType = accessor.returnType;

        if (isBool(returnType)) {
          sink.writeln("if (node.$name) '$name': node.$name,");
        } else if (isEnum(returnType)) {
          sink.writeln("'$name': node.$name.name,");
        } else if (isNum(returnType) || isString(returnType)) {
          if (typeSystem.isNullable(returnType)) {
            sink.write("if (node.$name case var $name?) '$name': ");
          } else {
            sink.write("'$name': node.");
          }

          sink.writeln('$name,');
        } else if (isAstNode(returnType)) {
          if (typeSystem.isNullable(returnType)) {
            sink.write("if (node.$name case var $name?) '$name': ");
          } else {
            sink.write("'$name':  node.");
          }

          sink.writeln('$name.accept(this),');
        } else if (isNodeList(returnType)) {
          sink
            ..writeln('if (node.$name.isNotEmpty)')
            ..writeln("  '$name': <Map<String, Object?>?>[")
            ..writeln('    for (var item in node.$name) item.accept(this),')
            ..writeln('  ],');
        } else {
          sink.writeln("     // '$name': $returnType");
        }

        writed.add(name);
      }
    }
  }

  void writeSuperFields(InterfaceType type, String parent, Set<String> writed) {
    for (var interface in type.interfaces) {
      var name = interface.getDisplayString(withNullability: false);

      if (name == 'AstNode' || name == 'Object') {
        continue;
      }

      sink.writeln('     // $parent - $name');
      writeFields(interface.element, writed);
      writeSuperFields(interface, name, writed);
    }
  }

  for (var method in throwingAstVisitorClass.methods) {
    if (method.name.startsWith('visit')) {
      var type = method.parameters.first.type as InterfaceType;

      if (!isAstNode(type)) {
        continue;
      }

      var name = type.getDisplayString(withNullability: false);

      sink
        ..write('\n')
        ..write('\n  @override')
        ..write('\n  Map<String, Object?>? visit$name($name node) {')
        ..write('\n    return <String, Object?>{')
        ..write('...getLocation(node),')
        ..write("'class': '$name',");

      var writed = <String>{
        // null check on null
        'isQualified',

        // stack overflow
        'nullShortingTermination',
        'parent',
        'unlabeled',
        'unParenthesized',

        // alias
        'sortedDirectivesAndDeclarations',
      };

      writeFields(type.element, writed);
      writeSuperFields(type, name, writed);

      sink
        ..write('\n    };')
        ..write('\n  }');
    }
  }

  sink.write('\n}\n');
  await sink.close();

  var result = Process.runSync('dart', <String>['format', file.path]);
  exitCode = result.exitCode;
}

const String header = '''
// generated with `tools/generate_dart_to_json.dart`

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

Map<String, Object?> getToken(Token token) {
  return <String, Object?>{
    'start': token.offset,
    'end': token.end,
    'type': token.type.name,
    'lexeme': token.lexeme,
  };
}

Map<String, Object?> getLocation(AstNode node) {
  return <String, Object?>{
    'start': node.offset,
    'end': node.end,
  };
}

class DartToJsonVisitor implements AstVisitor<Map<String, Object?>> {
  const DartToJsonVisitor();

  List<Map<String, Object?>?> visitAll(List<AstNode> nodes) {
    return <Map<String, Object?>?>[for (var node in nodes) node.accept(this)];
  }''';
