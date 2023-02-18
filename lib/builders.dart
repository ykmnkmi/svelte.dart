import 'dart:async';

import 'package:build/build.dart' show BuildStep, Builder, BuilderOptions;
import 'package:path/path.dart' show basenameWithoutExtension;
import 'package:svelte/compiler.dart';

Builder svelteBuilder(BuilderOptions options) {
  return const SvelteBuilder();
}

class SvelteBuilder implements Builder {
  const SvelteBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '.svelte': <String>['.svelte.dart'],
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var input = buildStep.inputId;
    var output = input.changeExtension('.svelte.dart');
    var source = await buildStep.readAsString(input);

    var ast = parse(source, sourceUrl: input.uri);

    var baseName = basenameWithoutExtension(input.pathSegments.last);
    var name = getNameFromFileName(baseName);
    var component = Component(ast, source, name);
    // TODO(compiler): *
  }
}
