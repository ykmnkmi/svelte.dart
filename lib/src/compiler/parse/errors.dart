import 'parse.dart';

extension ParserErrors on Parser {
  Never unexpectedEOF(Pattern pattern) {
    error('unexpected-eof', 'unexpected $pattern');
  }

  Never unexpectedToken(Pattern pattern) {
    error('unexpected-token', 'expected $pattern');
  }
}
