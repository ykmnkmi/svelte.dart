import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

Future<void> main() async {
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

  var astFile = File.fromUri(astFileUri);
  astFile = astFile.absolute;

  var visitorFile = File.fromUri(visitorFileUri);
  visitorFile = visitorFile.absolute;

  var includedPaths = <String>[astFile.path, visitorFile.path];
  var collection = AnalysisContextCollection(includedPaths: includedPaths);

  var context = collection.contextFor(visitorFile.absolute.path);
  var session = context.currentSession;
  var resolvedUnit = await session.getResolvedUnit(visitorFile.path);

  if (resolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var library = resolvedUnit.libraryElement;
  var throwingAstVisitor = library.getClass('ThrowingAstVisitor');

  if (throwingAstVisitor == null) {
    throw Exception('ThrowingAstVisitor is not resolved');
  }

  context = collection.contextFor(astFile.path);
  session = context.currentSession;
  resolvedUnit = await session.getResolvedUnit(astFile.path);

  if (resolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var typeSystem = resolvedUnit.typeSystem;
  library = resolvedUnit.libraryElement;

  var astNode = library.getClass('AstNode');

  if (astNode == null) {
    throw Exception('AstNode is not resolved');
  }

  var astType = typeSystem.instantiateInterfaceToBounds(
    element: astNode,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  bool isAstNode(DartType type) {
    return typeSystem.isSubtypeOf(type, astType);
  }

  var nodeList = library.getClass('NodeList');

  if (nodeList == null) {
    throw Exception('NodeList is not resolved');
  }

  var nodeListType = typeSystem.instantiateInterfaceToBounds(
    element: nodeList,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  bool isNodeList(DartType type) {
    return typeSystem.isSubtypeOf(type, nodeListType);
  }

  bool isString(DartType type) {
    return type.isDartCoreString;
  }

  bool isNum(DartType type) {
    return type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum;
  }

  bool isBool(DartType type) {
    return type.isDartCoreBool;
  }

  var klasses = library.topLevelElements.whereType<ClassElement>().toList();
  klasses.sort((left, right) => left.nameOffset.compareTo(right.nameOffset));

  var sink = File('lib/src/compiler/dart_to_json.dart').openWrite();
  sink.write(header);

  void writeFields(InterfaceElement interface, Set<String> writed) {
    if (interface.name == 'AstNode' ||
        interface.name == 'NullShortableExpression') {
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

        if (typeSystem.isNullable(accessor.returnType)) {
          prefix = "\n      if (node.$name != null) '$name':";
          check = '!';
        } else {
          prefix = "\n      '$name':";
          check = '';
        }

        if (isAstNode(accessor.returnType)) {
          sink.write('$prefix node.$name$check.accept(this),');
        } else if (isNodeList(accessor.returnType)) {
          sink
            ..write('\n      if (node.$name.isNotEmpty)')
            ..write("\n        '$name': <Map<String, Object?>?>[")
            ..write(
                '\n          for (var item in node.$name) item.accept(this),')
            ..write('\n        ],');
        } else if (isString(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isNum(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isBool(accessor.returnType)) {
          sink.write("\n     if (node.$name) '$name': node.$name$check,");
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
      var method = throwingAstVisitor.getMethod('visit$name');

      if (method == null) {
        continue;
      }

      sink
        ..write('\n')
        ..write('\n  @override')
        ..write('\n  Map<String, Object?> visit$name($name node) {')
        ..write('\n    return <String, Object?>{')
        ..write("\n      '_': '$name',")
        ..write('\n      ...getLocation(node),');

      // throws null check on null or stack overflow
      var writed = <String>{'isQualified', 'unParenthesized', 'unlabeled'};

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
  sink.close();
}

const String header = '''
// generated with `tools/generate_script_to_json.dart`
// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

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
