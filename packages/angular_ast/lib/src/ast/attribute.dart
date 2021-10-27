import 'package:collection/collection.dart' show ListEquality;
import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

abstract class Attribute implements Node {
  factory Attribute(String name, [String? value, List<Standalone> childNodes]) = _SyntheticAttributeAst;

  factory Attribute.from(Node origin, String name, [String? value, List<Standalone> childNodes]) =
      _SyntheticAttributeAst.from;

  factory Attribute.parsed(SourceFile sourceFile, Token nameToken,
      [AttributeValueToken? valueToken, Token? equalSignToken, List<Standalone> childNod]) = ParsedAttribute;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  String get name;

  String? get value;

  String? get quotedValue;

  @override
  List<Standalone> get childNodes;

  @override
  bool operator ==(Object? other) {
    return other is Attribute && name == other.name && listEquals.equals(childNodes, other.childNodes);
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    return 'AttributeAst {$name}';
  }
}

class ParsedAttribute extends Node with Attribute implements ParsedDecorator, TagOffsetInfo {
  ParsedAttribute(SourceFile sourceFile, this.nameToken,
      [this.valueToken, this.equalSignToken, this.childNodes = const <Standalone>[]])
      : super.parsed(nameToken, valueToken == null ? nameToken : valueToken.rightQuote, sourceFile);

  @override
  final Token nameToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  final List<Standalone> childNodes;

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
  String? get quotedValue {
    return valueToken?.lexeme;
  }

  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  @override
  Token? get prefixToken {
    return null;
  }

  @override
  int? get prefixOffset {
    return null;
  }

  @override
  Token? get suffixToken {
    return null;
  }

  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticAttributeAst extends Synthetic with Attribute {
  _SyntheticAttributeAst(this.name, [this.value, this.childNodes = const <Standalone>[]]);

  _SyntheticAttributeAst.from(Node origin, this.name, [this.value, this.childNodes = const <Standalone>[]])
      : super.from(origin);

  @override
  final String name;

  @override
  final String? value;

  @override
  final List<Standalone> childNodes;

  @override
  String? get quotedValue => value == null ? null : '"$value"';
}
