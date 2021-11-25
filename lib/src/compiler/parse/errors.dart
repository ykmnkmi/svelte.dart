import 'package:source_span/source_span.dart' show SourceSpan;

import 'parse.dart';

class CompileError extends Error {
  CompileError(this.code, this.message, this.span);

  final String code;

  final String message;

  final SourceSpan span;

  @override
  String toString() {
    return span.message(message);
  }
}

extension ParserErrors on Parser {
  Never unexpectedEOF(Pattern pattern) {
    error('unexpected-eof', 'unexpected $pattern');
  }

  Never unexpectedToken(Pattern pattern) {
    error('unexpected-token', 'expected $pattern');
  }
}
