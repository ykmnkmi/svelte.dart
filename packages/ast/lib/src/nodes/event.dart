import 'package:collection/collection.dart';

import '../hash.dart';
import '../nodes.dart';
import '../token/tokens.dart';
import '../visitor.dart';

class Event extends Node implements ParsedDecorator, TagOffsetInfo {
  Event(this.prefixToken, this.nameToken, this.suffixToken, [this.valueToken, this.equalSignToken])
      : super(prefixToken, valueToken == null ? suffixToken : valueToken.rightQuote);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  // [suffixToken] may be null if 'on-' is used instead of '('.
  @override
  final Token? suffixToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  int get hashCode {
    return hash2(name, reductions);
  }

  String get name {
    return nameWithoutParentheses.split('.').first;
  }

  String get nameWithoutParentheses {
    return nameToken.lexeme;
  }

  @override
  int get nameOffset {
    return nameToken.offset;
  }

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  List<String> get reductions {
    final split = nameWithoutParentheses.split('.');
    return split.sublist(1);
  }

  @override
  int? get suffixOffset {
    return suffixToken?.offset;
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
    return other is Event && name == other.name && const ListEquality<String>().equals(reductions, other.reductions);
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitEvent(this, context);
  }

  @override
  String toString() {
    return reductions.isEmpty ? '$Event {$name=$value}' : '$Event {$name.${reductions.join(',')}="$value"}';
  }
}
