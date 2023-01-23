import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

Future<void> main() async {
  var tokenUri = Uri(
      scheme: 'package', path: '_fe_analyzer_shared/src/scanner/token.dart');
  var tokenFileUri = await Isolate.resolvePackageUri(tokenUri);

  if (tokenFileUri == null) {
    throw Exception('token uri is not resolved');
  }

  var astUri = Uri(scheme: 'package', path: 'analyzer/dart/ast/ast.dart');
  var astFileUri = await Isolate.resolvePackageUri(astUri);

  if (astFileUri == null) {
    throw Exception('ast uri is not resolved');
  }

  var visitorUri =
      Uri(scheme: 'package', path: 'analyzer/dart/ast/visitor.dart');
  var visitorFileUri = await Isolate.resolvePackageUri(visitorUri);

  if (visitorFileUri == null) {
    throw Exception('visitor uri is not resolved');
  }

  var tokenFile = File.fromUri(tokenFileUri);
  tokenFile = tokenFile.absolute;

  var astFile = File.fromUri(astFileUri);
  astFile = astFile.absolute;

  var visitorFile = File.fromUri(visitorFileUri);
  visitorFile = visitorFile.absolute;

  var includedPaths = <String>[tokenFile.path, astFile.path, visitorFile.path];
  var collection = AnalysisContextCollection(includedPaths: includedPaths);

  // Token
  var tokenContext = collection.contextFor(tokenFile.path);
  var tokenSession = tokenContext.currentSession;
  var tokenResolvedUnit = await tokenSession.getResolvedUnit(tokenFile.path);

  if (tokenResolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var tokenLibrary = tokenResolvedUnit.libraryElement;
  var tokenClass = tokenLibrary.getClass('Token');

  if (tokenClass == null) {
    throw Exception('Token is not resolved');
  }

  var tokenTypeSystem = tokenResolvedUnit.typeSystem;

  var tokenType = tokenTypeSystem.instantiateInterfaceToBounds(
    element: tokenClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  var astContext = collection.contextFor(astFile.path);
  var astSession = astContext.currentSession;
  var astResolvedUnit = await astSession.getResolvedUnit(astFile.path);

  if (astResolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var astLibrary = astResolvedUnit.libraryElement;
  var astNodeClass = astLibrary.getClass('AstNode');

  if (astNodeClass == null) {
    throw Exception('AstNode is not resolved');
  }

  var astTypeSystem = astResolvedUnit.typeSystem;

  var astNodeType = astTypeSystem.instantiateInterfaceToBounds(
    element: astNodeClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  var nodeListClass = astLibrary.getClass('NodeList');

  if (nodeListClass == null) {
    throw Exception('NodeList is not resolved');
  }

  var nodeListType = astTypeSystem.instantiateInterfaceToBounds(
    element: nodeListClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  var visitorContext = collection.contextFor(visitorFile.path);
  var visitorSession = visitorContext.currentSession;
  var visitorResolvedUnit =
      await visitorSession.getResolvedUnit(visitorFile.path);

  if (visitorResolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var visitorLibrary = visitorResolvedUnit.libraryElement;
  var throwingAstVisitorClass = visitorLibrary.getClass('ThrowingAstVisitor');

  if (throwingAstVisitorClass == null) {
    throw Exception('ThrowingAstVisitor is not resolved');
  }

  bool isNum(DartType type) {
    return type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum;
  }

  bool isBool(DartType type) {
    return type.isDartCoreBool;
  }

  bool isString(DartType type) {
    return type.isDartCoreString;
  }

  bool isToken(DartType type) {
    return tokenTypeSystem.isSubtypeOf(type, tokenType);
  }

  bool isAstNode(DartType type) {
    return astTypeSystem.isSubtypeOf(type, astNodeType);
  }

  bool isNodeList(DartType type) {
    return astTypeSystem.isSubtypeOf(type, nodeListType);
  }

  bool isVisitorMethod(ClassElement element) {
    var method = throwingAstVisitorClass.getMethod('visit${element.name}');
    return method != null;
  }

  var klasses = astLibrary.topLevelElements
      .whereType<ClassElement>()
      .where(isVisitorMethod)
      .toList();

  klasses.sort((left, right) => left.nameOffset.compareTo(right.nameOffset));

  var file = File('lib/src/compiler/dart_to_json.dart');
  var sink = file.openWrite();
  sink.write(header);

  void writeFields(InterfaceElement interface, Set<String> writed) {
    if (interface.name == 'AstNode') {
      return;
    }

    for (var accessor in interface.accessors) {
      if (accessor.hasDeprecated) {
        continue;
      }

      var name = accessor.name;

      if (writed.contains(accessor.name)) {
        continue;
      }

      if (accessor.isGetter) {
        String prefix, check;

        if (astTypeSystem.isNullable(accessor.returnType)) {
          prefix = "\n      if (node.$name != null) '$name':";
          check = '!';
        } else {
          prefix = "\n      '$name':";
          check = '';
        }

        if (isBool(accessor.returnType)) {
          sink.write("\n     if (node.$name) '$name': node.$name$check,");
        } else if (isNum(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isString(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isToken(accessor.returnType)) {
          sink.write('$prefix describeToken(node.$name$check),');
        } else if (isAstNode(accessor.returnType)) {
          sink.write('$prefix node.$name$check.accept(this),');
        } else if (isNodeList(accessor.returnType)) {
          sink
            ..write('\n      if (node.$name.isNotEmpty)')
            ..write("\n        '$name': <Map<String, Object?>?>[")
            ..write(
                '\n          for (var item in node.$name) item.accept(this),')
            ..write('\n        ],');
        }

        writed.add(name);
      }
    }
  }

  for (var klass in klasses) {
    var name = klass.name;

    if (name == 'AstNode') {
      continue;
    }

    if (isAstNode(klass.thisType)) {
      sink
        ..write('\n')
        ..write('\n  @override')
        ..write('\n  Map<String, Object?> visit$name($name node) {')
        ..write('\n    return <String, Object?>{')
        ..write('\n      ...getLocation(node),')
        ..write("\n      'class': '$name',");

      // throws null check on null or stack overflow
      var writed = <String>{'nullShortingTermination', 'unlabeled', 'unParenthesized'};

      writeFields(klass, writed);

      for (var interface in klass.interfaces) {
        writeFields(interface.element, writed);
      }

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
// generated with `tools/generate_script_to_json.dart`
// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

Map<String, Object?> describeToken(Token token) {
  return <String, Object?>{
    'start': token.offset,
    'end': token.end,
    'type': token.type.name,
    'lexeme': token.lexeme,
  };
}

class DartToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  const DartToJsonVisitor();

  Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }

  List<Map<String, Object?>?> visitAll(List<AstNode> nodes) {
    return <Map<String, Object?>?>[for (var node in nodes) node.accept(this)];
  }''';
