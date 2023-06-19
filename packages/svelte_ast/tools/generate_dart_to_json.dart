import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';

import 'shared/utils.dart';

// TODO(dart2json): serialize Token, ...
Future<void> main() async {
  Directory analyzerRoot = await getRoot('analyzer');
  Directory feRoot = await getRoot('_fe_analyzer_shared');

  List<String> includedPaths = <String>[analyzerRoot.path, feRoot.path];
  AnalysisContextCollection collection =
      AnalysisContextCollection(includedPaths: includedPaths);

  AnalysisContext astContext = collection.contextFor(analyzerRoot.path);
  AnalysisSession astSession = astContext.currentSession;

  Uri astUri = Uri(path: 'lib/dart/ast/ast.dart');
  astUri = analyzerRoot.uri.resolveUri(astUri);

  LibraryElement astlibrary = await getLibrary(astSession, astUri);
  TypeSystem astTypeSystem = astlibrary.typeSystem;

  ClassElement astNodeClass = getClass(astlibrary, 'AstNode');
  ClassElement astVisitorClass = getClass(astlibrary, 'AstVisitor');

  InterfaceType astNodeType = astTypeSystem.instantiateInterfaceToBounds(
    element: astNodeClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  AnalysisContext tokenContext = collection.contextFor(analyzerRoot.path);
  AnalysisSession tokenSession = tokenContext.currentSession;

  Uri tokenUri = Uri(path: 'lib/src/scanner/token.dart');
  tokenUri = feRoot.uri.resolveUri(tokenUri);

  LibraryElement tokenlibrary = await getLibrary(tokenSession, tokenUri);
  TypeSystem tokenTypeSystem = tokenlibrary.typeSystem;

  ClassElement tokenClass = getClass(tokenlibrary, 'Token');

  InterfaceType tokenType = tokenTypeSystem.instantiateInterfaceToBounds(
    element: tokenClass,
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
    return type is! InvalidType && astTypeSystem.isSubtypeOf(type, astNodeType);
  }

  bool isToken(DartType type) {
    return type is! InvalidType && tokenTypeSystem.isSubtypeOf(type, tokenType);
  }

  bool isNodeList(DartType type) {
    return type is InterfaceType &&
        type.typeArguments.length == 1 &&
        isAstNode(type.typeArguments.first);
  }

  File file = File('lib/src/dart_to_json.dart');
  IOSink sink = file.openWrite();
  sink.write(header);

  void writeFields(InterfaceElement interface, Set<String> writed) {
    for (PropertyAccessorElement accessor in interface.accessors) {
      if (accessor.hasDeprecated || accessor.isPrivate || accessor.isStatic) {
        continue;
      }

      String name = accessor.name;

      if (writed.contains(accessor.name)) {
        continue;
      }

      if (accessor.isGetter) {
        DartType returnType = accessor.returnType;

        if (isBool(returnType)) {
          sink.writeln("if (node.$name) '$name': node.$name,");
        } else if (isEnum(returnType)) {
          sink.writeln("'$name': node.$name.name,");
        } else if (isNum(returnType) || isString(returnType)) {
          if (astTypeSystem.isNullable(returnType)) {
            sink.write("if (node.$name case var $name?) '$name': ");
          } else {
            sink.write("'$name': node.");
          }

          sink.writeln('$name,');
        } else if (isAstNode(returnType)) {
          if (astTypeSystem.isNullable(returnType)) {
            sink.write("if (node.$name case var $name?) '$name': ");
          } else {
            sink.write("'$name':  node.");
          }

          sink.writeln('$name.accept(this),');
        } else if (isToken(returnType)) {
          if (astTypeSystem.isNullable(returnType)) {
            sink.write("if (node.$name case var $name?) '$name': ");
          } else {
            sink.write("'$name':  node.");
          }

          sink.writeln('getToken($name),');
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
    for (InterfaceType interface in type.interfaces) {
      String name = interface.getDisplayString(withNullability: false);

      if (name == 'AstNode' || name == 'Object') {
        continue;
      }

      sink.writeln('     // $parent - $name');
      writeFields(interface.element, writed);
      writeSuperFields(interface, name, writed);
    }
  }

  for (MethodElement method in astVisitorClass.methods) {
    if (method.name.startsWith('visit')) {
      InterfaceType type = method.parameters.first.type as InterfaceType;

      if (!isAstNode(type)) {
        continue;
      }

      String name = type.getDisplayString(withNullability: false);

      sink
        ..write('\n')
        ..write('\n  @override')
        ..write('\n  Map<String, Object?>? visit$name($name node) {')
        ..write('\n    return <String, Object?>{')
        ..write('...getLocation(node),')
        ..write("'type': '$name',");

      Set<String> writed = <String>{
        'type',

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

  ProcessResult result = Process.runSync('dart', <String>['format', file.path]);
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
