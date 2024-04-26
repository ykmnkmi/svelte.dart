import 'package:svelte_ast/svelte_ast.dart';

final class Warning {}

final class Component {
  Component({
    required this.ast,
    required this.source,
    required this.name,
    this.fileName,
    List<Warning>? warnings,
  }) : warnings = warnings ?? <Warning>[] {
    walkModule();
  }

  final SvelteAst ast;

  final String source;

  final String name;

  final String? fileName;

  final List<Warning> warnings;

  void walkModule() {}
}
