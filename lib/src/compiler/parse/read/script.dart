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

class _CompilationUnit extends CompilationUnitImpl {
  factory _CompilationUnit.from(int contentStart, int contentEnd, CompilationUnit unit) {
    var begin = Token(unit.beginToken.type, contentStart);
    var end = Token(unit.endToken.type, contentEnd);
    return _CompilationUnit(begin, null, unit.directives, unit.declarations, end, unit.featureSet, unit.lineInfo);
  }

  _CompilationUnit(
    super.beginToken,
    super.scriptTag,
    super.directives,
    super.declarations,
    super.endToken,
    super.featureSet,
    super.lineInfo,
  );

  @override
  int get offset {
    return beginToken.offset;
  }

  @override
  int get end {
    return endToken.end;
  }
}

extension ScriptParser on Parser {
  static final RegExp nonNewLineRe = RegExp(r'[^\n]');

  static final RegExp scriptCloseRe = RegExp(r'<\/script\s*>');

  bool isModule(List<Node>? attributes) {
    if (attributes == null) {
      return false;
    }

    Node? module;

    for (var attribute in attributes) {
      if (attribute is Attribute && attribute.name == 'module') {
        module = attribute;
        break;
      }
    }

    if (module == null) {
      return false;
    }

    if (module.children.isNotEmpty) {
      invalidScriptModuleAttribute(module.start);
    }

    return true;
  }

  void script(int offset, List<Node>? attributes) {
    var contentStart = index;
    var data = readUntil(scriptCloseRe, unclosedScript);
    var contentEnd = index;

    // TODO(error): handle
    if (scan(scriptCloseRe)) {
      var module = isModule(attributes);
      var prefix = template.substring(0, contentStart).replaceAll(nonNewLineRe, ' ');
      var unit = _CompilationUnit.from(contentStart, contentEnd, parseScript(offset, prefix + data));
      scripts.add(Script(start: offset, end: index, isModule: module, content: unit));
      return;
    }

    unclosedScript();
  }

  static CompilationUnit parseScript(int offset, String script, {AnalysisErrorListener? errorListener}) {
    errorListener ??= RecordingErrorListener();

    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(script, '<script>');
    var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
    scanner.configureFeatures(featureSetForOverriding: featureSet, featureSet: featureSet);

    var token = scanner.tokenize();
    var lineInfo = LineInfo(scanner.lineStarts);
    var parser = AST.Parser(source, errorListener, featureSet: scanner.featureSet, lineInfo: lineInfo);
    return parser.parseCompilationUnit(token);
  }
}
