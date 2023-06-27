import 'package:svelte_ast/svelte_ast.dart';

class Component {
  Component({
    required this.ast,
    required this.source,
    required this.name,
    required this.warnings,
  });

  final SvelteAst ast;

  final String source;

  final String name;

  final List<String> warnings;
}
