import 'package:svelte/src/compiler/interface.dart';

class Component {
  Component(this.ast, this.source, this.name);

  final Ast ast;

  final String source;

  final String name;
}
