// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/token.dart' show TokenType;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/scanner.dart';
import 'package:svelte_ast/src/state/mustache.dart';
import 'package:svelte_ast/src/state/tag.dart';
import 'package:svelte_ast/src/state/text.dart';

extension FragmentParser on Parser {
  Node? fragment() {
    return switch (token.type) {
      TokenType.LT => tag(),
      TokenType.OPEN_CURLY_BRACKET => mustache(),
      SvelteToken.DATA => text(),
      TokenType type => throw StateError(type.name),
    };
  }
}
