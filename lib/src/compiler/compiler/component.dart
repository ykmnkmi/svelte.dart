import 'package:svelte/src/compiler/interface.dart';

class Component {
  Component({
    required this.name,
    required this.source,
    required this.ast,
  }) {
    build();
  }

  final String name;

  final String source;

  final Ast ast;

  void build() {}
}
