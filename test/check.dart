import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/string_source.dart';

void main() {
  var string = 'external int count = 0;';
  var featureSet = FeatureSet.latestLanguageVersion();
  var source = StringSource(string, '<memory>');
  var errorListener = RecordingErrorListener();
  var scanner = Scanner.fasta(source, errorListener);
  scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

  var token = scanner.tokenize();
  var lineInfo = LineInfo(scanner.lineStarts);
  var parser = Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);
  var result = parser.parseCompilationUnit(token);

  for (var declaration in result.declarations) {
    if (declaration is TopLevelVariableDeclaration) {
      print(declaration.externalKeyword);
    }
  }
}
