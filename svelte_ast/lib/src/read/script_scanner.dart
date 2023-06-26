// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/characters.dart' show $EOF;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart'
    show ErrorToken, StringScanner, Token;

class ScriptScanner extends StringScanner {
  ScriptScanner({
    required String string,
    int offset = 0,
    super.configuration,
  }) : super(string, includeComments: true) {
    scanOffset = offset - 1;
  }

  @override
  void appendToken(Token token) {
    if (token is ErrorToken) {
      throw token;
    }

    super.appendToken(token);
  }

  Token scan(Pattern end) {
    int next = advance();

    while (true) {
      if (groupingStack.isEmpty && string.startsWith(end, scanOffset)) {
        break;
      }

      if (identical(next, $EOF)) {
        break;
      }

      next = bigSwitch(next);
    }

    appendEofToken();
    return firstToken();
  }

  @override
  Token tokenize() {
    throw UnsupportedError('Use scan instead.');
  }
}
