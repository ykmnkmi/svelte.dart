// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit;
import 'package:analyzer/dart/ast/token.dart' show Token;
import 'package:analyzer/error/listener.dart' show RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/ast/ast.dart'
    show CompilationUnitImpl, CompilationUnitMemberImpl, DirectiveImpl;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/generated/parser.dart' as ast show Parser;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parse/errors.dart';
import 'package:nutty/src/compiler/parse/parse.dart';

class _CompilationUnit extends CompilationUnitImpl {
  factory _CompilationUnit.from(
      int contentStart, int contentEnd, CompilationUnit unit) {
    var begin = Token(unit.beginToken.type, contentStart);
    var end = Token(unit.endToken.type, contentEnd);
    return _CompilationUnit(
      beginToken: begin,
      scriptTag: null,
      directives: unit.directives as List<DirectiveImpl>,
      declarations: unit.declarations as List<CompilationUnitMemberImpl>,
      endToken: end,
      featureSet: unit.featureSet,
      lineInfo: unit.lineInfo,
    );
  }

  _CompilationUnit({
    required super.beginToken,
    required super.scriptTag,
    required super.directives,
    required super.declarations,
    required super.endToken,
    required super.featureSet,
    required super.lineInfo,
  });

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

  String getContext(List<Node>? attributes) {
    if (attributes == null) {
      return 'default';
    }

    Node? context;

    for (var attribute in attributes) {
      if (attribute is NamedNode && attribute.name == 'context') {
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

  void script(int offset, List<Node>? attributes) {
    var contentStart = index;
    var data = readUntil(scriptCloseRe, unclosedScript);
    var contentEnd = index;

    // TODO(error): handle
    if (scan(scriptCloseRe)) {
      var context = getContext(attributes);
      var prefix =
          template.substring(0, contentStart).replaceAll(nonNewLineRe, ' ');
      var featureSet = FeatureSet.latestLanguageVersion();
      var source = StringSource(prefix + data, null, uri: sourceFile.url);
      var errorListener = RecordingErrorListener();
      var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);
      scanner.configureFeatures(
          featureSetForOverriding: featureSet, featureSet: featureSet);

      var token = scanner.tokenize();
      var lineInfo = LineInfo(scanner.lineStarts);
      var parser = ast.Parser(source, errorListener,
          featureSet: scanner.featureSet, lineInfo: lineInfo);
      var unit = parser.parseCompilationUnit(token);
      var errors = errorListener.errors.toList();
      unit = _CompilationUnit.from(contentStart, contentEnd, unit);
      scripts.add(Script(
          start: offset,
          end: index,
          context: context,
          content: unit,
          errors: errors));
      return;
    }

    unclosedScript();
  }
}
