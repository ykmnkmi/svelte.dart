import 'dart:async';

import 'package:build/build.dart' show BuildStep, Builder, BuilderOptions;
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart' show DartFormatter;
import 'package:path/path.dart' show basenameWithoutExtension;

Builder svelteBuilder(BuilderOptions options) {
  return const SvelteBuilder();
}

class SvelteBuilder implements Builder {
  const SvelteBuilder();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '.svelte': <String>['.dart'],
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var input = buildStep.inputId;
    var output = input.changeExtension('.dart');

    var name = basenameWithoutExtension(input.path);

    var library = Library((library) {
      library.body.add(Class((klass) {
        klass
          ..name = name
          ..extend = svelteRef('Component')
          ..constructors.add(getComponentConstructor());
      }));
    });

    var emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    var formatter = DartFormatter();
    var code = library.accept(emitter);
    var content = formatter.format('$code', uri: output.uri);
    await buildStep.writeAsString(output, content);
  }
}

Reference svelteRef(String symbol) {
  return refer(symbol, 'package:svelte/runtime.dart');
}

Reference webRef(String symbol) {
  return refer(symbol, 'package:web/web.dart');
}

List<Parameter> getParameters() {
  return <Parameter>[
    Parameter((parameter) {
      parameter
        ..type = webRef('Element?')
        ..name = 'target'
        ..named = true;
    }),
    Parameter((parameter) {
      parameter
        ..type = webRef('Node?')
        ..name = 'anchor'
        ..named = true;
    }),
    Parameter((parameter) {
      parameter
        ..type = refer('Map<String, Object?>?')
        ..name = 'props'
        ..named = true;
    }),
    Parameter((parameter) {
      parameter
        ..type = refer('bool')
        ..name = 'hydrate'
        ..defaultTo = Code('false')
        ..named = true;
    }),
    Parameter((parameter) {
      parameter
        ..type = refer('bool')
        ..name = 'intro'
        ..defaultTo = Code('false')
        ..named = true;
    }),
  ];
}

Expression getInitExpression({
  bool createFragment = false,
  bool createInstance = false,
  Map<String, int>? props,
  List<int>? dirty,
}) {
  return svelteRef('init').call(const <Expression>[], {
    'component': CodeExpression(Code('this')),
    'options': CodeExpression(Code('''(
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      )''')),
    if (createInstance)
      'createInstance': CodeExpression(Code('createInstance')),
    if (createFragment)
      'createFragment': CodeExpression(Code('createFragment')),
    if (props != null)
      'props': literalMap(props, refer('String'), refer('int')),
    if (dirty != null) 'dirty': literalList(dirty, refer('int')),
  });
}

Constructor getComponentConstructor() {
  return Constructor((constructor) {
    constructor
      ..optionalParameters.addAll(getParameters())
      ..body = Block((block) {
        block.addExpression(getInitExpression());
      });
  });
}
