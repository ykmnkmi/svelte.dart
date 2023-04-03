// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/token.dart' show StringToken;
import 'package:analyzer/dart/ast/ast.dart' show SimpleIdentifier;
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:svelte/compiler.dart';

extension ContextParser on Parser {
  SimpleIdentifier readContext() {
    var start = position;
    var identifier = readIdentifier();

    if (identifier != null) {
      var token = StringToken(TokenType.IDENTIFIER, identifier, start);
      return astFactory.simpleIdentifier(token);
    }

    // TODO(parser): implement destructuring
    unexpectedTokenDestructure();
  }
}
