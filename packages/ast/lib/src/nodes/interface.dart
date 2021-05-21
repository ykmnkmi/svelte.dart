import '../token/tokens.dart';
import '../visitor.dart';

abstract class Node {
  Node(this.beginToken, this.endToken) : isParent = false;

  final Token? beginToken;

  final Token? endToken;

  final bool isParent;

  List<Node> get childNodes {
    return const <Node>[];
  }

  R? accept<R, C>(Visitor<R, C> visitor, [C context]);
}

abstract class ParsedDecorator {
  Token get nameToken;

  int? get prefixOffset;

  Token? get prefixToken;

  int? get suffixOffset;

  Token? get suffixToken;

  AttributeValueToken? get valueToken;
}

abstract class TagOffsetInfo {
  int? get equalSignOffset;

  int get nameOffset;

  int? get quotedValueOffset;

  int? get valueOffset;
}
