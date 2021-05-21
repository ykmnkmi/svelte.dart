import 'package:meta/meta.dart';

import '../hash.dart';

part 'parser_exception.dart';
part 'exceptions.dart';

abstract class ExceptionHandler {
  void handle(ParserException? e);
}

@sealed
class ThrowingExceptionHandler implements ExceptionHandler {
  @literal
  const ThrowingExceptionHandler();
  @override
  void handle(ParserException? exception) {
    if (exception != null) {
      throw exception;
    }
  }
}

class RecoveringExceptionHandler implements ExceptionHandler {
  RecoveringExceptionHandler() : exceptions = <ParserException>[];

  final List<ParserException> exceptions;

  @override
  void handle(ParserException? exception) {
    if (exception != null) {
      exceptions.add(exception);
    }
  }
}
