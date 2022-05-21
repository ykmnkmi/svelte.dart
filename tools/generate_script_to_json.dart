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

  var visitorUri = Uri(scheme: 'package', path: 'analyzer/dart/ast/visitor.dart');
  var visitorFileUri = await Isolate.resolvePackageUri(visitorUri);

  if (visitorFileUri == null) {
    throw Exception('visitor uri is not resolved');
  }

  var astFile = File.fromUri(astFileUri);
  var visitorFile = File.fromUri(visitorFileUri);

  var includedPaths = <String>[astFile.absolute.path, visitorFile.absolute.path];
  var collection = AnalysisContextCollection(includedPaths: includedPaths);

  var context = collection.contextFor(visitorFile.absolute.path);
  var session = context.currentSession;
  var resolvedUnit = await session.getResolvedUnit(visitorFile.absolute.path);

  if (resolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var library = resolvedUnit.libraryElement;
  var throwingAstVisitor = library.getType('ThrowingAstVisitor');

  if (throwingAstVisitor == null) {
    throw Exception('ThrowingAstVisitor is not resolved');
  }

  context = collection.contextFor(astFile.absolute.path);
  session = context.currentSession;
  resolvedUnit = await session.getResolvedUnit(astFile.absolute.path);

  if (resolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var typeSystem = resolvedUnit.typeSystem;
  library = resolvedUnit.libraryElement;

  var astNode = library.getType('AstNode');

  if (astNode == null) {
    throw Exception('AstNode is not resolved');
  }

  var astType = typeSystem.instantiateToBounds2(classElement: astNode, nullabilitySuffix: NullabilitySuffix.question);

  bool isAstNode(DartType type) {
    return typeSystem.isSubtypeOf(type, astType);
  }

  var nodeList = library.getType('NodeList');

  if (nodeList == null) {
    throw Exception('NodeList is not resolved');
  }

  var nodeListType =
      typeSystem.instantiateToBounds2(classElement: nodeList, nullabilitySuffix: NullabilitySuffix.question);

  bool isNodeList(DartType type) {
    return typeSystem.isSubtypeOf(type, nodeListType);
  }

  bool isString(DartType type) {
    return type.isDartCoreString;
  }

  bool isNum(DartType type) {
    // TODO: check for num alone
    return type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum;
  }

  bool isBool(DartType type) {
    return type.isDartCoreBool;
  }

  var klasses = library.topLevelElements.whereType<ClassElement>().toList();
  klasses.sort(((left, right) => left.nameOffset.compareTo(right.nameOffset)));

  var sink = File('lib/src/compiler/script_to_json.dart').openWrite();
  sink.write(header);

  void writeFields(ClassElement klass, Set<String> writed) {
    if (klass.name == 'AstNode' || klass.name == 'NullShortableExpression') {
      return;
    }

    for (var accessor in klass.accessors) {
      if (accessor.hasDeprecated) {
        continue;
      }

      var name = accessor.name;

      if (writed.contains(accessor.name)) {
        continue;
      }

      if (accessor.isGetter) {
        var check = '';
        String prefix;

        if (typeSystem.isNullable(accessor.returnType)) {
          prefix = '\n      if (node.$name != null) \'$name\':';
          check = '!';
        } else {
          prefix = '\n      \'$name\':';
        }

        if (isAstNode(accessor.returnType)) {
          sink.write('$prefix node.$name$check.accept(this),');
        } else if (isNodeList(accessor.returnType)) {
          sink
            ..write('$prefix <Map<String, Object?>?>[\n')
            ..write('        for (var item in node.$name$check) item.accept(this),\n')
            ..write('      ],');
        } else if (isString(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isNum(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isBool(accessor.returnType)) {
          sink.write('$prefix node.$name$check,');
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
        ..write('\n      ...getLocation(node),')
        ..write('\n      \'_\': \'$name\',');

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

  sink.write('\n}');
  sink.close();
}

const String header = '''
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ScriptToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  const ScriptToJsonVisitor();

  Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }''';
