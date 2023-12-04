import 'package:build/build.dart';

class SvelteBuilder implements Builder {
  const SvelteBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '^{{dir}}/{{file}}.svelte': <String>[
        '{{dir}}/{{file}}.svelte.dart',
      ],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    var inputAsset = buildStep.inputId;

    var outputAsset = inputAsset.changeExtension('.svelte.dart');
    var instanceAsset = inputAsset.changeExtension('.svelte.instance.dart');

    print(outputAsset);
    print(instanceAsset);
  }
}
