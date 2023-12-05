import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/src/formatter.dart';

class MetaBuilder implements Builder {
  const MetaBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '{{dir}}/{{file}}.svelte': <String>[
        '{{dir}}/{{file}}.svelte.html',
        '{{dir}}/{{file}}.svelte.instance.dart',
        '{{dir}}/{{file}}.svelte.module.dart',
      ],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    var inputAsset = buildStep.inputId;

    var htmlAsset = inputAsset.changeExtension('.svelte.html');

    var instanceAsset = inputAsset.changeExtension('.svelte.instance.dart');
    var moduleAsset = inputAsset.changeExtension('.svelte.module.dart');

    var fileName = path.basename(inputAsset.path);

    var content = await buildStep.readAsString(inputAsset);
    var ast = parse(content, fileName: fileName);

    var instanceBuffer = StringBuffer('// $fileName\n');

    var html = content;
    String? instance, module;

    if (ast.instance case var script?) {
      var body = script.body;

      for (var directive in body.directives) {
        instanceBuffer.writeln(directive);
      }

      if (ast.module != null) {
        instanceBuffer
          ..writeln()
          ..writeln("import '${moduleAsset.path}';")
          ..writeln();
      }

      if (body.properties.isEmpty) {
        instanceBuffer
          ..writeln()
          ..write('void component() {');
      } else {
        instanceBuffer
          ..writeln()
          ..writeln('void component({');

        for (var property in script.body.properties) {
          instanceBuffer.writeln(' ${property.variables},');
        }

        instanceBuffer.write('}) {');
      }

      var updatedVariables = <String>{};

      for (var node in script.body.nodes.cast<Statement>()) {
        if (node is LabeledStatement && node.labels.first.label.name == r'$') {
          if (node.unlabeled case ExpressionStatement expression) {
            if (expression.expression case AssignmentExpression assign) {
              if (assign.leftHandSide case SimpleIdentifier identifier) {
                if (updatedVariables.add(identifier.name)) {
                  instanceBuffer
                    ..writeln()
                    ..writeln('   \$: var ${node.unlabeled}');

                  continue;
                }
              }
            }
          }

          instanceBuffer
            ..writeln()
            ..writeln('   $node');
        } else {
          instanceBuffer
            ..writeln()
            ..writeln('   $node');
        }
      }

      instanceBuffer.writeln('}');
      instance = formatter.format('$instanceBuffer');
      html = replace(html, script.start, script.end);
    }

    if (ast.module case var script?) {
      module = formatter.format(script.content.data);
      html = replace(html, script.start, script.end);
    }

    await buildStep.writeAsString(htmlAsset, html);

    if (instance != null) {
      await buildStep.writeAsString(instanceAsset, instance);
    }

    if (module != null) {
      await buildStep.writeAsString(moduleAsset, module);
    }
  }

  static bool isInstance(AssetId asset) {
    return asset.path.endsWith('.svelte.instance.dart');
  }

  static bool isModule(AssetId asset) {
    return asset.path.endsWith('.svelte.module.dart');
  }

  static String replace(String content, int start, int end) {
    var space = const LineSplitter()
        .convert(content.substring(start, end))
        .map<String>((line) => ' ' * line.length)
        .join('\n');

    return content.replaceRange(start, end, space);
  }
}
