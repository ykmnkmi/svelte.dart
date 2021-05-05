import '../parser.dart';

void identifier(DartParser parser) {}

extension on Parser {
  String? start() {
    return startNoDollar() ?? r'$';
  }

  String? startNoDollar() {
    return letter() ?? '_';
  }

  String? partNoDollar() {
    return letter() ?? digit();
  }

  String? letter() {
    return read(RegExp('[a-zA-Z]'));
  }

  String? digit() {
    return read(RegExp('[0-9]'));
  }

  String? readAll(State state) {
    var result = state(this);

    if (result == null) {
      return null;
    }

    final buffer = StringBuffer();

    while (result != null) {
      buffer.write(result);
      result = state(this);
    }

    return '$buffer';
  }
}
