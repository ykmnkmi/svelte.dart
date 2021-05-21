import '../../hash.dart';
import '../../nodes.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

class Annotation extends Node {
  Annotation(this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken);

  final Token prefixToken;

  final Token nameToken;

  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  int get hashCode {
    return hash2(name, value);
  }

  String get name {
    return nameToken.lexeme;
  }

  int get prefixOffset {
    return prefixToken.offset;
  }

  int? get suffixOffset {
    return null;
  }

  Token? get suffixToken {
    return null;
  }

  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  bool operator ==(Object? other) {
    if (other is Annotation) {
      return name == other.name && value == other.value;
    }

    return false;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitAnnotation(this, context);
  }

  @override
  String toString() {
    return value == null ? '$Annotation {$name}' : '$Annotation {$name="$value"}';
  }
}
