import 'package:piko/compiler.dart';

void main() {
  final tree = parse('<button (click)="handleClick()">Clicked {{ count }} {{ count == 1 ? "time" : "times" }}</button>');

  final compiler = Compiler();
  final frame = Frame();

  tree.forEach((node) {
    node.accept(compiler, frame);
  });

  print(frame);
}
