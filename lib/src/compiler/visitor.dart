import 'nodes.dart';

class Interpolator extends Visitor<String?, String> {
  const Interpolator();

  @override
  String visitIdentifier(Identifier node, [String? context]) {
    return '{${node.name}}';
  }

  @override
  String visitText(Text node, [String? context]) {
    return node.data;
  }

  static String visitAll(List<Node> nodes) {
    const visitor = Interpolator();
    return '\'${nodes.map<String>((Node node) => node.accept(visitor)).join()}\'';
  }
}

abstract class Visitor<C, R> {
  const Visitor();

  R visitAttribute(Attribute node, [C? context]) {
    throw UnimplementedError();
  }

  R visitComment(Comment node, [C? context]) {
    throw UnimplementedError();
  }

  R visitElement(Element node, [C? context]) {
    throw UnimplementedError();
  }

  R visitFragment(Fragment node, [C? context]) {
    throw UnimplementedError();
  }

  R visitIdentifier(Identifier node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }
}
