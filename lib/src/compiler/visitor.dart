import 'nodes.dart';

abstract class Visitor<R> {
  R visitComment(Comment node) {
    throw UnimplementedError();
  }

  R visitElement(Element node) {
    throw UnimplementedError();
  }

  R visitFragment(Fragment node) {
    throw UnimplementedError();
  }

  R visitIdentifier(Identifier node) {
    throw UnimplementedError();
  }

  R visitNodeList(NodeList node) {
    throw UnimplementedError();
  }

  R visitText(Text node) {
    throw UnimplementedError();
  }
}
