import 'package:nutty/src/compiler/ast.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

List<Node> parse(String source, {Object? sourceUrl}) {
  var parser = Parser(source, sourceUrl: sourceUrl);
  return parser.stack.first.children;
}
