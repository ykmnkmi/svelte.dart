// import 'package:meta/meta.dart';

// import 'exception_handler/exception_handler.dart';
// import 'scanner.dart';
// import 'token/tokens.dart';

// @sealed
// class Lexer {
//   @literal
//   const Lexer();

//   Iterable<Token> tokenize(String template, ExceptionHandler exceptionHandler) sync* {
//     final scanner = Scanner(template, exceptionHandler);

//     var token = scanner.scan();

//     while (token != null) {
//       yield token;
//       token = scanner.scan();
//     }
//   }
// }
