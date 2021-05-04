import '../nodes.dart';
import '../visitor.dart';
import 'program.dart';

Program ssr(String name, Fragment fragment) {
  return SSRRenderer(name).render(fragment);
}

class SSRRenderer implements Visitor<void> {
  SSRRenderer(this.name) : buffer = StringBuffer();

  final String name;

  final StringBuffer buffer;

  Program render(Fragment fragment) {
    return Program(name, buffer.toString());
  }

  @override
  void visitComment(Comment node) {
    throw UnimplementedError();
  }

  @override
  void visitElement(Element node) {
    throw UnimplementedError();
  }

  @override
  void visitFragment(Fragment node) {
    throw UnimplementedError();
  }

  @override
  void visitIdentifier(Identifier node) {
    throw UnimplementedError();
  }

  @override
  void visitText(Text node) {
    throw UnimplementedError();
  }
}
