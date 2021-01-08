import 'package:piko/compiler.dart';

void main() {
  final tree = parse('<button (click)="handleClick()">Clicked {{ count }} {{ count == 1 ? "time" : "times" }}</button>');

  final compiler = Compiler();
  final context = Context();

  tree.forEach((node) {
    node.accept(compiler, context);
  });

  print(context);
}
