import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class Property implements Node {
  factory Property(String name, [String? value, String? postfix, String? unit]) = _SyntheticProperty;

  factory Property.from(Node? origin, String name, [String? value, String? postfix, String? unit]) =
      _SyntheticProperty.from;

  factory Property.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken, Token? suffixToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedProperty;

  String get name;

  String? get value;

  @override
  int get hashCode {
    return Object.hash(name, postfix, unit);
  }

  String? get postfix;

  String? get unit;

  @override
  bool operator ==(Object? other) {
    return other is Property && name == other.name && postfix == other.postfix && unit == other.unit;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitProperty(this, context);
  }

  @override
  String toString() {
    if (unit != null) {
      return 'PropertyAst {$name.$postfix.$unit}';
    }

    if (postfix != null) {
      return 'PropertyAst {$name.$postfix}';
    }

    return 'PropertyAst {$name}';
  }
}

class ParsedProperty extends Node with Property implements ParsedDecorator, TagOffsetInfo {
  ParsedProperty(SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? suffixToken : valueToken.rightQuote, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  // [suffixToken] may be null of 'bind-' is used instead of '['.
  @override
  final Token? suffixToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  String get _nameWithoutBrackets {
    return nameToken.lexeme;
  }

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  String get name {
    return _nameWithoutBrackets.split('.').first;
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
  String? get postfix {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 1 ? split[1] : null;
  }

  @override
  String? get unit {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 2 ? split[2] : null;
  }

  @override
  int? get suffixOffset {
    return suffixToken?.offset;
  }
}

class _SyntheticProperty extends Synthetic with Property {
  _SyntheticProperty(this.name, [this.value, this.postfix, this.unit]);

  _SyntheticProperty.from(Node? origin, this.name, [this.value, this.postfix, this.unit]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;

  @override
  final String? postfix;

  @override
  final String? unit;
}
