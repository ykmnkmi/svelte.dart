import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/src/formatter.dart';
import 'package:svelte_builder/src/template_expression_writer.dart';

class SvelteBuilder implements Builder {
  const SvelteBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '{{dir}}/{{file}}.svelte': <String>[
        '{{dir}}/{{file}}.svelte.instance.dart',
        '{{dir}}/{{file}}.svelte.module.dart',
        '{{dir}}/{{file}}.svelte.dart',
      ],
    };
  }

  Future<LibraryElement> resolveInstance(
      BuildStep buildStep, SvelteAst ast) async {
    var inputAsset = buildStep.inputId;

    var instanceAsset = inputAsset.changeExtension('.svelte.instance.dart');
    String? modulePath;

    if (ast.module case var script?) {
      var moduleAsset = inputAsset.changeExtension('.svelte.module.dart');
      var module = formatter.format(script.content.data);
      await buildStep.writeAsString(moduleAsset, module);
      modulePath = moduleAsset.path;
    }

    if (ast.instance case var script?) {
      var instanceBuffer = StringBuffer();

      var body = script.body;

      for (var directive in body.directives) {
        instanceBuffer.writeln(directive);
      }

      if (modulePath != null) {
        instanceBuffer
          ..writeln()
          ..writeln("import '$modulePath';")
          ..writeln();
      }

      if (body.properties.isEmpty) {
        instanceBuffer
          ..writeln()
          ..write('void component() {');
      } else {
        instanceBuffer
          ..writeln()
          ..write('void component(');

        if (script.body.properties.isNotEmpty) {
          instanceBuffer
            ..write('{')
            ..write(script.body.properties.first.variables);

          for (var property in script.body.properties.skip(1)) {
            instanceBuffer.write(', ${property.variables}');
          }

          instanceBuffer.write('}');
        }

        instanceBuffer.write(') {');
      }

      for (var node in script.body.nodes.cast<Statement>()) {
        if (node is LabeledStatement && node.labels.first.label.name == r'$') {
          if (node.unlabeled case ExpressionStatement expression) {
            if (expression.expression case AssignmentExpression assign) {
              if (assign.leftHandSide is SimpleIdentifier) {
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
      }

      instanceBuffer.writeln(r'  $template: {');

      ast.html.accept(TemplateExpressionWriter(), instanceBuffer);

      instanceBuffer.writeln('  }');

      instanceBuffer.writeln('}');

      var instance = formatter.format('$instanceBuffer');
      await buildStep.writeAsString(instanceAsset, instance);
    }

    return await buildStep.resolver.libraryFor(instanceAsset);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    var inputAsset = buildStep.inputId;

    var outputBuffer = StringBuffer('// ${inputAsset.path}\n');
    var outputAsset = inputAsset.changeExtension('.svelte.dart');

    var fileName = path.basename(inputAsset.path);
    var template = await buildStep.readAsString(inputAsset);

    var ast = parse(template, fileName: fileName);

    var instanceLibrary = await resolveInstance(buildStep, ast);
    var component = instanceLibrary.definingCompilationUnit.functions.first;
    var componentAst = await buildStep.resolver.astNodeFor(component);

    if (componentAst is FunctionDeclaration) {
      outputBuffer.writeln('// ${componentAst.runtimeType}');
    }

    await buildStep.writeAsString(outputAsset, '$outputBuffer');
  }
}
