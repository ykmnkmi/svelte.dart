import '../nodes.dart';
import '../token/tokens.dart';
import '../visitor.dart';

class Text extends Node {
  Text(Token textToken) : super(textToken, textToken);

  @override
  int get hashCode => value.hashCode;

  String get value {
    return beginToken!.lexeme;
  }

  @override
  bool operator ==(Object? other) {
    return other is Text && value == other.value;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitText(this, context);
  }

  @override
  String toString() {
    return '$Text {$value}';
  }
}
