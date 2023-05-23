import 'package:svelte_ast/svelte_ast.dart';

void main() {
  var node = parse('{ @const name = "world" }');

  void visit(Node node) {
    if (node case Text text) {
      print((text.start, text.end));
      print(text.data);
    } else if (node case Fragment output) {
      output.nodes.forEach(visit);
    } else if (node case MustacheTag mustacheTag) {
      print((mustacheTag.start, mustacheTag.end));
      print((mustacheTag.expression.offset, mustacheTag.expression.end));
      print(mustacheTag.expression);
    } else if (node case ConstTag constTag) {
      print((constTag.start, constTag.end));
      print((constTag.expression.offset, constTag.expression.end));
      print(constTag.expression);
    } else {
      print((node.start, node.end));
      print(node.runtimeType);
    }
  }

  visit(node);
}
