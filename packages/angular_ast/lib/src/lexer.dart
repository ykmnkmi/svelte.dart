import 'package:meta/meta.dart' show literal;

import 'scanner.dart';
import 'token/tokens.dart';

class Lexer {
  @literal
  const Lexer();

  Iterable<Token> tokenize(String template) sync* {
    var scanner = Scanner(template);
    var token = scanner.scan();

    while (token != null) {
      yield token;
      token = scanner.scan();
    }
  }
}
