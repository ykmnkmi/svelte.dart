import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/mustache.dart';
import 'package:svelte_ast/src/state/text.dart';

final RegExp textEndRe = RegExp('[<{]');

extension FramentParser on Parser {
  Node? fragment() {
    if (match(openCurlRe)) {
      return mustache();
    }

    return text();
  }
}
