import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/mustache.dart';
import 'package:svelte_ast/src/state/text.dart';

extension FragmentParser on Parser {
  Node? fragment() {
    if (match('{')) {
      return mustache();
    }

    return text();
  }
}
