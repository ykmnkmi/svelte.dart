import 'package:string_scanner/string_scanner.dart';

import 'nodes.dart';
import 'parser.dart';

Expression expression(Parser parser) {
  return ExpressionParser().scan(parser.scanner);
}

class ExpressionParser {
  ExpressionParser() : identifierReg = RegExp('([a-zA-Z][a-zA-Z0-9]*)');

  final RegExp identifierReg;

  Expression parse(String template, {int? position}) {
    final scanner = StringScanner(template.trimRight(), position: position);
    return scan(scanner);
  }

  Expression scan(StringScanner scanner) {
    return expression(scanner);
  }

  Expression expression(StringScanner scanner) {
    if (scanner.scan(identifierReg)) {
      return Identifier(scanner.lastMatch![0]!);
    } else {
      scanner.error('primary expression expected');
    }
  }
}
