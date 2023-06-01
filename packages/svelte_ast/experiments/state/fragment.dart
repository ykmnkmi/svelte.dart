// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/scanner/token.dart' show TokenType;
import 'package:svelte_ast/src/ast.dart';

import '../parser.dart';
import '../scanner.dart';
import 'mustache.dart';
import 'text.dart';

extension FragmentParser on Parser {
  Node? fragment() {
    return switch (token.type) {
      TokenType.OPEN_CURLY_BRACKET => mustache(),
      SvelteToken.DATA => text(),
      TokenType type => throw StateError(type.name),
    };
  }
}
