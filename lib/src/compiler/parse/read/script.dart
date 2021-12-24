import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

import '../../parse/errors.dart';
import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension ScriptParser on Parser {
  static late final RegExp closeRe = compile(r'<\/script\s*>');

  static late final RegExp allRe = compile(r'[^\n]');

  String getContext(List<Node>? attributes) {
    if (attributes == null) {
      return 'default';
    }

    Node? context;

    for (Node attribute in attributes) {
      if (attribute.name == 'context') {
        context = attribute;
        break;
      }
    }

    if (context == null) {
      return 'default';
    }

    List<Node> children = context.children;

    if (children.length != 1 || children.first.type != 'Text') {
      invalidScriptContextAttribute(context.start);
    }

    String? value = children.first.data;

    if (value == null || value != 'module') {
      invalidScriptContextValue(context.start);
    }

    return value;
  }

  void script(int start, List<Node>? attributes) {
    String data = readUntil(closeRe, unclosedScript);

    if (scan(closeRe)) {
      String context = getContext(attributes);
      String source = template.substring(0, start).replaceAll(allRe, ' ') + data;
      // TODO(error): handle
      ParseStringResult result = parseString(content: source);
      scripts.add(Node(start: start, end: index, type: 'Script', data: context, source: result.unit));
      return;
    }

    unclosedScript();
  }
}
