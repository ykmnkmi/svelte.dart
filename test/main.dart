import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/string_source.dart';

void main() {
  // var input = '<Component test={{\'a\': 1} />';
  var expression = '{\'a\': 1} />';
  var offset = 17; // = input.indexOf(expression);
  var featureSet = FeatureSet.latestLanguageVersion();
  var source = StringSource(expression, '<expression>');
  var errorListener = RecordingErrorListener();
  var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
  scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

  var token = scanner.tokenize(reportScannerErrors: false);
  var lineInfo = LineInfo(scanner.lineStarts);
  var parser = Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);

  var result = parser.parseExpression(token);
  print(result.isSynthetic);
}