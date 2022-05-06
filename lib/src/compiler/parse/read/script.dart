import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/utils/patterns.dart';

extension ScriptParser on Parser {
  static final RegExp closeRe = compile(r'<\/script\s*>');

  static final RegExp allRe = compile(r'[^\n]');

  String getContext(List<Node>? attributes) {
    if (attributes == null) {
      return 'default';
    }

    Node? context;

    for (var attribute in attributes) {
      if (attribute.name == 'context') {
        context = attribute;
        break;
      }
    }

    if (context == null) {
      return 'default';
    }

    var children = context.children;

    if (children == null || children.length != 1 || children.first.type != 'Text') {
      invalidScriptContextAttribute(context.start);
    }

    var value = children.first.data;

    if (value == null || value != 'module') {
      invalidScriptContextValue(context.start);
    }

    return value;
  }

  void script(int start, List<Node>? attributes) {
    var data = readUntil(closeRe, unclosedScript);

    // TODO(error): handle
    if (scan(closeRe)) {
      var context = getContext(attributes);
      var source = template.substring(0, start).replaceAll(allRe, ' ') + data;
      var result = parseString(content: source);
      var node = Node(start: start, end: index, type: 'Script', data: context, library: result.unit);
      scripts.add(node);
      return;
    }

    unclosedScript();
  }
}
