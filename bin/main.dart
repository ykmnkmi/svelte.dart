import 'package:angular_ast/angular_ast.dart';

void main() {
  // Create an AST tree by parsing an AngularDart template.
  final tree = parse('<button (click)="handleClick()">Clicked {{ count }} {{ count == 1 ? "time" : "times" }}</button>');
  final button = tree.first as ElementAst;

  print(button.events.first);
}
