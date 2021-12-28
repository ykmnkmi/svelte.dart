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

    if (children.length != 1 || children.first.type != 'Text') {
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

    if (scan(closeRe)) {
      var context = getContext(attributes);
      var source = template.substring(0, start).replaceAll(allRe, ' ') + data;
      // TODO(error): handle
      var result = parseString(content: source);
      scripts.add(Node(start: start, end: index, type: 'Script', data: context, library: result.unit));
      return;
    }

    unclosedScript();
  }
}
