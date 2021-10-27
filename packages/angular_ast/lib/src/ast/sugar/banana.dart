import 'package:source_span/source_span.dart' show SourceFile;

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

abstract class Banana implements Node {
  factory Banana(String name, [String? field]) = _SyntheticBanana;

  factory Banana.from(Node origin, String name, [String? field]) = _SyntheticBanana.from;

  factory Banana.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken, Token suffixToken,
      AttributeValueToken? valueToken, Token? equalSignToken) = ParsedBanana;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  String get name;

  String? get value;

  @override
  bool operator ==(Object? other) {
    return other is Banana && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitBanana(this, context);
  }

  @override
  String toString() {
    return 'BananaAst {$name="$value"}';
  }
}

class ParsedBanana extends Node with Banana implements ParsedDecorator, TagOffsetInfo {
  ParsedBanana(
      SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken, this.valueToken, this.equalSignToken)
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : suffixToken, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  @override
  final Token suffixToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  String get name {
    return nameToken.lexeme;
  }

  @override
  int get nameOffset {
    return nameToken.offset;
  }

  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  int get suffixOffset {
    return suffixToken.offset;
  }
}

class _SyntheticBanana extends Synthetic with Banana {
  _SyntheticBanana(this.name, [this.value]);

  _SyntheticBanana.from(Node origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
