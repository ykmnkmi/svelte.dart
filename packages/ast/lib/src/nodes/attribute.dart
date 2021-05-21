import 'package:collection/collection.dart';

import '../hash.dart';
import '../nodes.dart';
import '../token/tokens.dart';
import '../visitor.dart';

class Attribute extends Node implements ParsedDecorator, TagOffsetInfo {
  Attribute(this.nameToken, [this.valueToken, this.equalSignToken, this.mustaches]) : super(nameToken, valueToken == null ? nameToken : valueToken.rightQuote);

  @override
  final Token nameToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  final List<Interpolation>? mustaches;

  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  int get hashCode {
    return hash2(name, value);
  }

  String get name {
    return nameToken.lexeme;
  }

  @override
  int get nameOffset {
    return nameToken.offset;
  }

  String? get quotedValue {
    return valueToken?.lexeme;
  }

  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  @override
  bool operator ==(Object? other) {
    if (other is Attribute) {
      return name == other.name && value == other.value && const ListEquality<Interpolation>().equals(mustaches, other.mustaches);
    }

    return false;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    return quotedValue == null ? '$Attribute {$name}' : '$Attribute {$name=$quotedValue}';
  }
}
