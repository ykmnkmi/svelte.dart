// ignore_for_file: avoid_print

import 'package:svelte_ast/svelte_ast.dart';

const String template = '''
{#if user.loggedIn}
  Log out
{/if}
''';

void main() {
  var node = parse(template);

  void visit(Node node) {
    print(node.runtimeType);
    print((node.start, node.end));

    if (node case Text text) {
      print(text.data);
    } else if (node case Fragment fragment) {
      fragment.nodes.forEach(visit);
    } else if (node case MustacheTag mustacheTag) {
      print((mustacheTag.expression.offset, mustacheTag.expression.end));
      print(mustacheTag.expression);
    } else if (node case ConstTag constTag) {
      print((constTag.expression.offset, constTag.expression.end));
      print(constTag.expression);
    } else {
      print('Unimplemented');
    }
  }

  visit(node);
}
