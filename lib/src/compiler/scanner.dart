import 'package:string_scanner/string_scanner.dart';

extension StringScannerExtension on StringScanner {
  void whitespace({bool required = false}) {
    const whitespaces = <int>[32, 9, 10, 13];

    if (required) {
      error('expected whitespace');
    }

    while (!isDone && whitespaces.contains(peekChar())) {
      readChar();
    }
  }
}
