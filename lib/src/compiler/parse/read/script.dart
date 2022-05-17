import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/ast/ast.dart' show CompilationUnitImpl;
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart' as AST;
import 'package:analyzer/src/string_source.dart';
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/parse.dart';

class _CompilationUnit extends CompilationUnitImpl implements CompilationUnit {
  _CompilationUnit(super.beginToken, super.scriptTag, super.directives, super.declarations, super.endToken,
      super.featureSet, super.lineInfo);

  @override
  int get offset {
    return beginToken.offset;
  }
}

extension ScriptParser on Parser {
  static final RegExp closeRe = RegExp(r'<\/script\s*>');

  static final RegExp allRe = RegExp(r'[^\n]');

  String getContext(List<Attribute>? attributes) {
    if (attributes == null) {
      return 'default';
    }

    Attribute? context;

    for (var attribute in attributes) {
      if (attribute.name == 'context') {
        context = attribute;
        break;
      }
    }

    if (context == null) {
      return 'default';
    }

    var children = context.children;

    if (children.length != 1 || children.first is! Text) {
      invalidScriptContextAttribute(context.start);
    }

    var first = children.first;

    if (first is DataNode && first.data == 'module') {
      return 'module';
    }

    invalidScriptContextValue(context.start);
  }

  void script(int start, List<Attribute>? attributes) {
    var scriptStart = index;
    var data = readUntil(closeRe, unclosedScript);

    // TODO(error): handle
    if (scan(closeRe)) {
      var context = getContext(attributes);
      var prefix = template.substring(0, scriptStart).replaceAll(allRe, ' ');
      var unit = parseScript(scriptStart, prefix + data);
      var node = Script(start: start, end: index, context: context, content: unit);
      scripts.add(node);
      return;
    }

    unclosedScript();
  }

  static CompilationUnit parseScript(int offset, String script, //
      {AnalysisErrorListener? errorListener}) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(script, '<script>');
    var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
    scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);
    var parser = AST.Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);
    var unit = parser.parseCompilationUnit(token);
    var beginToken = Token(unit.beginToken.type, offset);
    return _CompilationUnit(beginToken, null, unit.directives, unit.declarations, unit.endToken, featureSet, lineInfo);
  }
}
