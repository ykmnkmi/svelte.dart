import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:svelte/src/compiler/compiler/warnings.dart';
import 'package:svelte/src/compiler/interface.dart';

class CompileOptions {
  const CompileOptions({
    this.name,
  });

  final String? name;
}

class Component {
  Component({
    required this.ast,
    required String source,
    required this.name,
    Object? sourceUrl,
  })  : source = SourceFile.fromString(source, url: sourceUrl),
        tag = name {
    // TODO(compiler): set component options
    // TODO(compiler): set namespace

    walkModuleScript();
  }

  final Ast ast;

  final SourceFile source;

  final String name;

  final String tag;

  void warn({
    required int start,
    int? end,
    required ({String code, String message}) warning,
  }) {}

  void walkModuleScript() {
    var module = ast.module;

    if (module == null) {
      return;
    }

    module.unit.accept(LabeledModule(this));
  }
}

class LabeledModule extends RecursiveAstVisitor<void> {
  LabeledModule(this.component);

  final Component component;

  @override
  void visitLabeledStatement(LabeledStatement node) {
    for (var label in node.labels) {
      if (label.label.name == r'$') {
        component.warn(
          start: label.offset,
          end: label.end,
          warning: moduleScriptReactiveDeclaration,
        );
      }
    }
  }
}
