import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/error/listener.dart' show RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/generated/parser.dart' as analyzer show Parser;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:stack_trace/stack_trace.dart';

const String content = '''
onMount(() {
  print(StackTrace.current);
});
''';

void main() {
  try {
    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(content, null);

    var errorListener = RecordingErrorListener();
    var scanner = Scanner.fasta(source, errorListener);

    scanner.configureFeatures(
      featureSetForOverriding: featureSet,
      featureSet: featureSet,
    );

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);

    var parser = analyzer.Parser(
      source,
      errorListener,
      featureSet: scanner.featureSet,
      lineInfo: lineInfo,
    );

    var result = parser.parseCompilationUnit(token);

    for (var childEntity in result.childEntities) {
      print(childEntity.runtimeType);
    }
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
