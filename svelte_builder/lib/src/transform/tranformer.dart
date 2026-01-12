import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/src/recase.dart';
import 'package:svelte_builder/src/transform/visitor.dart';

final class Transformer implements Builder {
  const Transformer();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '{{dir}}/{{file}}.svelte': <String>['{{dir}}/{{file}}.svelte.dart'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    AssetId inputAsset = buildStep.inputId;
    AssetId outputAsset = inputAsset.changeExtension('.svelte.dart');

    String fileName = path.basename(inputAsset.path);
    String componentName = pascalCase(path.basenameWithoutExtension(fileName));

    String template = await buildStep.readAsString(inputAsset);

    Root root = parse(template, fileName: fileName, uri: inputAsset.uri);

    TransformVisitor transformer = TransformVisitor(
      componentName: componentName,
      template: template,
    );

    StringBuffer outputBuffer = StringBuffer();
    root.accept(transformer, outputBuffer);

    String componentCode = DartFormatter(
      languageVersion: Version(3, 8, 0),
    ).format(outputBuffer.toString(), uri: inputAsset.uri);

    await buildStep.writeAsString(outputAsset, componentCode);
  }
}
