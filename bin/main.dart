import 'package:piko/compiler.dart';

void main() {
  final tree = parse('Clicked {{ count }} {{ count == 1 ? "time" : "times" }}',sourceUrl: '<runtime>');

  final compiler = Compiler();
  final frame = Frame();

  tree.forEach((node) {
    node.accept(compiler, frame);
  });

  print(frame.created);
  print(frame.mounted);
}
