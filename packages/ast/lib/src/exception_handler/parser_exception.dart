part of 'exception_handler.dart';

@sealed
class ParserException extends Error {
  ParserException(this.errorCode, this.offset, this.length);

  final int? length;

  final ParserErrorCode errorCode;

  final int? offset;

  @override
  bool operator ==(Object o) {
    if (o is ParserException) {
      return errorCode == o.errorCode && length == o.length && offset == o.offset;
    }

    return false;
  }

  @override
  int get hashCode {
    return hash3(errorCode, length, offset);
  }

  @override
  String toString() {
    return 'ParserException {$errorCode}';
  }
}
