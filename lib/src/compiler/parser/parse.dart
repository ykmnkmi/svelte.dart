import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

Node parse(String source, {Object? sourceUrl}) {
  var parser = Parser(source, sourceUrl: sourceUrl);
  return parser.html;
}
