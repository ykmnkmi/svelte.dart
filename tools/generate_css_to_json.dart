import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

Future<void> main() async {
  var cssUri = Uri(scheme: 'package', path: 'csslib/visitor.dart');
  var cssFileUri = await Isolate.resolvePackageUri(cssUri);

  if (cssFileUri == null) {
    throw Exception('ast uri is not resolved');
  }

  var cssFile = File.fromUri(cssFileUri);
  cssFile = cssFile.absolute;

  var includedPaths = <String>[cssFile.path];
  var collection = AnalysisContextCollection(includedPaths: includedPaths);

  var context = collection.contextFor(cssFile.path);
  var session = context.currentSession;
  var resolvedUnit = await session.getResolvedUnit(cssFile.path);

  if (resolvedUnit is! ResolvedUnitResult) {
    throw Exception('library is not resolved');
  }

  var library = resolvedUnit.libraryElement;
  var treeNodeClass = library.getClass('TreeNode');

  if (treeNodeClass == null) {
    throw Exception('TreeNode is not resolved');
  }

  var typeProvider = resolvedUnit.typeProvider;
  var typeSystem = resolvedUnit.typeSystem;

  var treeNodeType = typeSystem.instantiateInterfaceToBounds(
    element: treeNodeClass,
    nullabilitySuffix: NullabilitySuffix.question,
  );

  var treeNodeListType = typeProvider.listType(treeNodeType);

  var visitorBaseClass = library.getClass('VisitorBase');

  if (visitorBaseClass == null) {
    throw Exception('Visitor is not resolved');
  }

  bool isBool(DartType type) {
    return type.isDartCoreBool;
  }

  bool isEnum(DartType type) {
    return type.isDartCoreEnum;
  }

  bool isNum(DartType type) {
    return type.isDartCoreNum;
  }

  bool isString(DartType type) {
    return type.isDartCoreString;
  }

  bool isTreeNode(DartType type) {
    return typeSystem.isSubtypeOf(type, treeNodeType);
  }

  bool isTreeNodeList(DartType type) {
    return typeSystem.isSubtypeOf(type, treeNodeListType);
  }

  var file = File('lib/src/compiler/css_to_json.dart');
  var sink = file.openWrite();
  sink.write(header);

  void writeFields(InterfaceElement interface, Set<String> writed) {
    for (var accessor in interface.accessors) {
      if (accessor.hasDeprecated || accessor.isPrivate) {
        continue;
      }

      var name = accessor.name;

      if (writed.contains(accessor.name)) {
        continue;
      }

      if (accessor.isGetter) {
        var returnType = accessor.returnType;
        String prefix, check;

        if (typeSystem.isNullable(returnType)) {
          prefix = "\n      if (node.$name != null) '$name':";
          check = '!';
        } else {
          prefix = "\n      '$name':";
          check = '';
        }

        if (isBool(returnType)) {
          sink.write("\n      if (node.$name) '$name': node.$name$check,");
        } else if (isEnum(returnType)) {
          sink.write('$prefix node.$name$check.toString(),');
        } else if (isNum(returnType) || isString(returnType)) {
          sink.write('$prefix node.$name$check,');
        } else if (isTreeNode(returnType)) {
          sink.write('$prefix node.$name$check.visit(this),');
        } else if (isTreeNodeList(returnType)) {
          sink
            ..write('\n      if (node.$name.isNotEmpty)')
            ..write("\n        '$name': <Map<String, Object?>>[")
            ..write(
                '\n          for (var item in node.$name) item.visit(this) as Map<String, Object?>,')
            ..write('\n        ],');
        }

        writed.add(name);
      }
    }
  }

  for (var method in visitorBaseClass.methods) {
    if (method.name.startsWith('visit')) {
      var type = method.parameters.first.type as InterfaceType;

      if (!typeSystem.isSubtypeOf(type, treeNodeType)) {
        continue;
      }

      var name = type.getDisplayString(withNullability: false);

      sink
        ..write('\n')
        ..write('\n  @override')
        ..write('\n  Map<String, Object?> visit$name($name node) {')
        ..write('\n    return <String, Object?>{')
        ..write('\n      ...getLocation(node),')
        ..write("\n      'type': '$name',");

      var writed = <String>{
        // null check on null
        // 'isQualified',

        // stack overflow
        // 'nullShortingTermination',
        // 'unlabeled',
        // 'unParenthesized',
      };

      writeFields(type.element, writed);

      for (var interface in type.allSupertypes) {
        var name = interface.getDisplayString(withNullability: false);

        if (name == 'TreeNode') {
          break;
        }

        sink.write('\n      // $name');
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
// generated with `tools/generate_css_to_json.dart`
// ignore_for_file: avoid_renaming_method_parameters, depend_on_referenced_packages

import 'package:csslib/visitor.dart';

Map<String, int> getLocation(TreeNode node) {
  var span = node.span;

  if (span == null) {
    return const <String, int>{};
  }

  return <String, int>{
    'start': span.start.offset,
    'end': span.end.offset,
  };
}

class CssToJsonVisitor implements VisitorBase {
  const CssToJsonVisitor();

  List<Map<String, Object?>> visitAll(List<TreeNode> nodes) {
    return <Map<String, Object?>>[for (var node in nodes) node.visit(this) as Map<String, Object?>];
  }''';
