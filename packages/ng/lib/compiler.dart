import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:expression/variable.dart';

import 'src/fragment.dart';

String compile(String template,
    {String name = 'App', List<Variable> exports = const <Variable>[], bool minimize = true, String? sourceUrl}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  ElementAst? instanceScript, moduleScript;

  for (var i = 0; i < nodes.length;) {
    final node = nodes[i];

    if (node is ElementAst && node.name == 'script') {
      if (node.attributes.any(hasModuleContext)) {
        if (moduleScript != null) {
          throw StateError('a component can only have one instance-level <script> element');
        } else {
          moduleScript = node;
        }
      } else {
        if (instanceScript != null) {
          throw StateError('a component can only have one <script context="module"> element');
        } else {
          instanceScript = node;
        }
      }

      nodes.removeAt(i);
    } else {
      i += 1;
    }
  }

  if (instanceScript != null) {
    print(format(instanceScript));
  }

  nodes = minimize ? const MinimizeWhitespaceVisitor().visitAllRoot(nodes) : nodes;
  return compileNodes(nodes, name: name, exports: exports);
}
