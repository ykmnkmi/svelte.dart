import 'package:source_span/source_span.dart' show SourceSpan;

class ParseError extends Error {
  ParseError(this.errorCode, this.span);

  final ErrorCode errorCode;

  final SourceSpan span;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'code': errorCode.code,
      'message': errorCode.message,
      'line': span.start.line + 1,
      'column': span.start.column,
      'offset': span.start.offset,
    };
  }

  @override
  String toString() {
    return 'ParseError: ${errorCode.message}';
  }
}

typedef ErrorCode = ({String code, String message});

const ErrorCode expectedBlockType = (
  code: 'expected-block-type',
  message: 'Expected if, each or await',
);

const ErrorCode invalidDebugArgs = (
  code: 'invalid-debug-args',
  message: '{@debug ...} arguments must be identifiers',
);

const ErrorCode invalidConstArgs = (
  code: 'invalid-const-args',
  message: '{@const ...} must be an assignment',
);

ErrorCode unexpectedEOFToken(Pattern token) {
  return (
    code: 'unexpected-eof',
    message: 'Unexpected $token',
  );
}

ErrorCode unexpectedToken(Pattern token) {
  return (
    code: 'unexpected-token',
    message: 'Expected $token',
  );
}
