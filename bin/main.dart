import 'package:piko/compiler.dart';

void main() {
  final tree = parse('Clicked {{ count }} {{ count == 1 ? "time" : "times" }}', sourceUrl: '<runtime>');

  final compiler = Compiler();
  final frame = Frame('App');

  tree.forEach((node) {
    node.accept(compiler, frame);
  });

  print(frame.variables);
  print(frame.created);
  print(frame.mounted);
  print(frame.compile());
}
