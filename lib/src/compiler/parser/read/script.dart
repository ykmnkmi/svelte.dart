// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit;
import 'package:analyzer/dart/ast/token.dart' show Token;
import 'package:analyzer/error/listener.dart' show RecordingErrorListener;
import 'package:analyzer/source/line_info.dart' show LineInfo;
import 'package:analyzer/src/dart/ast/ast.dart'
    show CompilationUnitImpl, CompilationUnitMemberImpl, DirectiveImpl;
import 'package:analyzer/src/dart/scanner/scanner.dart' show Scanner;
import 'package:analyzer/src/generated/parser.dart' as analyzer show Parser;
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

final RegExp scriptEndRe = RegExp('<\\/script\\s*>');

class _CompilationUnit extends CompilationUnitImpl {
  factory _CompilationUnit.from(int start, int end, CompilationUnit unit) {
    var beginToken = Token(unit.beginToken.type, start);
    var endToken = Token(unit.endToken.type, end);

    return _CompilationUnit(
      beginToken: beginToken,
      scriptTag: null,
      directives: unit.directives as List<DirectiveImpl>,
      declarations: unit.declarations as List<CompilationUnitMemberImpl>,
      endToken: endToken,
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
  String getContext(List<TemplateNode> attributes) {
    TemplateNode? context;

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

    if (children == null ||
        children.length != 1 ||
        children.first.type != 'Text') {
      invalidScriptContextAttribute(context.start);
    }

    if (children.first.data == 'module') {
      return 'module';
    }

    invalidScriptContextValue(context.start);
  }

  void script(int offset, List<TemplateNode> attributes) {
    var start = position;
    var content = readUntil(scriptEndRe, unclosedScript);
    var end = position;
    expect(scriptEndRe, unclosedScript);

    var context = getContext(attributes);
    var prefix = template.substring(0, start).replaceAll(nonNewLineRe, ' ');
    var featureSet = FeatureSet.latestLanguageVersion();
    var source = StringSource(prefix + content, null, uri: sourceFile.url);
    var errorListener = RecordingErrorListener();
    var scanner = Scanner.fasta(source, errorListener, offset: offset - 1);

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

    if (errorListener.errors.isNotEmpty) {
      var analysisError = errorListener.errors.first;

      error(
        code: 'parse-error',
        message: analysisError.message,
        position: analysisError.offset,
      );
    }

    var unit = parser.parseCompilationUnit(token);
    unit = _CompilationUnit.from(start, end, unit);

    scripts.add(Script(
      start: offset,
      end: position,
      context: context,
      content: unit,
    ));
  }
}

void script(Parser parser, int offset, List<TemplateNode> attributes) {
  parser.script(offset, attributes);
}
