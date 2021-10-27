import 'package:meta/meta.dart' show literal;

import 'scanner.dart';
import 'token.dart';

class MicroLexer {
  // Prevent inheritance.
  @literal
  const MicroLexer();

  Iterable<MicroToken> tokenize(String template) sync* {
    var scanner = MicroScanner(template);
    var token = scanner.scan();

    while (token != null) {
      yield token;
      token = scanner.scan();
    }
  }
}
