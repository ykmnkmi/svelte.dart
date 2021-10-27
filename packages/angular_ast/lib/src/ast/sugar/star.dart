import 'package:source_span/source_span.dart' show SourceFile;

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

abstract class Star implements Node {
  factory Star(String name, [String? value]) = _SyntheticStar;

  factory Star.from(Node origin, String name, [String? value]) = _SyntheticStar.from;

  factory Star.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedStar;

  @override
  int get hashCode {
    return Object.hash(value, name);
  }

  String get name;

  String? get value;

  @override
  bool operator ==(Object? other) {
    return other is Property && value == other.value && name == other.name;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitStar(this, context);
  }

  @override
  String toString() {
    if (value == null) {
      return 'StarAst {$name}';
    }

    return 'StarAst {$name="$value"}';
  }
}

class ParsedStar extends Node with Star implements ParsedDecorator, TagOffsetInfo {
  ParsedStar(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  @override
  Token? get suffixToken => null;

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
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticStar extends Synthetic with Star {
  _SyntheticStar(this.name, [this.value]);

  _SyntheticStar.from(Node origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
