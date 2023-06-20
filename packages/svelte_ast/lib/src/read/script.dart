import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp _scriptCloseTag = RegExp('<\\/script\\s*>');

extension ScriptParser on Parser {
  String _getContext(int start, List<Node> nodes) {
    Attribute? attribute;

    for (Node node in nodes) {
      if (node case Attribute(name: 'context')) {
        attribute = node;
      }
    }

    if (attribute == null) {
      return 'default';
    }

    if (attribute.value case <Node>[Text(data: String data)]) {
      if (data == 'module') {
        return data;
      }

      error(invalidScriptContextValue, start);
    }

    error(invalidScriptContextAttribute, start);
  }

  void readScript(int start, List<Node> attributes) {
    expect('>');

    String context = _getContext(start, attributes);
    String data = readUntil(_scriptCloseTag, unclosedScript);

    if (isDone) {
      error(unclosedScript);
    }

    throw UnimplementedError('${(context, data)}');
  }
}
