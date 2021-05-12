import 'nodes.dart';

class Interpolator extends Visitor<String?, String> {
  const Interpolator();

  @override
  String visit(Node node, [String? context]) {
    return node.accept(this, context);
  }

  @override
  String visitIdentifier(Identifier node, [String? context]) {
    if (context == null) {
      return '\$${node.name}';
    }

    return '\${$context.${node.name}}';
  }

  @override
  String visitNodeList(NodeList node, [String? context]) {
    return '\'${node.children.map<String>((Node node) => node.accept(this, context)).join()}\'';
  }

  @override
  String visitText(Text node, [String? context]) {
    return node.data;
  }

  static String visitAll(List<Node> nodes, [String? context]) {
    final interpolator = const Interpolator();
    return '\'${nodes.map<String>((Node node) => node.accept(interpolator, context)).join()}\'';
  }
}

abstract class Visitor<C, R> {
  const Visitor();

  R visit(Node node, [C? context]) {
    throw UnimplementedError();
  }

  R visitAttribute(Attribute node, [C? context]) {
    throw UnimplementedError();
  }

  R visitElement(Element node, [C? context]) {
    throw UnimplementedError();
  }

  R visitNodeList(NodeList node, [C? context]) {
    throw UnimplementedError();
  }

  R visitIdentifier(Identifier node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }
}
