// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show StringScanner;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/error/listener.dart' show ErrorReporter;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:stack_trace/stack_trace.dart' show Trace;

import 'svelte_script_parser.dart';

const String string = '''
import 'package:svelte/svelte.dart';

external int count = 0;

var unused = null;

onMount(() {
  print('mounted');

  Future<void>.delayed(Duration(seconds: 2), () {
    count += 1;
  });
});

onDestroy(() {
  print('destroyed');
});
''';

void main() {
  var featureSet = FeatureSet.latestLanguageVersion();
  var configuration = dart.Scanner.buildConfig(featureSet);
  var scanner = StringScanner(string, configuration: configuration);
  // scanner.scanOffset = parser.position;

  var token = scanner.tokenize();

  var lineInfo = LineInfo(scanner.lineStarts);
  var source = StringSource(string, 'main.dart');
  var errorListener = ThrowingErrorListener();
  var reporter = ErrorReporter(errorListener, source,
      isNonNullableByDefault: featureSet.isEnabled(Feature.non_nullable));
  var astBuilder = AstBuilder(reporter, source.uri, true, featureSet, lineInfo);

  var parser = SvelteScriptParser(astBuilder,
      allowPatterns: featureSet.isEnabled(Feature.patterns));

  try {
    print(parser.parse(token));
  } catch (error, trace) {
    print(error);
    print(Trace.format(trace));
  }
}
