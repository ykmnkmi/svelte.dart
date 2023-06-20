// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show StringScanner, Token;
import 'package:analyzer/dart/analysis/features.dart' show Feature, FeatureSet;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart'
    show AnalysisErrorListener, ErrorReporter;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:stack_trace/stack_trace.dart' show Trace;

const String string = '''
void main() {
  external int count = 0;
}
''';

void main() {
  var featureSet = FeatureSet.latestLanguageVersion();
  var configuration = dart.Scanner.buildConfig(featureSet);
  var scanner = StringScanner(string, configuration: configuration);
  // scanner.scanOffset = -1;

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
    var result = parser.parse(token);
    print(result);
  } catch (error, trace) {
    print(error);
    print(Trace.format(trace));
  }
}

final class ThrowingErrorListener extends AnalysisErrorListener {
  @override
  void onError(AnalysisError error) {
    throw error;
  }
}

final class SvelteScriptParser extends fe.Parser {
  SvelteScriptParser(this.astBuilder, {super.allowPatterns})
      : super(astBuilder) {
    astBuilder.parser = this;
  }

  final AstBuilder astBuilder;

  Object? parse(Token token) {
    throw UnimplementedError();
  }
}
