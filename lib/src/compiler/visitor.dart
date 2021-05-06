import 'nodes.dart';

abstract class Visitor<C, R> {
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

  R visitNodeList(NodeList node, [C? context]) {
    throw UnimplementedError();
  }

  R visitText(Text node, [C? context]) {
    throw UnimplementedError();
  }
}
