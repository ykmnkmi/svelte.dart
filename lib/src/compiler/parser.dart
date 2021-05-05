import 'errors.dart';

typedef State = String? Function(Parser parser);

abstract class Parser {
  Parser(this.template) : index = 0;

  final String template;

  int index;

  bool get isDone {
    return index >= template.length;
  }

  String get rest {
    return template.substring(index);
  }

  bool eat(String string, {bool required = false, String? message}) {
    if (match(string)) {
      index += string.length;
      return true;
    }

    if (required) {
      error(code: 'unexpected-${isDone ? 'eof' : 'token'}', message: message ?? "expected '$string'");
    }

    return false;
  }

  Never error({String? code, String? message}) {
    final start = index - 10 < 0 ? 0 : index - 10;
    final end = index + 10 < template.length ? index + 10 : template.length;
    throw CompileError(code: code, message: message, source: template.substring(start, end), offset: index - start);
  }

  bool match(String string) {
    return template.substring(index, index + string.length) == string;
  }

  String? look(Pattern pattern) {
    final match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return null;
    }

    return match[0];
  }

  String? read(Pattern regExp) {
    final result = look(regExp);

    if (result != null) {
      index += result.length;
    }

    return result;
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
      error(message: 'unexpected end of input');
    }

    final start = index;
    final end = template.indexOf(pattern, index);

    if (end > 0) {
      index = end;
      return template.substring(start, end);
    }

    index = template.length;
    return template.substring(start);
  }

  void whitespace({bool required = false}) {
    const whitespaces = <String>[' ', '\t', '\r', '\n'];

    if (required && whitespaces.contains(template[index])) {
      error(code: 'missing-whitespace', message: 'expected whitespace');
    }

    while (!isDone && whitespaces.contains(template[index])) {
      index += 1;
    }
  }
}
