import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

extension ScriptParser on Parser {
  void readScript(int start, List<Node> attributes) {
    expect('>');
    throw UnimplementedError();
  }
}
